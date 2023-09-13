extends Camera2D

var follow_player = true
var y_offset = -68
@onready var player = get_parent().get_node('Player')
@onready var battle_hud = get_parent().get_node('BattleHUD')

func _ready():
	position.x == player.position.x
	position.y == player.position.y + y_offset

func _process(delta):
	if follow_player and player:
		position.x = lerp(position.x, player.position.x, 0.1)
		position.y = lerp(position.y, player.position.y + y_offset, 0.1)
	var half_viewport = get_viewport_rect().size / 2.0
	var cam_center = get_screen_center_position()
	var cam_current_pos = cam_center - half_viewport
	battle_hud.global_position = cam_current_pos
