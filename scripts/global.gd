extends Node

var rng = RandomNumberGenerator.new()
var focused_npc = null
var current_level_y_pos = 435

const max_hats = 6

## indexs all hats and their height in pixels
const hat_index = {
	"wizard": 11,
	"witch": 12,
	"snapback": 5,
	"shroom": 8,
	"nurse": 7,
	"hardhat":7,
	"fedora": 7,
	"crown": 7,
	"cowboy": 8,
	"baseball": 6,
	"cloche": 5,
	"floppy": 6,
	"pirate": 8,
	"straw": 5,
	"beanie": 7,
	"fairy": 4,
	"monster": 6,
	"sport": 6,
	"tophat": 11,
	"raccoon": 6,
	"party": 8
}

var names_by_hat = {
	"wizard": ["Merlin", "Gandalf", "Elodin", "Radagast", "Morgana"],
	"witch": ["Sabrina", "Morgana", "Hecate", "Elphaba", "Glinda"],
	"snapback": ["Jayden", "Kai", "Logan", "Brooklyn", "Maddox"],
	"shroom": ["Fungo", "Moss", "Lichen", "Sporus", "Mycelium"],
	"nurse": ["Florence", "Clara", "Nightingale", "Agnes", "Edith"],
	"hardhat": ["Bob", "Mason", "Bill", "Jack", "Ella"],
	"fedora": ["Frank", "Dean", "Sammy", "Vincent", "Leonard"],
	"crown": ["Arthur", "Elizabeth", "Victoria", "Henry", "Diana"],
	"cowboy": ["Wyatt", "Cody", "Jesse", "Daisy", "Billy"],
	"baseball": ["Derek", "Babe", "Jackie", "Lou", "Mickey"],
	"cloche": ["Josephine", "Flora", "Daisy", "Evelyn", "Harriet"],
	"floppy": ["Summer", "Lily", "Rose", "Bree", "Sunny"],
	"pirate": ["Blackbeard", "Jack", "Morgan", "Grace", "Anne"],
	"straw": ["Dorothy", "Penny", "Juliet", "Harvey", "Lucas"],
	"beanie": ["Skyler", "Winter", "Hazel", "Jasper", "Milo"],
	"fairy": ["Link", "Titania", "Oberon", "Navi", "Luna"],
	"monster": ["Sully", "Mike", "Frank", "Morty", "Drac"],
	"sport": ["Jordan", "Serena", "Tiger", "Ronaldo", "Simone"],
	"tophat": ['Gerald'],
	"raccoon": ["Ron"],
	"party": ["Rod", "Chad"]
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
			if not part.name == 'body':
				part.texture = load(data.sprite_state[part.name])
			if part.name == 'body' or part.name == 'hair':
				part.material.set_shader_param("palette_swap", load("res://players/wizard/creator/palette/"+part.name+"/"+part.name+"_"+data.pallete_sprite_state[part.name]+".png"))
				part.material.set_shader_param("greyscale_palette", load("res://players/wizard/creator/palette/"+part.name+"/"+part.name+"_000.png"))
			make_shaders_unique(part)
	return data

func play_random_sfx(parent, fname, custom_range=5, db_override=0, ext='.ogg'):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = db_override
	rng.randomize()
	var track_num = rng.randi_range(1, custom_range)
	sfx_player.stream = load('res://sfx/'+fname+'_'+str(track_num)+ext)
	sfx_player.finished.connect(sfx_player.queue_free)
	parent.add_child(sfx_player)
	sfx_player.play()

func play_sfx(parent, fname, db_override=0, ext='.ogg'):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = db_override
	sfx_player.stream = load('res://assets/sfx/'+fname+ext)
	sfx_player.finished.connect(sfx_player.queue_free)
	parent.add_child(sfx_player)
	sfx_player.play()

func focus_npc(npc):
	if focused_npc and focused_npc != npc:
		focused_npc.hide_interact()
	focused_npc = npc
	focused_npc.show_interact()

func unfocus_npc(npc):
	if focused_npc and focused_npc == npc:
		focused_npc.hide_interact()
		focused_npc = null

func unfocus_current():
	if focused_npc:
		focused_npc.hide_interact()
	focused_npc = null
