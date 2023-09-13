extends CharacterBody2D

var speed = 100
var start_pos = Vector2(128, 450)
var end_pos = Vector2(1875, 450)
var target_pos = start_pos
var is_moving = true
var is_dancing = false
var last_direction = 1 # 1 for right, -1 for left
@onready var anim_npc = $AnimationPlayer
@onready var idle_timer = $SpriteHolder/IdleTimer
#@onready var text_bubble = $TextBubble
#@onready var text_bubble_label = $TextBubble/Text

@export var random = false

const idle_text_lines = ["Zzz...", "This place is a dump...", "M'lady!"]
const dancing_text_lines = ["Let's break it down", "Oh yeah baby!", "ohh ahh"]

func _ready():
	global_position = start_pos
	set_new_target()

func _physics_process(delta):
	if is_moving:
		var move_direction = (target_pos - global_position).normalized()
		var movement = move_direction * speed * delta
		move_and_collide(movement)
		
		is_dancing = false
		# Check direction so correct walking animation plays
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
	# Dance 
	var groove_chance = randf()
	if groove_chance < 0.5:
		anim_npc.play("player/dance")
		is_dancing = true
	# Face previous direction if idleing
	elif last_direction == -1:
		anim_npc.play("player/idle_left")
	elif last_direction == 1:
		anim_npc.play("player/idle_right")
		
	# Show the text bubble and set its text
#	text_bubble.visible = true
#	if is_dancing:
#		text_bubble_label.text = dancing_text_lines.pick_random()
#	else:
#		text_bubble_label.text = idle_text_lines.pick_random()

func set_new_target():
#	text_bubble.visible = false
	target_pos.x = randf_range(start_pos.x, end_pos.x)
	target_pos.y = 450

func show_interact():
	$InteractButton.visible = true
	$InteractButton.play('default')

func hide_interact():
	$InteractButton.visible = false
	$InteractButton.stop()

func hat_fight():
	print('HAT FIGHT!')

func _on_idle_timer_timeout():
	set_new_target()
	is_moving = true

func _on_interact_area_body_entered(body):
	if body.name == 'Player':
		g.focus_npc(self)

func _on_interact_area_body_exited(body):
	if body.name == 'Player':
		g.unfocus_npc(self)
