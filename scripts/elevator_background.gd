extends Node2D

@onready var elevator_background = $TileMap

var speed = Vector2(0, 3000) # This will move the background downward

# Assuming each tile is 48 pixels tall and you have 10 tiles in height
var tile_height = 16
var total_tiles = 20
var total_height = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	position.y = -875

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update the position of the TileMap
	position += speed * delta
	
	# If the TileMap has moved down its entire height, loop it
	if position.y >= (total_height -100):
		position.y = -875
