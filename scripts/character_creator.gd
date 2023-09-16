extends Control

var tool_tip_scene = load("res://scenes/tool_tip.tscn")

@onready var sprite_holder = $SpriteHolder
@onready var stam_label = $Stam/Label
@onready var def_label = $Def/Label
@onready var cha_label = $Cha/Label
@onready var wit_label = $Wit/Label
@onready var available_points_label = $AvailablePoints

var stam = 0
var def = 0
var cha = 0
var wit = 0
var cap = 5
var current_total_stats = 0
var stats = {
	"stam": 2, # 8 (or 10?) is the base for STAM so 2 here would make the overall STAM 10 (or 12?)
	"def": 1,
	"cha": 1,
	"wit": 1
}
var starter_hat = ""

func _ready():
	# Connect buttons
	
	# Character Style
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
	$OutfitColor/Left.button_up.connect(_on_Color_Selection_button_up.bind(-1, "outfitcolor"))
	$OutfitColor/Right.button_up.connect(_on_Color_Selection_button_up.bind(1, "outfitcolor"))
	
	# Character Stats
	$Stam/Up.button_up.connect(_on_Character_Selection_button_up.bind(1, "stam_up"))
	$Stam/Down.button_up.connect(_on_Character_Selection_button_up.bind(-1, "stam_down"))
	$Def/Up.button_up.connect(_on_Character_Selection_button_up.bind(1, "def_up"))
	$Def/Down.button_up.connect(_on_Character_Selection_button_up.bind(-1, "def_down"))
	$Cha/Up.button_up.connect(_on_Character_Selection_button_up.bind(1, "cha_up"))
	$Cha/Down.button_up.connect(_on_Character_Selection_button_up.bind(-1, "cha_down"))
	$Wit/Up.button_up.connect(_on_Character_Selection_button_up.bind(1, "wit_up"))
	$Wit/Down.button_up.connect(_on_Character_Selection_button_up.bind(-1, "wit_down"))
	
	$Stam.mouse_entered.connect(_on_stat_mouse_entered.bind('stam'))
	$Def.mouse_entered.connect(_on_stat_mouse_entered.bind('def'))
	$Cha.mouse_entered.connect(_on_stat_mouse_entered.bind('cha'))
	$Wit.mouse_entered.connect(_on_stat_mouse_entered.bind('wit'))

	$Stam.mouse_exited.connect(_on_stat_mouse_exited.bind('stam'))
	$Def.mouse_exited.connect(_on_stat_mouse_exited.bind('def'))
	$Cha.mouse_exited.connect(_on_stat_mouse_exited.bind('cha'))
	$Wit.mouse_exited.connect(_on_stat_mouse_exited.bind('wit'))
	
	update_stat_labels()
	available_points_label.text = "Available: 0"
	
	# Generate random character idling
	sprite_holder.create_random_character()
	starter_hat = sprite_holder.random_starter_hat
	
	$Hat.text = starter_hat
	
	$AnimationPlayer.play("player/idle_right")

func _process(delta):
	pass


@onready var tool_tip_data = {
	'stam': {
		'header': 'Stamina',
		'content': 'This score increases your Health',
		'node': $Stam
	},
	'def': {
		'header': 'Defense',
		'content': 'This score reduces incoming damage',
		'node': $Def
	},
	'cha': {
		'header': 'Charisma',
		'content': 'This score is how powerful your CHA buffs are.',
		'node': $Cha
	},
	'wit': {
		'header': 'Wit',
		'content': 'This score is how damaging your insults are to your opponent.',
		'node': $Wit
	}
}
var current_tool_tip

func _on_stat_mouse_entered(stat):
	var new_tool_tip = tool_tip_scene.instantiate()
	new_tool_tip.get_node('Header').text = tool_tip_data[stat].header
	new_tool_tip.get_node('Content').text = tool_tip_data[stat].content
	add_child(new_tool_tip)
	new_tool_tip.global_position.y = tool_tip_data[stat].node.global_position.y - 150
	new_tool_tip.global_position.x = tool_tip_data[stat].node.global_position.x - 200
	current_tool_tip = new_tool_tip
	
func _on_stat_mouse_exited(stat):
	current_tool_tip.queue_free()
	current_tool_tip = null

func store_player_state():
	stats['stam'] += 8
	var player_customized_state = {
		'sprite_state': sprite_holder.sprite_state,
		'pallete_sprite_state': sprite_holder.pallete_sprite_state,
		'player_stats': stats,
		'starter_hat': starter_hat,
		'name': $TextEdit.text
	}
	var f = FileAccess.open("user://player_state.save", FileAccess.WRITE)
	var json = JSON.new()
	f.store_string(json.stringify(player_customized_state, "  "))
	f.close()

func generate_random_stats(max_value: int) -> void:
	# Ensure max_value can be distributed among the four stats
	if max_value < 4:
		print("Max value is too small to distribute among all stats!")
		return

	var remaining = max_value

	# Randomly distribute values among the first three stats and assign the rest to the last stat
	stats["stam"] = randi() % (remaining - 2) + 1
	remaining -= stats["stam"]
	stats["def"] = randi() % (remaining - 1) + 1
	remaining -= stats["def"]
	stats["cha"] = randi() % remaining + 1
	remaining -= stats["cha"]
	stats["wit"] = remaining

	# Update labels
	update_stat_labels()

func update_stat_labels():
	stam_label.text = str(stats["stam"])
	def_label.text = str(stats["def"])
	cha_label.text = str(stats["cha"])
	wit_label.text = str(stats["wit"])

func _on_Character_Selection_button_up(dir: int, sprite: String):
	var stat_key = sprite.replace("_up", "").replace("_down", "")
	var old_value = stats[stat_key]
	var new_value = old_value + dir

	# Calculate current total stats
	var current_total = stats["stam"] + stats["def"] + stats["cha"] + stats["wit"]

	# If decreasing a value
	if dir == -1:
		# If we're trying to decrease the stat below -1, or if another stat is already at -1, don't allow
		if new_value < 0:
			print("Cannot decrease further!")
			return
	# If increasing a value
	elif dir == 1:
		# Check if this increase will make the total exceed max
		if (current_total + dir) > cap or new_value > 3:
			print("Cannot increase further!")
			return

	# Apply the change and update the respective label
	stats[stat_key] = new_value

	# Recalculate the current total after making changes
	current_total = stats["stam"] + stats["def"] + stats["cha"] + stats["wit"]

	# Update labels based on the sprite
	match sprite:
		"stam_up", "stam_down":
			stam_label.text = str(new_value)
		"def_up", "def_down":
			def_label.text = str(new_value)
		"cha_up", "cha_down":
			cha_label.text = str(new_value)
		"wit_up", "wit_down":
			wit_label.text = str(new_value)

	update_available_points_label(cap - current_total)

func update_available_points_label(total_points: int):
	var format_available_points = "Available: %s"
	var available_points = format_available_points % str(total_points)
	available_points_label.text = available_points

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
	if sprite == 'hat':
		starter_hat = files[new_index].get_slice('.', 0).capitalize()
		$Hat.text = starter_hat

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

func _on_random_character_button_up():
	sprite_holder.create_random_character()
	starter_hat = sprite_holder.random_starter_hat
	$Hat.text = starter_hat

func _on_continue_button_up():
	$Error.hide()
	if $TextEdit.text == "":
		$Error.show()
		return
	await store_player_state()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_random_stats_button_up():
	available_points_label.text = "Available: 0"
	generate_random_stats(cap)
