Shader "Unlit/01_sample"
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
            // Shader Setting
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color;
            // Vertex Shader
            float4 vert(float4 v : POSITION) : SV_POSITION
            {
                float4 o;
                o = UnityObjectToClipPos(v);
                return o;
            }

            // Fragment Shader
            fixed4 frag(float4 i : SV_POSITION) : SV_TARGET
            {
                // fixed4 o = fixed4(1, 0, 0, 1); // Red Color
                fixed4 o = _Color; // Color from Property
                return o;
            }
            ENDCG
        }
    }
}
