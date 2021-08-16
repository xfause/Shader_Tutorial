﻿Shader "Custom/45"
{
	Properties{
		//Properties
		_Color("Tint", Color) = (0,0,0,1)
		_MainTex("Texture", 2D) = "white"{}

		_OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
_OutlineWidth ("Outline Width", Range(0, 10)) = 1
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
			float4 _MainTex_TexelSize;

			fixed4 _Color;
			fixed4 _OutlineColor;
float _OutlineWidth;

			struct appdata {
				float4 vertex: POSITION;
				float2 uv: TEXCOORD0;
				fixed4 color: Color;
			};

			struct v2f {
				float4 position: SV_POSITION;
				float2 uv: TEXCOORD0;
				fixed4 color: Color;
				float3 worldPos: TEXCOORD1;
			};

			v2f vert(appdata v){
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			float2 uvPerWorldUnit(float2 uv, float2 space){
				float2 uvPerPixelX = abs(ddx(uv));
				float2 uvPerPixelY = abs(ddy(uv));
				float unitsPerPixelX = length(ddx(space));
				float unitsPerPixelY = length(ddy(space));
				float2 uvPerUnitX = uvPerPixelX / unitsPerPixelX;
				float2 uvPerUnitY = uvPerPixelY / unitsPerPixelY;
				return (uvPerUnitX+ uvPerUnitY);
			}

			fixed4 frag(v2f i): SV_Target {
				fixed4 col = tex2D(_MainTex, i.uv);
				col *= _Color;
				col *= i.color;				

				#define DIV_SQRT_2 0.70710678118
				float2 directions[8] = {float2(1, 0), float2(0, 1), float2(-1, 0), float2(0, -1),
					float2(DIV_SQRT_2, DIV_SQRT_2), float2(-DIV_SQRT_2, DIV_SQRT_2),
				float2(-DIV_SQRT_2, -DIV_SQRT_2), float2(DIV_SQRT_2, -DIV_SQRT_2)};

				float maxAlpha = 0;
				float2 sampleDistance =uvPerWorldUnit(i.uv, i.worldPos.xy) * _OutlineWidth;

				for (uint index=0;index<8;index++){
					float2 sampleUV = i.uv + directions[index] * sampleDistance;
					maxAlpha = max(maxAlpha, tex2D(_MainTex, sampleUV).a);
				}

				col.rgb = lerp(_OutlineColor, col.rgb, col.a);
				col.a = max(col.a, maxAlpha);

				return col;
			}

			ENDCG
		}
	}
	FallBack "Standard"
}
