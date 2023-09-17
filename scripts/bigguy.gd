extends CharacterBody2D

@export var tutorial = false

var type = "NPC"
var speed = 100
var is_fighting = false
var available_for_battle = true
var battle_pos = Vector2.ZERO
var battle_pos_speed = 150
var last_direction = 1 # 1 for right, -1 for left
var stats
var npc_name = 'Bouncer'
var is_player = false
var hat_stack = []

@onready var game = get_parent()
@onready var anim_npc = $AnimationPlayer
@onready var speech_bubble = $SpeechBubble

func _ready():
	anim_npc.play('idle')
	hat_stack = ['snapback']
	stats = {'stam': 10, 'def': 2, 'cha': 1, 'wit': 1}
	if g.level == 1:
		$Sprite2D.texture = load("res://assets/bigguy/bigguy002.png")
	if g.level == 2:
		$Sprite2D.texture = load("res://assets/bigguy/bigguy003.png")
		
func _update_shader_modulation(current_modulation):
	for sprite in $SpriteHolder.get_children():
		if sprite is Sprite2D:
			var mat = sprite.material
			if mat:
				mat.set_shader_parameter("parent_modulation", current_modulation)


func show_interact():
	$InteractButton.visible = true
	$InteractButton.play('default')

func hide_interact():
	$InteractButton.visible = false
	$InteractButton.stop()

func start_fighting(pos):
	battle_pos = pos
	# in_battle_pos = false
	is_fighting = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", battle_pos, 1)
	anim_npc.play("player/idle_left")


func _on_interact_area_body_entered(body):
	if tutorial: 
		$SpeechBubble.show()
		$SpeechBubble.set_text("Need some pointers?")
		get_parent().get_node('Start').show()
		get_parent().get_node('Skip').show()
	elif body.name == 'Player' and not body.is_fighting:
		print('interacting with big')
		# send up if they have enough hats if level 1
		if g.level == 1:
			if body.hat_stack.size() >= 5:
				speech_bubble.set_text('I like your hats, go ahead')
				speech_bubble.show()
				game.get_node('InteractButton').show()
				game.good_to_go_up = true
				await get_tree().create_timer(3).timeout
				speech_bubble.hide()
			else:
				speech_bubble.set_text('Get more hats and talk to me')
				speech_bubble.show()
				await get_tree().create_timer(3).timeout
				speech_bubble.hide()

func _on_interact_area_body_exited(body):
	if tutorial:
		$SpeechBubble.hide()
		get_parent().get_node('Start').hide()
		get_parent().get_node('Skip').hide()
	elif body.name == 'Player':
		pass
