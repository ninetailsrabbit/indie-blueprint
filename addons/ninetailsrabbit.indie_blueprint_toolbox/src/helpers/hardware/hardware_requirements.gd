## Used the following repository as reference for graphic settings https://github.com/godotengine/godot-demo-projects/blob/master/3d/graphics_settings
class_name IndieBlueprintHardwareRequirements

class GraphicQualityDisplay:
	var project_setting: String
	var property_name: StringName
	var value: Variant
	
	func _init(_project_setting:  String, _property_name: String, _value: Variant) -> void:
		project_setting = _project_setting
		property_name = _property_name
		value = _value
		
		
enum QualityPreset {
	Low,
	Medium,
	High,
	Ultra
}


static var gpu_quality: Dictionary[QualityPreset, Array] = {
	QualityPreset.Low: [
		 # Integrated Graphics (Common & Entry-Level)
		"Intel UHD Graphics",
		"Intel UHD Graphics (11th Gen+)", # Most common integrated graphics today
		"Intel Iris Xe Graphics", # Base configurations, higher EUs can sometimes push Medium
		"AMD Radeon Graphics", # Integrated graphics in lower-end Ryzen processors
		"Apple M1", # Integrated GPU on original M1 chip (non-Pro/Max/Ultra)
		"Apple M2", # Integrated GPU on original M2 chip (non-Pro/Max/Ultra)
		"Apple M3", # Integrated GPU on original M3 chip (non-Pro/Max/Ultra)
		"Intel HD Graphics", # Older, ubiquitous Intel integrated graphics
		"Intel Iris Graphics", # Older Iris variants

		# NVIDIA GeForce GT/GTX Series (Entry-Level Discrete & Older)
		"GTX 1630", # A modern card specifically designed for low-end
		"GTX 1050 (3GB)", # The 3GB version often struggles more with VRAM
		"GTX 1050", # Mobile version is typically weaker
		"GT 1030",
		"GT 1010",
		"GTX 950", # The mobile version is typically weaker than desktop
		"GTX 940MX",
		"GTX 930MX",
		"GTX 920MX",
		"GTX 910M",
		"GTX 750 (non-Ti)", # While efficient, now mostly low for modern games
		"GTX 745",
		"GT 740",
		"GT 730",
		"GT 720",
		"GT 710",
		"GT 705",
		"GeForce 840M", "GeForce 830M", "GeForce 820M", "GeForce 810M",
		"GeForce 740M", "GeForce 735M", "GeForce 720M", "GeForce 710M",
		"GTX 650", "GTX 645", # Older Kepler series that now fall to Low
		"GT 640", "GT 630", "GT 620", "GT 610", # Very old GT series
		# AMD Radeon RX Series (Entry-Level Discrete & Older)
		"RX 6400", # Designed for entry-level, often performs better on PCIe 4.0
		"RX 6500 XT", # Can drop to Low if bandwidth-limited
		"RX 550", # Common low-end discrete GPU
		"RX 460",
		"RX 560",
		"RX 570 (4GB)", # The 4GB version struggles with VRAM more than 8GB
		"RX 470 (4GB)", # The 4GB version struggles with VRAM more than 8GB
		
		# AMD Radeon R-Series (Older desktop and mobile, generally weak)
		"R9 260X",
		"R7 260",
		"R7 250X",
		"R7 250",
		"R7 240",
		"R5 240",
		"R5 235X",
		"R5 235",
		"R5 230",
		"R5 220",
		"R9 360",
		"R7 350",
		"R5 340X",
		"R5 340",
		"R5 330",
		"R9 M375", "R9 M370X", "R9 M365X", "R7 M360", "R5 M335", "R5 M330",
		"R9 M295X", "R9 M290X", "R9 M280X", "R9 M275X", "R9 M270X", "R9 M265X", "R7 M265", "R7 M260X", "R7 M260", "R5 M255", "R5 M230",
		"R7 M465", "R7 M460", "RX 455", "R7 450", "R7 M440", "R7 435", "R7 430", "R5 435", "R7 M435", "R5 M430", "R5 430", "R5 M420",
		
		# Very Old/Generic Professional Workstation Cards (if truly low performance for gaming)
		"NVIDIA Quadro K600", "NVIDIA Quadro P400", "NVIDIA NVS 310", # Examples of very low-end workstation GPUs
		"AMD FirePro V3900", "AMD FirePro V4900", # Examples of very old/low-end FirePro GPUs
	],
	QualityPreset.Medium: [
		 # NVIDIA GeForce RTX 30 Series (Ampere Architecture) - Entry-level RTX
		"RTX 3050 (6GB)", # The 6GB version is slightly less powerful than 8GB, fitting here
	
		# NVIDIA GeForce GTX 16 Series (Turing Architecture - Non-RTX)
		"GTX 1660 SUPER",
		"GTX 1660 Ti",
		"GTX 1660",
		"GTX 1650 SUPER",
		"GTX 1650 (GDDR6)", # Specify GDDR6 for better performance

		# AMD Radeon RX 6000 Series (RDNA 2 Architecture) - Entry-level RDNA 2
		"RX 6500 XT",
		"RX 6400", # Primarily for pre-built systems due to PCIe 4.0 x4 limitation

		# AMD Radeon RX 5000 Series (RDNA Architecture)
		"RX 5600 XT",
		"RX 5500 XT (8GB)", # 8GB version for better VRAM
		"RX 5500 XT (4GB)",

		# Intel Arc Series (Entry to Mid)
		"Intel Arc A750", # Strong competitor, especially with driver improvements
		"Intel Arc A580",
		"Intel Arc A380",

		# NVIDIA GeForce GTX 10 Series (Pascal Architecture) - Still viable
		"GTX 1070 Ti", # Can sometimes push high, but consistently medium in newer titles
		"GTX 1070",
		"GTX 1060 (6GB)", # The 6GB is significantly better than 3GB
		"GTX 1050 Ti", # Borderline, but with tweaks, still medium capable at 1080p

		# AMD Radeon RX 500 Series (Polaris Architecture) - Legacy, but persistent
		"RX 590",
		"RX 580 (8GB)", # 8GB for VRAM heavy titles
		"RX 570 (8GB)",

		# NVIDIA GeForce GTX 900 Series (Maxwell Architecture) - Aging, but some still hold on
		"GTX 980 Ti", # A former flagship, still surprisingly capable of medium at 1080p
		"GTX 980",
		"GTX 970",
	],
	QualityPreset.High: [
		"Vega 56",
		"Vega 64",
		"GTX 1080 Ti",
		"GTX 1080",
		"RX 5700 XT", 
		"RX 5700",
		# NVIDIA GeForce RTX 40 Series (Ada Lovelace Architecture)
		"RTX 4060 Ti",
		"RTX 4060",

		# AMD Radeon RX 7000 Series (RDNA 3 Architecture)
		"RX 7700 XT",
		"RX 7600 XT",
		"RX 7600",

		# NVIDIA GeForce RTX 30 Series (Ampere Architecture) - High to Mid-High
		"RTX 3070",
		"RTX 3060 Ti",
		"RTX 3060 (12GB)", # Specify 12GB for better performance in this tier
		"RTX 3050 (8GB)", # Often can deliver high settings with FSR/DLSS

		# AMD Radeon RX 6000 Series (RDNA 2 Architecture) - High to Mid-High
		"RX 6800",
		"RX 6750 XT",
		"RX 6700 XT",
		"RX 6700",
		"RX 6650 XT",
		"RX 6600 XT",
		"RX 6600",

		# NVIDIA GeForce RTX 20 Series (Turing Architecture) - Still capable
		"RTX 2080 Ti",   # While older, still offers strong "High" performance
		"RTX 2080 Super",
		"RTX 2080",
		"RTX 2070 Super",
		"RTX 2070",
		"RTX 2060 Super",
		"RTX 2060 (12GB)", # The 12GB version is stronger
		"RTX 2060",

		# AMD Radeon RX 5000 Series (RDNA Architecture) - Older, but still viable for High
		"RX 5700 XT",
		"RX 5700",
	],
	QualityPreset.Ultra: [
		# NVIDIA GeForce RTX 40 Series (Ada Lovelace Architecture)
		"RTX 4090", 
		"RTX 4080 SUPER", 
		"RTX 4080", 
		"RTX 4070 Ti SUPER", 
		"RTX 4070 Ti", 
		"RTX 4070 SUPER",

		# AMD Radeon RX 7000 Series (RDNA 3 Architecture)
		"RX 7900 XTX", 
		"RX 7900 XT",
		"RX 7900 GRE",
		"RX 7800 XT", 

		# NVIDIA GeForce RTX 30 Series (Ampere Architecture) - High-end
		"RTX 3090 Ti", 
		"RTX 3090", 
		"RTX 3080 Ti", 
		"RTX 3080 (12GB)", # Specifically the 12GB version for higher performance
		"RTX 3070 Ti",

		# AMD Radeon RX 6000 Series (RDNA 2 Architecture) - High-end
		"RX 6950 XT", 
		"RX 6900 XT", 
		"RX 6800 XT",

		# Professional/Workstation GPUs (often perform at or above high-end consumer cards)
		"NVIDIA RTX 6000 Ada Generation", 
		"NVIDIA RTX A6000", 
		"Quadro RTX 8000", 
		"Titan RTX",
	],
}

