class_name LabelHelper


static func adjust_text(label: Label, max_size: int = 200) -> void:
	label.custom_minimum_size.x = min(label.size.x, max_size)
	
	if label.size.x > max_size:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size.y = label.size.y
