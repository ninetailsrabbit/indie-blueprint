@icon("res://components/cards/2D/icons/deck.svg")
class_name DeckControl extends Control

const PlayingCardScene: PackedScene = preload("res://components/cards/2D/control/playing_card_control.tscn")

signal loaded_new_deck
signal added_card(card: PlayingCardControl)
signal added_cards(card: Array[PlayingCardControl])
signal picked_card(card: PlayingCardControl)
signal removed_card(card: PlayingCardControl)
signal added_to_discard_pile(card: PlayingCardControl)
signal recovered_card_from_discard_pile(card: PlayingCardControl)
signal emptied_deck
signal filled
signal shuffled

@export var playing_cards_size: Vector2 = Vector2.ZERO


#region Card templates
var cards_by_suit: Dictionary = {}
var cards: Array[PlayingCardControl] = []
var jokers: Array[PlayingCardControl] = []
var backs: Array[CompressedTexture2D] = []
#endregion


var current_back_texture: CompressedTexture2D
var current_cards_by_suit: Dictionary = {}
var current_cards: Array[PlayingCardControl] = []
var discard_pile: Array[PlayingCardControl] = []

var jokers_count_for_empty_deck: bool = false

var visual_pile_cards_amount: int = 5
var visual_pile_counter: int:
	set(value):
		@warning_ignore("integer_division")
		visual_pile_counter = clampi(value, 0, calculate_visual_pile_counter())

#region Preparation 
func _enter_tree() -> void:
	removed_card.connect(on_removed_card)


func _ready() -> void:
	if current_back_texture == null and backs.size() > 0:
		current_back_texture = backs.pick_random()


@warning_ignore("integer_division")
func calculate_visual_pile_counter() -> int:
	return ceili(cards.size() / visual_pile_cards_amount)
#
#func load_deck_data(raw_data: DeckDatabase.DeckRawData, playing_card_scene: PackedScene = PlayingCardScene) -> Deck:
	#deck_type = raw_data.type
	#backs.append_array(raw_data.deck[PlayingCard.Suits.Back])
	#
	#_add_jokers_to_deck(raw_data, playing_card_scene)
	#_add_cards_to_deck(raw_data, playing_card_scene)
	#
	#if current_back_texture == null and backs.size() > 0:
		#current_back_texture = backs.pick_random()
		#
	#loaded_new_deck.emit()
	#
	#return self
	

func draw_visual_pile(amount: int = visual_pile_cards_amount, distance: float = 1.5) -> void:
	@warning_ignore("integer_division")
	visual_pile_counter = calculate_visual_pile_counter()
	
	var reference_card: PlayingCardControl = cards[0]
	
	for i in amount:
		var visual_sprite = TextureRect.new()
		
		if reference_card.card.texture_size != reference_card.card.back_texture.get_size():
			visual_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			visual_sprite.size = reference_card.card.texture_size
			
		visual_sprite.texture = current_back_texture
		visual_sprite.position = Vector2(i * distance, -i * distance)
		add_child(visual_sprite)
		
		if i == 0:
			visual_sprite.position.y += 1
			visual_sprite.show_behind_parent = true
			visual_sprite.self_modulate = reference_card.shadow_color
	

func fill() -> DeckControl:
	current_cards = cards.duplicate()
	current_cards_by_suit = cards_by_suit.duplicate(true)
	## The jokers can be only added by the function 'add_jokers'
	current_cards_by_suit[PlayingCard.Suits.Joker].clear()
	
	filled.emit()
	
	return self


func shuffle() -> DeckControl:
	current_cards.shuffle()
	shuffled.emit()
	
	return self
#endregion
	
#region Random pickers
func pick_random_card() -> PlayingCardControl:
	if current_cards.is_empty():
		return null
	
	return pick_card(current_cards.pick_random())
	

func pick_random_cards(amount: int) -> Array[PlayingCardControl]:
	if current_cards.is_empty():
		return []
	
	var selected_cards: Array[PlayingCardControl] = []
	amount = clamp(amount, 1, current_cards.size())
	
	for i in amount:
		selected_cards.append(pick_card(current_cards.pick_random()))
	
	return selected_cards


func pick_random_number_card() -> PlayingCardControl:
	return pick_card(number_cards().pick_random())


## The function parameter "suit" is not typed as the suits are separated into different enums
func pick_random_card_from_suit(suit) -> PlayingCardControl:
	if current_cards_by_suit.has(suit) and current_cards_by_suit[suit].size() > 0:
		return pick_card(current_cards_by_suit[suit].pick_random())
	
	return null


func pick_random_card_of_value(value: int) -> PlayingCardControl:
	var selected_cards: Array[PlayingCardControl] = current_cards.filter(
		func(playing_card: PlayingCardControl): return playing_card.card.value == value
		)
	
	if selected_cards.size() > 0:
		return pick_card(selected_cards.pick_random())
	
	return null


func pick_random_card_of_suit_and_value(suit, value: int) -> PlayingCardControl:
	var selected_cards: Array[PlayingCardControl] = cards_from_suit(suit).filter(
		func(playing_card: PlayingCardControl): return playing_card.card.value == value
		)
	
	if selected_cards.size() > 0:
		return pick_card(selected_cards.pick_random())
	
	return null


