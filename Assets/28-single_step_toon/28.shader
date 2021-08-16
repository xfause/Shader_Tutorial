Shader "Custom/28"
{

    Properties{
        //Properties
        _Color("Tint", Color) = (0,0,0,1)
        _MainTex("Texture", 2D) = "white"{}
        [HDR] _Emission ("Emission", color) = (0,0,0)

        [Header(Lighting Parameters)]
        _ShadowTint ("Shadow Color", Color) = (0, 0, 0, 1)

    }
    Subshader{
        Tags{
            //Subshader Tags
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        //Settings for pass

        CGPROGRAM

        #pragma surface surf Stepped fullforwardshadows

        sampler2D _MainTex;
        fixed4 _Color;
        half3 _Emission;
        float3 _ShadowTint;

        struct Input {
            float2 uv_MainTex;
        };

        float4 LightingStepped(SurfaceOutput s, float3 lightDir, half3 viewDir, float shadowAttenuation){
            float toWardsLight = dot(s.Normal , lightDir);
            float toWardsLightChange = fwidth(toWardsLight);
            float lightIntensity = smoothstep(0, toWardsLightChange, toWardsLight);

            #ifdef USING_DIRECTIONAL_LIGHT
                float attenuationChange= fwidth(shadowAttenuation) * 0.5;
                float shadow = smoothstep(0.5-attenuationChange, 0.5+attenuationChange, shadowAttenuation);
            #else
                float attenuationChange = fwidth(shadowAttenuation);
                float shadow = smoothstep(0, attenuationChange, shadowAttenuation);
            #endif
            lightIntensity = lightIntensity * shadow;

            float3 shadowColor = s.Albedo * _ShadowTint;
            float4 color;
            color.rgb = lerp(shadowColor, s.Albedo, lightIntensity) * _LightColor0.rgb;
            color.a = s.Alpha;

            return color;
        }

        void surf(Input i, inout SurfaceOutput o) {
            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;
            o.Albedo = col.rgb;
            o.Emission = _Emission;
        }


        //shader code
        ENDCG
    }
    FallBack "Standard"
}
