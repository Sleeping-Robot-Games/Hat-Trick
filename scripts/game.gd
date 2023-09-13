extends Node2D

var battle_pos_offset = 80
var battle_pos_y = 450
@onready var npc_pool = $NPCPool
@onready var cam = $Camera

func hat_fight(player, opponent):
	g.unfocus_current()
	cam.follow_player = false
	var player_pos = get_left_battle_pos()
	var opponent_pos = get_right_battle_pos()
	player.start_fighting(player_pos.x, player_pos.y)
	opponent.start_fighting(opponent_pos.x, opponent_pos.y)
	# TODO: trigger below once both player and opponent in battle pos?
	for npc in npc_pool.get_children():
		if npc != opponent:
			npc.fade_out()
	# TODO: zoom in
	# TODO: show battle overlay

func get_left_battle_pos():
	var half_viewport = cam.get_viewport_rect().size.x / 2
	#var cam_center = cam.get_screen_center_position().x
	var cam_center = cam.get_target_position().x
	var cam_left = cam_center - half_viewport + battle_pos_offset
	
	return Vector2(cam_left, battle_pos_y)

func get_right_battle_pos() -> Vector2:
	var half_viewport = cam.get_viewport_rect().size.x / 2
	var cam_center = cam.get_screen_center_position().x
	var cam_right = cam_center + half_viewport - battle_pos_offset
	
	return Vector2(cam_right, battle_pos_y)
