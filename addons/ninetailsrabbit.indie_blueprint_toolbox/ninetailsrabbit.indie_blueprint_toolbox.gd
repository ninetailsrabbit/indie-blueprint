@tool
extends EditorPlugin


var preloader_timer: Timer
var mutex: Mutex

	
func _enter_tree() -> void:
	add_autoload_singleton("IndieBlueprintWindowManager", "res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/autoloads/viewport/window_manager.gd")
	
	add_custom_type(
		"IndieBlueprintSmartDecal", 
		"Decal", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/3D/decals/smart_decal.gd"),
		null
	)
	
	add_custom_type(
		"IndieBlueprintDraggable2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/drag/draggable_2d.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/drag/draggable_2d.svg")
	)
	
	add_custom_type(
		"IndieBlueprintOrbitComponent2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/orbit/orbit.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/orbit/orbit.svg")
	)
	
	add_custom_type(
		"IndieBlueprintRotatorComponent2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/rotation/rotator.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/rotation/rotator.svg")
	)
	
	add_custom_type(
		"IndieBlueprintSwingComponent2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/swing/swing.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/swing/swing.svg")
	)
	
	add_custom_type(
		"IndieBlueprintFollowComponent2D", 
		"Node2D", 
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/follow/follow.gd"),
		preload("res://addons/ninetailsrabbit.indie_blueprint_toolbox/src/components/2D/motion/follow/follow.svg")
	)
	
	IndieBlueprintToolboxSettings.setup_preloader_output_path()
	IndieBlueprintToolboxSettings.setup_preloader_classname()
	IndieBlueprintToolboxSettings.setup_enable_timer(false)
	IndieBlueprintToolboxSettings.setup_preloader_update_frequency()
	IndieBlueprintToolboxSettings.setup_include_scripts()
	IndieBlueprintToolboxSettings.setup_include_scenes()
	IndieBlueprintToolboxSettings.setup_include_resources()
	IndieBlueprintToolboxSettings.setup_include_shaders()
	IndieBlueprintToolboxSettings.setup_exclude_paths()
	IndieBlueprintToolboxSettings.setup_supported_image_types()
	IndieBlueprintToolboxSettings.setup_supported_audio_types()
	IndieBlueprintToolboxSettings.setup_supported_font_types()
	
	if OS.is_debug_build():
		if mutex == null:
			mutex = Mutex.new()

		if preloader_timer == null:
			preloader_timer = Timer.new()
			preloader_timer.name = "PreloaderTimer"
			preloader_timer.wait_time = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.PreloaderUpdateFrequencySetting)
			preloader_timer.one_shot = false
			preloader_timer.autostart = true
			add_child(preloader_timer)
			preloader_timer.timeout.connect(on_preloader_timeout_update)

		if not ProjectSettings.settings_changed.is_connected(on_project_settings_changed):
			ProjectSettings.settings_changed.connect(on_project_settings_changed)


func _exit_tree() -> void:
	if mutex:
		mutex.unlock()
		
	mutex = null
	
	if ProjectSettings.settings_changed.is_connected(on_project_settings_changed):
		ProjectSettings.settings_changed.disconnect(on_project_settings_changed)

	if preloader_timer:
		preloader_timer.stop()
		preloader_timer.free()
		
	preloader_timer = null
	
	remove_custom_type("IndieBlueprintFollowComponent2D")
	remove_custom_type("IndieBlueprintSwingComponent2D")
	remove_custom_type("IndieBlueprintRotatorComponent2D")
	remove_custom_type("IndieBlueprintOrbitComponent2D")
	remove_custom_type("IndieBlueprintDraggable2D")
	remove_custom_type("IndieBlueprintSmartDecal")
	
	remove_autoload_singleton("IndieBlueprintWindowManager")


