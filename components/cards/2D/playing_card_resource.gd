class_name PlayingCard extends Resource


const SpanishSuits: Array[Suits] = [
	Suits.Cup,
	Suits.Gold,
	Suits.Club,
	Suits.Sword,
]

const FrenchSuits: Array[Suits] = [
	Suits.Heart,
	Suits.Diamond,
	Suits.Club,
	Suits.Spade
]

enum Suits {
	Cup,
	Gold,
	Sword,
	Club,
	Heart,
	Diamond,
	Spade,
	Joker,
	Back
}

enum Orientation {
	FaceUp,
	FaceDown
}

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export_group("Texture")
## When is not Vector2(0, 0) this size will override the original one
@export var texture_size: Vector2 = Vector2.ZERO
## The front texture that displays the value of the card
@export var front_texture: CompressedTexture2D
## The back texture when is face down
@export var back_texture: CompressedTexture2D
@export_group("Values")
@export var suit: Suits
## The meta value from the card
@export var value: float = 1.0
## The value that this card have in the table, can differ from the meta value
@export var table_value: float = 1.0


#region Suit information
func is_spanish() -> bool:
	return suit in SpanishSuits
	

func is_french() -> bool:
	return suit in FrenchSuits


func is_joker() -> bool:
	return value == 0 or suit == Suits.Joker
	
	
func is_ace() -> bool:
	return value == 1
	
	
func is_number() -> bool:
	return value > 1 and value < 11 if is_french() else value > 1 and value < 8


func is_figure() -> bool:
	return is_jack() or is_queen() or is_knight() or is_king()


func is_cup() -> bool:
	return is_spanish() and suit == Suits.Cup
	
	
func is_gold() -> bool:
	return is_spanish() and suit == Suits.Gold


func is_sword() -> bool:
	return is_spanish() and suit == Suits.Sword
	
	
func is_heart() -> bool:
	return is_french() and suit == Suits.Heart
	
	
func is_diamond() -> bool:
	return is_french() and suit == Suits.Diamond


func is_spade() -> bool:
	return is_french() and suit == Suits.Spade
	

func is_club() -> bool:
	return suit == Suits.Club


func is_jack() -> bool:
	return value == 11 if is_french() else value == 10
	
	
func is_queen() -> bool:
	return value == 12 if is_french() else false


func is_knight() -> bool:
	return value == 11 if is_spanish() else false
	
	
func is_king() -> bool:
	return value == 13 if is_french() else value == 12
#endregion
