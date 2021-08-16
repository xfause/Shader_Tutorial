Shader "Custom/9"
{

    Properties{
        //Properties
        _Color("Tint", Color) = (0,0,0,1)
        _MainTex("Texture", 2D) = "white"{}
        _Smoothness("Smoothness", Range(0,1)) = 0
        _Metallic("Metallic", Range(0,1)) = 0
        [HDR] _Emission ("Emission", color) = (0,0,0)
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        [PowerSlider(4)] _FresnelExponent ("Fresnel Exponent", Range(0.25, 4)) = 1
    }
    Subshader{
        Tags{
            //Subshader Tags
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        //Settings for pass

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex;
        fixed4 _Color;
        fixed4 _FresnelColor;
        float _FresnelExponent;

        half _Smoothness;
        half _Metallic;
        half3 _Emission;

        struct Input {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
            INTERNAL_DATA
        };

        void surf(Input i, inout SurfaceOutputStandard o) {
            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;
            o.Albedo = col.rgb;
            
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            // o.Emission = _Emission;
            float fresnel = dot(i.worldNormal, i.viewDir);
            fresnel = saturate(1-fresnel);
            fresnel = pow(fresnel, _FresnelExponent);

            float3 fresnelColor = fresnel * _FresnelColor;
            o.Emission = _Emission + fresnelColor;

        }


        //shader code
        ENDCG
    }
    FallBack "Standard"
}
