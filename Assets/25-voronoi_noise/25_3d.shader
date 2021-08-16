Shader "Custom/25_3d"
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

        float3 voronoiNoise(float3 value){
            float3 baseCell = floor(value);

            float minDistToCell = 10;
            float3 toClosestCell;
            float3 closestCell;
            [unroll]
            for(int x1=-1; x1<=1; x1++){
                [unroll]
                for(int y1=-1; y1<=1; y1++){
                    [unroll]
                    for(int z1=-1; z1<=1; z1++){
                        float3 cell = baseCell + float3(x1, y1, z1);
                        float3 cellPosition = cell + rand3dTo3d(cell);
                        float3 toCell = cellPosition - value;
                        float distToCell = length(toCell);
                        if(distToCell < minDistToCell){
                            minDistToCell = distToCell;
                            closestCell = cell;
                            toClosestCell = toCell;
                        }
                    }
                }
            }

            float minEdgeDistance = 10;
            [unroll]
            for(int x2=-1; x2<=1; x2++){
                [unroll]
                for(int y2=-1; y2<=1; y2++){
                    [unroll]
                    for(int z2=-1; z2<=1; z2++){
                        float3 cell = baseCell + float3(x2, y2, z2);
                        float3 cellPosition = cell + rand3dTo3d(cell);
                        float3 toCell = cellPosition - value;

                        float3 diffToClosestCell = abs(closestCell - cell);
                        bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
                        if(!isClosestCell){
                            float3 toCenter = (toClosestCell + toCell) * 0.5;
                            float3 cellDifference = normalize(toCell - toClosestCell);
                            float edgeDistance = dot(toCenter, cellDifference);
                            minEdgeDistance = min(minEdgeDistance, edgeDistance);
                        }
                    }
                }
            }

            float random = rand3dTo1d(closestCell);
            return float3(minDistToCell, random, minEdgeDistance);
        }

        void surf(Input i, inout SurfaceOutputStandard o) {
            float3 value = i.worldPos.xyz / _CellSize;
            value.y += _Time.y * _TimeScale;
            float3 noise = voronoiNoise(value);

            float3 cellColor = rand1dTo3d(noise.y);
            float valueChange = fwidth(value.z) * 0.5;
            float isBorder = 1-smoothstep(0.05-valueChange, 0.05+valueChange, noise.z);
            float3 color = lerp(cellColor, _BorderColor, isBorder);
            o.Albedo = color;
        }
        ENDCG
    }
    FallBack "Standard"
}
