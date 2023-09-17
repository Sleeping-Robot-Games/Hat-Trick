extends Camera2D

# Screen shake variables
var shake_duration = 0.0
var shake_magnitude = 0.0
var shake_speed = 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.shake_camera(10, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if shake_duration > 0:
		# Calculate an offset using a random direction and the magnitude
		var offset = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized() * shake_magnitude
		# Apply the offset to the camera's position
		self.global_position += offset
		
		# Decrease the duration of the shake by the elapsed time
		shake_duration -= delta
	else:
		shake_duration = 0.0
		shake_magnitude = 0.0
		
func shake_camera(duration, magnitude):
	shake_duration = duration
	shake_magnitude = magnitude
