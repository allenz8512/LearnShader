Shader "Unity Shaders Book/Chapter 7/Normal Map In World Space"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    
    SubShader
    {
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            
            uniform fixed4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            // 声明法线贴图
            uniform sampler2D _BumpMap;
            uniform float4 _BumpMap_ST;
            uniform fixed4 _Specular;
            // 声明法线贴图凹凸系数
            uniform float _BumpScale;
            uniform float _Gloss;
            
            struct a2v {
				float4 vertex : POSITION;
				// NORMAL语义声明模型顶点法线
				float3 normal : NORMAL;
				// TANGENT语义声明模型顶点切线
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
            };
            
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 用xy分量保存主贴图的纹理坐标
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                // 用zw分量保存法线贴图的纹理坐标
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                float3 worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                // 因为一个插值寄存器最多存储float4大小的变量，把切线空间到世界空间的变换矩阵分到3个变量存储
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_TARGET {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
               // Get the normal in tangent space
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				// Transform the narmal from tangent space to world space
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            
            ENDCG
        }             
    }
    
    Fallback "Specular"
}