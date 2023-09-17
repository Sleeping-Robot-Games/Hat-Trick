extends Node2D

var hat = 'baseball'

func set_hat(hat_name):
	hat = hat_name
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = load("res://assets/sprites/hat/"+hat+".png")
	atlas_tex.region = Rect2(0, 0, 32, 32)
	$Sprite.texture = atlas_tex
	scale = Vector2(4, 4)

func _on_area_2d_body_entered(body):
	if body.name == 'Player':
		body.add_hat(hat)
		queue_free()
