﻿Shader "Custom/43_1"
{
	Properties{
		_FromColor ("From Color", Color) = (0, 0, 0, 1) //the base color
		_ToColor ("To Color", Color) = (1,1,1,1) //the color to blend to
	}

	SubShader{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

		Pass{
			CGPROGRAM

			//include useful shader functions
			#include "UnityCG.cginc"
			#include "Interpolation.cginc"

			//define vertex and fragment shader
			#pragma vertex vert
			#pragma fragment frag

			//the colors to blend between
			fixed4 _FromColor;
			fixed4 _ToColor;

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
				// float inverseLerped = invLerp(from, to, value);
				// float result = lerp(form, to, inverseLerped);
				return 0;
			}

			ENDCG
		}
	}
}
