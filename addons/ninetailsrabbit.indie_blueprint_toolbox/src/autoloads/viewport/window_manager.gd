extends Node

## Configuration for 4k Games
# Viewport Size: 1920x1080
# Aspect: Expand
# Mode: Canvas items

## Configuration for retro psx games
# Viewport Size: 320x180 o 640x360 depending on the textures details you want
# Aspect: Keep
# Mode: Viewport
# Textures: Nearest

## Configuration for pixel art games that allows smooth camera movement
## Original source https://www.reddit.com/r/godot/comments/1hab9tb/how_i_setup_my_pixel_art_game_in_godot_4/
# Viewport Size: 1920x1080 depending on the details you want
# Aspect: Keep
# Scale: 3, Scale mode: Integer
# Mode: Canvas items
# Textures: Nearest (Don't activate the Snaps 2D options for textures\)

const Resolution_Mobile: StringName = &"mobile"
const Resolution4_3: StringName = &"4:3"
const Resolution16_9: StringName = &"16:9"
const Resolution16_10: StringName = &"16:10"
const Resolution21_9: StringName = &"21:9"
const IntegerScalingResolutions: StringName = &"integer_scaling"

const AspectRatio4_3: Vector2i = Vector2i(4, 3)
const AspectRatio16_9: Vector2i = Vector2i(16,9)
const AspectRatio16_10: Vector2i = Vector2i(16, 10)
const AspectRatio21_9: Vector2i = Vector2i(21, 9)

var resolutions: Dictionary[StringName, Array] = {
	Resolution_Mobile: [
		Vector2i(320, 480),  # Older smartphones
		Vector2i(320, 640),
		Vector2i(375, 667),  # Older smartphones
		Vector2i(375, 812),
		Vector2i(390, 844),  # Older smartphones
		Vector2i(414, 896),  # Some Iphone models
		Vector2i(480, 800),  # Older smartphones
		Vector2i(640, 960),  # Some Iphone models
		Vector2i(640, 1136), # Some Iphone models
		Vector2i(750, 1334), # Common tablet resolution
		Vector2i(768, 1024),
		Vector2i(768, 1334),
		Vector2i(768, 1280),
		Vector2i(1080, 1920), # Some Iphone models
		Vector2i(1242, 2208), # Mid-range tables
		Vector2i(1536, 2048), # High resolutions in larger tablets and some smartphones
	],
	Resolution4_3: [
	  	Vector2i(320, 180),
	   	Vector2i(512, 384),
		Vector2i(768, 576),
		Vector2i(1024, 768),
	],
	Resolution16_9: [
	  	Vector2i(320, 180),
		Vector2i(400, 224),
		Vector2i(640, 360),
		Vector2i(960, 540),
		Vector2i(1280, 720), # 720p
		Vector2i(1280, 800), # SteamDeck
		Vector2i(1366, 768),
		Vector2i(1600, 900),
		Vector2i(1920, 1080), # 1080p
		Vector2i(2560, 1440),
		Vector2i(3840, 2160),
		Vector2i(5120, 2880),
		Vector2i(7680, 4320), # 8K
	],
	Resolution16_10: [
		Vector2i(960, 600),
		Vector2i(1280, 800),
		Vector2i(1680, 1050),
		Vector2i(1920, 1200),
		Vector2i(2560, 1600),
	],
	Resolution21_9: [
	 	Vector2i(1280, 540),
		Vector2i(1720, 720),
		Vector2i(2560, 1080),
		Vector2i(3440, 1440),
		Vector2i(3840, 2160), # 4K
		Vector2i(5120, 2880),
		Vector2i(7680, 4320), # 8K
	],
	IntegerScalingResolutions: [
		Vector2(320, 180),
		Vector2(640, 360),
		Vector2(960, 540),
		Vector2(1280, 720),
		Vector2(1600, 900),
		Vector2(1920, 1080),
	]
}

enum DaltonismTypes {
	No,
	Protanopia,
	Deuteranopia,
	Tritanopia,
	Achromatopsia
}

func _enter_tree() -> void:
	get_tree().root.size_changed.connect(on_size_changed)
	

#region Resolution getters
func get_mobile_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	return _get_resolution(Resolution_Mobile, use_computer_screen_limit)


func get_4_3_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	return _get_resolution(Resolution4_3, use_computer_screen_limit)


func get_16_9_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	return _get_resolution(Resolution16_9, use_computer_screen_limit)


func get_16_10_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	return _get_resolution(Resolution16_10, use_computer_screen_limit)


func get_21_9_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	return _get_resolution(Resolution21_9, use_computer_screen_limit)


func get_integer_scaling_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	return _get_resolution(IntegerScalingResolutions, use_computer_screen_limit)
	

