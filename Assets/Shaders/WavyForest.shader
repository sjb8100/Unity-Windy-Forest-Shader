﻿Shader "Custom/Wavy Forest" {

	// TODO
	// 1. Distribute X tiling by consistent steps instead of texture width to ensure consistency across multiple textures
	//		^ Replace "_TileX" with "_DensityX" and make it happen

	Properties {

		// Shader properties are denoted by:
		// 1. The variable name _MainTex
		// 2. The inspector label "Base (RGB)"
		// 3. The variable type 2D
		// 4. The default value "white"

		_RampTex ("Color Ramp", 2D) = "gray" {}
		_MainTex ("Base Texture", 2D) = "white" {}
//		_DarkTex ("Shadow Texture", 2D) = "black" {}
		_CombTex ("Shadow & Mask Texture", 2D) = "black" {}
		_DarkAmount ("Shadow Amount", range(0.1, 1)) = 0.5
//		_Mask ("Mask", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", range(0, 1)) = 0.1
		_SpeedX ("Speed X", float) = 1.5
		_Scale ("Scale", range(0, 1)) = 0.5
		_TileX ("Tile X", float) = 5
	}

	SubShader {
		Tags {
			"Queue"="Transparent"
			"RenderType"="Transparent"
		}

		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert alpha

		sampler2D _RampTex;
		sampler2D _MainTex;
//		float4 uv_MainTex_ST;
		sampler2D _CombTex;
//		float4 uv_CombTex_ST;

		float _DarkAmount;
		float _SpeedX;
		float _Scale;
		float _TileX;

		struct Input {
			float2 uv_MainTex;
			float2 uv_CombTex;
		};

		void surf (Input IN, inout SurfaceOutput o)
		{	

			// Adjust a few values to something reasonable
			_Scale *= 0.01;
			_DarkAmount *= 35;

			float2 uv2 = IN.uv_CombTex;

			// Apply our shadow area
			uv2.x += sin((uv2.x - uv2.y) * _TileX + _Time.g * _SpeedX) * _Scale;
			half4 dark = tex2D (_CombTex, uv2);

			// Wavy calculations
			float2 uv = IN.uv_MainTex;
			uv.x += sin((uv.x - uv.y) * _TileX + _Time.g * _SpeedX) * _Scale;

			// Mask calculations
//			float2 uvMask = IN.uv_CombTex;
			uv2.x += sin((uv2.x - uv2.y) * _TileX + _Time.g * _SpeedX) * _Scale;
			half4 mask = tex2D (_CombTex, uv2);
			half4 c = tex2D (_MainTex, uv);

			// Apply our color ramp
			fixed tempData = tex2D(_MainTex, uv);

			// Increase our brightness by a bit
			c += 0.05;

			// Adjust our contrast
			c *= 0.95;

			// Now let's darken the intended shadow areas with our shadow texture
			c -= (dark.g / _DarkAmount);

//			fixed2 rampUV = fixed2(c.r,);
            fixed3 rampColor = tex2D(_RampTex, c.rgb);

			o.Albedo = rampColor.rgb;
			o.Alpha = mask.r;
		}

		ENDCG
	}
	Fallback "Diffuse"

}