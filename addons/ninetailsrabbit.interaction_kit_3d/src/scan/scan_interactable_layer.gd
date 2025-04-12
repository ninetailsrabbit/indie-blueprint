extends CanvasLayer

signal scan_started(target: Node3D)
signal scan_ended(target: Node3D)

@onready var scan_interactable: ScanInteractable = %ScanInteractable
@onready var control: Control = $Control

var original_mouse_mode: Input.MouseMode


func _ready() -> void:
	hide()
	
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scan_interactable.scan_ended.connect(on_scan_ended)


func scan(target: Node3D) -> void:
	show()
	
	original_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	scan_started.emit(target)
	control.mouse_filter = Control.MOUSE_FILTER_PASS
	scan_interactable.scan(target)


func on_scan_ended(target: Node3D) -> void:
	hide()
	scan_ended.emit(target)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	Input.mouse_mode = original_mouse_mode
