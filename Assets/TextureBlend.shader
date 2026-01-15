Shader "Unlit/TextureBlend"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _SubTex  ("SubTex", 2D)  = "white" {}
        _MaskTex ("MaskTex", 2D) = "black" {}
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SubTex;
            float4 _SubTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uvMain : TEXCOORD0;
                float2 uvSub  : TEXCOORD1;
                float2 uvMask : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvSub  = TRANSFORM_TEX(v.uv, _SubTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _MaskTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 main = tex2D(_MainTex, i.uvMain);
                fixed4 sub  = tex2D(_SubTex,  i.uvSub);
                fixed4 mask = tex2D(_MaskTex, i.uvMask);
                fixed4 col = lerp(main, sub, mask.r);
                return col;
            }
            ENDCG
        }
    }
}
