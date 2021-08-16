﻿Shader "Custom/30_line"
{

    Properties{
        _InsideColor("Inside Color", Color) = (.5, 0, 0, 1)
        _OutsideColor("Outside Color", Color) = (0, .5, 0, 1)
        _LineDistance("Mayor Line Distance", Range(0, 2)) = 1
        _LineThickness("Mayor Line Thickness", Range(0, 0.1)) = 0.05
        [IntRange]_SubLines("Lines between major lines", Range(1, 10)) = 4
        _SubLineThickness("Thickness of inbetween lines", Range(0, 0.05)) = 0.01
    }
    Subshader{
        Tags{
            //Subshader Tags
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass {
            CGPROGRAM

            #include "UnityCG.cginc"

            #include "SDF_2D.cginc"

            #pragma vertex vert
            #pragma fragment frag

            float4 _InsideColor;
            float4 _OutsideColor;
            float _LineDistance;
            float _LineThickness;
            float _SubLines;
            float _SubLineThickness;

            struct appdata{
                float4 vertex : POSITION;
            };

            struct v2f{
                float4 position : SV_POSITION;
                float4 worldPos : TEXCOORD0;
            };

            v2f vert(appdata v){
                v2f o;
                //calculate the position in clip space to render the object
                o.position = UnityObjectToClipPos(v.vertex);
                //calculate world position of vertex
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float scene(float2 position) {
                float2 circlePosition = position;
                circlePosition = rotate(circlePosition, _Time.y * 0.2);
                circlePosition = translate(circlePosition, float2(2,0));
                float sceneDistance = rectangle(circlePosition, float2(1,2));
                return sceneDistance;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                float dist = scene(i.worldPos.xz);
                fixed4 col = lerp(_InsideColor, _OutsideColor, step(0, dist));
                
                float distChange = fwidth(dist) * 0.5;
                float majorLineDist = abs(frac(dist / _LineDistance + 0.5) - 0.5) * _LineDistance;
                float majorLines = smoothstep(_LineThickness - majorLineDist, _LineThickness + majorLineDist, majorLineDist);

                float distBetweenSubLines = _LineDistance / _SubLines;
                float subLineDistance = abs(frac(dist / distBetweenSubLines + 0.5) - 0.5) * distBetweenSubLines;
                float subLines = smoothstep(_SubLineThickness - distChange, _SubLineThickness + distChange, subLineDistance);
            
                return col * majorLines * subLines;
            }

            ENDCG
        }
    }
    FallBack "Standard"
}
