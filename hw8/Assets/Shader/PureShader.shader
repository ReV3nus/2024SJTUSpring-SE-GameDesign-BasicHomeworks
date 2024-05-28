Shader "Unlit/PureShader"
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
            };

            struct FragmentData
            {
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _MainColor;


            FragmentData vert (VertexData v)
            {
                FragmentData o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (FragmentData i) : SV_Target
            {
                return _MainColor;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
