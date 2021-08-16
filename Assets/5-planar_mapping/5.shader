﻿Shader "Custom/5"
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
            };

            struct v2f {
                float4 position: SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            v2f vert(appdata v){
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                // o.uv = v.vertex.xz;
                // o.uv = TRANSFORM_TEX(v.vertex.xz, _MainTex);

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(worldPos.xz, _MainTex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                return col;
            }

            ENDCG
        }
    }
    FallBack "Standard"
}
