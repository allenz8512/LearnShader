// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unity Shaders Book/Chapter 9/Forward Rendering 2"
{
	Properties
	{
		_Specular("Specular", Color) = (1,1,1,1)
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Gloss("Gloss", Range( 8 , 256)) = 20

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
#endif
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform float4 _Diffuse;
			uniform float4 _Specular;
			uniform float _Gloss;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_normal = v.ase_normal;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
#endif
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float3 normalizeResult44 = normalize( mul( unity_ObjectToWorld, float4( i.ase_normal , 0.0 ) ).xyz );
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(WorldPosition);
				float3 normalizeResult41 = normalize( worldSpaceLightDir );
				float dotResult23 = dot( normalizeResult44 , normalizeResult41 );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizeResult42 = normalize( ase_worldViewDir );
				float3 normalizeResult43 = normalize( ( normalizeResult41 + normalizeResult42 ) );
				float dotResult51 = dot( normalizeResult44 , normalizeResult43 );
				float4 appendResult16 = (float4(( (UNITY_LIGHTMODEL_AMBIENT).rgb + ( ( ( ase_lightColor.rgb * (_Diffuse).rgb * max( 0.0 , dotResult23 ) ) + ( ase_lightColor.rgb * (_Specular).rgb * pow( max( 0.0 , dotResult51 ) , _Gloss ) ) ) * 1.0 ) ) , 1.0));
				
				
				finalColor = appendResult16;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18200
528;297;1018;546;1092.983;-276.1374;1.6;True;False
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;24;-986.7555,324.8679;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;39;-974.3473,515.9962;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;25;-933.0869,156.301;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;27;-926.5414,69.51869;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.NormalizeNode;41;-740.7968,349.9497;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;42;-740.2968,517.9501;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-734.1414,142.3188;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-576.8168,471.6956;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;44;-547.5957,206.1501;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;43;-430.575,500.5287;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;51;-129.9106,621.0967;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-133.0943,523.9926;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;23;-328.7853,222.7572;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-794.545,667.6218;Inherit;False;Property;_Specular;Specular;0;0;Create;True;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-617.8875,-111.5508;Inherit;False;Property;_Diffuse;Diffuse;1;0;Create;True;0;0;False;0;False;1,1,1,1;0.3207547,0.3131897,0.3131897,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;49;14.95075,565.3807;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;98.02406,748.4878;Inherit;False;Property;_Gloss;Gloss;2;0;Create;True;0;0;False;0;False;20;50;8;256;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-338.4109,93.75108;Inherit;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;21;-398.1341,-97.00187;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;36;-160.186,173.8397;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;10;-391.5142,-275.8259;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;47;215.7572,544.8043;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;46;-503.4856,670.0893;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-157.4682,-155.2423;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;107.329,259.4213;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;164.5686,-84.34532;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;6;-399.6273,-513.7219;Inherit;False;UNITY_LIGHTMODEL_AMBIENT;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;362.691,66.15747;Inherit;False;Constant;_atten;atten;3;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;321.2225,-162.9177;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;15;3.075546,-380.1249;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;18;558.4002,-208.2895;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;237.5193,-394.9595;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;468.8374,-427.9921;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;713.9276,-352.4286;Float;False;True;-1;2;ASEMaterialInspector;100;1;Unity Shaders Book/Chapter 9/Forward Rendering 2;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;41;0;24;0
WireConnection;42;0;39;0
WireConnection;28;0;27;0
WireConnection;28;1;25;0
WireConnection;40;0;41;0
WireConnection;40;1;42;0
WireConnection;44;0;28;0
WireConnection;43;0;40;0
WireConnection;51;0;44;0
WireConnection;51;1;43;0
WireConnection;23;0;44;0
WireConnection;23;1;41;0
WireConnection;49;0;50;0
WireConnection;49;1;51;0
WireConnection;21;0;2;0
WireConnection;36;0;37;0
WireConnection;36;1;23;0
WireConnection;47;0;49;0
WireConnection;47;1;3;0
WireConnection;46;0;1;0
WireConnection;20;0;10;1
WireConnection;20;1;21;0
WireConnection;20;2;36;0
WireConnection;45;0;10;1
WireConnection;45;1;46;0
WireConnection;45;2;47;0
WireConnection;9;0;20;0
WireConnection;9;1;45;0
WireConnection;8;0;9;0
WireConnection;8;1;5;0
WireConnection;15;0;6;0
WireConnection;19;0;15;0
WireConnection;19;1;8;0
WireConnection;16;0;19;0
WireConnection;16;3;18;0
WireConnection;0;0;16;0
ASEEND*/
//CHKSM=41CA57F2F2E16C4342C48F919B1D853F5E8FD061