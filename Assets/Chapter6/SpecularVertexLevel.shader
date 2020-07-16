Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level"
{
    Properties {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    
    SubShader {
        Pass {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            
            uniform float4 _Diffuse;
            uniform float4 _Specular;
            uniform float _Gloss;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 color : COLOR;
            };
            
            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                float3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                float3 viewDir = normalize(WorldSpaceViewDir(v.vertex));
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)), _Gloss);
                o.color = ambient + diffuse + specular;
                return o;
            }
            
            float4 frag(v2f i) : SV_Target {
                return float4(i.color, 1.0);
            }
                      
            ENDCG
        }
    }
    
    Fallback "Legacy Shaders/Specular"
}
