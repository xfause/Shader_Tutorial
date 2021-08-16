Shader "Custom/17"
{

    Properties{

        _OutlineColor("Outline Color", Color) = (0,0,0,1)
        _OutlineThickness("Outline Thickness", Range(0,.1)) = 0.03

        //Properties
        _Color("Tint", Color) = (0,0,0,1)
        _MainTex("Texture", 2D) = "white"{}
        _Smoothness("Smoothness", Range(0,1)) = 0
        _Metallic("Metallic", Range(0,1)) = 0
        [HDR] _Emission ("Emission", color) = (0,0,0)
    }
    Subshader{
        Tags{
            //Subshader Tags
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        //Settings for pass

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex;
        fixed4 _Color;

        half _Smoothness;
        half _Metallic;
        half3 _Emission;

        struct Input {
            float2 uv_MainTex;
        };

        void surf(Input i, inout SurfaceOutputStandard o) {
            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;
            o.Albedo = col.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Emission = _Emission;
        }
        ENDCG

        Pass {
            // 通过翻转对象 利用unity不绘制对象背面的特性 仅绘制边缘
            Cull Front

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;

            fixed4 _OutlineColor;
            float _OutlineThickness;

            struct appdata{
                float4 vertex: POSITION;
                float3 normal: Normal;
            };

            struct v2f {
                float4 position: SV_POSITION;
            };

            v2f vert(appdata v){
                v2f o;
                float3 normal = normalize(v.normal);
                float3 outlineOffset = normal * _OutlineThickness;
                float3 position = v.vertex + outlineOffset;
                o.position = UnityObjectToClipPos(position);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                return _OutlineColor;
            }

            ENDCG
        }
    }
    FallBack "Standard"
}
