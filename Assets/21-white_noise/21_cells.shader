Shader "Custom/21_random"
{

    Properties{
        _CellSize("Cell Size", Vector) = (1,1,1,0)
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

        float3 _CellSize;

        struct Input {
            float3 worldPos;
        };

        void surf(Input i, inout SurfaceOutputStandard o) {
            float3 value = floor(i.worldPos / _CellSize);
            o.Albedo = rand3dTo3d(value);
        }
        ENDCG
    }
    FallBack "Standard"
}
