Shader "Unlit/OutlineShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Shininess("Shininess", float) = 0
        
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineThickness ("Outline Thickness", Range(0,.1)) = 0.03
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

            float _OutlineThickness;
            float4 _OutlineColor;
            
            sampler2D _CameraDepthTexture;

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
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfVector = normalize(lightDir + viewDir);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 diffuse = col.rgb * lightColor * saturate(dot(lightDir, i.normal));
                fixed3 ambient = col.rgb * UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 specular = lightColor * pow(saturate(dot(i.normal, halfVector)), _Shininess);

                return float4(diffuse + ambient + specular, 1);
            }
            ENDCG
        }

        PASS
        {
            Cull front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityStandardBRDF.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            //color of the outline
            fixed4 _OutlineColor;
            //thickness of the outline
            float _OutlineThickness;
            

            v2f vert (appdata v)
            {
                v2f o;

                float3 normal = normalize(v.normal);
                float3 outlineOffset = normal * _OutlineThickness;
                float3 position = v.vertex + outlineOffset;

                o.vertex = UnityObjectToClipPos(position);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if(_OutlineThickness == 0)
                    discard;
                return _OutlineColor;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
