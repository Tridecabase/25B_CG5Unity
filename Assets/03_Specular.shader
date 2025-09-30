Shader "Unlit/03_Specular"
{
     Properties
    {
        _AlphaValue     ("Alpha Value", Float) = 0.8
        _WaveScsale     ("Wave Scsale", Range(0.02,0.15)) = 0.07
        _ReflDistort    ("Reflection Distort", Range(0,1.5)) = 0.5
        _RefrColor 	    ("Refraction Color", Color) = (0.24,0.85,0.92,1)
        _ReflectionTex  ("Reflection Texture", 2D) = "" {}
        _Color("Color", Color) = (1,0,0,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"       // 光源(色など)の情報を取得するために必要

            fixed4 _Color;

            struct appdata                  // appdataという構造体を宣言
            {
                float4 vertex : POSITION;   // セマンティクスが必要
                float3 normal : NORMAL;     // 法線情報(NORMAL)用のセマンティクス
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPosition : TEXCOORD1;   // ワールド座標用に変数を一つ追加
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);   // ワールド座標を計算して格納
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float intensity =
                    saturate(dot(normalize(i.normal), _WorldSpaceLightPos0));
                fixed4 diffuse = _Color * _LightColor0 * intensity;

                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);  // 視線ベクトル
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);  // 光源ベクトル
                i.normal = normalize(i.normal);  // 法線ベクトル
                float3 reflectDir = -lightDir + 2 * i.normal * dot(lightDir, i.normal);  // 反射ベクトル
                float specular = pow(saturate(dot(eyeDir, reflectDir)), 20) * _LightColor0;  // スペキュラ成分
                return diffuse + specular;
            }
            ENDCG
        }
    }
}
