@icon("res://components/interaction/2D/outline/outliner.svg")
class_name Outliner2D extends Node

const OutlineShader: Shader = preload("res://shaders/environment/2d_outline.gdshader")

@export var target: Node2D
@export var default_color: Color = Color.YELLOW
@export var default_thickness: float = 1.0

var material: ShaderMaterial


func _ready() -> void:
	if target and OutlineShader:
		material = ShaderMaterial.new()
		material.shader = OutlineShader
		target.material = material


func apply(color: Color = default_color, thickness: float = default_thickness) -> void:
	if target and material:
		material.set_shader_parameter("clr", color)
		material.set_shader_parameter("thickness", thickness)
		material.set_shader_parameter("type", 1)


func remove() -> void:
	if target and material:
		material.set_shader_parameter("thickness", 0)
