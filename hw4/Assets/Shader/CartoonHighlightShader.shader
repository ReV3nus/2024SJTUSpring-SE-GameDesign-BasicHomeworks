Shader "Custom/CartoonHighlightShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump"{}
        _AOTex("Ambient Occlusion Map", 2D) = "white"{}

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
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct VertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 uv : TEXCOORD0;
            };

            struct FragmentData {
                float3 worldPos : TEXCOORD0;
                // these three vectors will hold a 3x3 rotation matrix
                // that transforms from tangent to world space
                half3 tspace0 : TEXCOORD1; // tangent.x, bitangent.x, normal.x
                half3 tspace1 : TEXCOORD2; // tangent.y, bitangent.y, normal.y
                half3 tspace2 : TEXCOORD3; // tangent.z, bitangent.z, normal.z
                // texture coordinate for the normal map
                float2 uv : TEXCOORD4;
                float4 position : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _AOTex;
            float4 _AOTex_ST;

            FragmentData vert (VertexData v)
            {
                FragmentData o;
                o.position = UnityObjectToClipPos(v.position);
                o.worldPos = mul(unity_ObjectToWorld, v.position).xyz;
                half3 wNormal = UnityObjectToWorldNormal(v.normal);
                half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                // compute bitangent from cross product of normal and tangent
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
                // output the tangent space matrix
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float Pow2(float x)
            {
                return x*x;
            }
             float Pow5(float x)
            {
                return x*x*x*x*x;
            }
            float3 Schlick_F(half3 R, half cosA)
            {
                //// TODO: your implementation
                float3 F = R + (1-R) * Pow5(1 - cosA);
                return F;
            }
            float GGX_D(float roughness, float NdotH)
            {
             //   roughness = Pow2(roughness);
                float D = Pow2(roughness) / (UNITY_PI * (Pow2(1 + Pow2(NdotH) * (Pow2(roughness) - 1))));
                return D;
            }

            float CookTorrence_G (float NdotL, float NdotV, float VdotH, float NdotH){
                float G = 1;
                G = min(G, 2 * NdotH * NdotV / VdotH);
                G = min(G, 2 * NdotH * NdotL / VdotH);
                return G;
            }

            fixed4 frag (FragmentData i) : SV_Target
            {
                float4 mainTex = tex2D( _MainTex, i.uv );
				float4 normalTex = tex2D( _NormalMap, i.uv);
				float4 AOTex = tex2D( _AOTex, i.uv);

                //// Vectors
                float3 L = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.worldPos.xyz,_WorldSpaceLightPos0.w));
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 H = Unity_SafeNormalize(L + V);

                float3 tnormal = UnpackNormal(normalTex);
                // transform normal from tangent to world space
                float3 N;
                N.x = dot(i.tspace0, tnormal);
                N.y = dot(i.tspace1, tnormal);
                N.z = dot(i.tspace2, tnormal);
                
                float3 VR = Unity_SafeNormalize(reflect( -V, N ));

                //// Vector dot
                float NdotL = saturate( dot( N,L ));
                float NdotH = saturate( dot( N,H ));
                float NdotV = saturate( dot( N,V ));
                float VdotH = saturate( dot( V,H ));
                float LdotH = saturate( dot( L,H ));

                float3 albedo = mainTex.rgb;

                float3 lightColor = _LightColor0.rgb;

                //// Custom Shader
                //// 1. View Independent Lighting Terms
                //// Half Lambert
                float halfLambert = saturate(0.5 * dot( N,L ) + 0.5);
                float3 WarpedDiffuse = halfLambert;
                //// 1.2. Directional Ambient Term
                float3 AmbientLight = UNITY_LIGHTMODEL_AMBIENT.xyz * AOTex;

                float4 color = float4(albedo * (WarpedDiffuse + AmbientLight), 1);
                color = float4(0,0,0,1);

                //// 2. View Dependent Lighting Terms
                float litScale = 1;
                float3 H2 = normalize(float3(H.x, H.y * litScale, H.z));
                float3 N2 = normalize(float3(N.x, N.y * litScale, N.z));
                float Criterion = dot(N2,H2);
                float3 specular =  float3(1,1,1) * (Criterion >= 0.99 ? 1 : 0);

                litScale = 0.4;
                float splitDist = 0.6;
                H2 = normalize(float3(H.x, (H.y - splitDist) * litScale, H.z));
                N2 = normalize(float3(N.x, N.y * litScale, N.z));
                Criterion = dot(N2,H2);
                specular = saturate(specular + float3(1,1,1) * (Criterion >= 0.99 ? 1 : 0));

                color += float4(specular, 0);

                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
