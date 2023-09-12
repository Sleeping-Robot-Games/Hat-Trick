extends CharacterBody2D
const speed = 20
@onready var anim_player = $AnimationPlayer

var last_position = int(self.global_position.x) # starting position

func _ready():
	pass
func _physics_process(delta):
	
	var current_position = self.global_position.x
	if current_position <= last_position:
		move_npc(delta)
		$AnimationPlayer.play("player/walk_left")
	elif current_position > last_position:
		move_npc(delta)
		$AnimationPlayer.play("player/walk_right")
	else:
		pass

	last_position = current_position

func move_npc(delta):
	get_parent().set_progress(get_parent().get_progress() + (speed * delta))
