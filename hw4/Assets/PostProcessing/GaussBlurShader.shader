Shader "Custom/GaussBlurShader"
{
	Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("BlurSize", int) = 1
    }
    SubShader
    {
        CGINCLUDE
 
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        int _BlurSize;
 
        struct appdata
        {
            float2 texcoord : TEXCOORD0;
            float4 vertex : POSITION;
        };
 
        struct v2f
        {
            float2 uv[5] : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };
 
        v2f vertBlurVertial(appdata i){
            v2f o;
            o.vertex = UnityObjectToClipPos(i.vertex);
 
            half2 midPos = i.texcoord;
            
            o.uv[0] = midPos;
            o.uv[1] = midPos + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[2] = midPos - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[3] = midPos + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
            o.uv[4] = midPos - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
 
            return o;
        }
 
        v2f vertBlurHorizontal(appdata i){
            v2f o;
            o.vertex = UnityObjectToClipPos(i.vertex);
 
            half2 midPos = i.texcoord;
            
            o.uv[0] = midPos;
            o.uv[1] = midPos + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[2] = midPos - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[3] = midPos + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
            o.uv[4] = midPos - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
 
            return o;
        }
 
        fixed4 fragmentBlur(v2f i) : SV_Target{
            float weight[3] = {0.4026, 0.2442, 0.0545};
 
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
 
			for (int it = 1; it < 3; it++) {
				sum += tex2D(_MainTex, i.uv[it*2-1]).rgb * weight[it];
				sum += tex2D(_MainTex, i.uv[it*2]).rgb * weight[it];
			}
 
            return fixed4(sum, 1.0);
        }
 
        ENDCG
 
        Tags { "RenderType"="Opaque" }
 
        Pass
        {
            NAME "BLUR_VERTIAL"
 
            CGPROGRAM
 
            #pragma vertex vertBlurVertial
            #pragma fragment fragmentBlur
 
            ENDCG
        }
 
        Pass
        {
            NAME "BLUR_HORIZONTAL"
 
            CGPROGRAM
 
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragmentBlur
 
            ENDCG
        }
    }
    FallBack Off
}
