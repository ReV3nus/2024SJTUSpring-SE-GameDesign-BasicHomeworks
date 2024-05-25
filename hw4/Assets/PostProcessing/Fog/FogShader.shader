Shader "Custom/Fog"
{

	SubShader
	{
        ZTest Always
        ZWrite Off
        Cull Off

		HLSLINCLUDE

		#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"


		TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
		TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
		TEXTURE2D_SAMPLER2D(_NoiseTex, sampler_NoiseTex);
        float4 _MainTex_TexelSize;
		
		float _FogDensity = 1;
        float _FogHeight = 2;
        float _FogXSpeed = 0.5;
        float _FogYSpeed = 0.5;
        float _NoiseStrength = 1;
        float _NoiseScale = 1;
        float4 _FogColor = float4(1,1,1,1);
        float4x4 _FrustumCornersRay;

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


                float depth =  SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture,  i.texcoord).r;
                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,sampler_CameraDepthTexture,i.texcoord));
                depth = Linear01Depth(depth); 

                float3 FrustumDepth = _FrustumCornersRay[0].xyz * (1 - i.texcoord.x) * (1 - i.texcoord.y) +
                                    _FrustumCornersRay[1].xyz * (i.texcoord.x) * (1 - i.texcoord.y) +
                                    _FrustumCornersRay[2].xyz * (1 - i.texcoord.x) * (i.texcoord.y) +
                                    _FrustumCornersRay[3].xyz * (i.texcoord.x) * (i.texcoord.y);

                float2 offset = _Time.y * float2(_FogXSpeed, _FogYSpeed);
                float3 noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, (i.texcoord + offset) * _NoiseScale).rgb * _NoiseStrength;

                //int index = round(i.texcoord.x) + 2*round(i.texcoord.y);


                //return float4(normalize(_FrustumCornersRay[index].xyz)/2+float3(0.5,0.5,0.5),1);
                //return float4(normalize(FrustumDepth)/2+float3(0.5,0.5,0.5),1);

                //float3 worldPos = _WorldSpaceCameraPos + linearDepth * _FrustumCornersRay[index].xyz;
                float3 worldPos = _WorldSpaceCameraPos + linearDepth * FrustumDepth;
                //return float4(normalize(worldPos)/2+float3(0.5,0.5,0.5),1);
                //float val = worldPos.y/10;
                //return float4(val,val,val,1);


                float fogDensity = saturate(saturate((_FogHeight - worldPos.y) / _FogHeight) * _FogDensity * (1 + noise * (1 - depth)));
                col = lerp(col, _FogColor, fogDensity);

                return float4(col, 1);
            }

            ENDHLSL
        }
	}	
}