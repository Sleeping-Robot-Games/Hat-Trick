extends CharacterBody2D

const type = "NPC"
const is_player = false
var speed = 100
var start_pos = Vector2(195, g.current_level_y_pos)
var end_pos = Vector2(1875, g.current_level_y_pos)
var target_pos = start_pos
var is_entering = false
var is_moving = false
var is_dancing = false
var is_paused = false
var is_fighting = false
var available_for_battle = true
var battle_pos = Vector2.ZERO
var battle_pos_speed = 150
var last_direction = 1 # 1 for right, -1 for left
var hat_stack = []
var stats
var npc_name
var active_hat

@onready var anim_npc = $AnimationPlayer
@onready var idle_timer = $SpriteHolder/IdleTimer
@onready var speech_bubble = $SpeechBubble

@export var random = true

const idle_text_lines = ["Zzz...", "This place is a dump...", "M'lady!"]
const dancing_text_lines = ["Let's break it down", "Oh yeah baby!", "ohh ahh"]

func _ready():
	if is_entering:
		available_for_battle = false
		modulate = Color(1, 1, 1, 0)
		
		var duration = 4
		var tween = get_tree().create_tween()
		
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "scale", Vector2(4, 4), duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween.parallel().tween_property(self, "position", Vector2(start_pos), duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		
		tween.parallel().tween_callback(set_moving.bind(true)).set_delay(duration)
		
		var shader_tween_hack = get_tree().create_tween()
		shader_tween_hack.tween_method(_update_shader_modulation, modulate, Color(1, 1, 1, 1), duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		
func _update_shader_modulation(current_modulation):
	for sprite in $SpriteHolder.get_children():
		if sprite is Sprite2D:
			var mat = sprite.material
			if mat:
				mat.set_shader_parameter("parent_modulation", current_modulation)

func set_moving(move):
	is_moving = move
	available_for_battle = move # Only set in the tween callback when they're out the door

func init_stats(hats, _stats):
	hat_stack = hats
	stats = _stats

func _physics_process(delta):
	if is_paused:
		return
		
	elif not is_fighting and is_moving:
		
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
	if not is_fighting:
		idle_timer.start(randf_range(2, 8))
		play_idle_animation()
	else:
		play_idle_animation()

func play_idle_animation():
	# Face previous direction if idleing
	if last_direction == -1:
		anim_npc.play("player/idle_left")
	elif last_direction == 1:
		anim_npc.play("player/idle_right")
		
	if not is_fighting:
		# Dance 
		var groove_chance = randf()
		if groove_chance < 0.01:
			anim_npc.play("player/dance")
			is_dancing = true

	# Show the speech bubble and set its text
#	speech_bubble.visible = true
#	if is_dancing:
#		speech_bubble.set_text(dancing_text_lines.pick_random())
#	else:
#		speech_bubble.set_text(idle_text_lines.pick_random())

func set_new_target(x = randf_range(start_pos.x, end_pos.x)):
	speech_bubble.visible = false
	is_moving = true
	target_pos.x = x
	target_pos.y = g.current_level_y_pos

func show_interact():
	$InteractButton.visible = true
	$InteractButton.play('default')

func hide_interact():
	$InteractButton.visible = false
	$InteractButton.stop()

func start_fighting(pos: Vector2):
	battle_pos = pos
	# in_battle_pos = false
	is_fighting = true
	is_moving = false
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", battle_pos, 1)
	anim_npc.play("player/idle_left")

func stop_fighting(is_victor=false):
	is_fighting = false
	if is_victor:
		$SpeechBubble.set_text(bc.victory_quips.pick_random())
	else:
		$SpeechBubble.set_text(bc.defeat_quips.pick_random())
	await get_tree().create_timer(1).timeout
	var tween = get_tree().create_tween()
	var offscreen_pos =  Vector2(battle_pos.x + 250, battle_pos.y)
	tween.tween_property(self, "position",offscreen_pos, 1)
	tween.tween_callback(queue_free)

func fade_out():
	is_paused = true
	var duration = 1.5
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	
	var shader_tween_hack = get_tree().create_tween()
	shader_tween_hack.tween_method(_update_shader_modulation, modulate, Color(1, 1, 1, 0), duration)

func _on_idle_timer_timeout():
	set_new_target()

func _on_interact_area_body_entered(body):
	if body.name == 'Player' and available_for_battle and not body.is_fighting:
		g.focus_npc(self)

func _on_interact_area_body_exited(body):
	if body.name == 'Player':
		g.unfocus_npc(self)
