Shader "Custom/23_2d"
{

    Properties{
        _CellSize("Cell Size", Range(0,1)) = 1
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

        float _CellSize;

        struct Input {
            float3 worldPos;
        };

        inline float easeIn(float interpolator){
            return interpolator * interpolator;
        }

        float easeOut(float interpolator){
            return 1-easeIn(1-interpolator);
        }

        float easeInOut(float interpolator){
            float easeInValue = easeIn(interpolator);
            float easeOutValue = easeOut(interpolator);
            return lerp(easeInValue, easeOutValue, interpolator);
        }

        float perlinNoise(float2 value){
            float2 lowerLeftDirection = rand2dTo2d(float2(floor(value.x), floor(value.y))) * 2 - 1;
            float2 lowerRightDirection = rand2dTo2d(float2(ceil(value.x), floor(value.y))) * 2 - 1;
            float2 upperLeftDirection = rand2dTo2d(float2(floor(value.x), ceil(value.y))) * 2 - 1;
            float2 upperRightDirection = rand2dTo2d(float2(ceil(value.x), ceil(value.y))) * 2 - 1;

            float2 fraction = frac(value);
            float2 lowerLeftFunctionValue = dot(lowerLeftDirection, fraction - float2(0, 0));
            float2 lowerRightFunctionValue = dot(lowerRightDirection, fraction - float2(1, 0));
            float2 upperLeftFunctionValue = dot(upperLeftDirection, fraction - float2(0, 1));
            float2 upperRightFunctionValue = dot(upperRightDirection, fraction - float2(1, 1));

            float interpolatorX = easeInOut(fraction.x);
            float interpolatorY = easeInOut(fraction.y);
            float lowerCells = lerp(lowerLeftFunctionValue, lowerRightFunctionValue, interpolatorX);
            float upperCells = lerp(upperLeftFunctionValue, upperRightFunctionValue, interpolatorX);
            float noise = lerp(lowerCells, upperCells, interpolatorY);
            return noise;
        }

        void surf(Input i, inout SurfaceOutputStandard o) {
            float2 value = i.worldPos.xy / _CellSize;
            float noise = perlinNoise(value) + 0.5;
            o.Albedo = noise;
        }
        ENDCG
    }
    FallBack "Standard"
}
