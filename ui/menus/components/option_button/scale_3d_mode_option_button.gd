class_name Scale3DModeOptionButton extends OptionButton

var valid_scale_modes: Array[Viewport.Scaling3DMode] = [
	Viewport.Scaling3DMode.SCALING_3D_MODE_BILINEAR,
	Viewport.Scaling3DMode.SCALING_3D_MODE_FSR,
	Viewport.Scaling3DMode.SCALING_3D_MODE_FSR2,
]


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():
			await ready

		prepare_scale_mode_items()


func _ready() -> void:
	prepare_scale_mode_items()

	item_selected.connect(on_scale_mode_selected)


func prepare_scale_mode_items() -> void:
	clear()
	
	for mode: Viewport.Scaling3DMode in valid_scale_modes:
		add_item(_scale_mode_to_string(mode), mode)
	
	select(get_item_index(get_viewport().scaling_3d_mode))
	

func _scale_mode_to_string(mode) -> String:
	match mode:
		Viewport.Scaling3DMode.SCALING_3D_MODE_BILINEAR:
			return tr(TranslationKeys.Scaling3dModeBilinear)
		Viewport.Scaling3DMode.SCALING_3D_MODE_FSR:
			return tr(TranslationKeys.Scaling3dModeFSR)
		Viewport.Scaling3DMode.SCALING_3D_MODE_FSR2:
			return tr(TranslationKeys.Scaling3dModeFSR2)
		_:
			return tr(TranslationKeys.Scaling3dModeBilinear)


func on_scale_mode_selected(idx) -> void:
	get_viewport().scaling_3d_mode = get_item_id(idx) as Viewport.Scaling3DMode
	SettingsManager.update_graphics_section(GameSettings.Scaling3DMode, get_viewport().scaling_3d_mode)
