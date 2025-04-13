class_name IndieBlueprintFirstPersonController extends CharacterBody3D

@export_group("Mechanics")
@export var run: bool = true
@export var dash: bool = true
@export var air_dash: bool = true
@export var jump: bool = true
@export var crouch: bool = true
@export var crawl: bool = false
@export var slide: bool = true
@export var wall_run: bool = false
@export var wall_jump: bool = false
@export var wall_climb: bool = false
@export var surf: bool = false
@export var swim: bool = false
@export var stairs: bool = true
@export var ladder_climb: bool = false

@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var camera: CameraShake3D = $Head/Eyes/CameraShake3D

var motion_input: MotionInput = MotionInput.new(self)
var was_grounded: bool = false
var is_grounded: bool = false
var original_head_position: Vector3


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		switch_mouse_capture_mode()


func _ready() -> void:
	IndieBlueprintInputHelper.capture_mouse()

	collision_layer = IndieBlueprintGameGlobals.player_collision_layer
	original_head_position = head.position


func _physics_process(_delta: float) -> void:
	motion_input.update()
	was_grounded = is_grounded
	is_grounded = is_on_floor()


func switch_mouse_capture_mode() -> void:
	if IndieBlueprintInputHelper.is_mouse_visible():
		IndieBlueprintInputHelper.capture_mouse()
	else:
		IndieBlueprintInputHelper.show_mouse_cursor()
