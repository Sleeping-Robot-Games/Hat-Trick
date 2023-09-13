extends Control

@onready var sprite_holder = $SpriteHolder

func _ready():
	# Connect buttons
	$Hat/Left.button_up.connect(_on_Sprite_Selection_button_up.bind(-1, "hat"))
	$Hat/Right.button_up.connect(_on_Sprite_Selection_button_up.bind(1, "hat"))
	$Hair/Left.button_up.connect(_on_Sprite_Selection_button_up.bind(-1, "hair"))
	$Hair/Right.button_up.connect(_on_Sprite_Selection_button_up.bind(1, "hair"))
	$HairColor/Left.button_up.connect(_on_Color_Selection_button_up.bind(-1, "haircolor"))
	$HairColor/Right.button_up.connect(_on_Color_Selection_button_up.bind(1, "haircolor"))
	$Body/Left.button_up.connect(_on_Color_Selection_button_up.bind(-1, "body"))
	$Body/Right.button_up.connect(_on_Color_Selection_button_up.bind(1, "body"))
	$Outfit/Left.button_up.connect(_on_Sprite_Selection_button_up.bind(-1, "outfit"))
	$Outfit/Right.button_up.connect(_on_Sprite_Selection_button_up.bind(1, "outfit"))

	sprite_holder.create_random_character()
	
	$AnimationPlayer.play("player/idle_right")

func _process(delta):
	pass

func store_player_state():
	var player_customized_state = {
		'sprite_state': sprite_holder.sprite_state,
		'pallete_sprite_state': sprite_holder.pallete_sprite_state
	}
	var f = FileAccess.open("user://player_state.save", FileAccess.WRITE)
	var json = JSON.new()
	f.store_string(json.stringify(player_customized_state, "  "))
	f.close()

func _on_Sprite_Selection_button_up(dir: int, sprite: String):
	var folder_path = sprite_holder.sprite_folder_path + sprite
	var files = g.files_in_dir(folder_path)
	var file = sprite_holder.sprite_state[sprite].split("/")[-1]
	var current_index = files.find(file)
	var new_index = current_index + dir
	if new_index > len(files) - 1:
		new_index = 0
	if new_index == -1:
		new_index = len(files) -1
	var new_sprite_path = folder_path + '/' + files[new_index]
	sprite_holder.set_sprite_texture(sprite, new_sprite_path)

func _on_Color_Selection_button_up(dir: int, palette_sprite: String):
	var folder_path = sprite_holder.palette_folder_path + palette_sprite
	var files = g.files_in_dir(folder_path)
	var new_color = int(sprite_holder.pallete_sprite_state[palette_sprite]) + dir
	if new_color == 0 and dir == -1:
		new_color = len(files) - 1
	if new_color == len(files) and dir == 1:
		new_color = 1
	var color_num = str(new_color).pad_zeros(3)
	sprite_holder.set_sprite_color(palette_sprite, sprite_holder.character_sprite_palette[palette_sprite], color_num)
	sprite_holder.pallete_sprite_state[palette_sprite] = color_num

func _on_random_button_up():
	sprite_holder.create_random_character()


func _on_continue_button_up():
	await store_player_state()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
