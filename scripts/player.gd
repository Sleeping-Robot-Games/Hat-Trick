extends CharacterBody2D

const speed = 3
var facing = "left"
var is_dancing = false
@onready var anim_player = $AnimationPlayer

var directions = {
	"right": Vector2(1, 0),
	"left": Vector2(-1, 0)
}
	
var inputs = {
	"right": ["ui_right", KEY_D],
	"left": ["ui_left", KEY_A],
	"action": ["ui_action", KEY_ENTER]
}

func _ready():
	# $HatTowerTimerTest.start()
	pass

func _physics_process(delta):
	move_and_collide(velocity * delta)
	handle_input()

func handle_input():
	var movement_direction = Vector2.ZERO
	
	for direction in directions.keys():
		if Input.is_action_pressed(inputs[direction][0]) or Input.is_key_pressed(inputs[direction][1]):
			movement_direction += directions[direction]
			facing = determine_animation_suffix(directions[direction])
			
	if movement_direction.length() > 0:
		is_dancing = false
		movement_direction = movement_direction.normalized()
		position += movement_direction * speed
		anim_player.play("player/walk_%s" % determine_animation_suffix(movement_direction))
	elif Input.is_action_just_pressed("ui_accept", KEY_E):
		if !is_dancing:
			is_dancing = true
		else:
			is_dancing = false
	elif is_dancing:
		anim_player.play("player/dance")
	else:
		anim_player.play("player/idle_%s" % facing)

func determine_animation_suffix(direction: Vector2) -> String:
	if direction == Vector2(1, 0):
		return "right"
	elif direction == Vector2(-1, 0):
		return "left"
	return ""

## TESTING HAT TOWER STACK
var active_hat = 'snapback'
var hat_array = g.hat_index.keys()
var hat_iteration = 0

func _on_timer_timeout():
	var new_hat = Sprite2D.new()
	new_hat.set_texture(load("res://assets/sprites/hat/%s.png" % hat_array[hat_iteration]))
	new_hat.hframes = 8
	new_hat.vframes = 3
	new_hat.frame = 0
	if hat_iteration == 0:
		new_hat.position.y = new_hat.position.y - g.hat_index[active_hat]
	else:
		var cumulative_y_decrement = g.hat_index[active_hat]
		for i in range(hat_iteration): 
			cumulative_y_decrement += g.hat_index[hat_array[i]]
		
		new_hat.position.y = new_hat.position.y - cumulative_y_decrement
		
	$HatHolder.add_child(new_hat)
	
	hat_iteration += 1
	if hat_iteration == len(hat_array):
		$HatTowerTimerTest.stop()
