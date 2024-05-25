Shader "Unlit/MyShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Shininess("Shininess", float) = 0
        _SpecularColor("specular Color", Color) = (1,1,1,1)
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
            #pragma shader_feature USE_SPECULAR
            #pragma shader_feature USE_NORMAL_SHADER

            #include "UnityCG.cginc"
            #include "UnityStandardBRDF.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Shininess;
            float4 _SpecularColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                #if USE_NORMAL_SHADER
                    return float4(i.normal, 1);
                #endif

                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfVector = normalize(lightDir + viewDir);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 diffuse = col.rgb * lightColor * saturate(dot(lightDir, i.normal));
                fixed3 ambient = col.rgb * UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 specular = float3(0,0,0);
                #if USE_SPECULAR
                    specular = _SpecularColor * pow(saturate(dot(i.normal, halfVector)), _Shininess);
                #endif

                return float4(diffuse + ambient + specular, 1);
            }
            ENDCG
        }
    }
    CustomEditor "CustomShaderGUI"
    Fallback "Diffuse"
}
