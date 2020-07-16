// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unity Shader Book/Chapter 7/Mask Texture 2"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_BumpSize("Bump Size", Float) = 1
		_SpecularMask("Specular Mask", 2D) = "white" {}
		_SpecularScale("Specular Scale", Float) = 1
		_Gloss("Gloss", Float) = 20
		_Specular("Specular", Color) = (0,0,0,0)

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
			#include "UnityStandardUtils.cginc"
			#include "AutoLight.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _Normal;
			uniform float4 _Normal_ST;
			uniform float _BumpSize;
			uniform float4 _Specular;
			uniform float _Gloss;
			uniform sampler2D _SpecularMask;
			uniform float4 _SpecularMask_ST;
			uniform float _SpecularScale;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
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
				float4 color8 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
				float2 uv0_MainTex = i.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 albedo11 = ( color8 * tex2D( _MainTex, uv0_MainTex ) );
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float2 uv0_Normal = float4(i.ase_texcoord1.xy,0,0).xy * _Normal_ST.xy + _Normal_ST.zw;
				float3 tangentNormal57 = UnpackScaleNormal( tex2D( _Normal, uv0_Normal ), _BumpSize );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3x3 ase_worldToTangent = float3x3(ase_worldTangent,ase_worldBitangent,ase_worldNormal);
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(WorldPosition);
				float3 normalizeResult28 = normalize( mul( ase_worldToTangent, worldSpaceLightDir ) );
				float dotResult37 = dot( tangentNormal57 , normalizeResult28 );
				float4 diffuse41 = ( albedo11 * ase_lightColor * max( 0.0 , dotResult37 ) );
				float3 worldSpaceViewDir26 = WorldSpaceViewDir( float4( 0,0,0,1 ) );
				float3 normalizeResult29 = normalize( mul( ase_worldToTangent, worldSpaceViewDir26 ) );
				float3 normalizeResult53 = normalize( ( normalizeResult28 + normalizeResult29 ) );
				float3 halfDir54 = normalizeResult53;
				float dotResult59 = dot( tangentNormal57 , halfDir54 );
				float2 uv0_SpecularMask = float4(i.ase_texcoord1.xy,0,0).xy * _SpecularMask_ST.xy + _SpecularMask_ST.zw;
				float4 specular62 = ( ase_lightColor * _Specular * pow( saturate( dotResult59 ) , _Gloss ) * ( tex2D( _SpecularMask, uv0_SpecularMask ).r * _SpecularScale ) );
				
				
				finalColor = ( ( UNITY_LIGHTMODEL_AMBIENT * albedo11 ) + diffuse41 + specular62 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18200
379;73;1148;583;1946.17;-1310.449;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;19;-1709.448,-310.9443;Inherit;False;1762.789;1157.593;;23;29;26;27;41;22;21;39;20;37;40;36;28;25;33;35;34;24;23;32;52;53;54;57;diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceViewDirHlpNode;26;-1610.03,649.0732;Inherit;False;1;0;FLOAT4;0,0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;24;-1603.123,337.0999;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldToTangentMatrix;23;-1604.274,546.1299;Inherit;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.TexturePropertyNode;32;-1655.717,-213.5547;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;False;0;False;None;3cc83a08b336096479ca18456c051d6a;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1311.567,607.111;Inherit;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1313.844,437.2909;Inherit;False;2;2;0;FLOAT3x3;0,0,0,0,0,1,1,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;29;-1150.866,607.809;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;28;-1152.669,436.497;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-1650.363,7.816469;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;13;-1707.607,-1214.899;Inherit;False;1153.773;742.6644;;6;8;11;9;6;7;4;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-919.4855,529.7415;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;33;-1353.211,-205.1886;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-1340.253,23.32163;Inherit;False;Property;_BumpSize;Bump Size;2;0;Create;True;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1637.757,-888.5614;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;False;0;False;8ac0077e545202340adee98368c005d3;708c43b43c56ff4488d10c97841325bb;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;36;-1027.044,-201.5073;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;53;-746.5223,539.2005;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-543.8308,531.0929;Inherit;False;halfDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1631.657,-645.4619;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-1089.392,95.3865;Inherit;False;tangentNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;44;-1718.462,1039.19;Inherit;False;1793.113;1039.459;;15;45;46;47;48;49;51;50;55;56;58;59;60;61;62;64;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;45;-1672.992,1259.445;Inherit;True;Property;_SpecularMask;Specular Mask;3;0;Create;True;0;0;False;0;False;None;d71328f07241fe04693c51d94587d406;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;8;-1637.527,-1099.652;Inherit;False;Constant;_Color;Color;1;0;Create;True;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-1346.057,-884.1615;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;56;-1667.127,1943.444;Inherit;False;54;halfDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-1663.725,1801.881;Inherit;False;57;tangentNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-1662.706,1498.509;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-985.5787,-959.6106;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;59;-1403.906,1814.739;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;60;-1241.921,1820.281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;37;-837.5408,312.4194;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1651.953,1662.665;Inherit;False;Property;_SpecularScale;Specular Scale;4;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-774.2227,-967.5695;Inherit;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-814.658,187.7463;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1265.441,1971.495;Inherit;False;Property;_Gloss;Gloss;5;0;Create;True;0;0;False;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;47;-1403.261,1347.166;Inherit;True;Property;_TextureSample2;Texture Sample 2;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;61;-1059.972,1839.927;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1103.098,1503.207;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;64;-1120.019,1226.244;Inherit;False;Property;_Specular;Specular;6;0;Create;True;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;50;-1124.776,1079.526;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightColorNode;21;-738.1895,-52.60577;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMaxOpNode;39;-684.5471,268.7036;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-750.6973,-175.0543;Inherit;False;11;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-791.2192,1089.434;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-454.6806,11.43817;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;17;371.9964,-580.3551;Inherit;False;972.2963;923.4709;;7;0;43;42;16;63;15;14;Output;1,1,1,1;0;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;15;396.5096,-462.7794;Inherit;False;UNITY_LIGHTMODEL_AMBIENT;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;410.8871,-335.5238;Inherit;True;11;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-208.6635,25.63022;Inherit;False;diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-591.1223,1104.97;Inherit;False;specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;655.3246,-383.7749;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;418.5813,98.0121;Inherit;True;62;specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;415.7051,-122.8997;Inherit;True;41;diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;789.9478,-196.1261;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;987.236,-196.3493;Float;False;True;-1;2;ASEMaterialInspector;100;1;Unity Shader Book/Chapter 7/Mask Texture 2;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;27;0;23;0
WireConnection;27;1;26;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;29;0;27;0
WireConnection;28;0;25;0
WireConnection;34;2;32;0
WireConnection;52;0;28;0
WireConnection;52;1;29;0
WireConnection;33;0;32;0
WireConnection;33;1;34;0
WireConnection;36;0;33;0
WireConnection;36;1;35;0
WireConnection;53;0;52;0
WireConnection;54;0;53;0
WireConnection;7;2;4;0
WireConnection;57;0;36;0
WireConnection;6;0;4;0
WireConnection;6;1;7;0
WireConnection;46;2;45;0
WireConnection;9;0;8;0
WireConnection;9;1;6;0
WireConnection;59;0;58;0
WireConnection;59;1;56;0
WireConnection;60;0;59;0
WireConnection;37;0;57;0
WireConnection;37;1;28;0
WireConnection;11;0;9;0
WireConnection;47;0;45;0
WireConnection;47;1;46;0
WireConnection;61;0;60;0
WireConnection;61;1;55;0
WireConnection;49;0;47;1
WireConnection;49;1;48;0
WireConnection;39;0;40;0
WireConnection;39;1;37;0
WireConnection;51;0;50;0
WireConnection;51;1;64;0
WireConnection;51;2;61;0
WireConnection;51;3;49;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;22;2;39;0
WireConnection;41;0;22;0
WireConnection;62;0;51;0
WireConnection;16;0;15;0
WireConnection;16;1;14;0
WireConnection;43;0;16;0
WireConnection;43;1;42;0
WireConnection;43;2;63;0
WireConnection;0;0;43;0
ASEEND*/
//CHKSM=805AAE9489222AA4465F7707EA597F4EF14803A7