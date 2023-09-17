extends Node2D

var max_npcs = 5
var npc_scene = load("res://scenes/npc.tscn")

var active_npcs = []

var good_to_go_up = false
var battle_pos_offset = 80
var battle_pos_y = g.current_level_y_pos
@onready var npc_pool = $NPCPool
@onready var cam = $Camera

var debug = true
# Called when the node enters the scene tree for the first time.
func _ready():
	if g.level == 1:
		get_node('Level/Floor1').show()
		get_node('Level/Floor2').hide()
		$NPCPool/BOSS.hide()
	if g.level == 2:
		get_node('Level/Floor2').show()
		get_node('Level/Floor1').hide()
		$NPCPool/BOSS.show()
		$BigGuy.hide()
		
	$NPCSpawnTimer.start()
	if debug:
		return
	# Entrance animation for player
	$Player.enter_room()
	

func _input(event):
	if good_to_go_up and Input.is_action_just_pressed("interact"):
		$Player.save_hats()
		get_tree().change_scene_to_file("res://scenes/elevator.tscn")

func npc_enters():
	var new_npc = npc_scene.instantiate()
	new_npc.get_node('AnimationPlayer').play('player/walk_right')
	new_npc.random = true
	new_npc.is_entering = true
	new_npc.position = Vector2(195, 360)
	active_npcs.append(new_npc)
	$NPCPool.add_child(new_npc)

func hat_fight(player, opponent):
	# g.stop_bgm('background')
	# g.play_bgm('Battle_Music_Main', -5)
	g.unfocus_current()
	cam.follow_player = false
	var player_pos = get_left_battle_pos()
	var opponent_pos = get_right_battle_pos()
	player.start_fighting(player_pos)
	opponent.start_fighting(opponent_pos)
	# TODO: trigger below once both player and opponent in battle pos?
	$NPCSpawnTimer.stop()
	for npc in npc_pool.get_children():
		if npc != opponent:
			npc.fade_out()
	# TODO: zoom in - I tried doing a zoom with a tween on the player script and the drag/level bounds is making it a PAIN, lets shelf it for now -bronsky
	$BattleHUD.start_battle(player, opponent)

func battle_over():
	$NPCSpawnTimer.start()
	
func get_left_battle_pos():
	var half_viewport = cam.get_viewport_rect().size.x / 2
	var cam_center = cam.get_screen_center_position().x
	var cam_left = cam_center - half_viewport + battle_pos_offset
	return Vector2(cam_left, battle_pos_y)

func get_right_battle_pos() -> Vector2:
	var half_viewport = cam.get_viewport_rect().size.x / 2
	var cam_center = cam.get_screen_center_position().x
	var cam_right = cam_center + half_viewport - battle_pos_offset
	return Vector2(cam_right, battle_pos_y)

func _on_npc_spawn_timer_timeout():
	if active_npcs.size() < max_npcs:
		npc_enters()
	else:
		$NPCSpawnTimer.stop()


func _on_button_button_up():
	var all_hats = g.hat_index.keys()
	$Player.add_hat(all_hats.pick_random())
	$NPCPool.get_children().pick_random().add_hat(all_hats.pick_random())
