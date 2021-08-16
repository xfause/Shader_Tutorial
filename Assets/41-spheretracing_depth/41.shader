Shader "Custom/41"
{
    Properties{
        _Color ("Color", Color) = (0, 0, 0, 1)
    }

    SubShader{
        //the material is completely non-transparent and is rendered at the same time as the other opaque geometry
        Tags{ 
            "RenderType"="Opaque" 
            "Queue"="Geometry+1"
            "DisableBatching"="True" 
            "IgnoreProjector"="True"
        }

        Pass{
            ZWrite On

            CGPROGRAM

            //include useful shader functions
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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

            float3 normal(float3 pos){
                // return surface normal
                #define NORMAL_EPSILON 0.01
                float changeX = scene(pos + float3(NORMAL_EPSILON, 0, 0)) - scene(pos - float3(NORMAL_EPSILON, 0, 0));
                float changeY = scene(pos + float3(0, NORMAL_EPSILON, 0)) - scene(pos - float3(0, NORMAL_EPSILON, 0));
                float changeZ = scene(pos + float3(0, 0, NORMAL_EPSILON)) - scene(pos - float3(0, 0, NORMAL_EPSILON));
                float3 surfaceNormal = float3(changeX, changeY, changeZ);
                surfaceNormal = mul(unity_WorldToObject, float4(surfaceNormal, 0));
                return normalize(surfaceNormal);
            }

            fixed4 lightColor(float3 pos) {
                // return light color
                float3 surfaceNormal = normal(pos);
                float3 lightDirection = _WorldSpaceLightPos0.xyz;
                float lightAngle = saturate(dot(surfaceNormal, lightDirection));
                return lightAngle * _LightColor0;
            }

            float4 renderSurface(float3 pos){
                float4 light = lightColor(pos);
                float4 color = _Color *light;
                return color;
            }

            //the fragment shader
            void frag(v2f i, out fixed4 color:SV_TARGET, out float depth:SV_Depth){
                float3 pos = i.localPosition;
                float3 dir = normalize(i.viewDirection.xyz);
                float progress = 0;
                float3 samplePoint = 0;

                bool hitsurface = false;

                #define THICKNESS 0.01
                #define MAX_STEPS 10
                
                for (uint iter=0;iter<MAX_STEPS;iter++){
                    samplePoint = pos + dir * progress;
                    float distance = scene(samplePoint);
                    if (distance<THICKNESS){
                        // 提高性能
                        hitsurface = true;
                        break;
                    }
                    progress = progress +distance;
                }
                clip(hitsurface? 1 : -1);
                color = renderSurface(samplePoint);
                float4 tracedClipPos = UnityObjectToClipPos(float4(samplePoint, 1.0));
                depth = tracedClipPos.z /tracedClipPos.w;
            }

            ENDCG
        }
    }

    Fallback "Standard"
}
