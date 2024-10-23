@icon("res://components/camera/2D/shake/shake_camera_2d.svg")
class_name ShakeCamera2D extends Camera2D

## ## Power of the trauma to control the intensity of camera shake.
@export var trauma_power: float = 1.5
## Speed of the noise to determine how quickly the shake changes over time.
@export var noise_speed: float = 5
## Decay rate to control how quickly the camera's trauma decreases over time.
@export var decay: float = 0.8
## Amplitude of the shake to adjust the magnitude of camera movement.
@export var amplitude: float = 18.0
## Type of noise used to generate the camera shake. Recommended TYPE_PERLIN OR TYPE_SIMPLEX
@export var noise_type: = FastNoiseLite.TYPE_PERLIN:
	set(value):
		if value != noise_type && is_node_ready():
			noise.noise_type = value
			noise.seed = randi()
			
		noise_type = value

@onready var noise = FastNoiseLite.new()

var trauma: float = 0.0
var noise_y: float = 0.0

func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		add_trauma(1.0)

func _ready():
	noise.seed = randi()
	noise.noise_type = noise_type


func _process(delta):
	if is_current() and trauma:
		trauma = max(trauma - decay * delta, 0)
		noise_y += noise_speed
		shake()


func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)


func shake():
	var amount = pow(trauma, trauma_power)
	offset = Vector2(amplitude * amount * noise.get_noise_2d(noise.seed, noise_y), amplitude * amount * noise.get_noise_2d(noise.seed * 2, noise_y))
