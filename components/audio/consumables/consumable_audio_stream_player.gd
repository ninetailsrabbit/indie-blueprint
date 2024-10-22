class_name ConsumableAudioStreamPlayer extends AudioStreamPlayer

@export var number_of_plays: int = 1


var current_plays: int = 0:
	set(value):
		if value != current_plays:
			current_plays = max(0, value)
			
			if current_plays >= number_of_plays and not is_queued_for_deletion():
				stream = null
				queue_free()


func _ready() -> void:
	finished.connect(on_finished)
	
	
func on_finished() -> void:
	current_plays += 1
