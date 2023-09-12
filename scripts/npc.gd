extends CharacterBody2D

var speed = 100
var start_pos = Vector2(128, 436)
var end_pos = Vector2(1875, 436)
var target_pos = start_pos
@onready var anim_npc = $AnimationPlayer

func _ready():
	global_position = start_pos
	set_new_target()

func _physics_process(delta):
	var move_direction = (target_pos - global_position).normalized()
	var movement = move_direction * speed * delta
	move_and_collide(movement)
	
	# Play the correct walking animation based on the direction
	if move_direction.x < 0:
		anim_npc.play("player/walk_left")
	elif move_direction.x > 0:
		anim_npc.play("player/walk_right")

	# Check if the character is close enough to the target position
	if global_position.distance_to(target_pos) < 10:
		set_new_target()

func set_new_target():
	target_pos.x = randf_range(start_pos.x, end_pos.x)
	target_pos.y = 436