static var graphics_quality_presets: Dictionary[QualityPreset, Array] = {
	## For low-end PCs with integrated graphics, as well as mobile devices
	QualityPreset.Low: [
		GraphicQualityDisplay.new("rendering/environment/glow_enabled", &"Glow", [false, false]),
		GraphicQualityDisplay.new("rendering/environment/screen_space_reflection", &"Screen Space Reflection", [false, RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_DISABLED, 8]),
		GraphicQualityDisplay.new("rendering/environment/sdfgi_enabled", &"SDFGI", [false, true]),
		GraphicQualityDisplay.new("rendering/environment/ssil_enabled", &"SSIL", false),
		GraphicQualityDisplay.new("rendering/environment/ssao_enabled", &"SSAO", [true, RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300]),
		GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_2d", &"AntiAliasing 2D", Viewport.MSAA_DISABLED),
		GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_3d", &"AntiAliasing 3D", Viewport.MSAA_DISABLED),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/positional_shadow/atlas_size", &"Directional shadow atlas", 2048),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", &"Shadow quality filter", RenderingServer.SHADOW_QUALITY_SOFT_LOW),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", &"Shadow quality filter", RenderingServer.SHADOW_QUALITY_SOFT_LOW),
		GraphicQualityDisplay.new("rendering/mesh_lod/lod_change/threshold_pixels", &"Mesh level of detail", 4.0),
		GraphicQualityDisplay.new("rendering/scaling_3d/scale", &"Scaling 3D when BILINEAR is enabled", 1.0),
		GraphicQualityDisplay.new("rendering/scaling_3d/fsr_sharpness", &"Scaling 3D when FSR is enabled", 0.5),
		GraphicQualityDisplay.new("directional_light/shadow_bias", &"Directional Light 3D Shadow Bias", 0.03),
	],
	QualityPreset.Medium: [
		GraphicQualityDisplay.new("rendering/environment/glow_enabled", &"Glow", [false, false]),
		GraphicQualityDisplay.new("rendering/environment/screen_space_reflection", &"Screen Space Reflection", [true, RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_LOW, 16]),
		GraphicQualityDisplay.new("rendering/environment/sdfgi_enabled", &"SDFGI", [false, true]),
		GraphicQualityDisplay.new("rendering/environment/ssil_enabled", &"SSIL", false),
		GraphicQualityDisplay.new("rendering/environment/ssao_enabled", &"SSAO", [true, RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 3, 50, 300]),
		GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_2d", &"AntiAliasing 2D", Viewport.MSAA_2X),
		GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_3d", &"AntiAliasing 3D", Viewport.MSAA_2X),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/positional_shadow/atlas_size", &"Directional shadow atlas", 4096),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", &"Shadow quality filter", RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", &"Shadow quality filter", RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM),
		GraphicQualityDisplay.new("rendering/mesh_lod/lod_change/threshold_pixels", &"Mesh level of detail", 2.0),
		GraphicQualityDisplay.new("rendering/scaling_3d/scale", &"Scaling 3D when BILINEAR is enabled", 1.0),
		GraphicQualityDisplay.new("rendering/scaling_3d/fsr_sharpness", &"Scaling 3D when FSR is enabled", 0.59),
		GraphicQualityDisplay.new("directional_light/shadow_bias", &"Directional Light 3D Shadow Bias", 0.02),
		
	],
	QualityPreset.High: [
		GraphicQualityDisplay.new("rendering/environment/glow_enabled", &"Glow", [false, true]),
		GraphicQualityDisplay.new("rendering/environment/screen_space_reflection", &"Screen Space Reflection", [true, RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_HIGH, 32]),
		GraphicQualityDisplay.new("rendering/environment/sdfgi_enabled", &"SDFGI", [true, false]),
		GraphicQualityDisplay.new("rendering/environment/ssil_enabled", &"SSIL", true),
		GraphicQualityDisplay.new("rendering/environment/ssao_enabled", &"SSAO", [true, RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 4, 50, 300]),
		GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_2d", &"AntiAliasing 2D", Viewport.MSAA_4X),
		GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_3d", &"AntiAliasing 3D", Viewport.MSAA_4X),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/positional_shadow/atlas_size", &"Directional shadow atlas", 8192),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", &"Shadow quality filter", RenderingServer.SHADOW_QUALITY_SOFT_HIGH),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", &"Shadow quality filter", RenderingServer.SHADOW_QUALITY_SOFT_HIGH),
		GraphicQualityDisplay.new("rendering/mesh_lod/lod_change/threshold_pixels", &"Mesh level of detail", 1.0),
		GraphicQualityDisplay.new("rendering/scaling_3d/scale", &"Scaling 3D when BILINEAR is enabled", 1.0),
		GraphicQualityDisplay.new("rendering/scaling_3d/fsr_sharpness", &"Scaling 3D when FSR is enabled", 0.67),
		GraphicQualityDisplay.new("directional_light/shadow_bias", &"Directional Light 3D Shadow Bias", 0.01),
		
	],
	QualityPreset.Ultra: [
		GraphicQualityDisplay.new("rendering/environment/glow_enabled", &"Glow", [false, true]),
		GraphicQualityDisplay.new("rendering/environment/screen_space_reflection", &"Screen Space Reflection", [true, RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_HIGH, 64]),
		GraphicQualityDisplay.new("rendering/environment/sdfgi_enabled", &"SDFGI", [true, false]),
		GraphicQualityDisplay.new("rendering/environment/ssil_enabled", &"SSIL", true),
		GraphicQualityDisplay.new("rendering/environment/ssao_enabled", &"SSAO", [true, RenderingServer.ENV_SSAO_QUALITY_ULTRA, true, 0.85, 5, 50, 300]),
		GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_2d", &"AntiAliasing 2D", Viewport.MSAA_8X),
		GraphicQualityDisplay.new("rendering/anti_aliasing/quality/msaa_3d", &"AntiAliasing 3D", Viewport.MSAA_8X),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/positional_shadow/atlas_size", &"Directional shadow atlas", 16384),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", &"Shadow quality filter", RenderingServer.SHADOW_QUALITY_SOFT_ULTRA),
		GraphicQualityDisplay.new("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", &"Shadow quality filter", RenderingServer.SHADOW_QUALITY_SOFT_ULTRA),
		GraphicQualityDisplay.new("rendering/mesh_lod/lod_change/threshold_pixels", &"Mesh level of detail", 0),
		GraphicQualityDisplay.new("rendering/scaling_3d/scale", &"Scaling 3D when BILINEAR is enabled", 1.0),
		GraphicQualityDisplay.new("rendering/scaling_3d/fsr_sharpness", &"Scaling 3D when FSR is enabled", 0.77),
		GraphicQualityDisplay.new("directional_light/shadow_bias", &"Directional Light 3D Shadow Bias", 0.005),
	],
}

