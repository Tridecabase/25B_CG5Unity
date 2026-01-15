Shader "Unlit/StencilBuffer_B"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _HiddenColor ("Hidden Color", Color) = (0,1,0,1)
        _DepthBias ("Depth Bias", Float) = 0.001
    }

    SubShader
    {
        // Render after geometry and ignore depth test; decide occlusion per-pixel using camera depth texture
        Pass
        {
            Tags { "Queue" = "Geometry+1" }

            // allow transparency and write color channels
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGBA

            ZTest Always
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Declare the camera depth texture for sampling
            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _HiddenColor;
            float _DepthBias;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }

            // helper to sample camera depth
            float SampleCameraDepth(float4 screenPos)
            {
                float rawDepth = UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(screenPos)));
                return rawDepth;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // object projected depth in same [0,1] space
                float objDepth = i.screenPos.z / i.screenPos.w;

                // sample scene depth
                float sceneDepth = SampleCameraDepth(i.screenPos);

                // compare with bias: if sceneDepth < objDepth - bias then something is closer => occluded
                bool occluded = sceneDepth < objDepth - _DepthBias;

                fixed4 baseCol = tex2D(_MainTex, i.uv) * _Color;
                if (occluded)
                {
                    // keep original alpha so B remains visible/opaque as expected
                    return fixed4(_HiddenColor.rgb, baseCol.a * _HiddenColor.a);
                }
                else
                {
                    return baseCol;
                }
            }
            ENDCG
        }
    }
}
