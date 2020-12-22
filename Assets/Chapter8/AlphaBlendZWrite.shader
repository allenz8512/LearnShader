Shader "Unity Shaders Book/Chapter 8/Alpha Blend Zwrite"
{
    Properties
    {
        _Color ("Main Tint", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        // Alpha Scale 只起到把Alpha值降低的作用（Alpha越接近0越透明）
        _AlphaScale("Alpha Scale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags
        {
            // 队列3000，需要透明度混合（可实现半透明）的物体使用这个队列
            "Queue"="Transparent"
            // 不受阴影投射影响
            "IgnoreProjector"="True"
            // 内置约定的分类标签，这里是不带裁剪(clip)的透明对象，和摄像机shader替换api相关
            "RenderType"="Transparent"
        }

        Pass
        {
             // 多使用一个pass，这个pass内开启深度写入
            ZWrite On
            // 颜色掩码用于屏蔽RGBA通道，0表示不输出任何颜色
            ColorMask 0 
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            // 关闭深度写入
            ZWrite Off
            // 指定透明度混合模式
            // 这里使用的混合因子表示 DstColor = SrcAlpha * SrcColor + (1 - SrcAlpha) * DstColorOld
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "Lighting.cginc"

            uniform fixed4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform fixed _AlphaScale;

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
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                return fixed4(albedo + ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
}