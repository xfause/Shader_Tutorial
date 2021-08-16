Shader "Custom/39"
{
    Properties{
        _Color ("Color", Color) = (0, 0, 0, 1)
    }

    SubShader{
        //the material is completely non-transparent and is rendered at the same time as the other opaque geometry
        Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

        Pass{
            CGPROGRAM

            //include useful shader functions
            #include "UnityCG.cginc"

            //define vertex and fragment shader
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;

            //the object data that's put into the vertex shader
            struct appdata{
                float4 vertex : POSITION;
            };

            //the data that's used to generate fragments and can be read by the fragment shader
            struct v2f{
                float4 position : SV_POSITION;
                float4 localPosition: TEXCOORD0;
                float4 viewDirection: TEXCOORD1;
            };

            //the vertex shader
            v2f vert(appdata v){
                v2f o;
                //convert the vertex positions from object space to clip space so they can be rendered
                o.position = UnityObjectToClipPos(v.vertex);
                o.localPosition = v.vertex;
                float4 objectSpaceCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                o.viewDirection = v.vertex - objectSpaceCameraPos;
                return o;
            }

            // 没有减去球体中心的位置 放置在原点
            float scene(float3 pos){
                return length(pos) - 0.5;
            }

            //the fragment shader
            fixed4 frag(v2f i) : SV_TARGET{
                float3 pos = i.localPosition;
                float3 dir = normalize(i.viewDirection.xyz);
                float progress = 0;

                #define THICKNESS 0.01
                #define MAX_STEPS 10
                
                for (uint iter=0;iter<MAX_STEPS;iter++){
                    float3 samplePoint = pos + dir * progress;
                    float distance = scene(samplePoint);
                    if (distance<THICKNESS){
                        return _Color;
                    }
                    progress = progress +distance;
                }
                clip(-1);
                return 0;
            }

            ENDCG
        }
    }

    Fallback "Standard"
}
