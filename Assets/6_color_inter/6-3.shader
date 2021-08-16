Shader "Custom/6-3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex ("Second Texture", 2D) = "white" {}

        _BlendTex("Blend Texture", 2D) = "grey"
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
        }

    Pass {
            CGPROGRAM

        #include "UnityCG.cginc"

        #pragma vertex vert
        #pragma fragment frag

        sampler2D _MainTex;
        float4 _MainTex_ST;
        sampler2D _SecondTex;
        float4 _SecondTex_ST;
        sampler2D _BlendTex;
        float4 _BlendTex_ST;


        struct appdata{
            float4 vertex: POSITION;
            float3 uv: TEXCOORD0;
        };

        struct v2f {
            float4 position: SV_POSITION;
            float2 uv: TEXCOORD0;
        };

        v2f vert(appdata v){
            v2f o;
            o.position = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        fixed4 frag(v2f i): SV_Target{
            float2 main_uv = TRANSFORM_TEX(i.uv, _MainTex);
            float2 second_uv = TRANSFORM_TEX(i.uv, _SecondTex);
            float2 blend_uv = TRANSFORM_TEX(i.uv, _BlendTex);

            fixed4 main_color = tex2D(_MainTex, main_uv);
            fixed4 second_color = tex2D(_SecondTex, second_uv);
            fixed4 blend_color = tex2D(_BlendTex, blend_uv);

            fixed blend_value = blend_color.r;

            fixed4 col = lerp(main_color, second_color, blend_value);
            return col;
        }

        ENDCG
        }
    }
    FallBack "Diffuse"
}
