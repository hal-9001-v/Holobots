Shader "Unlit/LineTool"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,0)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

          Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _MainColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = _MainColor;

                return col;
            }
            ENDCG
        }
    }
}
