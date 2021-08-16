﻿Shader "Custom/4"
{

    Properties{
        //Properties
        _Color("Tint", Color) = (0,0,0,1)
        _MainTex("Texture", 2D) = "white"{}
    }
    Subshader{
        Tags{
            //Subshader Tags
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        //Settings for pass
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off
        Cull off

        Pass {
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;

            struct appdata {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                fixed4 color: Color;
            };

            struct v2f {
                float4 position: SV_POSITION;
                float2 uv: TEXCOORD0;
                fixed4 color: Color;
            };

            v2f vert(appdata v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i): SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                col *= i.color;
                return col;
            }

            ENDCG
        }
    }
    FallBack "Standard"
}