func generate_preloader_file() -> void:
	if mutex.try_lock(): 
		## Regex to ignore hidden files/folders from the project that does not need to be loaded
		var ignored_files_regex: RegEx = RegEx.new()
		ignored_files_regex.compile(r"^res://(\..+|.*\.(uid|md|cfg|import|godot))$")
		
		var excluded_paths: Array[String] = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.ExcludePathSetting)
		
		if excluded_paths == null:
			excluded_paths = ["addons"]
			
		var image_extensions: Array[String] = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.ImageTypesSetting)
		var audio_extensions: Array[String] = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.AudioTypesSetting)
		var font_extensions: Array[String] = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.FontTypesSetting)
		var include_scripts: bool = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.IncludeScriptsSetting)
		var include_scenes: bool = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.IncludeScenesSetting)
		var include_resources: bool = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.IncludeResourcesSetting)
		var include_shaders: bool = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.IncludeShadersSetting)
	
		var output_path: String = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.OutputPreloaderPathSetting)
		var preloader_classname: String = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.PreloaderClassNameSetting)
		
		DirAccess.make_dir_recursive_absolute(output_path)
		
		output_path = output_path.path_join("preloader.gd")
		var preloader_file: FileAccess = FileAccess.open(output_path, FileAccess.WRITE)
		preloader_file.store_line("class_name IndieBlueprintPreloader\n")
		
		var scenes: Array[String] = []
		var scripts: Array[String] = []
		var resources: Array[String] = []
		var shaders: Array[String] = []
		var images: Array[String] = []
		var audios: Array[String] = []
		var fonts: Array[String] = []
		
		for file_path: String in IndieBlueprintFileHelper.get_files_recursive("res://"):
			if not ignored_files_regex.search(file_path):
				var excluded: bool = false
				
				for excluded_path: String in excluded_paths:
					if file_path.containsn(excluded_path):
						excluded = true
						break
				
				if excluded:
					continue
				
				var extension: String = file_path.get_extension()
				
				if extension in image_extensions:
					images.append(file_path)
					
				elif extension in audio_extensions:
					audios.append(file_path)

				elif extension in font_extensions:
					fonts.append(file_path)
					
				elif include_scripts and extension == "gd":
					scripts.append(file_path)
					
				elif include_scenes and extension in ["tscn", "scn"]:
					scenes.append(file_path)
					
				elif include_resources and extension in ["tres", "res"]:
					resources.append(file_path)
					
				elif include_shaders and extension == "gdshader":
					shaders.append(file_path)
		
		_create_preload_section(preloader_file, "Scenes", scenes)
		_create_preload_section(preloader_file, "Scripts", scripts)
		_create_preload_section(preloader_file, "Resources", resources)
		_create_preload_section(preloader_file, "Shaders", shaders)
		_create_preload_section(preloader_file, "Images", images)
		_create_preload_section(preloader_file, "Audios", audios)
		_create_preload_section(preloader_file, "Fonts", fonts)
		
		preloader_file.close()
		mutex.unlock()
		call_thread_safe(&"scan_filesystem")


func _create_preload_section(preloader: FileAccess, section: String, file_paths: Array[String]) -> void:
	if file_paths.is_empty():
		return
	
	preloader.store_line("class %s:" % section)
	
	var type: String = ""
	var suffix: String = ""
	
	match section:
		"Scenes":
			type = ": PackedScene"
			suffix = "Scene"
		"Resources":
			type = ": Resource"
			suffix = "Resource"
		"Images":
			type = ": CompressedTexture2D"
			suffix = "Image"
		"Audios":
			type = ": AudioStream"
			suffix = "Audio"
		"Fonts":
			type = ": Fonts"
			suffix = "Font"
		"Shaders":
			type = ": Shader"
			suffix = "Shader"
	
	var processed_names: Array[String] = []
	
	for path: String in file_paths:
		var extension: String = path.get_extension()
		
		if section == "Audios":
			match extension:
				"mp3":
					type= ": AudioStreamMP3"
				"ogg":
					type = ": AudioStreamOggVorbis"
				"wav":
					type = ": AudioStreamWAV"
				
		var constant_name: String = IndieBlueprintStringHelper\
			.replace_tokens(path.get_file().trim_suffix("." + extension), [".", "-"], "_")\
			.lstrip("0123456789")\
			.to_pascal_case() + suffix
	
		if processed_names.has(constant_name) or ClassDB.class_exists(constant_name):
			var frequency: Dictionary = IndieBlueprintArrayHelper.frequency([constant_name])
			constant_name += "_%d" % frequency[constant_name]
		
		processed_names.append(constant_name)
		
		preloader.store_line("\tconst %s%s = preload(\"%s\")\n" % [constant_name, type, path])


func scan_filesystem() -> void:
	EditorInterface.get_resource_filesystem().scan()
	

func on_project_settings_changed() -> void:
	if preloader_timer:
		if ProjectSettings.get_setting(IndieBlueprintToolboxSettings.EnableTimerSetting):
			preloader_timer.stop()
			preloader_timer.wait_time = ProjectSettings.get_setting(IndieBlueprintToolboxSettings.PreloaderUpdateFrequencySetting)
			preloader_timer.start()
		else:
			preloader_timer.stop()


func on_preloader_timeout_update() -> void:
	WorkerThreadPool.add_task(generate_preloader_file, false, "Read and generate preloader file with project resources")
