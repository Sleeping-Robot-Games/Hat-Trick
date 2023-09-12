extends Node

var rng = RandomNumberGenerator.new()

const hat_index = {
	"wizard": 11,
	"witch": 12,
	"snapback": 5,
	"shroom": 11,
	"nurse": 7,
	"hardhat":7,
	"fedora": 7,
	"crown": 7,
	"cowboy": 8,
	"baseball": 5
}

func folders_in_dir(path: String) -> Array:
	var folders = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var folder = dir.get_next()
		if folder == "":
			break
		if not folder.begins_with("."):
			folders.append(folder)
	dir.list_dir_end()
	return folders


func files_in_dir(path: String, keyword: String = "") -> Array:
	var files = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if keyword != "" and file.find(keyword) == -1:
			continue
		if not file.begins_with(".") and file.ends_with(".import"):
			files.append(file.replace(".import", ""))
	dir.list_dir_end()
	return files


func make_shaders_unique(sprite: Sprite2D):
	var mat = sprite.material.duplicate(true)
	sprite.material = mat
	
func load_character(parent_node: Node2D):
	var f = FileAccess.open("user://player_state.save", FileAccess.READ)
	var json = JSON.new()
	json.parse(f.get_as_text())
	f.close()
	var data = json.get_data()
	for part in parent_node.get_children():
		if part is Sprite2D:
			if part.name == 'Hair' or part.name == 'Hat':
				part.texture = load(data.sprite_state[part.name])
			if part.name == 'Robe' or part.name == 'Hat':
				part.material.set_shader_param("palette_swap", load("res://players/wizard/creator/palette/Color/Color_"+data.pallete_sprite_state["Color"]+".png"))
				part.material.set_shader_param("greyscale_palette", load("res://players/wizard/creator/palette/Color/Color_000.png"))
			elif part.name == 'Hair':
				part.material.set_shader_param("palette_swap", load("res://players/wizard/creator/palette/"+part.name+"color/"+part.name+"color_"+data.pallete_sprite_state[part.name+'color']+".png"))
				part.material.set_shader_param("greyscale_palette", load("res://players/wizard/creator/palette/"+part.name+"color/"+part.name+"color_000.png"))
			else:
				part.material.set_shader_param("palette_swap", load("res://players/wizard/creator/palette/"+part.name+"/"+part.name+"_"+data.pallete_sprite_state[part.name]+".png"))
				part.material.set_shader_param("greyscale_palette", load("res://players/wizard/creator/palette/"+part.name+"/"+part.name+"_000.png"))
			make_shaders_unique(part)
	return data
	
func play_random_sfx(parent, name, custom_range = 5, db_override = 0):
	var sfx_player = AudioStreamPlayer.new()
#	sfx_player.volume_db = db_override
#	rng.randomize()
#	var track_num = rng.randi_range(1, custom_range)
#	sfx_player.stream = load('res://sfx/'+name+'_'+str(track_num)+'.ogg')
#	sfx_player.connect("finished", sfx_player, "queue_free")
#	parent.add_child(sfx_player)
#	sfx_player.play()


func play_sfx(parent, name, db_override = 0):
	var sfx_player = AudioStreamPlayer.new()
#	sfx_player.volume_db = db_override
#	rng.randomize()
#	sfx_player.stream = load('res://sfx/'+name+'.ogg')
#	sfx_player.connect("finished", sfx_player, "queue_free")
#	parent.add_child(sfx_player)
#	sfx_player.play()