func pick_random_ace() -> PlayingCardControl:
	var aces: Array[PlayingCardControl] = current_cards.filter(
		func(playing_card: PlayingCardControl): return playing_card.card.is_ace()
		)
	
	if aces.is_empty():
		return null
		
	return pick_card(aces.pick_random())


func pick_random_jack() -> PlayingCardControl:
	var jacks: Array[PlayingCardControl] = current_cards.filter(
		func(playing_card: PlayingCardControl): return playing_card.card.is_jack()
		)
	
	if jacks.is_empty():
		return null
		
	return pick_card(jacks.pick_random())


func pick_random_queen() -> PlayingCardControl:
	var queens: Array[PlayingCardControl] = current_cards.filter(
		func(playing_card: PlayingCardControl): return playing_card.card.is_queen()
		)
	
	if queens.is_empty():
		return null
		
	return pick_card(queens.pick_random())


func pick_random_knight() -> PlayingCardControl:
	var knights: Array[PlayingCardControl] = current_cards.filter(
		func(playing_card: PlayingCardControl): return playing_card.card.is_knight()
		)
	
	if knights.is_empty():
		return null
		
	return pick_card(knights.pick_random())


func pick_random_king() -> PlayingCardControl:
	var kings: Array[PlayingCardControl] = current_cards.filter(
		func(playing_card: PlayingCardControl): return playing_card.card.is_king()
		)
	
	if kings.is_empty():
		return null
		
	return pick_card(kings.pick_random())


func pick_random_joker() -> PlayingCardControl:
	var selected_jokers: Array[PlayingCardControl] = current_cards.filter(
		func(playing_card: PlayingCardControl): return playing_card.card.is_joker()
		)
	
	if selected_jokers.is_empty():
		return null
		
	return pick_card(selected_jokers.pick_random())

#endregion

#region Pickers
func pick_cards(selected_cards: Array[PlayingCardControl]) -> Array[PlayingCardControl]:
	for card in selected_cards:
		pick_card(card)
		
	return selected_cards
	
	
func pick_card(card: PlayingCardControl) -> PlayingCardControl:
	remove_card(card)
	picked_card.emit(card)
	
	return card


func number_cards() -> Array[PlayingCardControl]:
	return extract_number_cards(current_cards)
	

func number_cards_from_suit(suit) -> Array[PlayingCardControl]:
	return extract_number_cards(cards_from_suit(suit))


func figure_cards() -> Array[PlayingCardControl]:
	return extract_figure_cards(current_cards)
	

func figure_cards_from_suit(suit) -> Array[PlayingCardControl]:
	return extract_figure_cards(cards_from_suit(suit))


func extract_number_cards(selected_cards: Array[PlayingCardControl]) -> Array[PlayingCardControl]:
	return selected_cards.filter(func(playing_card: PlayingCardControl): return playing_card.card.is_number())


func extract_figure_cards(selected_cards: Array[PlayingCardControl]) -> Array[PlayingCardControl]:
	return selected_cards.filter(func(playing_card: PlayingCardControl): return playing_card.card.is_figure())
	

func cards_from_suit(suit) -> Array[PlayingCardControl]:
	if current_cards_by_suit.has(suit):
		return current_cards_by_suit[suit]
	
	return []

#endregion

func add_cards(new_cards: Array[PlayingCardControl], allow_duplicates: bool = false) -> void:
	for card: PlayingCardControl in new_cards:
		add_card(card, allow_duplicates)
	
	added_cards.emit(new_cards)


func add_card(playing_card: PlayingCardControl, allow_duplicates: bool = false) -> void:
	if allow_duplicates:
		current_cards.append(playing_card)
		current_cards_by_suit[playing_card.card.suit].append(playing_card)
	else:
		if not current_cards.has(playing_card):
			current_cards.append(playing_card)
			
		if not current_cards_by_suit[playing_card.card.suit].has(playing_card):
			current_cards_by_suit[playing_card.card.suit].append(playing_card)
	
	added_card.emit(playing_card)
	
	
func remove_card(playing_card: PlayingCardControl):
	current_cards.erase(playing_card)
	
	if current_cards_by_suit.has(playing_card.card.suit):
		current_cards_by_suit[playing_card.card.suit].erase(playing_card)
		removed_card.emit(playing_card)
	
	if is_empty():
		emptied_deck.emit()
	
	add_to_discard_pile(playing_card)
	

func add_jokers(amount: int, selected_card: PlayingCardControl = null) -> DeckControl:
	if amount > 0 and jokers.size() > 0:
		var new_jokers: Array[PlayingCardControl] = []
		var joker: PlayingCardControl = selected_card if selected_card != null and selected_card.card.is_joker() else jokers.pick_random()
		
		new_jokers.assign(ArrayHelper.repeat(joker, amount))
		
		add_cards(new_jokers)
		
	return self
	

