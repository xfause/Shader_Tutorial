Shader "Custom/4_1d"
{

    Properties{
        _CellSize("Cell Size", Range(0,1)) = 1
        _Roughness("Roughness", range(1,8)) =3
        _Persistance("Persistance", Range(0,1)) = 0.4
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

        #define OCTAVES 4

        float _CellSize;
        float _Roughness;
        float _Persistance;

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

        float gradientNoise(float value){
            float fraction = frac(value);
            float interpolator = easeInOut(fraction);
            float preCellInclination = rand1dTo1d(floor(value)) * 2 -1;
            float preCellLinePoint = preCellInclination * fraction;

            float nextCellInclination = rand1dTo1d(ceil(value)) * 2 - 1;
            float nextCellLinePoint = nextCellInclination * (fraction - 1); 

            return lerp(preCellLinePoint, nextCellLinePoint, interpolator);
        }

        float sampleLayeredNoise(float value){
            float noise = 0;
            float frequency = 1;
            float factor = 1;

            [unroll]
            for(int i=0;i<OCTAVES;i++){
                noise = noise + gradientNoise(value * frequency + i * 0.72354) * factor;
                factor *= _Persistance;
                frequency *= _Roughness;
            }
            return noise;
        }

        void surf(Input i, inout SurfaceOutputStandard o) {
            float value = i.worldPos.x / _CellSize;
            float noise = sampleLayeredNoise(value);

            float dist = abs(noise-i.worldPos.y);
            float pixelHeight = fwidth(i.worldPos.y);
            float lineIntensity = smoothstep(2*pixelHeight, pixelHeight, dist);
            o.Albedo = lerp(1,0, lineIntensity);
        }
        ENDCG
    }
    FallBack "Standard"
}
