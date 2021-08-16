Shader "Custom/16"
{

    Properties{
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _NormalMult ("Normal Outline Multiplier", Range(0,4)) = 1
        _NormalBias ("Normal Outline Bias", Range(1,4)) = 1
        _DepthMult ("Depth Outline Multiplier", Range(0,4)) = 1
        _DepthBias ("Depth Outline Bias", Range(1,4)) = 1
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    }

    SubShader{
        // markers that specify that we don't need culling
        // or reading/writing to the depth buffer
        Cull Off
        ZWrite Off
        ZTest Always

        Pass{
            CGPROGRAM
            //include useful shader functions
            #include "UnityCG.cginc"

            //define vertex and fragment shader
            #pragma vertex vert
            #pragma fragment frag

            //texture and transforms of the texture
            sampler2D _MainTex;
            
            sampler2D _CameraDepthNormalsTexture;
            float4 _CameraDepthNormalsTexture_TexelSize;

            float _NormalMult;
            float _NormalBias;
            float _DepthMult;
            float _DepthBias;

            float4 _OutlineColor;

            //the object data that's put into the vertex shader
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

            void Compare(inout float depthOutline, inout float normalOutline,
            float baseDepth, float3 baseNormal, float2 uv, float2 offset
            ){

                float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, 
                uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);
                float3 neighborNormal;
                float neighborDepth;
                DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
                neighborDepth = neighborDepth * _ProjectionParams.z;

                float depthDifference = baseDepth - neighborDepth;
                depthOutline = depthOutline + depthDifference;

                float3 normalDifference = baseNormal - neighborNormal;
                normalDifference = normalDifference.r + normalDifference.g + normalDifference.b;
                normalOutline = normalOutline + normalDifference;
            }

            //the fragment shader
            fixed4 frag(v2f i) : SV_TARGET{
                float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
                
                float3 normal;
                float depth;
                DecodeDepthNormal(depthNormal, depth, normal);
                depth = depth * _ProjectionParams.z;

                float depthDifference = 0;
                float normalDifference = 0;
                
                Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(1, 0));
                Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(0, 1));
                Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(0, -1));
                Compare(depthDifference, normalDifference, depth, normal, i.uv, float2(-1, 0));

                depthDifference = depthDifference * _DepthMult;
                depthDifference = saturate(depthDifference);
                depthDifference = pow(depthDifference, _DepthBias);

                normalDifference = normalDifference * _NormalMult;
                normalDifference = saturate(normalDifference);
                normalDifference = pow(normalDifference, _NormalBias);

                float outline = normalDifference + depthDifference;

                float4 sourceColor = tex2D(_MainTex, i.uv);
                float4 color = lerp(sourceColor, _OutlineColor, outline);

                return color;                
            }

            ENDCG
        }
    }
}
