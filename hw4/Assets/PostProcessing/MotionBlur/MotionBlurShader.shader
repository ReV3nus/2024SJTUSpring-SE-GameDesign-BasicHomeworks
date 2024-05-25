Shader "Custom/MotionBlur"
{

	SubShader
	{
        ZTest Always
        ZWrite Off
        Cull Off

		HLSLINCLUDE

		#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"


		TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		TEXTURE2D_SAMPLER2D(_PreTex, sampler_PreTex);
        float4 _MainTex_TexelSize;
		
        float _BlurAlpha = 0.9;

		ENDHLSL
		
 
        Tags { "RenderType"="Opaque" }

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
                return float4(col, _BlurAlpha);
            }

            ENDHLSL
        }
	}	
}