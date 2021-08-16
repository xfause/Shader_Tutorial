Shader "Custom/37"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _CycleSpeed ("Hue Cycle Speed", Range(0, 1)) = 0
    }
    SubShader {
        //the material is completely non-transparent and is rendered at the same time as the other opaque geometry
        Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

        Pass{
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "HSVLibrary.cginc"

            float _CycleSpeed;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            #pragma vertex vert
            #pragma fragment frag
            struct appdata{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            //the data that's used to generate fragments and can be read by the fragment shader
            struct v2f{
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            //the vertex shader
            v2f vert(appdata v){
                v2f o;
                //convert the vertex positions from object space to clip space so they can be rendered
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //the fragment shader
            fixed4 frag(v2f i) : SV_TARGET{
                // float diagonal = i.uv.x - i.uv.y;
                // float3 col = hsv2rgb(float3(diagonal, i.uv.x, i.uv.y));
                // return float4(col, 1);

                float3 col = tex2D(_MainTex, i.uv);
                float3 hsv = rgb2hsv(col);
                hsv.x += i.uv.y + _Time.y * _CycleSpeed;
                col = hsv2rgb(hsv);
                return float4(col, 1);
            }

            ENDCG
        }
    }
    FallBack "Standard"
}
