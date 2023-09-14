extends CanvasGroup

var rng = RandomNumberGenerator.new()

@onready var character_sprite = {
	'body': $body,
	'hair': $hair,
	'outfit': $outfit,
	'hat': $hat
}

@onready var character_sprite_palette = {
	'body': character_sprite['body'],
	'haircolor': character_sprite['hair'],
	'outfitcolor': character_sprite['outfit'],
}

var sprite_state: Dictionary
var pallete_sprite_state: Dictionary

var sprite_folder_path = "res://assets/sprites/"
var palette_folder_path = "res://assets/palettes/"

var random_starter_hat = ""
var starter_hat
var player_stats: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	if parent is CharacterBody2D:
		if 'NPC' == parent.type and parent.random:
			create_random_character()
			parent.init_stats([random_starter_hat.to_lower()], generate_random_stats(4))
			parent.npc_name = g.names_by_hat[random_starter_hat.to_lower()].pick_random()
		elif 'Player' == parent.type:
			var character_data = load_character()
			sprite_state = character_data.sprite_state
			pallete_sprite_state = character_data.pallete_sprite_state
			parent.add_hat(character_data.starter_hat.to_lower())
			parent.apply_stats(character_data.player_stats)
			parent.player_name = character_data.name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_random_stats(max):
	# Randomly distribute values among the first three stats and assign the rest to the last stat
	player_stats["stam"] = randi() % (max - 2) + 1
	max -= player_stats["stam"]
	player_stats["def"] = randi() % (max - 1) + 1
	max -= player_stats["def"]
	player_stats["cha"] = randi() % max + 1
	max -= player_stats["cha"]
	player_stats["wit"] = max
	
func load_character():
	var f = FileAccess.open("user://player_state.save", FileAccess.READ)
	var json = JSON.new()
	if f:
		json.parse(f.get_as_text())
		f.close()
		var data = json.get_data()
		set_sprites(data)
		return data

func set_sprites(data):
	for part in get_children():
		if part is Sprite2D:
			if not part.name == 'body':
				part.texture = load(data.sprite_state[part.name])
			if part.name == 'body' or part.name == 'hair':
				var sprite_name = 'haircolor' if part.name == 'hair' else part.name
				part.material.set_shader_parameter("palette_swap", load(palette_folder_path + sprite_name + "/" + sprite_name + "_" + data.pallete_sprite_state[sprite_name] + ".png"))
				part.material.set_shader_parameter("greyscale_palette", load(palette_folder_path + sprite_name + "/" + sprite_name + "_000.png"))
				g.make_shaders_unique(part)
	
func random_asset(folder: String, keyword: String = "") -> String:
	var files: Array
	files = g.files_in_dir(folder)
	if keyword == "":
		files = g.files_in_dir(folder)
	if files.size() == 0:
		return ""
	rng.randomize()
	var random_index = rng.randi_range(0, files.size() - 1)
	if 'hat' in folder:
		random_starter_hat = files[random_index].get_slice('.', 0).capitalize()
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

func flip_h():
	for sprite in get_children():
		sprite.flip_h = true
