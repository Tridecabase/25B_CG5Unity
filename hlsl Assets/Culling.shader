Shader "Unlit/culling"
{
    Properties
    {
        _MaskTexFront ("Mask Texture FRONT", 2D) = "white" {}
        _MaskTexBack  ("Mask Texture BACK", 2D)  = "white" {}
        _Dissolve     ("Dissolve", Range(0,1))   = 0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        TEXTURE2D(_MaskTexFront);
        SAMPLER(sampler_MaskTexFront);
        TEXTURE2D(_MaskTexBack);
        SAMPLER(sampler_MaskTexBack);
        float _Dissolve;

        struct Attributes { float4 positionOS : POSITION; float2 uv : TEXCOORD0; };
        struct Varyings   { float4 positionHCS : SV_POSITION; float2 uv : TEXCOORD0; };

        Varyings vert(Attributes v)
        {
            Varyings o;
            o.positionHCS = TransformObjectToHClip(v.positionOS);
            o.uv = v.uv;
            return o;
        }

        float4 FragFront(Varyings i) : SV_Target
        {
            float mask = SAMPLE_TEXTURE2D(_MaskTexFront, sampler_MaskTexFront, i.uv).r;
            clip(mask - _Dissolve);
            float4 col = SAMPLE_TEXTURE2D(_MaskTexFront, sampler_MaskTexFront, i.uv);
            return col;
        }

        float4 FragBack(Varyings i) : SV_Target
        {
            float mask = SAMPLE_TEXTURE2D(_MaskTexBack, sampler_MaskTexBack, i.uv).r;
            clip(mask - _Dissolve);
            float4 col = SAMPLE_TEXTURE2D(_MaskTexBack, sampler_MaskTexBack, i.uv);
            return col;
        }

        // デバッグ: front を R、back を G にして独立を目視確認
        float4 FragDebug(Varyings i) : SV_Target
        {
            float4 f = SAMPLE_TEXTURE2D(_MaskTexFront, sampler_MaskTexFront, i.uv);
            float4 b = SAMPLE_TEXTURE2D(_MaskTexBack, sampler_MaskTexBack, i.uv);
            return float4(f.r, b.r, 0, 1);
        }
        ENDHLSL

        Pass
        {
            Name "Front"
            Tags { "LightMode"="UniversalForward" }
            Cull Front
            ZWrite Off

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

            TEXTURE2D(_MaskTexFront);
            SAMPLER(sampler_MaskTexFront);
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
                float mask = SAMPLE_TEXTURE2D(_MaskTexFront, sampler_MaskTexFront, i.uv).r;
                clip(mask - _Dissolve);
                return half4(0,1,1,1);
            }
            ENDHLSL
        }

        // -------- Pass 2: BACK (renders front-faces when Cull Back) --------
        Pass
        {
            Name "Back"
            Tags { "LightMode"="UniversalForward" }
            Cull Back
            ZWrite Off

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

            TEXTURE2D(_MaskTexBack);
            SAMPLER(sampler_MaskTexBack);
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
                float4 mask = SAMPLE_TEXTURE2D(_MaskTexBack, sampler_MaskTexBack, i.uv);
                clip(mask.r - _Dissolve);
                return mask;
            }
            ENDHLSL
        }
    }
}