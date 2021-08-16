Shader "Custom/34"
{
    Properties{
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metalness", Range(0, 1)) = 0
        [HDR] _Emission ("Emission", color) = (0,0,0)

        _DissolveTex("Dissolve Texture", 2D) = "black"{}
        _DissolveAmount("Dissolve Amount", Range(0,1)) = 0.5

    }

    SubShader{
        //the material is completely non-transparent and is rendered at the same time as the other opaque geometry
        Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _DissolveTex;

        float _DissolveAmount;

        fixed4 _Color;

        half _Smoothness;
        half _Metallic;
        half3 _Emission;

        struct Input {
            float2 uv_MainTex;
            float2 uv_DissolveTex;
        };

        void surf (Input i, inout SurfaceOutputStandard o) {

            float dissolve = tex2D(_DissolveTex, i.uv_DissolveTex).r;
            dissolve = dissolve * 0.999;
            float isVisible = dissolve - _DissolveAmount;
            clip(isVisible);

            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;

            o.Albedo = col;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Emission = _Emission;
        }

        ENDCG
    }
    FallBack "Standard"
}
