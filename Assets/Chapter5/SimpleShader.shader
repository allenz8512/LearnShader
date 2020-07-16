// 定义Shader分类（类似目录url用'/'分隔）和名称
Shader "Unity Shaders Book/Chapter 5/Simple Shader" {
    // 定义Shader属性
    Properties {
        // 定义一个显示名称为“Color Tint”类型为颜色（fixed4）的属性
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    // 针对显卡A的SubShader，
    SubShader {
        // first pass
        Pass {
            // 设置渲染状态和标签，此处无
            
            // cg代码
            CGPROGRAM
            
            // 引入其它文件，定义编译指令，“UnityCG.cginc”会被自动引入，此句可以忽略
            #include "UnityCG.cginc"
            // 定义顶点着色器函数
            #pragma vertex vert
            // 定义片元着色器函数
            #pragma fragment frag 
            
            // 引入Properties中定义的_Color变量
            uniform fixed4 _Color;
            
            // 定义顶点着色器输入结构体，可直接使用内置的：
            // appdata_base：    顶点位置，顶点法线，第一组纹理坐标
            // appdata_tan：     顶点位置，顶点法线，顶点切线，第一组纹理坐标
            // appdata_full：    顶点位置，顶点法线，顶点切线，四组纹理坐标，顶点颜色
            // appdata_img：     顶点位置，第一组纹理坐标
            struct a2v {
                // POSITION语义：模型顶点坐标，float4
                float4 vertex: POSITION;
                // NORMAL语义：模型空间法线向量，float3
                float3 normal: NORMAL;
                // TEXCOORD语义：模型的第一套纹理坐标，float2
                float4 texcoord: TEXCOORD;
            };
            
            // 定义顶点着色器输出结构体，可直接使用内置的：
            // v2f_img：     裁剪空间位置，纹理坐标
            struct v2f {
                // SV_POSITION语义：裁剪空间中的位置，float4
                float4 pos : SV_POSITION;
                // 传递一个颜色到片元着色器，fixed3
                fixed3 color : COLOR0;
            };

            // 顶点着色器函数
            v2f vert(a2v v) {
                // 声明顶点着色器输出
                v2f o;
                // 内置宏将顶点坐标转换为裁剪空间坐标
                o.pos = UnityObjectToClipPos(v.vertex);
                // 将范围在[-1.0,1.0]的法线向量映射为[0,1]的颜色
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            // 片元着色器函数，输出在裁剪空间，使用SV_TARGET语义，fixed4
            fixed4 frag(v2f i) : SV_TARGET {
                fixed3 c = i.color;
                // 颜色和"Color Tint"的颜色进行混合
                c *= _Color.rgb;
                // 输出在该裁剪空间坐标的颜色，
                return fixed4(c, 1.0);
            }

            ENDCG
        }
    }
}