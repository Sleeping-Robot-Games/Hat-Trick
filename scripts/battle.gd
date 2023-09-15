extends Node

var rng = RandomNumberGenerator.new()

@onready var hud = get_parent()

# will hold all relavant info that will be mutable during battle
var player: Dictionary
var opponent: Dictionary

var o: CharacterBody2D # Opponent Node
var p: CharacterBody2D # Player Node

var winner
var loser

var round = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Start of battle:
## Assign all relevant info to opponent and player dictionaries
### Stats, Name, Hats, Health, 
## Load dialog options for player (called choices in playtest)
### These dialog options come from the singleton bc (battle_constants.gd)
### In this script we will dyanmically create two pools of each dialog option from bc for each combatant
### this way they don't speak the same insults to eachother

func start():
	assign_info()
	load_dialog_options()
	
func assign_info():
#	p = hud.player
#	o = hud.opponent
#
#	player['stats'] = p.stats
#	player['active_hat'] = p.hat_array[0]
#	opponent['stats'] = o.stats
#	opponent['active_hat'] = o.hat_array[0]
	player['active_hat'] = 'wizard'
	opponent['active_hat'] = 'witch'


func initialize_insults():
	var insults_copy = bc.WIT_INSULTS.duplicate(true)
	insults_copy.shuffle()
	var subset_1 = insults_copy.slice(0, insults_copy.size() / 2)
	var subset_2 = insults_copy.slice(insults_copy.size() / 2, insults_copy.size())
	return [subset_1, subset_2]

func load_dialog_options():
	var insult_subsets = initialize_insults()
	
	var player_insult = insult_subsets[0].pick_random()
	print(player_insult)
	insult_subsets[0].erase(player_insult)
	var opponent_insult = insult_subsets[0].pick_random()
	insult_subsets[0].erase(opponent_insult)
	print(opponent_insult)
	
	## IF CHA is not on cooldown for each combantant
	## TODO: CREATE DIALOG OPTIONS FOR CHA
	var player_cha_power = bc.CHA_POWERS[bc.HAT_CHA_POWERS[player['active_hat']]]
	print(player_cha_power)
	var opponent_cha_power = bc.CHA_POWERS[bc.HAT_CHA_POWERS[opponent['active_hat']]]
	print(opponent_cha_power)
	
	var player_hat_ability = bc.HAT_ABILITIES[player['active_hat']]
	print(player_hat_ability)
	var opponent_hat_ability = bc.HAT_ABILITIES[opponent['active_hat']]
	print(opponent_hat_ability)
	
	

# After dialog option is chosen
## Determine round initiative (WIT + CHA), if tied random
## Calculate outcome
### In initiative order resolve the dialogs
#### Apply damage or buffs 
#### maybe into a state object then send up to UI in a function that will play it out in an animation similar to the test animtaion set now
### Check for winner, if so end round early and conclude battle

## Resolve round
### Set cooldowns for any HATs or CHA options used
### refresh cooldowns that were already set from previous round to make available again
### Adjust hat order if any HAT abilities were used, send up to UI

## Conclude battle
### If player won award hat, send up to UI
### If player lost send NPC to next room
### Clear any state to null for player, oppponent, p, o, round, winner, loser, etc
### Remove battle UI and set camera back to normal
