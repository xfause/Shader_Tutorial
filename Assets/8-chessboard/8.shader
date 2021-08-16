Shader "Custom/8"
{

    Properties{
		//Properties

        _Scale("Pattern Size", Range(0,10)) = 1
        _EvenColor("Color 1", color) = (0,0,0,1)
        _OddColor("Color 2", color) = (0,0,0,1)
	}
	Subshader{
		Tags{
			//Subshader Tags
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
		}

		//Settings for all passes

		Pass{
			Tags{
				//Pass Tags
			}

			//Settings for pass

			CGPROGRAM
            
            // useful shader functions
            #include "UnityCG.cginc"

            // define vertex and fragment shader function
            #pragma vertex vert
            #pragma fragment frag

            float _Scale;

            float4 _EvenColor;
            float4 _OddColor;

            struct appdata {
                float4 vertex: POSITION;
            };

            struct v2f {
                float4 position: SV_POSITION;
                float3 worldPos: TEXCOORD0;
            };

            // vertex shader function
            v2f vert(appdata v) {
                v2f o;
                //convert vertex position of object to clip position
                o.position = UnityObjectToClipPos(v.vertex);
                // apply texture to UV position and pass to struct v2f
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i): SV_Target{
                
                float3 adjustedWorldPos = floor(i.worldPos / _Scale);
                float chessboard = adjustedWorldPos.x + adjustedWorldPos.y + adjustedWorldPos.z;
                chessboard = frac(chessboard * 0.5);
                chessboard *= 2;

                float4 color = lerp(_EvenColor, _OddColor, chessboard);

                return color;
            }


			//shader code
			ENDCG
		}
	}
    FallBack "Standard"
}
