Shader "Custom/30"
{

    Properties{
        _Color("Color", Color) = (1,1,1,1)

    }
    Subshader{
        Tags{
            //Subshader Tags
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass {
            CGPROGRAM

            #include "UnityCG.cginc"

            #include "SDF_2D.cginc"

            #pragma vertex vert
            #pragma fragment frag

            float3 _Color;

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
                // float2 circlePosition = translate(position, float2(3, 2));
                // float sceneDistance = circle(circlePosition, 2);
                // return sceneDistance;

                float2 circlePosition = position;
                circlePosition = rotate(circlePosition, _Time.y * 0.2);
                circlePosition = translate(circlePosition, float2(2,0));
                // float pulseScale = 1 * 0.5*sin(_Time.y * 3.14);
                // circlePosition = scale(circlePosition, pulseScale);
                float sceneDistance = rectangle(circlePosition, float2(1,2));
                return sceneDistance;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                float dist = scene(i.worldPos.xz);
                float distChange = fwidth(dist) * 0.5;
                float antialiasedCutoff = smoothstep(distChange, -distChange, dist);
                fixed4 col = fixed4(_Color, antialiasedCutoff);
                return col;
            }

            ENDCG
        }
    }
    FallBack "Standard"
}
