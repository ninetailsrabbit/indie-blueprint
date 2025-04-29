@icon("res://addons/ninetailsrabbit.indie_blueprint_ui/src/debug_ui/metrics/performance_metrics.svg")
extends Control

@export var show_hardware_specs_input_action: StringName = &"performance_metrics"
@export var only_fps_counter: bool = false:
	set(value):
		only_fps_counter = value
		
		if is_inside_tree():
			vsync_label.visible = not only_fps_counter
			
			if memory_label:
				memory_label.visible = not only_fps_counter
				
			os_label.visible = not only_fps_counter
			distro_label.visible = not only_fps_counter
			cpu_label.visible = not only_fps_counter
			gpu_label.visible = not only_fps_counter

@onready var fps_label: Label = %FPSLabel
@onready var vsync_label: Label = %VsyncLabel
@onready var memory_label: Label = %MemoryLabel
@onready var os_label: Label = %OSLabel
@onready var distro_label: Label = %DistroLabel
@onready var cpu_label: Label = %CPULabel
@onready var gpu_label: Label = %GPULabel


func _input(_event: InputEvent) -> void:
	if InputMap.has_action(show_hardware_specs_input_action) \
		and Input.is_action_just_pressed(show_hardware_specs_input_action):
		visible = !visible


func _enter_tree() -> void:
	visibility_changed.connect(on_visibility_changed)


func _ready() -> void:
	hide()
	
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	
	if not OS.is_debug_build():
		memory_label.queue_free()
		
	if only_fps_counter:
		vsync_label.hide()
		
		if memory_label:
			memory_label.hide()
			
		os_label.hide()
		distro_label.hide()
		cpu_label.hide()
		gpu_label.hide()

	vsync_label.text = "Vsync: %s" % ("Yes" if DisplayServer.window_get_vsync_mode() > 0 else "No")
	os_label.text = "OS: %s" % OS.get_name()
	distro_label.text = "Distro: %s" % OS.get_distribution_name()
	cpu_label.text = "CPU: %s" % OS.get_processor_name()
	gpu_label.text = "GPU: %s" % RenderingServer.get_video_adapter_name()
	

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	
	if OS.is_debug_build() and memory_label:
		memory_label.text = "Memory: %d MiB" % (OS.get_static_memory_usage() / 1048576.0)
	

func on_visibility_changed() -> void:
	set_process(visible)
