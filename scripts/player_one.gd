extends CharacterBody2D

const SPEED = 2
var idle_direction = "left"
@onready var anim_player = $AnimationPlayer

var directions = {
	"right": Vector2(1, 0),
	"left": Vector2(-1, 0)
}
	
var inputs = {
	"right": ["ui_right", KEY_D],
	"left": ["ui_left", KEY_A]
}

func _process(delta):
	handle_input()

func handle_input():
	var movement_direction = Vector2.ZERO
	
	for direction in directions.keys():
		if Input.is_action_pressed(inputs[direction][0]) or Input.is_key_pressed(inputs[direction][1]):
			movement_direction += directions[direction]
			idle_direction = determine_animation_suffix(directions[direction])
			
	if movement_direction.length() > 0:
		movement_direction = movement_direction.normalized()
		position += movement_direction * SPEED
		anim_player.play("Player/walk_%s" % determine_animation_suffix(movement_direction))
	else:
		anim_player.play("Player/idle_%s" % idle_direction)
		
func determine_animation_suffix(direction: Vector2) -> String:
	if direction == Vector2(1, 0):
		return "right"
	elif direction == Vector2(-1, 0):
		return "left"
	return ""
