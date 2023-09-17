extends CharacterBody2D

@export var tutorial = false

var type = "NPC"
var speed = 100
#var start_pos = Vector2(195, g.current_level_y_pos)
#var end_pos = Vector2(1875, g.current_level_y_pos)
#var target_pos = start_pos
var is_fighting = false
var available_for_battle = true
var battle_pos = Vector2.ZERO
var battle_pos_speed = 150
var last_direction = 1 # 1 for right, -1 for left
var stats
var npc_name = 'Bouncer'
var is_player = false
var hat_stack = []

@onready var anim_npc = $AnimationPlayer
#@onready var speech_bubble = $SpeechBubble
#@onready var speech_bubble_label = speech_bubble.get_node("MarginContainer/NinePatchRect/CenterContainer/Label")

func _ready():
	anim_npc.play('idle')
	hat_stack = ['snapback']
	stats = {'stam': 10, 'def': 2, 'cha': 1, 'wit': 1}
		
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
	elif body.name == 'Player' and available_for_battle and not body.is_fighting:
		g.focus_npc(self)

func _on_interact_area_body_exited(body):
	if tutorial:
		$SpeechBubble.hide()
		get_parent().get_node('Start').hide()
		get_parent().get_node('Skip').hide()
	elif body.name == 'Player':
		g.unfocus_npc(self)
