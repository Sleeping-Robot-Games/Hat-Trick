extends Node2D

var max_npcs = 5
var npc_scene = load("res://scenes/npc.tscn")

var active_npcs = []

var battle_pos_offset = 80
var battle_pos_y = g.current_level_y_pos
@onready var npc_pool = $NPCPool
@onready var cam = $Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	npc_enters()

func npc_enters():
	var new_npc = npc_scene.instantiate()
	new_npc.get_node('AnimationPlayer').play('player/walk_right')
	new_npc.random = true
	new_npc.is_entering = true
	new_npc.position = Vector2(195, 360)
	active_npcs.append(new_npc)
	$NPCPool.add_child(new_npc)

func hat_fight(player, opponent):
	g.unfocus_current()
	cam.follow_player = false
	var player_pos = get_left_battle_pos()
	var opponent_pos = get_right_battle_pos()
	player.start_fighting(player_pos.x)
	opponent.start_fighting(opponent_pos.x)
	# TODO: trigger below once both player and opponent in battle pos?
	for npc in npc_pool.get_children():
		if npc != opponent:
			npc.fade_out()
	$NPCSpawnTimer.stop()
	# TODO: zoom in - I tried doing a zoom with a tween on the player script and the drag/level bounds is making it a PAIN, lets shelf it for now -bronsky
	# TODO: show battle overlay

func get_left_battle_pos():
	var half_viewport = cam.get_viewport_rect().size.x / 2
	var cam_center = cam.get_screen_center_position().x
	var cam_current_pos = cam_center - half_viewport
	var battle_spot = cam_current_pos + battle_pos_offset

	if battle_spot < cam_current_pos:
		return Vector2(cam_current_pos + battle_pos_offset, battle_pos_y)
	else:
		return Vector2(battle_spot, battle_pos_y)

func get_right_battle_pos() -> Vector2:
	var half_viewport = cam.get_viewport_rect().size.x / 2
	var cam_center = cam.get_screen_center_position().x
	var cam_right_end = cam_center + half_viewport
	var battle_spot = cam_right_end - battle_pos_offset

	if battle_spot > cam_right_end:
		return Vector2(cam_right_end - battle_pos_offset, battle_pos_y)
	else:
		return Vector2(battle_spot, battle_pos_y)



func _on_npc_spawn_timer_timeout():
	if active_npcs.size() < max_npcs:
		npc_enters()
	else:
		$NPCSpawnTimer.stop()
