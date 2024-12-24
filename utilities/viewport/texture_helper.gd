class_name TextureHelper


static func get_texture_dimensions(texture: Texture2D) -> Rect2i:
	return texture.get_image().get_used_rect()
	
	
static func get_texture_rect_dimensions(texture_rect: TextureRect) -> Vector2:
	var texture: Texture2D = texture_rect.texture
	var used_rect: Rect2i = get_texture_dimensions(texture)
	var texture_dimensions: Vector2 = Vector2(used_rect.size) * texture_rect.scale

	return texture_dimensions


static func get_sprite_dimensions(sprite: Sprite2D) -> Vector2:
	var texture: Texture2D = sprite.texture
	var used_rect: Rect2i = get_texture_dimensions(texture)
	var sprite_dimensions: Vector2 = Vector2(used_rect.size) * sprite.scale

	return sprite_dimensions


static func get_png_rect_from_texture(texture: Texture2D) -> Rect2i:
	var image: Image = texture.get_image()
	
	assert(image !=null and image is Image, "TextureHelper->get_png_rect_from_texture: The image from the texture is null, the texture it's invalid")
	
	var top_position: int = image.get_height()
	var bottom_position: int = 0
	
	var right_position: int = image.get_width()
	var left_position: int = 0
	
	for x in image.get_width():
		for y in image.get_height():
			var pixel_color: Color = image.get_pixel(x, y)
			
			if pixel_color.a:
				if top_position > y:
					top_position = y
					
				if bottom_position < y:
					bottom_position = y
				
				if right_position > x:
					right_position = x
					
				if left_position < x:
					left_position = x
	
	var position: Vector2i = Vector2i(left_position - right_position,  bottom_position - top_position)
	var size: Vector2i = Vector2i(right_position + roundi(position.x / 2.0),  top_position + roundi(position.y / 2.0))
	
	return Rect2i(position, size)
	
	
