Shader "Unlit/TextureShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct FragmentData
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _MainColor;


            FragmentData vert (VertexData v)
            {
                FragmentData o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (FragmentData i) : SV_Target
            {
                //return _MainColor;
                return float4(i.normal, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
