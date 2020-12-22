Shader "Unity Shaders Book/Chapter 8/Alpha Test"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Cutoff("Alpha Cutoff",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            // 队列2450，需要透明度测试的物体使用这个队列
            "Queue"="AlphaTest"
            // 不受阴影投射影响
            "IgnoreProjector"="True"
            // 内置约定的分类标签，这里是带裁剪(clip)的透明对象，和摄像机shader替换api相关
            "RenderType"="TransparentCutout"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            // 关闭剔除，渲染背向摄像机的片元
            Cull Off

            CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "Lighting.cginc"

            uniform fixed4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform fixed _Cutoff;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                // 抛弃 texColor.a - _Cutoff < 0 的片元
                clip(texColor.a - _Cutoff);
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                return fixed4(albedo + ambient + diffuse, 1.0);
            }
            ENDCG
        }
    }
}