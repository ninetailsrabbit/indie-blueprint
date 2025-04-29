class_name AllowTelemetryCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = IndieBlueprintSettingsManager.get_analytics_section(IndieBlueprintGameSettings.AllowTelemetrySetting)
	toggled.connect(on_allow_telemetry_changed)


func on_allow_telemetry_changed(enabled: bool) -> void:
	IndieBlueprintSettingsManager.update_analytics_section(IndieBlueprintGameSettings.AllowTelemetrySetting, enabled)
