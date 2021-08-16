Shader "Custom/6-1"
{

    Properties{
        //Properties
        _Color("Tint", Color) = (0,0,0,1)
        _SecondaryColor("SecondaryColor", Color) = (1,1,1,1)
        _Blend("Blend Value", Range(0,1)) = 0
        _MainTex("Texture", 2D) = "white"{}
    }
    Subshader{
        Tags{
            //Subshader Tags
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        //Settings for pass
        // Blend SrcAlpha OneMinusSrcAlpha
        // ZWrite off
        // Cull off

        Pass {
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Blend;

            fixed4 _Color;
            fixed4 _SecondaryColor;

            struct appdata {
                float4 vertex: POSITION;
                // float2 uv: TEXCOORD0;
            };

            struct v2f {
                float4 position: SV_POSITION;
                // float2 uv: TEXCOORD0;
            };

            v2f vert(appdata v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target {
                fixed4 col = lerp(_Color, _SecondaryColor, _Blend);
                // fixed4 col = _Color * (1 - _Blend) + _SecondaryColor * _Blend;
                return col;
            }

            ENDCG
        }
    }
}
