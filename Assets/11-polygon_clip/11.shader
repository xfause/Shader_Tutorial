Shader "Custom/11"
{
    //show values to edit in inspector
    Properties{
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader{
        //the material is completely non-transparent and is rendered at the same time as the other opaque geometry
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }

        Pass{
            CGPROGRAM

            //include useful shader functions
            #include "UnityCG.cginc"

            //define vertex and fragment shader
            #pragma vertex vert
            #pragma fragment frag

            //texture and transforms of the texture
            sampler2D _MainTex;
            float4 _MainTex_ST;

            //tint of the texture
            fixed4 _Color;

            uniform float2 _corners[1000];
            uniform uint _cornerCount;

            //the mesh data thats read by the vertex shader
            struct appdata{
                float4 vertex : POSITION;
            };

            //the data thats passed from the vertex to the fragment shader and interpolated by the rasterizer
            struct v2f{
                float4 position : SV_POSITION;
                float3 worldPos: TEXCOORD0;
            };

            v2f vert(appdata v) {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos.xzy;
                return o;
            }

            float isLeftOfLine(float2 pos, float2 linePoint1, float2 linePoint2){
                float2 lineDirection = linePoint2 - linePoint1;
                float2 lineNormal = float2(-lineDirection.y, lineDirection.x);
                float2 toPos = pos - linePoint1;
                float side = dot(toPos, lineNormal);
                side = step(0, side);
                return side;
            }

            fixed4 frag(v2f i):SV_Target {
                float outsideTriangle = 0;
                [loop]
                for(uint index; index<_cornerCount;index++){
                    outsideTriangle += isLeftOfLine(i.worldPos.xz, _corners[index], _corners[(index+1) % _cornerCount]);
                }
                clip(-outsideTriangle);
                return _Color;
            }

            ENDCG
        }
    }
}
