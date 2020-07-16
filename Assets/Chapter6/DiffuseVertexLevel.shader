// 漫反射逐顶点光照
Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex-Level" {
    Properties{
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader{
        Pass {
            // 使用前向渲染的ForwardBase路径，该pass会计算环境光、最重要的平行光、逐顶点/SH光源和Lightmaps
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            // 引入内置光照定义
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            uniform fixed4 _Diffuse;
             
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 color : COLOR;
            };

            v2f vert(a2v v) {
                // 标准光照模型分为emissive（自发光）、specular（高光反射）、diffuse（漫反射）、ambient（环境光）四部分
                v2f o;
                // 输出裁剪空间坐标 
                o.pos = UnityObjectToClipPos(v.vertex);
                // 获取环境光
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 计算在世界坐标下的法线向量 
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                //fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                // 获取世界坐标下光照向量，_WorldSpaceLightPos0为光源方向内置变量，这里假设只有一个环境光（方向光）
                float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                // 计算漫反射，_LightColor0为光源颜色内置变量，这里使用兰伯特定律公式计算
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                // 输出颜色
                o.color = ambient + diffuse;
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                return float4(i.color, 1.0);
            }

            ENDCG
        }      
    }
    
    // 容错回退
    Fallback "Legacy Shaders/Diffuse"
}