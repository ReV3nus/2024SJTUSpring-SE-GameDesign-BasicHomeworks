Shader "Custom/TF2Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump"{}
        _AOTex("Ambient Occlusion Map", 2D) = "white"{}
        _DiffuseFunction("Diffuse Warping Function", 2D) = "Typical diffuse light warping function"{}
        _Glossiness("Smoothness",Range(0,1)) = 1
        _Metallicness("Metallicness",Range(0,1)) = 0
        

		[NoScaleOffset] _WetMap("Wet Map", 2D) = "black" {}
		[Enum(UV0,0,UV1,1)] _WetMapUV("Wet Map UV Set", Float) = 1
		// droplets for non-porous horizontal surfaces
		[HideInInspector] _WetBumpMap("Wet Bump Map", 2D) = "bump" {}
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
            #pragma multi_compile DEPTHWRITE_ON

            #include "UnityCG.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct VertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 uv : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
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
				float2 uv1 : TEXCOORD5;
                float4 position : SV_POSITION;
                float2 depth : TEXCOORD6;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _AOTex;
            float4 _AOTex_ST;
            sampler2D _DiffuseFunction;
            float4 _DiffuseFunction_ST;
            float _Glossiness;
            float _Metallicness;
            

			sampler2D _WetMap;
			half _WetMapUV;
			sampler2D _WetBumpMap;

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
				o.uv1 = v.texcoord1;
                UNITY_TRANSFER_DEPTH(o.depth);
                return o;
            }
            

			// https://seblagarde.wordpress.com/2013/04/14/water-drop-3b-physically-based-wet-surfaces/
			void AddWater(float2 uv, float metalness, inout half3 diffuse, inout float smoothness, inout fixed4 bumpMap, float2 wsPos, float3 normalWS)
			{
				fixed wetMap = tex2D(_WetMap, uv).r;
				float porosity = saturate((1 - smoothness) - 0.2);//saturate(((1-Gloss) - 0.5)) / 0.4 );
				float factor = lerp(1, 0.2, (1 - metalness) * porosity);
				float collectWater = max(0, normalWS.y);
				diffuse *= lerp(1.0, factor, wetMap);
				smoothness = lerp(smoothness, 0.95, saturate(wetMap * wetMap));// lerp(1, factor, 0.5 * wetMap));
				bumpMap = lerp(bumpMap, tex2D(_WetBumpMap, wsPos * 20), wetMap * collectWater);
			}

            // UnityIndirect GetUnityIndirect(float3 lightColor, float3 lightDirection, float3 normalDirection,float3 viewDirection, float3 viewReflectDirection, float attenuation, float roughness, float3 worldPos){
            //     //// Set UnityLight
            //     UnityLight light;
            //     light.color = lightColor;
            //     light.dir = lightDirection;
            //     light.ndotl = saturate(dot( normalDirection, lightDirection));

            //     //// Set UnityGIInput
            //     UnityGIInput d;
            //     d.light = light;
            //     d.worldPos = worldPos;
            //     d.worldViewDir = viewDirection;
            //     d.atten = attenuation;
            //     d.ambient = 0.0h;
            //     d.boxMax[0] = unity_SpecCube0_BoxMax;
            //     d.boxMin[0] = unity_SpecCube0_BoxMin;
            //     d.probePosition[0] = unity_SpecCube0_ProbePosition;
            //     d.probeHDR[0] = unity_SpecCube0_HDR;
            //     d.boxMax[1] = unity_SpecCube1_BoxMax;
            //     d.boxMin[1] = unity_SpecCube1_BoxMin;
            //     d.probePosition[1] = unity_SpecCube1_ProbePosition;
            //     d.probeHDR[1] = unity_SpecCube1_HDR;

            //     //// Set EnvironmentData
            //     Unity_GlossyEnvironmentData ugls_en_data;
            //     ugls_en_data.roughness = roughness;
            //     ugls_en_data.reflUVW = viewReflectDirection;
                
            //     //// GetGI
            //     UnityGI gi = UnityGlobalIllumination(d, 1.0h, normalDirection, ugls_en_data );
            //     return gi.indirect;
            // }

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

                //// Light attenuation
                float attenuation = LIGHT_ATTENUATION(i);

                //// Indirect Global Illumination
                //UnityIndirect gi =  GetUnityIndirect(_LightColor0.rgb, L, N, V, VR, attenuation, 1- _Glossiness, i.worldPos.xyz);

                //// Compute Roughness
                float perceptualRoughness = SmoothnessToPerceptualRoughness(_Glossiness);
                float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

                half oneMinusReflectivity;
                half3 specColor;
                float3 albedo = DiffuseAndSpecularFromMetallic (mainTex.rgb, _Metallicness, /*out*/ specColor, /*out*/ oneMinusReflectivity);
                albedo = mainTex.rgb;

                // Water Fix
				float metalness = _Metallicness;
				float smoothness = _Glossiness;
                float3 normalWS = float3(i.tspace0.z, i.tspace1.z, i.tspace2.z);
				AddWater((_WetMapUV == 0) ? i.uv : i.uv1, metalness, /*inout*/ albedo, /*inout*/ smoothness, /*inout*/ normalTex, i.worldPos, normalWS);

                float3 lightColor = _LightColor0.rgb;

                float3 tnormal = UnpackNormal(normalTex);
                // transform normal from tangent to world space
                float3 N;
                N.x = dot(i.tspace0, tnormal);
                N.y = dot(i.tspace1, tnormal);
                N.z = dot(i.tspace2, tnormal);
                
                float3 VR = Unity_SafeNormalize(reflect( -V, N ));
                float NdotL = saturate( dot( N,L ));
                float NdotH = saturate( dot( N,H ));
                float NdotV = saturate( dot( N,V ));
                float VdotH = saturate( dot( V,H ));
                float LdotH = saturate( dot( L,H ));

                //// Custom Shader
                //// 1. View Independent Lighting Terms
                //// Half Lambert
                float halfLambert = saturate(0.5 * dot( N,L ) + 0.5);
                //// Diffuse Warping Function
                float3 warpFunction = tex2D(_DiffuseFunction, float2(halfLambert, 0.5));
                float3 WarpedDiffuse = warpFunction * lightColor;
                //// 1.2. Directional Ambient Term
                float3 AmbientLight = UNITY_LIGHTMODEL_AMBIENT.xyz * AOTex;

                float4 color = float4(albedo * (WarpedDiffuse + AmbientLight), 1);




                //// 2. View Dependent Lighting Terms
                //// 2.1. Multiple Phong Terms
                float D = GGX_D(roughness, NdotH);
                float3 F = Schlick_F(specColor, LdotH);
                float G = CookTorrence_G(NdotL, NdotV, VdotH, NdotH);
                float3 directSpecular = (D * F * G) * UNITY_PI / (4 * (NdotL * NdotV));
                directSpecular = saturate(directSpecular);

                //// 2.2. Dedicated Rim Lighting
                float grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
                float Kr = 0.2;
                float3 worldUp = float3(0, 1, 0);
                float3 U = normalize(mul(unity_ObjectToWorld, worldUp)).xyz;
                //float3 U = _WorldSpaceUp;
                float NdotU = saturate( dot( N,U ));
                float3 RimLight = NdotU * Kr * FresnelLerp(specColor, grazingTerm, NdotV);
                RimLight = saturate(RimLight);

                //return float4(RimLight + directSpecular, 1);

                color += float4(directSpecular + RimLight, 1);

                return color;
            }
            ENDCG
        }
    }
    Fallback "Standard"
}
