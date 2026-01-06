Shader "Unlit/discard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaValue     ("Alpha Value", Float) = 0.3
        _WaveScsale     ("Wave Scsale", Range(0.02,0.15)) = 0.07
        _ReflDistort    ("Reflection Distort", Range(0,1.5)) = 0.5
        _RefrColor 	    ("Refraction Color", Color) = (0.24,0.85,0.92,1)
        _ReflectionTex  ("Reflection Texture", 2D) = "" {}
        _Color("Color", Color) = (1,0,0,1)
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            // Shader Setting
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"       // 光源(色など)の情報を取得するために必要

            fixed4 _Color;
            float _AlphaValue;

            struct appdata                  // appdataという構造体を宣言
            {
                float4 vertex : POSITION;   // セマンティクスが必要
                float3 normal : NORMAL;     // 法線情報(NORMAL)用のセマンティクス
                float2 uv : TEXCOORD0;      // UV情報(TEXCOORD0)用のセマンティクス
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPosition : TEXCOORD1;   // ワールド座標用に変数を一つ追加
                float2 uv : TEXCOORD0;      // UV情報(TEXCOORD0)用のセマンティクス
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);   // ワールド座標を計算して格納
                o.uv = v.uv;
                return o;
            }

            // Fragment Shader
            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                if (col.a < 0.5)
                {
                    discard;
                }

                return col;
            }
            ENDCG
        }
    }
}
