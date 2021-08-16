Shader "Custom/24_3d"
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

        float3 perlinNoise(float3 value){
            float3 fraction = frac(value);
            float interpolatorX = easeInOut(frac(fraction.x));
            float interpolatorY = easeInOut(frac(fraction.y));
            float interpolatorZ = easeInOut(frac(fraction.z));

            float cellNoiseZ[2];
            [unroll]
            for (int z=0;z<=1;z++){
                float cellNoiseY[2];
                [unroll]
                for (int y=0;y<=1;y++){
                    float cellNoiseX[2];
                    [unroll]
                    for (int x=0;x<=1;x++){
                        float3 cell = floor(value) + float3(x,y,z);
                        float3 cellDirection = rand3dTo3d(cell) * 2 - 1;
                        float3 compareVector = fraction - float3(x,y,z);
                        cellNoiseX[x] = dot(cellDirection, compareVector);
                    }
                    cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
                }
                cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
            }
            float3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
            return noise;

        }

        float sampleLayeredNoise(float3 value){
            float noise = 0;
            float frequency = 1;
            float factor = 1;
            [unroll]
            for (int i=0;i<OCTAVES;i++){
                noise = noise + perlinNoise(value * frequency + i * 0.72354) * factor;
                factor *= _Persistance;
                frequency *= _Roughness;
            }
            return noise;
        }

        void surf(Input i, inout SurfaceOutputStandard o) {
            float3 value = i.worldPos / _CellSize;
            float noise = sampleLayeredNoise(value) + 0.5;
            o.Albedo = noise;
        }
        ENDCG
    }
    FallBack "Standard"
}
