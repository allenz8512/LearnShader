Shader "Unity Shaders Book/Chapter 6/HalfLambert"
{
    Properties{
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader{
        Pass {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            uniform fixed4 _Diffuse;
             
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;
                // 输出裁剪空间坐标 
                o.pos = UnityObjectToClipPos(v.vertex);
                // 计算在世界坐标下的法线向量 
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag(v2f i) : SV_Target {               
                // 获取环境光
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 归一化后的像素世界坐标法线
                float3 worldNormal = normalize(i.worldNormal);
                // 归一化后的世界坐标像素方向光法线
                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                // 半兰伯特光照模型
                float halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                // 计算漫反射
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;       
                float3 color = ambient + diffuse;
                return float4(color, 1.0);
            }

            ENDCG
        }     
    }
}
