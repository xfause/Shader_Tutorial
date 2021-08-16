Shader "Custom/12"
{

    Properties{
        //Properties
        _Color("Tint", Color) = (0,0,0,1)
        _MainTex("Texture", 2D) = "white"{}
        _Smoothness("Smoothness", Range(0,1)) = 0
        _Metallic("Metallic", Range(0,1)) = 0
        [HDR] _Emission ("Emission", color) = (0,0,0)

        _Amplitude("Wave size", range(0,1)) = 0.4
        _Frequency("Wave Freqency", range(1,8)) = 2
        _AnimationSpeed("Animation Speed", range(0,5)) = 1
    }
    Subshader{
        Tags{
            //Subshader Tags
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        //Settings for pass

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        sampler2D _MainTex;
        fixed4 _Color;

        half _Smoothness;
        half _Metallic;
        half3 _Emission;

        float _Amplitude;
        float _Frequency;
        float _AnimationSpeed;

        void vert(inout appdata_full data){
            float4 modifiedPos = data.vertex;
            modifiedPos.y += sin(data.vertex.x * _Frequency+ _Time.y * _AnimationSpeed) * _Amplitude;
            
            float3 posPlusTangent = data.vertex + data.tangent* 0.01;
            posPlusTangent.y += sin(posPlusTangent.x * _Frequency+ _Time.y * _AnimationSpeed) * _Amplitude;

            float3 bitangent = cross(data.normal, data.tangent);
            float3 posPlusBitangent = data.vertex + bitangent * 0.01;
            posPlusBitangent.y += sin(posPlusBitangent.x * _Frequency+ _Time.y * _AnimationSpeed) * _Amplitude;
            
            float3 modifiedTangent = posPlusTangent - modifiedPos;
            float3 modifiedBitangent = posPlusBitangent - modifiedPos;

            float3 modifiedNormal = cross(modifiedTangent, modifiedBitangent);
            data.normal = normalize(modifiedNormal);
            data.vertex = modifiedPos;
        }

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


        //shader code
        ENDCG
    }
    FallBack "Standard"
}
