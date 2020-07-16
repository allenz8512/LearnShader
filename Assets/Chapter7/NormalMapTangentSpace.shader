Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space"
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
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
            };
            
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 用xy分量保存主贴图的纹理坐标
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                // 用zw分量保存法线贴图的纹理坐标
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                // 使用内置宏获取切线空间信息， 得到binormal（副法线，也就是切线空间的y轴）和rotation（从模型空间切换到切线空间的变换矩阵）
                // 着色器输入必须名为v并包含normal和tangent字段
                TANGENT_SPACE_ROTATION;
                // 将光照方向转换到切线空间
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                // 将视角方向转换到切线空间
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                // 对法线贴图进行采样
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);            
                // 将法线坐标空间重新映射为[-1,1]，并调整凹凸度
                // 凹凸度越大，法线的Z轴偏离越大
                // 贴图类型必须为Normal
                fixed3 tangentNormal = UnpackNormalWithScale(packedNormal, _BumpScale);
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            
            ENDCG
        }             
    }
    
    Fallback "Specular"
}