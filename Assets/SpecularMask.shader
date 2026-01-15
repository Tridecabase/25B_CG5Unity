Shader "Unlit/SpecularMask"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _MaskTex ("MaskTex", 2D) = "black" {}
        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _SpecIntensity ("Specular Intensity", Range(0,10)) = 1
        _Shininess ("Shininess (pow)", Range(1,64)) = 16
        _AmbientColor ("Ambient Color", Color) = (0.18,0.18,0.18,1)
        _AOIntensity ("AO Intensity", Range(0,1)) = 0.6
        _DiffuseStrength ("Diffuse Strength", Range(0,2)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            fixed4 _SpecColor;
            float _SpecIntensity;
            float _Shininess;
            fixed4 _AmbientColor;
            float _AOIntensity;
            float _DiffuseStrength;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 worldPos4 = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos4.xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // base color
                fixed4 baseCol = tex2D(_MainTex, i.uv);
                // mask controls where specular applies and acts as rough occlusion map
                fixed4 mask = tex2D(_MaskTex, i.uv);
                float maskR = mask.r;

                // normalize
                float3 N = normalize(i.worldNormal);

                // determine light direction (handle directional and positional light)
                float3 L;
                if (_WorldSpaceLightPos0.w == 0)
                {
                    // directional light
                    L = normalize(_WorldSpaceLightPos0.xyz);
                }
                else
                {
                    // point/spot light: direction from surface to light
                    L = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }

                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

                // Lambert diffuse
                float NdotL = max(dot(N, L), 0);
                fixed3 diffuseTerm = baseCol.rgb * (NdotL * _DiffuseStrength);

                // ambient
                fixed3 ambientTerm = _AmbientColor.rgb;

                // use mask.r as occlusion: where mask.r is low -> darker crevice
                float occlusion = lerp(1.0 - _AOIntensity, 1.0, maskR);

                fixed3 lit = (ambientTerm + diffuseTerm) * occlusion;

                // Phong specular: reflect L around normal and dot with V
                float3 R = reflect(-L, N);
                float specAngle = max(dot(R, V), 0);
                float spec = pow(specAngle, _Shininess) * _SpecIntensity * maskR;

                fixed3 specCol = _SpecColor.rgb * spec;

                fixed3 outCol = baseCol.rgb * lit + specCol;
                outCol = saturate(outCol);
                return fixed4(outCol, baseCol.a);
            }
            ENDCG
        }
    }
}
