// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LocalUVOcean"
{
	Properties
	{
		_WaveDir("WaveDir", Vector) = (1,0,0,0)
		_WaveSpeed("WaveSpeed", Float) = 1
		_WaveStretch("WaveStretch", Vector) = (0.23,0.01,0,0)
		_WaveTile("WaveTile", Float) = 1
		_WaveHeight("WaveHeight", Float) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.8
		_TopColor("Top Color", Color) = (0.2672659,0.8237126,0.8584906,1)
		_BottomColor("Bottom Color", Color) = (0.2055892,0.597784,0.6226415,1)
		[Normal]_NormalMap("NormalMap", 2D) = "bump" {}
		_WorldspaceTile("WorldspaceTile", Float) = 1
		_NormalPanSpeed("NormalPanSpeed", Float) = 0
		_NormalStrength("NormalStrength", Range( 0 , 1)) = 1
		_Foam("Foam", 2D) = "white" {}
		_SeaFoamTile("SeaFoamTile", Float) = 1
		_FoamNoiseTiling("FoamNoiseTiling", Float) = 0.03
		_RimPower("RimPower", Float) = 0
		_RimColor("RimColor", Color) = (0,0,0,0)
		_Distance("Distance", Float) = 0
		_Falloff("Falloff", Float) = 0
		_RotationAngle("RotationAngle", Float) = 0
		_PosOffset("PosOffset", Vector) = (0,0,0,0)
		_Cubemap("Cubemap", CUBE) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldRefl;
			INTERNAL_DATA
			float3 worldNormal;
		};

		uniform float _WaveHeight;
		uniform float _WaveSpeed;
		uniform float2 _WaveDir;
		uniform float _RotationAngle;
		uniform float2 _PosOffset;
		uniform float2 _WaveStretch;
		uniform float _WaveTile;
		uniform sampler2D _NormalMap;
		uniform float _NormalPanSpeed;
		uniform float _WorldspaceTile;
		uniform float _NormalStrength;
		uniform samplerCUBE _Cubemap;
		uniform float4 _BottomColor;
		uniform float4 _TopColor;
		uniform sampler2D _Foam;
		uniform float _SeaFoamTile;
		uniform float _FoamNoiseTiling;
		uniform float4 _RimColor;
		uniform float _RimPower;
		uniform float _Smoothness;
		uniform float _Distance;
		uniform float _Falloff;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_4_0 = ( _Time.y * _WaveSpeed );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 break143 = ase_vertex3Pos;
			float temp_output_144_0 = ( break143.z + _PosOffset.y );
			float3 appendResult145 = (float3(( break143.x + _PosOffset.x ) , temp_output_144_0 , temp_output_144_0));
			float3 rotatedValue135 = RotateAroundAxis( float3( 0,0,0 ), appendResult145, normalize( float3( 0,1,0 ) ), _RotationAngle );
			float3 break138 = rotatedValue135;
			float4 appendResult8 = (float4(break138.x , break138.z , 0.0 , 0.0));
			float4 WorldspaceUV9 = appendResult8;
			float4 WaveTileUV18 = ( ( WorldspaceUV9 * float4( _WaveStretch, 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner2 = ( temp_output_4_0 * _WaveDir + WaveTileUV18.xy);
			float simplePerlin2D1 = snoise( panner2 );
			float2 panner21 = ( temp_output_4_0 * _WaveDir + ( WaveTileUV18 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D20 = snoise( panner21 );
			float WavePattern25 = ( simplePerlin2D1 + simplePerlin2D20 );
			float3 WaveHeight29 = ( ( float3(0,1,0) * _WaveHeight ) * WavePattern25 );
			v.vertex.xyz += WaveHeight29;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 break143 = ase_vertex3Pos;
			float temp_output_144_0 = ( break143.z + _PosOffset.y );
			float3 appendResult145 = (float3(( break143.x + _PosOffset.x ) , temp_output_144_0 , temp_output_144_0));
			float3 rotatedValue135 = RotateAroundAxis( float3( 0,0,0 ), appendResult145, normalize( float3( 0,1,0 ) ), _RotationAngle );
			float3 break138 = rotatedValue135;
			float4 appendResult8 = (float4(break138.x , break138.z , 0.0 , 0.0));
			float4 WorldspaceUV9 = appendResult8;
			float4 temp_output_69_0 = ( WorldspaceUV9 / 1.0 );
			float2 panner53 = ( 1.0 * _Time.y * ( float2( 1,0 ) * _NormalPanSpeed ) + ( temp_output_69_0 * _WorldspaceTile ).xy);
			float2 panner54 = ( 1.0 * _Time.y * ( float2( -1,0 ) * ( _NormalPanSpeed * 3.0 ) ) + ( temp_output_69_0 * ( _WorldspaceTile * 5.0 ) ).xy);
			float3 Normals63 = BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, panner53 ), _NormalStrength ) , UnpackScaleNormal( tex2D( _NormalMap, panner54 ), _NormalStrength ) );
			o.Normal = Normals63;
			float4 temp_output_76_0 = ( WorldspaceUV9 / 10.0 );
			float2 panner82 = ( 1.0 * _Time.y * float2( 0.05,0.03 ) + ( temp_output_76_0 * _FoamNoiseTiling ).xy);
			float simplePerlin2D81 = snoise( panner82 );
			float clampResult92 = clamp( ( tex2D( _Foam, ( temp_output_76_0 * _SeaFoamTile ).xy ).r * simplePerlin2D81 ) , 0.0 , 1.0 );
			float SeaFoam93 = clampResult92;
			float temp_output_4_0 = ( _Time.y * _WaveSpeed );
			float4 WaveTileUV18 = ( ( WorldspaceUV9 * float4( _WaveStretch, 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner2 = ( temp_output_4_0 * _WaveDir + WaveTileUV18.xy);
			float simplePerlin2D1 = snoise( panner2 );
			float2 panner21 = ( temp_output_4_0 * _WaveDir + ( WaveTileUV18 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D20 = snoise( panner21 );
			float WavePattern25 = ( simplePerlin2D1 + simplePerlin2D20 );
			float4 lerpResult40 = lerp( _BottomColor , ( _TopColor + SeaFoam93 ) , saturate( WavePattern25 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV113 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode113 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV113, _RimPower ) );
			float4 lerpResult115 = lerp( lerpResult40 , _RimColor , fresnelNode113);
			float4 WaterColor44 = ( texCUBE( _Cubemap, normalize( WorldReflectionVector( i , Normals63 ) ) ) * lerpResult115 );
			o.Albedo = WaterColor44.rgb;
			float lerpResult134 = lerp( _Smoothness , 0.1 , pow( ( distance( ase_vertex3Pos , _WorldSpaceCameraPos ) / _Distance ) , _Falloff ));
			o.Smoothness = lerpResult134;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.worldRefl = -worldViewDir;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18912
262;843.3334;1498;564;-540.3335;-650.3257;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;34;-2516.88,-1565.775;Inherit;False;1700.588;603.6495;Comment;11;146;145;135;138;8;9;141;142;144;143;166;Worldspace UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;166;-2506.752,-1373.38;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;143;-2295.889,-1210.597;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector2Node;146;-2359.957,-1078.634;Inherit;False;Property;_PosOffset;PosOffset;20;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-2106.461,-1275.837;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;144;-2129.184,-1109.268;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;145;-1949.557,-1227.844;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-2494.476,-1496.184;Inherit;False;Property;_RotationAngle;RotationAngle;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;135;-1823.271,-1447.515;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;138;-1486.859,-1453.41;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;8;-1328.28,-1451.278;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-1058.633,-1451.61;Inherit;False;WorldspaceUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;35;-2398.199,-609.1427;Inherit;False;1163.905;386.6643;Comment;6;11;10;12;13;14;18;Wave TIle UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-2314.403,-559.1427;Inherit;False;9;WorldspaceUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;11;-2348.199,-445.4783;Inherit;False;Property;_WaveStretch;WaveStretch;2;0;Create;True;0;0;0;False;0;False;0.23,0.01;0.15,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;13;-2105.199,-337.4784;Inherit;False;Property;_WaveTile;WaveTile;3;0;Create;True;0;0;0;False;0;False;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2030.199,-497.4783;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;94;-3231.813,2220.731;Inherit;False;1993.014;969.5964;Comment;14;92;91;81;88;76;78;73;86;82;71;79;74;93;111;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-3094.693,2669.7;Inherit;False;Constant;_Float1;Float 1;14;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-3181.813,2528.385;Inherit;False;9;WorldspaceUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1793.199,-455.4783;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-1462.294,-391.8889;Inherit;False;WaveTileUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;36;-2532.986,-64.67358;Inherit;False;1893.358;1029.353;Comment;13;22;3;6;19;4;5;23;2;21;1;20;24;25;Wave Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;65;-3437.385,1095.528;Inherit;False;3640.344;1054.1;Comment;21;63;61;37;46;53;45;62;54;49;52;59;57;69;56;55;60;51;50;48;58;70;Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;76;-2864.844,2554.336;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-2848.871,3064.073;Inherit;False;Property;_FoamNoiseTiling;FoamNoiseTiling;14;0;Create;True;0;0;0;False;0;False;0.03;0.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2042.279,399.0461;Inherit;False;Property;_WaveSpeed;WaveSpeed;1;0;Create;True;0;0;0;False;0;False;1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-3174.892,1505.09;Inherit;False;Property;_WorldspaceTile;WorldspaceTile;9;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-2942.697,2861.941;Inherit;False;Property;_SeaFoamTile;SeaFoamTile;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-2579.385,2976.865;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-3359.762,1382.845;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2162.395,1576.737;Inherit;False;Property;_NormalPanSpeed;NormalPanSpeed;10;0;Create;True;0;0;0;False;0;False;0;0.0075;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-2270.396,610.6358;Inherit;False;18;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-3409.204,1258.984;Inherit;False;9;WorldspaceUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-2022.227,311.9321;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;71;-2857.429,2270.731;Inherit;True;Property;_Foam;Foam;12;0;Create;True;0;0;0;False;0;False;c5879f804853b9140ada27308d8f7816;c5879f804853b9140ada27308d8f7816;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleDivideOpNode;69;-3140.075,1201.969;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;2;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2862.569,1711.483;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;56;-2280.364,1831.215;Inherit;False;Constant;_NormalPanDir2;NormalPanDir2;12;0;Create;True;0;0;0;False;0;False;-1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;55;-2160.709,1271.7;Inherit;False;Constant;_NormalPanDir;NormalPanDir;11;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2012.404,1768.859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;5;-2482.986,276.9385;Inherit;False;Property;_WaveDir;WaveDir;0;0;Create;True;0;0;0;False;0;False;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1742.851,367.0313;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-2061.489,-14.67358;Inherit;False;18;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;82;-2331.001,3034.328;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.05,0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2586.8,2561.75;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1974.435,703.517;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.1,0.1,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1896.119,1859.865;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;111;-2400.011,2388.946;Inherit;True;Property;_TextureSample24;Texture Sample 24;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-2575.027,1664.161;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;2;-1715.425,121.338;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-2744.426,1198.086;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;21;-1726.821,711.0918;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;81;-1932.781,2812.609;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1926.454,1266.644;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;45;-2448.528,1418.889;Inherit;True;Property;_NormalMap;NormalMap;8;1;[Normal];Create;True;0;0;0;False;0;False;caecb7663e614c0e8d1cf595085ee759;caecb7663e614c0e8d1cf595085ee759;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;62;-1746.129,1529.549;Inherit;False;Property;_NormalStrength;NormalStrength;11;0;Create;True;0;0;0;False;0;False;1;0.35;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;54;-1693.885,1745.265;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;20;-1419.251,706.6798;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-1846.799,2475.985;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;53;-1736.017,1199.233;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-1407.856,116.926;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;46;-1343.969,1802.864;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;1;[Normal];Create;True;0;0;0;False;0;False;45;65ad2866d920b0a489948a1717fb33c6;65ad2866d920b0a489948a1717fb33c6;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-1149.523,465.8035;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;92;-1677.2,2487.185;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-1353.066,1365.121;Inherit;True;Property;_Normal;Normal;7;1;[Normal];Create;True;0;0;0;False;0;False;45;65ad2866d920b0a489948a1717fb33c6;65ad2866d920b0a489948a1717fb33c6;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;43;-56.17201,-978.0858;Inherit;False;1821.067;953.5989;;16;154;44;120;115;113;40;116;95;39;114;97;96;38;41;150;157;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-1466.799,2496.785;Inherit;False;SeaFoam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;61;-957.4158,1460.452;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-867.6278,515.5975;Inherit;False;WavePattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;-15.05742,-597.976;Inherit;False;Property;_TopColor;Top Color;6;0;Create;True;0;0;0;False;0;False;0.2672659,0.8237126,0.8584906,1;0.03137254,0.1678032,0.1882353,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;96;4.297199,-381.4941;Inherit;False;93;SeaFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-70.68701,1465.01;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;192.5648,-171.0061;Inherit;False;25;WavePattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-11.76493,-931.8678;Inherit;False;63;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;114;480.458,-148.6003;Inherit;False;Property;_RimPower;RimPower;15;0;Create;True;0;0;0;False;0;False;0;18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;284.6582,-574.9594;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;97;376.3511,-300.2604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-17.3809,-768.5265;Inherit;False;Property;_BottomColor;Bottom Color;7;0;Create;True;0;0;0;False;0;False;0.2055892,0.597784,0.6226415,1;0.03025988,0.07861945,0.1886792,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;33;-964.3119,-935.9824;Inherit;False;800.3966;413.5448;Comment;6;16;28;27;26;17;29;Wave Height;1,1,1,1;0;0
Node;AmplifyShaderEditor.FresnelNode;113;673.087,-344.1325;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;116;624.046,-559.1401;Inherit;False;Property;_RimColor;RimColor;16;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0.8018868,0.608661,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;16;-903.9758,-885.9824;Inherit;False;Constant;_WaveUp;WaveUp;5;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldReflectionVector;150;187.5291,-923.6532;Inherit;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;40;553.3595,-715.3344;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-914.3119,-732.0823;Inherit;False;Property;_WaveHeight;WaveHeight;4;0;Create;True;0;0;0;False;0;False;1;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;123;-465.4415,854.8391;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;174;-318.4731,613.334;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;-846.8308,-637.4376;Inherit;False;25;WavePattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-732.1123,-822.0574;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceOpNode;125;-160.6664,805.3246;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;115;1003.24,-553.0731;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;154;1044.917,-813.2606;Inherit;True;Property;_Cubemap;Cubemap;21;0;Create;True;0;0;0;False;0;False;-1;None;30cbf4b08bdf6ad4588882bec867e53c;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;127;-120.0763,909.3412;Inherit;False;Property;_Distance;Distance;17;0;Create;True;0;0;0;False;0;False;0;528.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;239.9264,911.9364;Inherit;False;Property;_Falloff;Falloff;18;0;Create;True;0;0;0;False;0;False;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-555.5099,-766.1324;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;144.7806,815.9183;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;1347.794,-705.0767;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;32;176.3214,513.707;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-391.9153,-713.4463;Inherit;False;WaveHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;1554.349,-666.9299;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;128;392.7613,777.3604;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;1233.048,854.2411;Inherit;False;93;SeaFoam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;163;-2728.131,-1431.305;Inherit;True;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;134;1037.002,518.9386;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;1012.263,347.4467;Inherit;False;44;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;1030.337,438.0536;Inherit;False;63;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;937.1655,881.7146;Inherit;False;9;WorldspaceUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;7;-2679.624,-1155.286;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;30;1033.349,688.6589;Inherit;False;29;WaveHeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;124;-476.5849,697.8415;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;139;913.4305,788.8668;Inherit;False;44;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;1064.886,945.943;Inherit;False;25;WavePattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1238.955,411.0253;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;LocalUVOcean;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;143;0;166;0
WireConnection;142;0;143;0
WireConnection;142;1;146;1
WireConnection;144;0;143;2
WireConnection;144;1;146;2
WireConnection;145;0;142;0
WireConnection;145;1;144;0
WireConnection;145;2;144;0
WireConnection;135;1;141;0
WireConnection;135;3;145;0
WireConnection;138;0;135;0
WireConnection;8;0;138;0
WireConnection;8;1;138;2
WireConnection;9;0;8;0
WireConnection;12;0;10;0
WireConnection;12;1;11;0
WireConnection;14;0;12;0
WireConnection;14;1;13;0
WireConnection;18;0;14;0
WireConnection;76;0;73;0
WireConnection;76;1;78;0
WireConnection;86;0;76;0
WireConnection;86;1;88;0
WireConnection;69;0;48;0
WireConnection;69;1;70;0
WireConnection;51;0;50;0
WireConnection;60;0;58;0
WireConnection;4;0;3;0
WireConnection;4;1;6;0
WireConnection;82;0;86;0
WireConnection;74;0;76;0
WireConnection;74;1;79;0
WireConnection;23;0;22;0
WireConnection;59;0;56;0
WireConnection;59;1;60;0
WireConnection;111;0;71;0
WireConnection;111;1;74;0
WireConnection;52;0;69;0
WireConnection;52;1;51;0
WireConnection;2;0;19;0
WireConnection;2;2;5;0
WireConnection;2;1;4;0
WireConnection;49;0;69;0
WireConnection;49;1;50;0
WireConnection;21;0;23;0
WireConnection;21;2;5;0
WireConnection;21;1;4;0
WireConnection;81;0;82;0
WireConnection;57;0;55;0
WireConnection;57;1;58;0
WireConnection;54;0;52;0
WireConnection;54;2;59;0
WireConnection;20;0;21;0
WireConnection;91;0;111;1
WireConnection;91;1;81;0
WireConnection;53;0;49;0
WireConnection;53;2;57;0
WireConnection;1;0;2;0
WireConnection;46;0;45;0
WireConnection;46;1;54;0
WireConnection;46;5;62;0
WireConnection;24;0;1;0
WireConnection;24;1;20;0
WireConnection;92;0;91;0
WireConnection;37;0;45;0
WireConnection;37;1;53;0
WireConnection;37;5;62;0
WireConnection;93;0;92;0
WireConnection;61;0;37;0
WireConnection;61;1;46;0
WireConnection;25;0;24;0
WireConnection;63;0;61;0
WireConnection;95;0;38;0
WireConnection;95;1;96;0
WireConnection;97;0;41;0
WireConnection;113;3;114;0
WireConnection;150;0;157;0
WireConnection;40;0;39;0
WireConnection;40;1;95;0
WireConnection;40;2;97;0
WireConnection;27;0;16;0
WireConnection;27;1;28;0
WireConnection;125;0;174;0
WireConnection;125;1;123;0
WireConnection;115;0;40;0
WireConnection;115;1;116;0
WireConnection;115;2;113;0
WireConnection;154;1;150;0
WireConnection;17;0;27;0
WireConnection;17;1;26;0
WireConnection;126;0;125;0
WireConnection;126;1;127;0
WireConnection;120;0;154;0
WireConnection;120;1;115;0
WireConnection;29;0;17;0
WireConnection;44;0;120;0
WireConnection;128;0;126;0
WireConnection;128;1;129;0
WireConnection;134;0;32;0
WireConnection;134;2;128;0
WireConnection;0;0;31;0
WireConnection;0;1;64;0
WireConnection;0;4;134;0
WireConnection;0;11;30;0
ASEEND*/
//CHKSM=D36E43C01218EEFBCF9F80BDE37B6E813FCF6781