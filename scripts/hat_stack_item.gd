extends Control

@export var active = false
var has_hat = false
var hat_name = ""

func _ready():
	if active:
		$Border.texture = load("res://assets/ui/border0.png")
		has_hat = true
	else:
		$Border.texture = load("res://assets/ui/border1.png")

func change_hat(_hat_name, play_sfx=true):
	show()
	has_hat = true
	hat_name = _hat_name
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = load("res://assets/sprites/hat/"+hat_name+".png")
	atlas_tex.region = Rect2(0, 0, 32, 32)
	$Border/Hat.texture = atlas_tex

func no_hat():
	hide()
	hat_name = ""
	$Border/Hat.texture = null
