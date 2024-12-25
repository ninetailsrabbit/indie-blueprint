class_name FootstepSound extends Resource

enum FootstepType {
	Ground,
	Land,
	Jump
}


@export var material: StringName = &""
@export_category("Ground")
## The sound for a normal footstep in the ground
@export var ground_stream: AudioStream
## When enabled a pitch range value is applied each time the stream is played
@export var ground_use_pitch: bool = true
@export var ground_min_pitch_range : float = 0.9
@export var ground_max_pitch_range: float = 1.3
@export_category("Land")
## The sound when landing after fall in the ground
@export var land_stream: AudioStream
## When enabled a pitch range value is applied each time the stream is played
@export var land_use_pitch: bool = true
@export var land_min_pitch_range : float = 0.9
@export var land_max_pitch_range: float = 1.3
@export_category("Jump")
## The sound when jumping from the ground
@export var jump_stream: AudioStream
## When enabled a pitch range value is applied each time the stream is played
@export var jump_use_pitch: bool = true
@export var jump_min_pitch_range : float = 0.9
@export var jump_max_pitch_range: float = 1.3
