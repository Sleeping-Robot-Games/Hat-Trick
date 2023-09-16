extends Node2D
@onready var right_light_pulse = $TileMap/right_sign_light/AnimationPlayer
@onready var left_light_pulse = $TileMap/left_sign_light/AnimationPlayer
@onready var scrolling_hats_sign = $TileMap/hats_scrolling_sign
@onready var top_hat_sign = $TileMap/top_hat_sign
# Called when the node enters the scene tree for the first time.
func _ready():
	right_light_pulse.play("Light Pulse")
	left_light_pulse.play("Light Pulse")
	scrolling_hats_sign.play("Hats Scrolling Sign")
	top_hat_sign.play("Top Hat Sign")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
