Shader "Unlit/StencilBuffer_A"
{
    Properties
    {
        _Color ("Color", Color) = (1,0,0,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        // Occluder: draw normally and mark stencil with Ref 1
        Pass
        {
            Stencil
            {
                Ref 1
                ReadMask 255
                WriteMask 255
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            // write color and depth
            ColorMask RGBA
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
