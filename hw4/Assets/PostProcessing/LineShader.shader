Shader "TMP/LineStyle"
{
	HLSLINCLUDE

#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

	TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
	float _lineStrength = 1.0;
	float4 _lineColor = (0, 0, 0, 0);
	float4 _baseColor = (1, 1, 1, 0);

	float4 Frag(VaryingsDefault i) : SV_Target
	{
		float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
		float grayscale = col.r * 0.2126729f + col.g * 0.7151522f + col.b * 0.0721750f;
		float ddVal = (saturate(ddx(grayscale) + ddy(grayscale))*_lineStrength);
		float3 finalRGB = _baseColor.rgb * (1.0 - ddVal) + _lineColor.rgb * ddVal;
		float4 finalCol = float4(finalRGB, 1);
		return finalCol;
	}

		ENDHLSL

		SubShader
	{
		Cull Off ZWrite Off ZTest Always

			Pass
		{
			HLSLPROGRAM

				#pragma vertex VertDefault
				#pragma fragment Frag

			ENDHLSL
		}
	}	
}