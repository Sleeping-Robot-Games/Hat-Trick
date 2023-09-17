extends Camera2D
# Screen shake variables
var shake_duration = 0.0
var shake_magnitude = 0.0
var shake_speed = 50.0
var prev_pos = Vector2.ZERO
var shaking = false


var follow_player = true
var y_offset = -68
@onready var player = get_parent().get_node('Player')
@onready var battle_hud = get_parent().get_node('BattleHUD')

func _ready():
	prev_pos = global_position
	position.x = player.position.x
	position.y = player.position.y + y_offset


func _process(delta):
	if follow_player and player:
		position.x = lerp(position.x, player.position.x, 0.1)
		position.y = lerp(position.y, player.position.y + y_offset, 0.1)
	var half_viewport = get_viewport_rect().size / 2.0
	var cam_center = get_screen_center_position()
	var cam_current_pos = cam_center - half_viewport
	battle_hud.global_position = cam_current_pos
	
	if not follow_player and shaking:
		if shake_duration > 0:
			# Calculate an offset using a random direction and the magnitude
			var offset = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized() * shake_magnitude
			# Apply the offset to the camera's position
			self.global_position += offset
			
			# Decrease the duration of the shake by the elapsed time
			shake_duration -= delta
		else:
			shake_duration = 0.0
			shake_magnitude = 0.0
			self.global_position = prev_pos
			shaking = false
		
func shake_camera(duration, magnitude):
	prev_pos = global_position
	shake_duration = duration
	shake_magnitude = magnitude
	shaking = true
