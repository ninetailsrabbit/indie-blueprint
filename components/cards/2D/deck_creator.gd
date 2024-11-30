## This tool generates the PlayingCard resource files for a new deck that follows
## the folder template included in cards/2D/database
@tool
class_name DeckCreator extends Node


@export var generate: bool = false:
	set(value):
		create_deck_resources(deck_path)
		
		
@export_dir() var deck_path: String = ""


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
		
		if folder_name == "backs":
			backs.append(ResourceLoader.load(file))
			continue
		
		var card: PlayingCard = PlayingCard.new()
		card.id = file_name.to_snake_case()
		card.suit = folder_to_suit(folder_name)
		card.front_texture = ResourceLoader.load(file)
		
		if card.is_joker():
			card.value = 0.0
			card.table_value = 0.0
		else:
			card.value = float(number_regex.search(resource_name).get_string())
			card.table_value = card.value
		
		if backs.size() > 0:
			card.back_texture = backs[0]
		
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
