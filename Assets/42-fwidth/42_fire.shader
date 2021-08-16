Shader "Custom/42_fire"
{
    //show values to edit in inspector
	Properties{
		_MainTex ("Fire Noise", 2D) = "white" {}
		_ScrollSpeed("Animation Speed", Range(0, 2)) = 1
	
		_Color1 ("Color 1", Color) = (0, 0, 0, 1)
		_Color2 ("Color 2", Color) = (0, 0, 0, 1)
		_Color3 ("Color 3", Color) = (0, 0, 0, 1)
		
		_Edge1 ("Edge 1-2", Range(0, 1)) = 0.25
		_Edge2 ("Edge 2-3", Range(0, 1)) = 0.5
	}

	SubShader{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}
		
		Cull Off

		Pass{
			CGPROGRAM

			//include useful shader functions
			#include "UnityCG.cginc"

			//define vertex and fragment shader
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color1;
			fixed4 _Color2;
			fixed4 _Color3;
			
			float _Edge1;
			float _Edge2;
			
			float _ScrollSpeed;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;

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

			float aaStep(float compValue, float gradient){
				float halfChange = fwidth(gradient) / 2;
				float lowerEdge = compValue - halfChange;
				float upperEdge = compValue + halfChange;
				float stepped = (gradient-lowerEdge) / (upperEdge - lowerEdge);
				stepped = saturate(stepped);
				return stepped;
			}

			//the fragment shader
			fixed4 frag(v2f i) : SV_TARGET{
                float fireGradient = 1-i.uv.y;
				fireGradient = fireGradient * fireGradient;

				float2 fireUV = TRANSFORM_TEX(i.uv, _MainTex);
				fireUV.y -= _Time.y * _ScrollSpeed;

				float fireNoise = tex2D(_MainTex, fireUV).x;
				float outline = aaStep(fireNoise, fireGradient);
				float edge1 = aaStep(fireNoise, fireGradient - _Edge1);
				float edge2 = aaStep(fireNoise, fireGradient - _Edge2);

				fixed4 col = _Color1 * outline;
				col = lerp(col, _Color2, edge1);
				col = lerp(col, _Color3, edge2);

				return col;
			}

			ENDCG
		}
	}
}
