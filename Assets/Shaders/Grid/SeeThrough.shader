Shader "Holobots/SeeThrough"
{
    Properties
    {
        [NoScaleOffset]Texture2D_15b08835f3194b2b92c6de129bbbbdca("MainTexture", 2D) = "white" {}
        Color_07f87ef2f0fc4aa5a5c74ced73031173("Tint", Color) = (1, 1, 1, 0)
        _PlayerPos("PlayerPosition", Vector) = (0.5, 0.5, 0, 0)
        _Size("Size", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Opacity("Opacity", Range(0, 1)) = 0.5
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_15b08835f3194b2b92c6de129bbbbdca_TexelSize;
        float4 Color_07f87ef2f0fc4aa5a5c74ced73031173;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_15b08835f3194b2b92c6de129bbbbdca);
        SAMPLER(samplerTexture2D_15b08835f3194b2b92c6de129bbbbdca);

            // Graph Functions
            
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_cf428a8029094a839939f82819b5dcea_Out_0 = _Smoothness;
            float4 _ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_23c282c92231462c9f7706de01322797_Out_0 = _PlayerPos;
            float2 _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3;
            Unity_Remap_float2(_Property_23c282c92231462c9f7706de01322797_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3);
            float2 _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2;
            Unity_Add_float2((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), _Remap_6e5553b818dd4f6a8bdfcd8fc468f71a_Out_3, _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2);
            float2 _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_8bedb3fcb24d4662be2231e054b0414c_Out_0.xy), float2 (1, 1), _Add_c9496b41953b4087ba3408c8beaa7c11_Out_2, _TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3);
            float2 _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2;
            Unity_Multiply_float(_TilingAndOffset_0956f3ba03df41879a80c6bcdbae3e98_Out_3, float2(2, 2), _Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2);
            float2 _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2;
            Unity_Subtract_float2(_Multiply_2b57ac75a387440da4d0a7800b5d744c_Out_2, float2(1, 1), _Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2);
            float _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_a53583573e5b429581a52ce93f2bc90b_Out_2);
            float _Property_6cbec061250541659f14adbc7a1c1aed_Out_0 = _Size;
            float _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2;
            Unity_Multiply_float(_Divide_a53583573e5b429581a52ce93f2bc90b_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0, _Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2);
            float2 _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0 = float2(_Multiply_32c8728d17254534a4db4c33cfd450c6_Out_2, _Property_6cbec061250541659f14adbc7a1c1aed_Out_0);
            float2 _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2;
            Unity_Divide_float2(_Subtract_d5a1c7192ac4444bb82aba77945c1944_Out_2, _Vector2_c9dd211916fd4a8ab81d110c81165d8d_Out_0, _Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2);
            float _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1;
            Unity_Length_float2(_Divide_a76c6a30dfec4335a4b356efb8f740ef_Out_2, _Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1);
            float _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1;
            Unity_OneMinus_float(_Length_fc8522bf7c034d248b5ea9521ae3b0d1_Out_1, _OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1);
            float _Saturate_bb059c5becf04c38886141ff551691d3_Out_1;
            Unity_Saturate_float(_OneMinus_f2ab511c659544c7afb21ae94744cd55_Out_1, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1);
            float _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3;
            Unity_Smoothstep_float(0, _Property_cf428a8029094a839939f82819b5dcea_Out_0, _Saturate_bb059c5becf04c38886141ff551691d3_Out_1, _Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3);
            float _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2);
            float _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2;
            Unity_Multiply_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _GradientNoise_4d0e1bafb34343debc46f6fa1bd56230_Out_2, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2);
            float _Add_f7c0a62afee04a59a045abe459981eb4_Out_2;
            Unity_Add_float(_Smoothstep_3918d345ebde40889e6115a6ff981567_Out_3, _Multiply_fe1ebc94c6a847628016c4c8159270bb_Out_2, _Add_f7c0a62afee04a59a045abe459981eb4_Out_2);
            float _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0 = _Opacity;
            float _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2;
            Unity_Multiply_float(_Add_f7c0a62afee04a59a045abe459981eb4_Out_2, _Property_7157fb12c0ea43caa2a83a4247da6462_Out_0, _Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2);
            float _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3;
            Unity_Clamp_float(_Multiply_3ef20a8a11ac495aa108c6d73c296d00_Out_2, 0, 1, _Clamp_898653decacd4fbeb65cfc00fff36435_Out_3);
            float _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            Unity_OneMinus_float(_Clamp_898653decacd4fbeb65cfc00fff36435_Out_3, _OneMinus_92d16580349040ca986f28035ef89183_Out_1);
            surface.BaseColor = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
            surface.Alpha = _OneMinus_92d16580349040ca986f28035ef89183_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}