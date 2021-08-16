Shader "Custom/25_2d"
{

    Properties{
        _CellSize("Cell Size", Range(0,2)) = 2
        _TimeScale("Time Scale", Range(0,1)) = 1
        _BorderColor("Border Color", Color) = (1,1,1,0)
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
        fixed4 _BorderColor;
        float _TimeScale;

        struct Input {
            float3 worldPos;
        };

        float3 voronoiNoise(float2 value){
            // float2 cell = floor(value);
            // float2 cellPosition = cell + rand2dTo2d(cell);
            // float2 toCell = cellPosition - value;
            // float distToCell = length(toCell);
            // return distToCell;

            // float2 baseCell = floor(value);
            // float minDistToCell = 10;
            // float2 closestCell;
            // [unroll]
            // for (int x= -1;x<=1;x++){
            //     [unroll]
            //     for (int y=-1;y<=1;y++){
            //         float2 cell = baseCell + float2(x,y);
            //         float2 cellPosition = cell + rand2dTo2d(cell);
            //         float2 toCell = cellPosition - value;
            //         float distToCell = length(toCell);
            //         if (distToCell< minDistToCell){
            //             minDistToCell = distToCell;
            //             closestCell = cell;
            //         }
            //     }
            // }
            // float random = rand2dTo1d(closestCell);
            // return float2(minDistToCell, random);

            float2 baseCell = floor(value);

            float minDistToCell = 10;
            float2 closestCell;
            float2 toClosestCell;
            [unroll]
            for (int x= -1;x<=1;x++){
                [unroll]
                for (int y=-1;y<=1;y++){
                    float2 cell = baseCell + float2(x,y);
                    float2 cellPosition = cell + rand2dTo2d(cell);
                    float2 toCell = cellPosition - value;
                    float distToCell = length(toCell);
                    if (distToCell< minDistToCell){
                        minDistToCell = distToCell;
                        closestCell = cell;
                        toClosestCell = toCell;
                    }
                }
            }

            float minEdgeDistance = 10;
            [unroll]
            for (int x2=-1;x2<=1;x2++){
                [unroll]
                for (int y2=-1;y2<=1;y2++){
                    float2 cell = baseCell + float2(x2, y2);
                    float2 cellPosition = cell + rand2dTo2d(cell);
                    float2 toCell = cellPosition - value;

                    float2 diffToClosestCell = abs(closestCell - cell);
                    bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y < 0.1;
                    if (!isClosestCell){
                        float2 toCenter = (toClosestCell + toCell) * 0.5;
                        float2 cellDiff = normalize(toCell - toClosestCell);
                        float edgeDistance = dot(toCenter, cellDiff);
                        minEdgeDistance = min(minEdgeDistance, edgeDistance);
                    }
                }
            }

            float random = rand2dTo1d(closestCell);
            return float3(minDistToCell, random, minEdgeDistance);
        }

        void surf(Input i, inout SurfaceOutputStandard o) {
            float2 value = i.worldPos.xy / _CellSize;
            value.y += _Time.y * _TimeScale;
            float3 noise = voronoiNoise(value);
            
            float3 cellColor = rand1dTo3d(noise.y);
            float valueChange = length(fwidth(value)) * 0.5;
            float isBorder = 1-smoothstep(0.05-valueChange, 0.05+valueChange, noise.z);
            float3 color = lerp(cellColor, _BorderColor, isBorder);
            o.Albedo = color;
        }
        ENDCG
    }
    FallBack "Standard"
}