static func auto_discover_graphics_quality() -> QualityPreset:
	var current_hardware_device_name = RenderingServer.get_video_adapter_name()
	
	for preset in gpu_quality:
		for adapter: String in gpu_quality[preset]:
			if current_hardware_device_name.containsn(adapter):
				return preset
				
	return QualityPreset.Medium


static func apply_graphics_on_directional_light(directional_light: DirectionalLight3D, quality_preset: QualityPreset = QualityPreset.Medium) -> void:
	var preset: Array[GraphicQualityDisplay] = []
	preset.assign(graphics_quality_presets[quality_preset])
	
	for quality: GraphicQualityDisplay in preset:
		match quality.project_setting:
			"directional_light/shadow_bias":
				directional_light.shadow_bias = quality.value


static func apply_graphics_on_environment(world_environment: WorldEnvironment, quality_preset: QualityPreset = QualityPreset.Medium) -> void:
	var viewport: Viewport = world_environment.get_viewport()
	var preset: Array[GraphicQualityDisplay] = []
	preset.assign(graphics_quality_presets[quality_preset])
	
	for quality: GraphicQualityDisplay in preset:
		match quality.project_setting:
			"rendering/environment/glow_enabled":
				world_environment.environment.glow_enabled =  quality.value[0]
				
				if world_environment.environment.glow_enabled:
					RenderingServer.environment_glow_set_use_bicubic_upscale(quality.value[1])
				
			"rendering/environment/screen_space_reflection":
				world_environment.environment.ssr_enabled = quality.value[0]
				
				if world_environment.environment.ssr_enabled:
					ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", quality.value[1])
					world_environment.environment.ssr_max_steps = quality.value[2]
			"rendering/environment/ssao_enabled":
				ProjectSettings.set_setting("rendering/environment/ssao/quality", quality.value[0])
				world_environment.environment.ssao_enabled = quality.value[0]
				
				if world_environment.environment.ssao_enabled:
					RenderingServer.environment_set_ssao_quality(quality.value[1], quality.value[2], quality.value[3], quality.value[4], quality.value[5], quality.value[6])
			"rendering/environment/sdfgi_enabled":
				world_environment.environment.sdfgi_enabled = quality.value[0]
	
				if world_environment.environment.sdfgi_enabled:
					RenderingServer.gi_set_use_half_resolution(quality.value[1])
			"rendering/environment/ssil_enabled":
				world_environment.environment.ssil_enabled = quality.value
			"rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality":
				RenderingServer.directional_soft_shadow_filter_set_quality(quality.value)
			"rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality":
				RenderingServer.positional_soft_shadow_filter_set_quality(quality.vallue)
			"rendering/lights_and_shadows/positional_shadow/atlas_size":
				RenderingServer.directional_shadow_atlas_set_size(quality.value, true)
				viewport.positional_shadow_atlas_size = quality.value
			"rendering/mesh_lod/lod_change/threshold_pixels":
				viewport.mesh_lod_threshold = quality.value
			"rendering/scaling_3d/scale":
				if viewport.scaling_3d_mode == Viewport.SCALING_3D_MODE_BILINEAR:
					viewport.scaling_3d_scale = quality.value
			"rendering/scaling_3d/fsr_sharpness":
				if viewport.scaling_3d_mode != Viewport.SCALING_3D_MODE_BILINEAR:
					## When using FSR upscaling, AMD recommends exposing the following values as preset options to users 
					## "Ultra Quality: 0.77", "Quality: 0.67", "Balanced: 0.59", "Performance: 0.5" instead of exposing the entire scale.
					viewport.scaling_3d_scale = quality.value
			"rendering/anti_aliasing/quality/msaa_3d":
				@warning_ignore("int_as_enum_without_cast")
				viewport.msaa_3d = quality.value
				
				if viewport.msaa_3d == Viewport.MSAA_DISABLED:
					RenderingServer.viewport_set_screen_space_aa(viewport.get_viewport_rid(), RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
				else:
					RenderingServer.viewport_set_screen_space_aa(viewport.get_viewport_rid(), RenderingServer.VIEWPORT_SCREEN_SPACE_AA_DISABLED)
