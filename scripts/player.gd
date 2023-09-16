extends CharacterBody2D

const speed = 3
const type = 'Player'

var facing = "left"
var is_dancing = false
var is_fighting = false
var battle_pos = Vector2.ZERO
var battle_pos_speed = 150
var hat_array = []
var stats
var player_name

@onready var anim_player = $AnimationPlayer
@onready var game = get_parent()

var directions = {
	"right": 1,
	"left": -1
}
var direction = 0

	
var inputs = {
	"right": ["ui_right", KEY_D],
	"left": ["ui_left", KEY_A],
	"action": ["ui_action", KEY_ENTER]
}

func _ready():
	#$HatTowerTimerTest.start()
	# position.y = 435
	pass

func start_fighting(x):
	battle_pos.x = x
	battle_pos.y = g.current_level_y_pos
	is_fighting = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", battle_pos, 1)
	
	anim_player.play("player/idle_right")

func add_hat(hat_name):
	hat_array.append(hat_name)
	if hat_array.size() == 1:
		return # this is the first hat from the character creation
	active_hat = hat_array[0]
	var new_hat = Sprite2D.new()
	new_hat.set_texture(load("res://assets/sprites/hat/%s.png" % hat_name))
	new_hat.hframes = 8
	new_hat.vframes = 3
	new_hat.frame = 0
	
	var cumulative_y_decrement = 0
	for i in range(hat_array.size()-1):
		cumulative_y_decrement += g.hat_index[hat_array[i]] / 1.5
	new_hat.position.y = new_hat.position.y - cumulative_y_decrement
	
	$HatHolder.add_child(new_hat)

func apply_stats(_stats):
	stats = _stats

func _physics_process(delta):
	if not is_fighting:
		move_and_collide(velocity * delta)
		handle_input()
		
	var hat_shift = 0.0
	for hat in $HatHolder.get_children():
		hat.flip_h = (facing == "right")
		hat_shift += 1.0
		var target_x = -direction * hat_shift
		hat.position.x = lerp(hat.position.x, target_x, 0.05)
		
		
func handle_input():
	var movement_direction = Vector2.ZERO
	var is_moving = false

	for dir_key in directions.keys():
		if Input.is_action_pressed(inputs[dir_key][0]) or Input.is_key_pressed(inputs[dir_key][1]):
			direction = directions[dir_key]
			movement_direction += Vector2(direction, 0)
			facing = determine_animation_suffix(Vector2(direction, 0))
			is_moving = true
	
	if not is_moving:
		direction = 0
			
	if movement_direction.length() > 0:
		is_dancing = false
		movement_direction = movement_direction.normalized()
		position += movement_direction * speed
		anim_player.play("player/walk_%s" % determine_animation_suffix(movement_direction))
	elif Input.is_action_just_pressed('interact') and g.focused_npc:
		game.hat_fight(self, g.focused_npc)
	elif Input.is_action_just_pressed("ui_accept", KEY_E):
		if !is_dancing:
			is_dancing = true
		else:
			is_dancing = false
	elif is_dancing:
		anim_player.play("player/dance")
	else:
		anim_player.play("player/idle_%s" % facing)

func determine_animation_suffix(dir: Vector2) -> String:
	if dir == Vector2(1, 0):
		return "right"
	elif dir == Vector2(-1, 0):
		return "left"
	return ""

## TESTING HAT TOWER STACK
var active_hat = 'snapback'
var all_hats = g.hat_index.keys()
var hat_iteration = 0

func _on_timer_timeout():
	add_hat(all_hats[hat_iteration])
	
	hat_iteration += 1
	
	if hat_iteration == all_hats.size():
		$HatTowerTimerTest.stop()

func _on_button_button_up():
	add_hat(all_hats.pick_random())
