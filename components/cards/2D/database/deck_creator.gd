## This tool generates the PlayingCard resource files for a new deck that follows
## the folder template included in cards/2D/database
@tool
class_name DeckCreator extends Node


@export var generate: bool = false:
	set(value):
		create_deck_resources(deck_path)
		
		
@export_dir() var deck_path: String = ""
@export var use_original_card_texture_size: bool = true:
	set(value):
		if value != use_original_card_texture_size:
			use_original_card_texture_size = value
			notify_property_list_changed()
@export var target_size: Vector2 = Vector2(48, 48)
@export var texture_scale: float = 1.0


func _validate_property(property: Dictionary):
	if property.name in ["target_size", "texture_scale"]:
		property.usage = PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR if use_original_card_texture_size else PROPERTY_USAGE_EDITOR
	
	
func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		queue_free()


func create_deck_resources(path: String) -> void:
	var image_format_regex = RegEx.new()
	var number_regex = RegEx.new()

	image_format_regex.compile("\\.(png|jpg|svg)$")
	number_regex.compile("\\d+")
	
	var backs: Array[CompressedTexture2D] = []
	
	for file: String in FileHelper.get_files_recursive(path, image_format_regex):
		var folder: String = file.get_base_dir()
		var folder_name: String = folder.split("/")[-1].strip_edges().to_lower()
		var file_name: String = file.get_basename().split("/")[-1] 
		var resource_name: String = file_name + ".tres"
		
		var card: PlayingCard = PlayingCard.new()
		card.id = file_name.to_snake_case()
		card.suit = folder_to_suit(folder_name)
		
		if folder_name == "backs":
			backs.append(ResourceLoader.load(file))
			card.back_texture = backs[0]
		else:
			card.front_texture = ResourceLoader.load(file)
			
		if use_original_card_texture_size:
			card.texture_size = backs[0].get_size() if folder_name == "backs" else card.front_texture.get_size()
		else:
			card.texture_size = _calculate_scale_texture_based_on_target_size(
			 	backs[0] if folder_name == "backs" else card.front_texture, 
				target_size, 
				texture_scale
				)
	
		if card.is_joker() or card.is_back():
			card.value = 0.0
			card.table_value = 0.0
		else:
			card.value = float(number_regex.search(resource_name).get_string())
			card.table_value = card.value
		
		ResourceSaver.save(card, "%s/%s" % [folder, resource_name])
		
	EditorInterface.get_resource_filesystem().scan()


func folder_to_suit(folder_name: String) -> PlayingCard.Suits:
	match folder_name:
		"backs":
			return PlayingCard.Suits.Back
		"jokers":
			return PlayingCard.Suits.Joker
		"hearts":
			return PlayingCard.Suits.Heart
		"diamonds":
			return PlayingCard.Suits.Diamond
		"spades":
			return PlayingCard.Suits.Spade
		"clubs": 
			return PlayingCard.Suits.Club
		"golds":
			return PlayingCard.Suits.Gold
		"swords":
			return PlayingCard.Suits.Sword
		"cups":
			return PlayingCard.Suits.Cup
		_:
			return PlayingCard.Suits.Joker


func _calculate_scale_texture_based_on_target_size(
	texture: Texture2D,
	target_texture_size: Vector2 = target_size,
	target_texture_scale: float = texture_scale) -> Vector2:
	var texture_size = texture.get_size()
	
	return Vector2(target_texture_size.x / texture_size.x, target_texture_size.y / texture_size.y) * target_texture_scale
