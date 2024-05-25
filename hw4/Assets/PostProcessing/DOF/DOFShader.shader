Shader "Custom/DOF"
{

	SubShader
	{
        ZTest Always
        ZWrite Off
        Cull Off

		HLSLINCLUDE

		#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"


		TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		TEXTURE2D_SAMPLER2D(_BlurTex, sampler_BlurTex);
		TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

        float4 _MainTex_TexelSize;
		
		float _BlurStrength = 1;
        float _MinFocusDistance = 0.3;
        float _MaxFocusDistance = 0.5;
        float _LessScale = 5;
        float _MoreScale = 5;
		
        float4 fragmentBlurVertical(VaryingsDefault i) : SV_Target
		{
			half2 midPos = i.texcoord;
			float2 uv[5];

            uv[0] = midPos;
            uv[1] = midPos + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurStrength;
            uv[2] = midPos - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurStrength;
            uv[3] = midPos + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurStrength;
            uv[4] = midPos - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurStrength;

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
            uv[1] = midPos + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurStrength;
            uv[2] = midPos - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurStrength;
            uv[3] = midPos + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurStrength;
            uv[4] = midPos - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurStrength;

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
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB

            HLSLPROGRAM
 
            #pragma vertex VertDefault
            #pragma fragment fragMotionBlur
 
		
            float4 fragMotionBlur(VaryingsDefault i) : SV_Target
		    {
                float3 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord).rgb;
                float3 blurCol = SAMPLE_TEXTURE2D(_BlurTex, sampler_BlurTex, i.texcoord).rgb;
                float depth =  SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture,  i.texcoord).r;
                depth = Linear01Depth(depth); 
                float3 ret = col;

                //blurCol = float3(0,0,0);
                if(depth < _MinFocusDistance)
                {
                    ret = lerp(col, blurCol, saturate((_MinFocusDistance - depth) * _LessScale)); 
                }
                else if(depth > _MaxFocusDistance)
                {
                    ret = lerp(col, blurCol, saturate((depth - _MaxFocusDistance) * _MoreScale)); 
                }
                return float4(ret, 1);
            }

            ENDHLSL
        }
	}	
}