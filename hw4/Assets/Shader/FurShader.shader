Shader "Unlit/FurShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        
        _FurColor ("Fur Color", Color) = (1, 1, 1, 1)
        _FurLength ("Fur Length", Range(0,.2)) = 0.03
        
		_Gravity("Gravity Direction", Vector) = (0,-1,0,0)
		_GravityStrength("Gravity Strength", Range(0,1)) = 0.25

        [Space(20)]
        _OcclusionColor("Fur Color", Color) = (1, 1, 1, 1)
        _FresnelLV("FresnelLV", Range(0,1)) = 0.1
        _LightFilter("Light Filter",  Range(-0.5,0.5)) = 0.0
        _FurDirLightExposure("FurDirLightExposure", Range(0,1)) = 0.1
        _DirLightColor("DirLightColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        CGINCLUDE

        #include "UnityCG.cginc"
        #include "UnityStandardBRDF.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
            float2 uv2 : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float3 normal : TEXCOORD1;
            float4 vertex : SV_POSITION;
            float3 worldPos : TEXCOORD2;
            float2 uv2 : TEXCOORD3;
        };
        
        sampler2D _MainTex;
        sampler2D _NoiseTex;

        float4 _MainTex_ST;
        float4 _NoiseTex_ST;
        float4 _FurColor;
        float _FurLength;
        
		half3 _Gravity;
		half _GravityStrength;

        float4 _OcclusionColor;
        float _FresnelLV;
        float _LightFilter;
        float _FurDirLightExposure;
        float4 _DirLightColor;

        v2f vert_fur (appdata v, half FUR_OFFSET)
        {
			half3 GravityDirection = lerp(v.normal, _Gravity * _GravityStrength + v.normal * (1 - _GravityStrength), FUR_OFFSET);

            v2f o;
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            o.uv2 = TRANSFORM_TEX(v.uv2, _NoiseTex);
            o.normal = UnityObjectToWorldNormal(v.normal);

            float3 position = v.vertex + GravityDirection * _FurLength * FUR_OFFSET;
            o.vertex = UnityObjectToClipPos(position);
            return o;
        }

        fixed4 frag_fur (v2f i, half FUR_OFFSET)
        {
            float3 L = _WorldSpaceLightPos0.xyz;
            float3 lightColor = _LightColor0.rgb;

            float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
            float3 N = i.normal;

            // sample the texture
            fixed4 col = tex2D(_MainTex, i.uv);
            fixed4 noise = tex2D(_NoiseTex, i.uv2);

            fixed alpha = step(FUR_OFFSET*FUR_OFFSET, noise.r);

            col.a = saturate(1 - FUR_OFFSET);

            col.a *= alpha;

            float3 normal = normalize(mul(UNITY_MATRIX_MV, float4(i.normal,0)).xyz);
            half3 SH = saturate(normal.y *0.25+0.35) ;
            half Occlusion =FUR_OFFSET*FUR_OFFSET;
            Occlusion +=0.04 ;
            half3 SHL = lerp (_OcclusionColor*SH,SH,Occlusion) ;
            half Fresnel = 1-max(0,dot(N,V));
            half RimLight =Fresnel * Occlusion; 
            RimLight *=RimLight; 
            RimLight *=_FresnelLV *SH;
            SHL +=RimLight;
            half NoL =dot(L,N);
            half DirLight= saturate (NoL+_LightFilter+ FUR_OFFSET ) ;
            DirLight *=_FurDirLightExposure*_DirLightColor;

            return float4((SHL + DirLight) * col.rgb , col.a);
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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


                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 diffuse = col.rgb * lightColor * saturate(dot(lightDir, i.normal));
                fixed3 ambient = col.rgb * UNITY_LIGHTMODEL_AMBIENT.xyz;


                return float4(diffuse + ambient, col.a);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.05);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.05);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.1);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.1);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.15);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.15);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.2);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.2);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.25);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.25);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.3);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.3);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.35);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.35);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.4);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.4);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.45);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.45);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.5);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.5);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.55);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.55);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.6);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.6);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.65);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.65);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.7);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.7);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.75);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.75);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.8);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.8);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.85);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.85);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.9);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.9);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 0.95);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 0.95);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            v2f vert (appdata v)
            {
                return vert_fur(v, 1.0);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                return frag_fur(i, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
