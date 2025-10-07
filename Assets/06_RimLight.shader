Shader "Unlit/06_RimLight"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaValue     ("Alpha Value", Float) = 0.8
        _WaveScsale     ("Wave Scsale", Range(0.02,0.15)) = 0.07
        _ReflDistort    ("Reflection Distort", Range(0,1.5)) = 0.5
        _RefrColor 	    ("Refraction Color", Color) = (0.24,0.85,0.92,1)
        _ReflectionTex  ("Reflection Texture", 2D) = "" {}
        _RimStrength   ("Rim Strength", Range(0,10)) = 5.0
        _RimColor     ("Rim Color", Color) = (0.9,0.9,1.0,1)
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
            float _RimStrength;
            float4 _RimColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);   // ワールド座標を計算して格納
                o.uv = v.uv;
                return o;
            }

        fixed4 frag (v2f i) : SV_Target
        {
            float2 tiling = _MainTex_ST.xy;
            float2 offset = _MainTex_ST.zw;

            fixed4 col = tex2D(_MainTex, i.uv * tiling + offset);

            float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
            float3 normal = normalize(i.normal);
            float rim = 1.0 - saturate(dot(viewDir, normal));
            rim = pow(rim, 6.0);

            fixed4 finalColor = col * _Color;
            finalColor.rgb += rim * _RimColor  * _RimStrength;

            return finalColor;
        }
            ENDCG
        }
    }
}
