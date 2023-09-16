extends Node2D

@onready var right_light_pulse = $Outside/right_sign_light/AnimationPlayer
@onready var left_light_pulse = $Outside/left_sign_light/AnimationPlayer
@onready var scrolling_hats_sign = $Outside/hats_scrolling_sign
@onready var top_hat_sign = $Outside/top_hat_sign

var battle_pos_offset = 80
var battle_pos_y = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	print($Player.position)
	right_light_pulse.play("Light Pulse")
	left_light_pulse.play("Light Pulse")
	scrolling_hats_sign.play("Hats Scrolling Sign")
	top_hat_sign.play("Top Hat Sign")

func hat_fight(player, opponent):
	# g.stop_bgm('background')
	# g.play_bgm('Battle_Music_Main', -5)
	g.unfocus_current()
	# cam.follow_player = false
	var player_pos = get_left_battle_pos()
	var opponent_pos = get_right_battle_pos()
	player.start_fighting(player_pos)
	opponent.start_fighting(opponent_pos)

	$BattleHUD.opponent_is_big = true
	$BattleHUD.start_battle(player, opponent)

func get_left_battle_pos():
	var half_viewport = get_viewport_rect().size.x / 2
	var screen_center = half_viewport
	var left_pos =( screen_center - half_viewport + battle_pos_offset)/3
	print(Vector2(left_pos, battle_pos_y))
	return Vector2(left_pos, battle_pos_y)

func get_right_battle_pos() -> Vector2:
	var half_viewport = get_viewport_rect().size.x / 2
	var screen_center = half_viewport
	var right_pos = (screen_center + half_viewport - battle_pos_offset)/3
	return Vector2(right_pos, battle_pos_y)


func _on_start_button_up():
	hat_fight($Player, $BigGuy)

func _on_skip_button_up():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