#region Discard pile
func add_to_discard_pile(playing_card: PlayingCardControl) -> void:
	if not discard_pile.has(playing_card):
		discard_pile.append(playing_card)
		added_to_discard_pile.emit(playing_card)


func extract_from_discard_pile(playing_card: PlayingCardControl) -> PlayingCardControl:
	if discard_pile.has(playing_card):
		var selected_card: PlayingCardControl = discard_pile[discard_pile.find(playing_card)]
		discard_pile.erase(playing_card)
		
		return selected_card
	
	return null


func recover_from_discard_pile(playing_card: PlayingCardControl) -> PlayingCardControl:
	var card_to_recover: PlayingCardControl = extract_from_discard_pile(playing_card)
	
	if card_to_recover != null:
		add_card(card_to_recover)
		recovered_card_from_discard_pile.emit(playing_card)
	return null
#endregion

#region Information
func has_aces() -> bool:
	return current_cards.any(func(playing_card: PlayingCardControl): return playing_card.card.is_ace())
	
	
func has_jokers() -> bool:
	return current_cards.any(func(playing_card: PlayingCardControl): return playing_card.card.is_joker())
	

func has_only_jokers() -> bool:
	return current_cards.all(func(playing_card: PlayingCardControl): return playing_card.card.is_joker())
	
	
func has_jacks() -> bool:
	return current_cards.any(func(playing_card: PlayingCardControl): return playing_card.card.is_jack())
	
	
func has_queens() -> bool:
	return current_cards.any(func(playing_card: PlayingCardControl): return playing_card.card.is_queen())
	

func has_knights() -> bool:
	return current_cards.any(func(playing_card: PlayingCardControl): return playing_card.card.is_knight())
	

func has_kings() -> bool:
	return current_cards.any(func(playing_card: PlayingCardControl): return playing_card.card.is_king())
	
	
func has_number_cards() -> bool:
	return current_cards.any(func(playing_card: PlayingCardControl): return playing_card.card.is_number())
	

func is_empty() -> bool:
	return (has_only_jokers() and not jokers_count_for_empty_deck) or current_cards.is_empty()


func size() -> int:
	return current_cards.size()

#endregion

#region Private
#func _add_jokers_to_deck(deck_data: DeckDatabase.DeckRawData, playing_card_scene: PackedScene) -> void:
	#for card_texture: CompressedTexture2D in deck_data.deck[PlayingCard.Suits.Joker]:
		#var joker_card: PlayingCardControl = playing_card_scene.instantiate()
		#joker_card.card.id = "joker_%d" % jokers.size() 
		#joker_card.card.display_name = "Joker"
		#joker_card.card.front_texture = card_texture
		#joker_card.card.value = 0
		#joker_card.card.table_value = 0
		#
		#if not playing_cards_size.is_zero_approx():
			#joker_card.card.texture_size = playing_cards_size
		#
		#jokers.append(joker_card)
		#
		#if cards_by_suit.has(PlayingCard.Suits.Joker):
			#cards_by_suit[PlayingCard.Suits.Joker].append(joker_card)
		#else:
			#cards_by_suit[PlayingCard.Suits.Joker] = [joker_card]
#
#
#func _add_cards_to_deck(deck_data: DeckDatabase.DeckRawData, playing_card_scene: PackedScene) -> void:
	#var suits = []
	#
	#if is_spanish_deck():
		#suits = PlayingCard.SpanishSuits
	#elif is_french_deck():
		#suits = PlayingCard.FrenchSuits
	#else:
		#return
		#
	#for suit in suits:
		#var card_value: int = 1
		#
		#for card_texture: CompressedTexture2D in deck_data.deck[suit]:
			#var playing_card: PlayingCardControl = playing_card_scene.instantiate()
			#playing_card.card.id = card_texture.resource_path.get_file().get_basename().strip_edges().to_camel_case()
			#playing_card.card.display_name = playing_card.card.id.to_pascal_case()
			#playing_card.card.front_texture = card_texture
			#playing_card.card.value = card_value
			#playing_card.card.table_value = card_value
			#playing_card.card.suit = suit
			#
			#if not playing_cards_size.is_zero_approx():
				#playing_card.card.texture_size = playing_cards_size
				#
			#cards.append(playing_card)
			#
			#if cards_by_suit.has(suit):
				#cards_by_suit[suit].append(playing_card)
			#else:
				#cards_by_suit[suit] = [playing_card]
				#
			#if is_spanish_deck():
				### In the spanish deck after the 7 the next one is the jack so we change the card value that allows to be 10 in the next iteration
				#if card_value == 7:
					#card_value = 10
				#else:
					#card_value += 1
			#else:
				#card_value += 1
#endregion

#region Signal callbacks
func on_added_card(_card: PlayingCardControl) -> void:
	visual_pile_counter += 1
	

func on_removed_card(_card: PlayingCardControl) -> void:
	visual_pile_counter -= 1
	
	if visual_pile_counter == 0 and get_child_count() > 0:
		NodeTraversal.get_last_child(self).queue_free()
		@warning_ignore("integer_division")
		visual_pile_counter = calculate_visual_pile_counter()

#endregion
