Shader "Unlit/02_Lambert"
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float intensity =
                    saturate(dot(normalize(i.normal), _WorldSpaceLightPos0));

                fixed4 diffuse = _Color * _LightColor0 * intensity;

                return diffuse;
            }
            ENDCG
        }
    }
}
