extends AnimatedSprite2D

# shake
var shaking = false
var shake_duration = 0.0
var shake_magnitude = 0.0
var shake_speed = 50.0
# launch
var launch_duration = 0.0
var launch_target = Vector2.ZERO

func shake(duration, magnitude):
	shake_duration = duration
	shake_magnitude = magnitude
	await get_tree().create_timer(duration).timeout

func _process(delta):
	if shake_duration > 0:
		# Calculate an offset using a random direction and the magnitude
		var offset = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized() * shake_magnitude
		# Apply the offset to our position
		position += offset
		# Decrease the duration of the shake by the elapsed time
		shake_duration -= delta
	else:
		shake_duration = 0.0
		shake_magnitude = 0.0
