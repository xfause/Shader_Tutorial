Shader "Custom/23_3d"
{

    Properties{
        _CellSize("Cell Size", Range(0,1)) = 1
        _ScrollSpeed("Scroll Speed", range(0,1)) = 1
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
        float _ScrollSpeed;

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

        void surf(Input i, inout SurfaceOutputStandard o) {
            float3 value = i.worldPos / _CellSize;
            value.y += _Time.y * _ScrollSpeed;
            float noise = perlinNoise(value) + 0.5;
            // o.Albedo = noise;
            noise = frac(noise * 6);

            float pixelNoiseChange = fwidth(noise);
            float heightLine = smoothstep(1-pixelNoiseChange,1, noise);
            heightLine += smoothstep(pixelNoiseChange,0, noise);
            o.Albedo = heightLine;
        }
        ENDCG
    }
    FallBack "Standard"
}
