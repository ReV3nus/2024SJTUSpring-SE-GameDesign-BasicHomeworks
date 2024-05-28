Shader "Custom/SketchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump"{}
        _AOTex("Ambient Occlusion Map", 2D) = "white"{}

        _Map1("Strokes Map 1", 2D) = "FurNoise"{}
        _Map2("Strokes Map 2", 2D) = "SketchMap2"{}
        _Map3("Strokes Map 3", 2D) = "SketchMap3"{}
        _Map4("Strokes Map 4", 2D) = "SketchMap4"{}
        _Map5("Strokes Map 5", 2D) = "SketchMap5"{}
        _Map6("Strokes Map 6", 2D) = "SketchMap6"{}

        
        _Threshold1("Threshold of Map 1 to 2",Range(0,1)) = 0.8
        _Threshold2("Threshold of Map 2 to 3",Range(0,1)) = 0.6
        _Threshold3("Threshold of Map 3 to 4",Range(0,1)) = 0.4
        _Threshold4("Threshold of Map 4 to 5",Range(0,1)) = 0.2
        _Threshold5("Threshold of Map 5 to 6",Range(0,1)) = 0

        _Scale("Scale of Strokes Maps", float) = 10

        

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _AOTex;
            float4 _AOTex_ST;

            sampler2D _Map1, _Map2, _Map3, _Map4, _Map5, _Map6;
            sampler2D _Map1_ST, _Map2_ST, _Map3_ST, _Map4_ST, _Map5_ST, _Map6_ST;
            float _Threshold1,_Threshold2,_Threshold3,_Threshold4,_Threshold5;
            float _Scale;

            
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

                float customLambert = saturate(0.5 * dot(N,L) + 0.5);
                float3 AmbientLight = UNITY_LIGHTMODEL_AMBIENT.xyz * AOTex;
                float LightVal = saturate((AmbientLight.x + AmbientLight.y + AmbientLight.z)/3 + customLambert);
                

                float3 color = float3(LightVal ,LightVal,LightVal);

                if(LightVal >= _Threshold1)
                {
                    float4 mapTex = tex2D(_Map1, i.uv * _Scale);
                    float4 mapTex2 = tex2D(_Map2, i.uv * _Scale);

                    color = mapTex2.rgb * (1 - LightVal) / (1 - _Threshold1) + mapTex.rgb * (LightVal - _Threshold1) / (1 - _Threshold1);
                }
                else if(LightVal >= _Threshold2)
                {
                    float4 mapTex = tex2D(_Map2, i.uv * _Scale);
                    float4 mapTex2 = tex2D(_Map3, i.uv * _Scale);

                    color = mapTex2.rgb * (_Threshold1 - LightVal) / (_Threshold1 - _Threshold2) + mapTex.rgb * (LightVal - _Threshold2) / (_Threshold1 - _Threshold2);
                }
                else if(LightVal >= _Threshold3)
                {
                    float4 mapTex = tex2D(_Map3, i.uv * _Scale);
                    float4 mapTex2 = tex2D(_Map4, i.uv * _Scale);

                    color = mapTex2.rgb * (_Threshold2 - LightVal) / (_Threshold2 - _Threshold3) + mapTex.rgb * (LightVal - _Threshold3) / (_Threshold2 - _Threshold3);
                }
                else if(LightVal >= _Threshold4)
                {
                    float4 mapTex = tex2D(_Map4, i.uv * _Scale);
                    float4 mapTex2 = tex2D(_Map5, i.uv * _Scale);

                    color = mapTex2.rgb * (_Threshold3 - LightVal) / (_Threshold3 - _Threshold4) + mapTex.rgb * (LightVal - _Threshold4) / (_Threshold3 - _Threshold4);
                }
                else if(LightVal >= _Threshold5)
                {
                    float4 mapTex = tex2D(_Map5, i.uv * _Scale);
                    float4 mapTex2 = tex2D(_Map6, i.uv * _Scale);

                    color = mapTex2.rgb * (_Threshold4 - LightVal) / (_Threshold4 - _Threshold5) + mapTex.rgb * (LightVal - _Threshold5) / (_Threshold4 - _Threshold5);
                }
                else
                {
                    float4 mapTex = tex2D(_Map6, i.uv * _Scale);
                    color = mapTex.rgb;
                }

                

                // Water Fix
				float metalness = 0;
				float smoothness = 0;
                float3 normalWS = float3(i.tspace0.z, i.tspace1.z, i.tspace2.z);
				AddWater((_WetMapUV == 0) ? i.uv : i.uv1, metalness, /*inout*/ color, /*inout*/ smoothness, /*inout*/ normalTex, i.worldPos, normalWS);


                return float4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
