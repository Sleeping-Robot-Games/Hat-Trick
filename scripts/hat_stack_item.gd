extends Control

@export var active = false

func _ready():
	if active:
		$Border.texture = load("res://assets/ui/border0.png")
	else:
		$Border.texture = load("res://assets/ui/border1.png")

func change_hat(hat_name):
	$Border/Hat.texture.atlas = load("res://assets/sprites/hat/"+hat_name+".png")
	$Border/Hat.texture.region = Rect2(0, 0, 32, 32)

func no_hat():
	$Border/Hat.texture = null
