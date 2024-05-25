Shader "Custom/Bloom"
{

	SubShader
	{
		Cull Off 

		HLSLINCLUDE

		#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"


		TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		TEXTURE2D_SAMPLER2D(_BloomTex, sampler_BloomTex);
        float4 _MainTex_TexelSize;

		float _lineStrength = 1.0;
		float4 _BloomColor = float4(1, 1, 1, 1);
		float _BloomStrength = 0.1;
		
        float4 fragmentBlurVertical(VaryingsDefault i) : SV_Target
		{
			half2 midPos = i.texcoord;
			float2 uv[5];

            uv[0] = midPos;
            uv[1] = midPos + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BloomStrength;
            uv[2] = midPos - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BloomStrength;
            uv[3] = midPos + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BloomStrength;
            uv[4] = midPos - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BloomStrength;

            float weight[3] = {0.4026, 0.2442, 0.0545};
 
            float3 sum = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[0]).rgb * weight[0];
 
			for (int it = 1; it < 3; it++) {
				sum += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[it*2-1]).rgb * weight[it];
				sum += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[it*2]).rgb * weight[it];
			}
            return float4(sum, 1.0);
        }
        
        float4 fragmentBlurHorizontal(VaryingsDefault i) : SV_Target
		{
			half2 midPos = i.texcoord;
			float2 uv[5];
			
            uv[0] = midPos;
            uv[1] = midPos + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BloomStrength;
            uv[2] = midPos - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BloomStrength;
            uv[3] = midPos + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BloomStrength;
            uv[4] = midPos - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BloomStrength;

            float weight[3] = {0.4026, 0.2442, 0.0545};
 
            float3 sum = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[0]).rgb * weight[0];
 
			for (int it = 1; it < 3; it++) {
				sum += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[it*2-1]).rgb * weight[it];
				sum += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[it*2]).rgb * weight[it];
			}
            return float4(sum, 1.0);
        }

		ENDHLSL
		
 
        Tags { "RenderType"="Opaque" }

        Pass
        {
 
            HLSLPROGRAM
 
            #pragma vertex VertDefault
            #pragma fragment fragmentBlurVertical
 
            ENDHLSL
        }
 
        Pass
        {
		
            HLSLPROGRAM
 
            #pragma vertex VertDefault
            #pragma fragment fragmentBlurHorizontal
 
            ENDHLSL
        }

		Pass
		{
			HLSLPROGRAM

			#pragma vertex VertDefault
			#pragma fragment frag

			float4 frag(VaryingsDefault i) : SV_Target
			{
				float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

				float tmp = col.r * _BloomColor.r + col.g * _BloomColor.g + col.b * _BloomColor.b;

				return col * tmp;
			}

			ENDHLSL
		}

		Pass
		{
			HLSLPROGRAM

			#pragma vertex VertDefault
			#pragma fragment frag

			float4 frag(VaryingsDefault i) : SV_Target
			{
				float4 col1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
				float4 col2 = SAMPLE_TEXTURE2D(_BloomTex, sampler_BloomTex, i.texcoord);
				return col1 + col2;
			}
			ENDHLSL
		}
	}	
}