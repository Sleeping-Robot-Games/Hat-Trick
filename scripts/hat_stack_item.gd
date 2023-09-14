extends Control

@export var active = false
var has_hat = false

func _ready():
	if active:
		$Border.texture = load("res://assets/ui/border0.png")
		has_hat = true
	else:
		$Border.texture = load("res://assets/ui/border1.png")

func change_hat(hat_name):
	show()
	has_hat = true
	$Border/Hat.texture.atlas = load("res://assets/sprites/hat/"+hat_name+".png")
	$Border/Hat.texture.region = Rect2(0, 0, 32, 32)

func no_hat():
	hide()
	$Border/Hat.texture = null
