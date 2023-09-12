extends Node2D

var rng = RandomNumberGenerator.new()

@onready var character_sprite = {
	'body': $body,
	'hair': $hair,
	'outfit': $outfit,
	'hat': $hat
}

@onready var character_sprite_palette = {
	'body': character_sprite['body'],
	'haircolor': character_sprite['hair']
}

@export var random = false

var pallete_sprite_state: Dictionary
var sprite_state: Dictionary

var sprite_folder_path = "res://assets/sprites/"
var palette_folder_path = "res://assets/palettes/"


# Called when the node enters the scene tree for the first time.
func _ready():
	if random:
		create_random_character()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	
func random_asset(folder: String, keyword: String = "") -> String:
	var files: Array
	files = g.files_in_dir(folder)
	if keyword == "":
		files = g.files_in_dir(folder)
	if files.size() == 0:
		return ""
	rng.randomize()
	var random_index = rng.randi_range(0, files.size() - 1)
	return folder+"/"+files[random_index]
	
func set_random_texture(sprite_name: String):
	var random_sprite = random_asset(sprite_folder_path + sprite_name)
	if random_sprite == "": # No assets in the folder yet continue to next folder
		return
	set_sprite_texture(sprite_name, random_sprite)

func set_random_color(palette_type: String):
	var random_color
	random_color = random_asset(palette_folder_path + palette_type)
	if random_color == "" or "000" in random_color:
		random_color = random_color.replace("000", "001")
	var color_num = random_color.substr(len(random_color)-7, 3)
	set_sprite_color(palette_type, character_sprite_palette[palette_type], color_num)
	pallete_sprite_state[palette_type] = color_num

func create_random_character():
	var sprite_folders = g.folders_in_dir(sprite_folder_path)
	var palette_folders = g.folders_in_dir(palette_folder_path)
	for folder in sprite_folders:
		set_random_texture(folder)
	for folder in palette_folders:
		set_random_color(folder)

func set_sprite_texture(sprite_name: String, texture_path: String):
	character_sprite[sprite_name].set_texture(load(texture_path))
	sprite_state[sprite_name] = texture_path

func set_sprite_color(folder, sprite: Sprite2D, color_num: String):
	var palette_path = "res://assets/palettes/{folder}/{folder}_{color_num}.png".format({
		"folder": folder,
		"color_num": color_num
	})
	var gray_palette_path = "res://assets/palettes/{folder}/{folder}_000.png".format({
		"folder": folder
	})
	g.make_shaders_unique(sprite)
	sprite.material.set_shader_parameter("palette_swap", load(palette_path))
	sprite.material.set_shader_parameter("greyscale_palette", load(gray_palette_path))
