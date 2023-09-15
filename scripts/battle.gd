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

var insult_subsets
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
	insult_subsets = initialize_insults()
	load_dialog_options()
	
func assign_info():
	p = hud.player
	o = hud.opponent

	player['stats'] = p.stats
	player['active_hat'] = p.hat_array[0]
	player['name'] = p.player_name
	opponent['stats'] = o.stats
	opponent['active_hat'] = o.hat_array[0]
	opponent['name'] = o.npc_name
	
#	player['active_hat'] = 'wizard'
#	opponent['active_hat'] = 'witch'


func initialize_insults():
	var insults_copy = bc.WIT_INSULTS.duplicate(true)
	insults_copy.shuffle()
	var subset_1 = insults_copy.slice(0, insults_copy.size() / 2)
	var subset_2 = insults_copy.slice(insults_copy.size() / 2, insults_copy.size())
	return [subset_1, subset_2]

func load_dialog_options():
	var player_insult = insult_subsets[0].pick_random()
	player['choices']['WIT'] = player_insult
	insult_subsets[0].erase(player_insult)
	var opponent_insult = insult_subsets[1].pick_random()
	opponent['choices']['WIT'] = opponent_insult
	insult_subsets[1].erase(opponent_insult)
	
	## IF CHA is not on cooldown for each combantant
	## TODO: CREATE DIALOG OPTIONS FOR CHA
	var player_cha_power = bc.CHA_POWERS[bc.HAT_CHA_POWERS[player['active_hat']]]
	player['choices']['CHA'] = player_cha_power
	var opponent_cha_power = bc.CHA_POWERS[bc.HAT_CHA_POWERS[opponent['active_hat']]]
	opponent['choices']['CHA'] = opponent_cha_power
	
	var player_hat_ability = bc.HAT_ABILITIES[player['active_hat']]
	player['choices']['HAT'] = player_hat_ability
	var opponent_hat_ability = bc.HAT_ABILITIES[opponent['active_hat']]
	opponent['choices']['HAT'] = opponent_hat_ability
	

func resolve_round():
	var init_array = determine_initiative()
	calculate_outcome(init_array)
	# check_winner()
	# adjust_cooldowns()
	# adjust_hat_order()
	
	# return round_state

func determine_initiative():
	var first_player
	var second_player
	
	var p_init = player['WIT'] + player['CHA']
	var o_init = opponent['WIT'] + opponent['CHA']
	
	if p_init > o_init:
		first_player = player
		second_player = opponent
	if o_init > p_init: 
		first_player = opponent
		second_player = player
	if p_init == o_init:
		var players = [player, opponent]
		players.shuffle()
		return players
	
	return [first_player, second_player]


func calculate_outcome(init_array):
	for i in range(init_array.size()):
		var combatant = init_array[i]
		## apply buffs
		for stat in combatant['choice'].keys():
			combatant[stat] = clamp(combatant[stat] + combatant['choice'][stat], 0, INF)
		## apply damage to opp	
		var opp = init_array[1 - i]  # Get the other player.
		rng.randomize()
		var base_dmg = rng.randirange(1, 3) 
		## TODO: declare "crits"
		var damage = bc.damage_formula(combatant['WIT'], opp['DEF'], base_dmg)
		opp["STAM"] = clamp(opp["STAM"] - damage, 0, INF)
		
		# Check for winner
		if other_player.STAM == 0:
			print(player.display_name + " is the winner")
			winner = player
			loser = other_player
			break
		
		
		
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
