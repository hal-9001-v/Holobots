Shader "Holobots/TronShader"
{
    Properties
    {
        [NoScaleOffset]Texture2D_d07fb8e8e4104d889a9cf0898523773d("Main Texture", 2D) = "white" {}
        [HDR]Color_091b4394a16f41e1a48ad9eb8cb374d3("Color", Color) = (1, 1, 1, 0)
        Color_32218e8c38954aa6be5adaa63d39cf2d("Emmision", Color) = (0.5188679, 0.08059166, 0, 0)
        Color_2("Inverse Emmision", Color) = (0.1603774, 0, 0, 0)
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_InvertColors_float4(float4 In, float4 InvertColors, out float4 Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

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
            UnityTexture2D _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
            float4 _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.tex, _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_R_4 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.r;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_G_5 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.g;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_B_6 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.b;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_A_7 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.a;
            float4 _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_091b4394a16f41e1a48ad9eb8cb374d3) : Color_091b4394a16f41e1a48ad9eb8cb374d3;
            float4 _Multiply_6451aa0d30bc417397e172a99026de27_Out_2;
            Unity_Multiply_float(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0, _Multiply_6451aa0d30bc417397e172a99026de27_Out_2);
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1;
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors = float4 (1
        , 1, 1, 0);    Unity_InvertColors_float4(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors, _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1);
            float4 Color_5d714827fe5f415ba806c0f4b70cd8dc = IsGammaSpace() ? LinearToSRGB(float4(0, 0, 0, 0)) : float4(0, 0, 0, 0);
            float4 _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, Color_5d714827fe5f415ba806c0f4b70cd8dc, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2);
            float4 _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2;
            Unity_Add_float4(_Multiply_6451aa0d30bc417397e172a99026de27_Out_2, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2, _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2);
            float4 _Property_7eec451867ba4d4c826b4839edbca6bb_Out_0 = Color_32218e8c38954aa6be5adaa63d39cf2d;
            float4 _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2;
            Unity_Multiply_float(_Property_7eec451867ba4d4c826b4839edbca6bb_Out_0, _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2);
            float4 _Property_bce552006e73433792835193f6611d81_Out_0 = Color_2;
            float4 _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, _Property_bce552006e73433792835193f6611d81_Out_0, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2);
            float4 _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2;
            Unity_Add_float4(_Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2, _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2);
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.BaseColor = (_Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_InvertColors_float4(float4 In, float4 InvertColors, out float4 Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

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
            UnityTexture2D _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
            float4 _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.tex, _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_R_4 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.r;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_G_5 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.g;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_B_6 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.b;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_A_7 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.a;
            float4 _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_091b4394a16f41e1a48ad9eb8cb374d3) : Color_091b4394a16f41e1a48ad9eb8cb374d3;
            float4 _Multiply_6451aa0d30bc417397e172a99026de27_Out_2;
            Unity_Multiply_float(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0, _Multiply_6451aa0d30bc417397e172a99026de27_Out_2);
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1;
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors = float4 (1
        , 1, 1, 0);    Unity_InvertColors_float4(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors, _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1);
            float4 Color_5d714827fe5f415ba806c0f4b70cd8dc = IsGammaSpace() ? LinearToSRGB(float4(0, 0, 0, 0)) : float4(0, 0, 0, 0);
            float4 _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, Color_5d714827fe5f415ba806c0f4b70cd8dc, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2);
            float4 _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2;
            Unity_Add_float4(_Multiply_6451aa0d30bc417397e172a99026de27_Out_2, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2, _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2);
            float4 _Property_7eec451867ba4d4c826b4839edbca6bb_Out_0 = Color_32218e8c38954aa6be5adaa63d39cf2d;
            float4 _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2;
            Unity_Multiply_float(_Property_7eec451867ba4d4c826b4839edbca6bb_Out_0, _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2);
            float4 _Property_bce552006e73433792835193f6611d81_Out_0 = Color_2;
            float4 _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, _Property_bce552006e73433792835193f6611d81_Out_0, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2);
            float4 _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2;
            Unity_Add_float4(_Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2, _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2);
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.BaseColor = (_Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

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
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

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
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

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
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_InvertColors_float4(float4 In, float4 InvertColors, out float4 Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

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
            UnityTexture2D _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
            float4 _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.tex, _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_R_4 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.r;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_G_5 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.g;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_B_6 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.b;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_A_7 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.a;
            float4 _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_091b4394a16f41e1a48ad9eb8cb374d3) : Color_091b4394a16f41e1a48ad9eb8cb374d3;
            float4 _Multiply_6451aa0d30bc417397e172a99026de27_Out_2;
            Unity_Multiply_float(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0, _Multiply_6451aa0d30bc417397e172a99026de27_Out_2);
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1;
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors = float4 (1
        , 1, 1, 0);    Unity_InvertColors_float4(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors, _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1);
            float4 Color_5d714827fe5f415ba806c0f4b70cd8dc = IsGammaSpace() ? LinearToSRGB(float4(0, 0, 0, 0)) : float4(0, 0, 0, 0);
            float4 _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, Color_5d714827fe5f415ba806c0f4b70cd8dc, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2);
            float4 _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2;
            Unity_Add_float4(_Multiply_6451aa0d30bc417397e172a99026de27_Out_2, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2, _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2);
            float4 _Property_7eec451867ba4d4c826b4839edbca6bb_Out_0 = Color_32218e8c38954aa6be5adaa63d39cf2d;
            float4 _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2;
            Unity_Multiply_float(_Property_7eec451867ba4d4c826b4839edbca6bb_Out_0, _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2);
            float4 _Property_bce552006e73433792835193f6611d81_Out_0 = Color_2;
            float4 _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, _Property_bce552006e73433792835193f6611d81_Out_0, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2);
            float4 _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2;
            Unity_Add_float4(_Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2, _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2);
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.BaseColor = (_Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2.xyz);
            surface.Emission = (_Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2.xyz);
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_InvertColors_float4(float4 In, float4 InvertColors, out float4 Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

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
            UnityTexture2D _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
            float4 _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.tex, _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_R_4 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.r;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_G_5 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.g;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_B_6 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.b;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_A_7 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.a;
            float4 _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_091b4394a16f41e1a48ad9eb8cb374d3) : Color_091b4394a16f41e1a48ad9eb8cb374d3;
            float4 _Multiply_6451aa0d30bc417397e172a99026de27_Out_2;
            Unity_Multiply_float(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0, _Multiply_6451aa0d30bc417397e172a99026de27_Out_2);
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1;
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors = float4 (1
        , 1, 1, 0);    Unity_InvertColors_float4(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors, _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1);
            float4 Color_5d714827fe5f415ba806c0f4b70cd8dc = IsGammaSpace() ? LinearToSRGB(float4(0, 0, 0, 0)) : float4(0, 0, 0, 0);
            float4 _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, Color_5d714827fe5f415ba806c0f4b70cd8dc, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2);
            float4 _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2;
            Unity_Add_float4(_Multiply_6451aa0d30bc417397e172a99026de27_Out_2, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2, _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2);
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.BaseColor = (_Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2.xyz);
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_InvertColors_float4(float4 In, float4 InvertColors, out float4 Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

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
            UnityTexture2D _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
            float4 _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.tex, _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_R_4 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.r;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_G_5 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.g;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_B_6 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.b;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_A_7 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.a;
            float4 _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_091b4394a16f41e1a48ad9eb8cb374d3) : Color_091b4394a16f41e1a48ad9eb8cb374d3;
            float4 _Multiply_6451aa0d30bc417397e172a99026de27_Out_2;
            Unity_Multiply_float(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0, _Multiply_6451aa0d30bc417397e172a99026de27_Out_2);
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1;
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors = float4 (1
        , 1, 1, 0);    Unity_InvertColors_float4(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors, _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1);
            float4 Color_5d714827fe5f415ba806c0f4b70cd8dc = IsGammaSpace() ? LinearToSRGB(float4(0, 0, 0, 0)) : float4(0, 0, 0, 0);
            float4 _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, Color_5d714827fe5f415ba806c0f4b70cd8dc, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2);
            float4 _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2;
            Unity_Add_float4(_Multiply_6451aa0d30bc417397e172a99026de27_Out_2, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2, _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2);
            float4 _Property_7eec451867ba4d4c826b4839edbca6bb_Out_0 = Color_32218e8c38954aa6be5adaa63d39cf2d;
            float4 _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2;
            Unity_Multiply_float(_Property_7eec451867ba4d4c826b4839edbca6bb_Out_0, _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2);
            float4 _Property_bce552006e73433792835193f6611d81_Out_0 = Color_2;
            float4 _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, _Property_bce552006e73433792835193f6611d81_Out_0, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2);
            float4 _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2;
            Unity_Add_float4(_Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2, _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2);
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.BaseColor = (_Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

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
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

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
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

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
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_InvertColors_float4(float4 In, float4 InvertColors, out float4 Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

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
            UnityTexture2D _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
            float4 _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.tex, _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_R_4 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.r;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_G_5 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.g;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_B_6 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.b;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_A_7 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.a;
            float4 _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_091b4394a16f41e1a48ad9eb8cb374d3) : Color_091b4394a16f41e1a48ad9eb8cb374d3;
            float4 _Multiply_6451aa0d30bc417397e172a99026de27_Out_2;
            Unity_Multiply_float(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0, _Multiply_6451aa0d30bc417397e172a99026de27_Out_2);
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1;
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors = float4 (1
        , 1, 1, 0);    Unity_InvertColors_float4(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors, _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1);
            float4 Color_5d714827fe5f415ba806c0f4b70cd8dc = IsGammaSpace() ? LinearToSRGB(float4(0, 0, 0, 0)) : float4(0, 0, 0, 0);
            float4 _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, Color_5d714827fe5f415ba806c0f4b70cd8dc, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2);
            float4 _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2;
            Unity_Add_float4(_Multiply_6451aa0d30bc417397e172a99026de27_Out_2, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2, _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2);
            float4 _Property_7eec451867ba4d4c826b4839edbca6bb_Out_0 = Color_32218e8c38954aa6be5adaa63d39cf2d;
            float4 _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2;
            Unity_Multiply_float(_Property_7eec451867ba4d4c826b4839edbca6bb_Out_0, _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2);
            float4 _Property_bce552006e73433792835193f6611d81_Out_0 = Color_2;
            float4 _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, _Property_bce552006e73433792835193f6611d81_Out_0, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2);
            float4 _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2;
            Unity_Add_float4(_Multiply_6b2330d46911472baa04b2b1b4a6dc76_Out_2, _Multiply_8105d413d3aa44a18e079cb03b4b5620_Out_2, _Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2);
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.BaseColor = (_Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2.xyz);
            surface.Emission = (_Add_365f1c955cbd4d398a8a531b20e58e3f_Out_2.xyz);
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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
        float4 Texture2D_d07fb8e8e4104d889a9cf0898523773d_TexelSize;
        float4 Color_091b4394a16f41e1a48ad9eb8cb374d3;
        float4 Color_32218e8c38954aa6be5adaa63d39cf2d;
        float4 Color_2;
        float2 _PlayerPos;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
        SAMPLER(samplerTexture2D_d07fb8e8e4104d889a9cf0898523773d);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_InvertColors_float4(float4 In, float4 InvertColors, out float4 Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

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
            UnityTexture2D _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_d07fb8e8e4104d889a9cf0898523773d);
            float4 _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.tex, _Property_be0297c2f654442f9e15cf7fc802ccdf_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_R_4 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.r;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_G_5 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.g;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_B_6 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.b;
            float _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_A_7 = _SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0.a;
            float4 _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_091b4394a16f41e1a48ad9eb8cb374d3) : Color_091b4394a16f41e1a48ad9eb8cb374d3;
            float4 _Multiply_6451aa0d30bc417397e172a99026de27_Out_2;
            Unity_Multiply_float(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _Property_b1918abe71d147d8ab3e2ac39fbb8cd6_Out_0, _Multiply_6451aa0d30bc417397e172a99026de27_Out_2);
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1;
            float4 _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors = float4 (1
        , 1, 1, 0);    Unity_InvertColors_float4(_SampleTexture2D_998ee6f7354d443cbcd8a886323f4edd_RGBA_0, _InvertColors_64d05e8a79294101b021dd6a0a61762b_InvertColors, _InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1);
            float4 Color_5d714827fe5f415ba806c0f4b70cd8dc = IsGammaSpace() ? LinearToSRGB(float4(0, 0, 0, 0)) : float4(0, 0, 0, 0);
            float4 _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2;
            Unity_Multiply_float(_InvertColors_64d05e8a79294101b021dd6a0a61762b_Out_1, Color_5d714827fe5f415ba806c0f4b70cd8dc, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2);
            float4 _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2;
            Unity_Add_float4(_Multiply_6451aa0d30bc417397e172a99026de27_Out_2, _Multiply_8b133b99311a4539bfc4c0e4b3bdf5cb_Out_2, _Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2);
            float _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0 = _Smoothness;
            float4 _ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0 = _PlayerPos;
            float2 _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3;
            Unity_Remap_float2(_Property_05bc6b1651d74a9eaf067b36cce25ae7_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3);
            float2 _Add_ea37115df07943d4bcc23fb99c964593_Out_2;
            Unity_Add_float2((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), _Remap_5dbfecaebb3642cebd529003a85bf8bd_Out_3, _Add_ea37115df07943d4bcc23fb99c964593_Out_2);
            float2 _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_b5841d29afbf48db9e66debecb5df805_Out_0.xy), float2 (1, 1), _Add_ea37115df07943d4bcc23fb99c964593_Out_2, _TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3);
            float2 _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2;
            Unity_Multiply_float(_TilingAndOffset_114e303347ca411b9109eeb39c4a5de2_Out_3, float2(2, 2), _Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2);
            float2 _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2;
            Unity_Subtract_float2(_Multiply_8fc784d86c5e43d59dca293bc4f9b309_Out_2, float2(1, 1), _Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2);
            float _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_ee11649a54a94e008614666bbfbc70d4_Out_2);
            float _Property_c006a056de9d46a593aa8fb52559553c_Out_0 = _Size;
            float _Multiply_088bc75e9ff148008e51a469187c7575_Out_2;
            Unity_Multiply_float(_Divide_ee11649a54a94e008614666bbfbc70d4_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0, _Multiply_088bc75e9ff148008e51a469187c7575_Out_2);
            float2 _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0 = float2(_Multiply_088bc75e9ff148008e51a469187c7575_Out_2, _Property_c006a056de9d46a593aa8fb52559553c_Out_0);
            float2 _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2;
            Unity_Divide_float2(_Subtract_faf0b70002bc4ce78fff906bbf89cec3_Out_2, _Vector2_2b4d832f62024e21be7114c17447fd2a_Out_0, _Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2);
            float _Length_6bfc7c214e60431d82626cdaec66589c_Out_1;
            Unity_Length_float2(_Divide_e2969e8a1e5644c1a51ef4a9d05ab925_Out_2, _Length_6bfc7c214e60431d82626cdaec66589c_Out_1);
            float _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1;
            Unity_OneMinus_float(_Length_6bfc7c214e60431d82626cdaec66589c_Out_1, _OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1);
            float _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1;
            Unity_Saturate_float(_OneMinus_3062f02135b84cec9d4761b5053bf8db_Out_1, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1);
            float _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3;
            Unity_Smoothstep_float(0, _Property_ad4b32689a6a41c5a44b362d17fecee6_Out_0, _Saturate_874cd6ecdf9a4490aee4e3d432c940e4_Out_1, _Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3);
            float _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2;
            Unity_GradientNoise_float(IN.uv0.xy, 10, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2);
            float _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2;
            Unity_Multiply_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _GradientNoise_262c41308531491bbeb3b54f2adcebd3_Out_2, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2);
            float _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2;
            Unity_Add_float(_Smoothstep_b5e8976097004f8ba36a8fbb68dc2801_Out_3, _Multiply_c3d5717ca8e34f37af0d2cf1e9b04183_Out_2, _Add_c16e939630a245d4bbde457bbfe6abd3_Out_2);
            float _Property_8ce72adab21144268e73551951f0483a_Out_0 = _Opacity;
            float _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2;
            Unity_Multiply_float(_Add_c16e939630a245d4bbde457bbfe6abd3_Out_2, _Property_8ce72adab21144268e73551951f0483a_Out_0, _Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2);
            float _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3;
            Unity_Clamp_float(_Multiply_ef6564b2252f4321936dc5dac153bb45_Out_2, 0, 1, _Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3);
            float _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
            Unity_OneMinus_float(_Clamp_ea39e14e25a643248164fd0bcb57f258_Out_3, _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1);
            surface.BaseColor = (_Add_c52d94bf2a3c4e3790c776b9b38b1e01_Out_2.xyz);
            surface.Alpha = _OneMinus_ae5a7e9c35e54f6e92a26b04d3ec1555_Out_1;
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