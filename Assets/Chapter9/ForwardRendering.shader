// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Unity Shaders Book/Chapter 9/Forward Rendering"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            Tags
            {
                "RenderType" = "ForwardBase"
            }

            CGPROGRAM
#pragma multi_compile_fwdbase
#pragma vertex vert
#pragma fragment frag

#include "Lighting.cginc"

            uniform fixed4 _Diffuse;
            uniform fixed4 _Specular;
            uniform float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                // 衰减值，因为平行光不存在衰减，所以固定为1.0
                fixed atten = 1.0;

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardAdd"
            }

            Blend One One

            CGPROGRAM
#pragma multi_compile_fwdadd
#pragma vertex vert
#pragma fragment frag

#include "Lighting.cginc"
#include "AutoLight.cginc"

            uniform fixed4 _Diffuse;
            uniform fixed4 _Specular;
            uniform float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;

                // SHADOW_COORDS(3)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                // 如果这个Pass的光源是平行光，Unity会定义USING_DIRECTIONAL_LIGHT宏
#ifdef USING_DIRECTIONAL_LIGHT
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
#else
                // 不是平行光，光源的方向为光源坐标减去该点坐标
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
#endif
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                // 使用内置宏计算不同种类的光源衰减值
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                // 大致原理如下，首先用unity_WorldToLight转置矩阵获取该片元在光源空间的坐标
                // 然后对光照衰减纹理_LightTexture0进行采样，并获取衰减值
                // #ifdef USING_DIRECTIONAL_LIGHT
                //                     fixed atten = 1.0;
                // #else
                // #if defined (POINT)
                //                 float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                //                 fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                // #elif defined (SPOT)
                //                 float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
                // 				fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                // #else
                //                 fixed atten = 1.0;
                // #endif
                // #endif

                return fixed4((diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
    }
}