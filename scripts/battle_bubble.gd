extends AnimatedSprite2D

# shake
var shake_duration = 0.0
var shake_magnitude = 0.0
var shake_speed = 50.0
# launch
var launch_duration = 0.0
var launch_target = Vector2.ZERO

func shake(duration, magnitude):
	shake_duration = duration
	shake_magnitude = magnitude

func launch(duration, target_pos):
	launch_duration = duration
	launch_target = target_pos

func _process(delta):
	if shake_duration > 0:
		# Calculate an offset using a random direction and the magnitude
		var offset = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized() * shake_magnitude
		# Apply the offset to our position
		global_position += offset
		# Decrease the duration of the shake by the elapsed time
		shake_duration -= delta
	else:
		shake_duration = 0.0
		shake_magnitude = 0.0
	
	if launch_duration > 0:
		global_position.x = lerp(global_position.x, launch_target.x, delta)
		global_position.y = lerp(global_position.y, launch_target.y, delta)
		launch_duration -= delta
	else:
		launch_duration = 0.0
		launch_target = Vector2.ZERO
