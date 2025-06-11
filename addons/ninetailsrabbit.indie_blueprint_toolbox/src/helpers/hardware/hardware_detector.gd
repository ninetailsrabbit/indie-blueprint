class_name IndieBlueprintHardwareDetector

static var engine_version: String = "Godot %s" % Engine.get_version_info().string
static var device: String = OS.get_model_name()
static var platform: String = OS.get_name()
static var distribution_name: String = OS.get_distribution_name()
static var video_adapter_name: String = RenderingServer.get_video_adapter_name()
static var processor_name: String = OS.get_processor_name()
static var processor_count: int = OS.get_processor_count() 
static var usable_threads: int = processor_count * 2 # I assume that each core has 2 threads
static var computer_screen_size: Vector2i = DisplayServer.screen_get_size()


static func renderer() -> String:
	return str(ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method"))


static func is_multithreading_enabled() -> bool:
	return ProjectSettings.get_setting("rendering/driver/threads/thread_model") == 2


static func is_exported_release() -> bool:
	return OS.has_feature("template")


static func renderer_is_forward() -> bool:
	return renderer().nocasecmp_to("forward_plus") == 0


static func render_is_compatibility() -> bool:
	return renderer().nocasecmp_to("gl_compatibility") == 0


static func renderer_is_mobile() -> bool:
	return renderer().nocasecmp_to("mobile") == 0


static func has_fsr() -> bool:
	return OS.has_feature("fsr")


static func is_steam_deck() -> bool:
	return IndieBlueprintStringHelper.equals_ignore_case(distribution_name, "SteamOS") \
		or video_adapter_name.containsn("radv vangogh") \
		or OS.get_processor_name().containsn("amd custom apu 0405")


static func is_mobile() -> bool:
	if not OS.has_feature("web"):
		return false
	
	return OS.get_name() == "Android" or OS.get_name() == "iOS" \
		or (is_web() and OS.has_feature("web_android")) or (is_web() and OS.has_feature("web_ios")) \
		or JavaScriptBridge.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)", true)
		

static func is_windows() -> bool:
	return OS.get_name() == "Windows" or (is_web() and OS.has_feature("web_windows"))


static func is_linux() -> bool:
	return OS.get_name() in ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"] or (is_web() and OS.has_feature("web_linuxbsd"))
	
		
static func is_mac() -> bool:
	return OS.get_name() == "macOS" or (is_web() and OS.has_feature("web_macos"))


static func is_web() -> bool:
	return OS.has_feature("Web")