func _get_resolution(aspect_ratio: StringName, use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	
	match aspect_ratio:
		Resolution4_3, Resolution16_10,  Resolution16_9, Resolution21_9, Resolution_Mobile, IntegerScalingResolutions:
			result.assign(resolutions[aspect_ratio])
		
	if use_computer_screen_limit:
		result.assign(result.filter(_filter_by_screen_size_limit))
		
	return result
	

func _filter_by_screen_size_limit(screen_size: Vector2i):
	return screen_size <= IndieBlueprintHardwareDetector.computer_screen_size
#endregion


func center_window_position(viewport: Viewport = get_viewport()) -> void:
	var windowSize: Vector2i = viewport.get_window().get_size_with_decorations()
	
	viewport.get_window().position = monitor_screen_center() - windowSize / 2

## Current screen center of the viewport in the world
func screen_center() -> Vector2i:
	return screen_size() / 2


func screen_size() -> Vector2:
	return get_viewport().get_visible_rect().size


func screen_ratio() -> float:
	var current_screen_size: Vector2 = screen_size()
	
	return current_screen_size.x / current_screen_size.y


## Center of the pc screen monitor used for play
func monitor_screen_center() -> Vector2i:
	return DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2


func get_camera2d_frame(viewport: Viewport = get_viewport()) -> Rect2:
	var camera_frame: Rect2 = viewport.get_visible_rect()
	var camera: Camera2D = viewport.get_camera_2d()
	
	if camera:
		camera_frame.position = camera.get_screen_center_position() - camera_frame.size / 2.0
		
	return camera_frame
	
	
#region Screenshot
## Recommended to call this method after await RenderingServer.frame_post_draw
func screenshot(viewport: Viewport) -> Image:
	var screenshot_image = viewport.get_texture().get_image()
	
	assert(screenshot_image is Image, "IndieBlueprintWindowManager::screenshot: The image output is null")

	return screenshot_image


func screenshot_to_folder(folder: String = "%s/screenshots" % [OS.get_user_data_dir()], viewport: Viewport = get_viewport()) -> Error:
	var create_dir_error: Error = DirAccess.make_dir_recursive_absolute(folder)
	
	if create_dir_error != OK:
		push_error("IndieBlueprintWindowManager::screenshot_to_folder: Can't create directory '%s'. Error: %s" % [folder, error_string(create_dir_error)])
		return create_dir_error
	
	await RenderingServer.frame_post_draw
	
	var screenshot_image: Image = screenshot(viewport)
	var screenshot_save_error = screenshot_image.save_png("%s/%s.png" % [folder, Time.get_datetime_string_from_system().replace(":", "_")])
	
	if screenshot_save_error != OK:
		push_error("IndieBlueprintWindowManager::screenshot_to_folder: Can't save screenshot image '%s'. Error: %s" % [folder, error_string(screenshot_save_error)])
		
	return screenshot_save_error

## Recommended to call this method after await RenderingServer.frame_post_draw
func screenshot_to_texture_rect(viewport: Viewport = get_viewport(), texture_rect: TextureRect = TextureRect.new()) -> TextureRect:
	await RenderingServer.frame_post_draw
	
	var screenshot_image = screenshot(viewport)
	texture_rect.texture = ImageTexture.create_from_image(screenshot_image)
	
	return texture_rect

#endregion

#region Parallax helpers
func adapt_parallax_background_to_horizontal_viewport(parallax_background: ParallaxBackground, viewport: Rect2 = get_window().get_visible_rect()) -> void:	
	for parallax_layer: ParallaxLayer in IndieBlueprintNodeTraversal.find_nodes_of_type(parallax_background, ParallaxLayer.new()):
		if parallax_layer.get_child(0) is Sprite2D:
			var sprite: Sprite2D = parallax_layer.get_child(0) as Sprite2D
			var texture_size = sprite.texture.get_size()
			sprite.scale = Vector2.ONE * (viewport.size.y / texture_size.y)
			
			parallax_layer.motion_mirroring = Vector2(texture_size.x * sprite.scale.x, 0)
		
		
func adapt_parallax_background_to_vertical_viewport(parallax_background: ParallaxBackground, viewport: Rect2 = get_window().get_visible_rect()) -> void:	
	for parallax_layer: ParallaxLayer in IndieBlueprintNodeTraversal.find_nodes_of_type(parallax_background, ParallaxLayer.new()):
		if parallax_layer.get_child(0) is Sprite2D:
			var sprite: Sprite2D = parallax_layer.get_child(0) as Sprite2D
			var texture_size = sprite.texture.get_size()
			sprite.scale = Vector2.ONE * (viewport.size.x / texture_size.x)
			
			parallax_layer.motion_mirroring = Vector2(0, texture_size.y * sprite.scale.y)


func adapt_parallax_to_horizontal_viewport(parallax: Parallax2D, viewport: Rect2 = get_window().get_visible_rect()) -> void:	
	if parallax.get_child(0) is Sprite2D:
		var sprite: Sprite2D = parallax.get_child(0) as Sprite2D
		var texture_size = sprite.texture.get_size()
		sprite.scale = Vector2.ONE * (viewport.size.y / texture_size.y)
		
		parallax.repeat_size = Vector2(texture_size.x * sprite.scale.x, 0)
	

func adapt_parallax_to_vertical_viewport(parallax: Parallax2D, viewport: Rect2 = get_window().get_visible_rect()) -> void:	
	if parallax.get_child(0) is Sprite2D:
		var sprite: Sprite2D = parallax.get_child(0) as Sprite2D
		var texture_size = sprite.texture.get_size()
		sprite.scale = Vector2.ONE * (viewport.size.x / texture_size.x)
		
		parallax.repeat_size = Vector2(0, texture_size.y * sprite.scale.y)
#endregion


#region Signal callbacks
## This callback center the screen when the display resolution is changed in-game
func on_size_changed() -> void:
	center_window_position()
#endregion
