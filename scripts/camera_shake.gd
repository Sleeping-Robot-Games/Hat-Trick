extends Camera2D

# Screen shake variables
var shake_duration = 0.0
var shake_magnitude = 0.0
var shake_speed = 50.0
var stopped = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("ControlPanel").play()
	g.play_sfx(self, 'elevator_sfx')
	g.play_bgm('elevator')
	self.shake_camera(8, 1)
	await get_tree().create_timer(6).timeout
	get_parent().get_node('Elevator Background').slow()
	await get_tree().create_timer(2).timeout
	get_parent().get_node('Elevator Background').stop()
	get_parent().get_node("Door").play()
	
	get_parent().get_node("InteractButton").show()
	stopped = true

func _input(event):
	if stopped and Input.is_action_just_pressed("interact"):
		g.level = 2
		g.stop_bgm('elevator')
		g.play_bgm('background')
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	

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
