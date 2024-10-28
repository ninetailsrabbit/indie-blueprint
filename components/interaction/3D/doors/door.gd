class_name Door extends Node3D

signal opened
signal closed
signal locked
signal unlocked
signal tried_to_open_locked_door


@export_group("Interaction parameters")
@export var interactable: Interactable3D
@export var is_open: bool = false:
	set(value):
		if value != is_open:
			if value:
				opened.emit()
			else:
				closed.emit()
		is_open = value
		
@export var is_locked := false:
	set(value):
		if value != is_locked:
			if value:
				unlocked.emit()
			
		is_locked = value
@export var door_name: String = "Door"
@export var key_id: String = ""
@export var delay_before_close: float = 0.0
@export_range(0, 180, 0.01) var default_open_angle: float = 0.0
@export_group("Tween")
@export var use_tweens: bool = false
@export var time_to_open: float = 0.3
@export var time_to_close: float = 0.3
@export var open_rotation: float = 90.0
@export var pivot_point: Node3D
@export_group("Animation")
@export var animation_player: AnimationPlayer
@export var open_door_animation: String = "open"
@export var close_door_animation: String = "close"
@export var locked_door_animation: String = "locked"
@export var unlocked_door_animation: String = "unlocked"

var door_tween: Tween

func _ready() -> void:
	if interactable == null:
		interactable = NodeTraversal.first_node_of_custom_class(self, Interactable3D) as Interactable3D
		
	if animation_player == null:
		animation_player = NodeTraversal.first_node_of_type(self, AnimationPlayer.new()) as AnimationPlayer
		
	assert(interactable is Interactable3D, "Door: The door %s needs an interactable to be valid" % door_name)
	assert(use_tweens or (not use_tweens and animation_player is AnimationPlayer), "Door: The door %s needs an animation player to be valid" % door_name)

	is_locked = not key_id.is_empty()
	
	pivot_point.rotation.y = deg_to_rad(default_open_angle)
	
	interactable.interacted.connect(on_interacted)
	tried_to_open_locked_door.connect(on_tried_to_open_locked_door)
	
	
func open() -> void:
	if is_locked:
		tried_to_open_locked_door.emit()
	else:
		if not is_open:
			if use_tweens:
				door_tween = create_tween()
				door_tween.tween_property(pivot_point, "rotation:y", deg_to_rad(open_rotation), time_to_open).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			else:
				animation_player.play(open_door_animation)
	
		is_open = true


func close() -> void:
	if not is_locked and delay_before_close > 0 and is_open:
		await get_tree().create_timer(delay_before_close).timeout
	
	if use_tweens:
		door_tween = create_tween()
		door_tween.tween_property(pivot_point, "rotation:y", deg_to_rad(default_open_angle), time_to_open).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	else:
		if animation_player.has_animation(close_door_animation):
			animation_player.play(close_door_animation)
		else:
			animation_player.play_backwards(open_door_animation)
		
	is_open = false


func use_key(id: String) -> void:
	if key_id == id:
		if animation_player.has_animation(unlocked_door_animation):
			animation_player.play(unlocked_door_animation)
			is_locked = false
			open()
	else:
		tried_to_open_locked_door.emit()


	
#To override on extended class
func lock() -> void:
	pass
	
func unlock() -> void:
	pass

func can_be_interacted() -> bool:
	return (animation_player is AnimationPlayer and not animation_player.is_playing()) \
		or (use_tweens and (door_tween == null or (door_tween and not door_tween.is_running())) )

#region Signal callbacks
func on_interacted() -> void:
	if can_be_interacted():
		if is_open:
			close()
		else:
			open()
		

func on_tried_to_open_locked_door() -> void:
	if is_locked and animation_player.has_animation(locked_door_animation) and can_be_interacted():
		animation_player.play(locked_door_animation)
#endregion
	
