Shader "Unlit/culling"
{
    Properties
    {
        _MaskTex ("Mask Texture FRONT", 2D) = "white" {}
        _Dissolve ("Dissolve", Range(0,1)) = 0
        _MaskTex ("Mask Texture BACK", 2D) = "white" {}
        _Dissolve ("Dissolve", Range(0,1)) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

        // -------- Pass 1: FRONT --------
        Pass
        {
            Name "Front"
            Tags { "LightMode"="UniversalForward" }
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            float _Dissolve;

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.uv = v.uv;
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv).r;
                clip(mask - _Dissolve);
                return half4(0,1,1,1);
            }
            ENDHLSL
        }

        // -------- Pass 2: BACK --------
        Pass
        {
            Name "Back"
            Tags { "LightMode"="UniversalForward" }
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            float _Dissolve;

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.uv = v.uv;
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.uv);
                clip(mask.r - _Dissolve);
                return mask;
            }
            ENDHLSL
        }
    }
}
