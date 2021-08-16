Shader "Custom/21_random"
{

    Properties{
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

        #include "WhiteNoise.cginc"

        struct Input {
            float3 worldPos;
        };

        void surf(Input i, inout SurfaceOutputStandard o) {
            o.Albedo = rand3dTo3d(i.worldPos);
        }
        ENDCG
    }
    FallBack "Standard"
}
