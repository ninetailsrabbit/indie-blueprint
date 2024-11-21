class_name PlayingCard extends Node2D

signal selected
signal hovered
signal faced_up
signal faced_down

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var size: Vector2 = Vector2(60, 84)
@export var front_texture: Texture2D
@export var back_texture: Texture2D
## The meta value from the card
@export var value: int = 1
## The value that this card have in the table, can differ from the meta value
@export var table_value: int = 1


enum Orientation {
	FaceUp,
	FaceDown
}

var card_orientation: PlayingCard.Orientation = Orientation.FaceDown:
	set(value):
		if card_orientation != value:
			card_orientation = value
			
			if is_face_up():
				faced_up.emit()
			else:
				faced_down.emit()

#region Card orientation
func is_face_up() -> bool:
	return card_orientation == Orientation.FaceUp
	
	
func is_face_down() -> bool:
	return card_orientation == Orientation.FaceDown
	
	
func face_up() -> void:
	card_orientation = Orientation.FaceUp 
	
	
func face_down() -> void:
	card_orientation = Orientation.FaceDown 

	
func flip() -> void:
	if is_face_up():
		face_down()
	else:
		face_up()
#endregion
	
	
#region Values
func is_joker() -> bool:
	return value == 0
	
	
func is_ace() -> bool:
	return value == 1
	
#endregion
