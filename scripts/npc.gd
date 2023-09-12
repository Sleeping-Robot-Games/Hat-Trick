extends CharacterBody2D

var speed = 100
var start_pos = Vector2(128, 436)
var end_pos = Vector2(1875, 436)
var target_pos = start_pos
var is_moving = true
var last_direction = 1 # 1 for right, -1 for left
@onready var anim_npc = $AnimationPlayer
@onready var idle_timer = $SpriteHolder/IdleTimer

func _ready():
	global_position = start_pos
	set_new_target()

func _physics_process(delta):
	if is_moving:
		var move_direction = (target_pos - global_position).normalized()
		var movement = move_direction * speed * delta
		move_and_collide(movement)

		if move_direction.x < 0:
			anim_npc.play("player/walk_left")
			last_direction = -1
		elif move_direction.x > 0:
			anim_npc.play("player/walk_right")
			last_direction = 1

		# Check if character has reached its target
		if (last_direction == 1 and global_position.x >= target_pos.x) or (last_direction == -1 and global_position.x <= target_pos.x):
			reach_target()

func reach_target():
	is_moving = false
	idle_timer.start(randf_range(2, 8))
	play_idle_animation()

func play_idle_animation():
	if last_direction == -1:
		anim_npc.play("player/idle_left")
	elif last_direction == 1:
		anim_npc.play("player/idle_right")

func set_new_target():
	target_pos.x = randf_range(start_pos.x, end_pos.x)
	target_pos.y = 436

func _on_idle_timer_timeout():
	set_new_target()
	is_moving = true
