Shader "Custom/15"
{

    Properties{
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _upCutoff ("up cutoff", Range(0,1)) = 0.7
        _topColor ("top color", Color) = (1,1,1,1)
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

            float4x4 _viewToWorld;
            float _upCutoff;
            float4 _topColor;

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

            //the fragment shader
            fixed4 frag(v2f i) : SV_TARGET{
                float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
                
                float3 normal;
                float depth;
                DecodeDepthNormal(depthNormal, depth, normal);

                depth = depth * _ProjectionParams.z;
                normal = mul((float3x3)_viewToWorld, normal);

                float up = dot(float3(0,1,0), normal);
                up = step(_upCutoff, up);
                float4 source = tex2D(_MainTex, i.uv);
                float4 col = lerp(source, _topColor, up*_topColor.a);
                return col;                
            }

            ENDCG
        }
    }
}
