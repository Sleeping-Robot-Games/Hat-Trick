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

var round_state = []
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
#	p = hud.player
#	o = hud.opponent
#
#	player['stats'] = p.stats
#	player['active_hat'] = p.hat_array[0]
#	player['name'] = p.player_name
#	player['choices'] = {}
#	opponent['stats'] = o.stats
#	opponent['active_hat'] = o.hat_array[0]
#	opponent['choices'] = {}
#	opponent['name'] = o.npc_name
	
	## FOR TESTINGS
	player['stats'] = {"wit": 2, "cha": 2, "def": 1, "stam": 10}
	player['active_hat'] = 'witch'
	player['choices'] = {}
	player['name'] = 'Bronsky'
	opponent['stats'] = {"wit": 2, "cha": 2, "def": 1, "stam": 10}
	opponent['active_hat'] = 'cowboy'
	opponent['choices'] = {}
	opponent['name'] = 'Steve'


func initialize_insults():
	var insults_copy = bc.WIT_INSULTS.duplicate(true)
	insults_copy.shuffle()
	var subset_1 = insults_copy.slice(0, insults_copy.size() / 2)
	var subset_2 = insults_copy.slice(insults_copy.size() / 2, insults_copy.size())
	return [subset_1, subset_2]

func load_dialog_options():
	var player_insult = insult_subsets[0].pick_random()
	player['choices']['wit'] = player_insult
	insult_subsets[0].erase(player_insult)
	var opponent_insult = insult_subsets[1].pick_random()
	opponent['choices']['wit'] = opponent_insult
	insult_subsets[1].erase(opponent_insult)
	
	## IF CHA is not on cooldown for each combantant
	## TODO: CREATE DIALOG OPTIONS FOR CHA
	var player_cha_power = bc.CHA_POWERS[bc.HAT_CHA_POWERS[player['active_hat']]].call(player["stats"]["cha"])
	player['choices']['cha'] = player_cha_power
	var opponent_cha_power = bc.CHA_POWERS[bc.HAT_CHA_POWERS[opponent['active_hat']]].call(opponent["stats"]["cha"])
	opponent['choices']['cha'] = opponent_cha_power
	
	var player_hat_ability = bc.HAT_ABILITIES[player['active_hat']]
	player['choices']['hat'] = player_hat_ability
	var opponent_hat_ability = bc.HAT_ABILITIES[opponent['active_hat']]
	opponent['choices']['hat'] = opponent_hat_ability

func choose(choice):
	round_state = []
	player['choice'] = choice
	## TESTING
	opponent['choice'] =  ['cha', 'wit', 'hat'].pick_random()
	
	resolve_round()

func resolve_round():
	var init_array = determine_initiative()
	calculate_outcome(init_array)
	print(round_state)
	# check_winner()
	# adjust_cooldowns()
	# adjust_hat_order()
	
	# return round_state

func determine_initiative():
	var first_player
	var second_player
	
	var p_init = player['stats']['wit'] + player['stats']['cha']
	var o_init = opponent['stats']['wit'] + opponent['stats']['cha']
	
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
		var r_state = {} # TODO: Add what the UI needs from the outcome
		
		var combatant = init_array[i]
		r_state['name'] = combatant.name
		var opp = init_array[1 - i]  # Get the opp of combatant.
		
		r_state['choice'] = combatant['choice']
		if combatant['choice'] == 'cha':
			## apply cha buffs
			for stat in combatant['choices']['cha'].keys():
				combatant['stats'][stat] = clamp(combatant['stats'][stat] + combatant['choices']['cha'][stat], 0, INF)
				r_state['buffs'] = {stat: combatant['choices']['cha'][stat]}
				
		if combatant['choice'] == 'wit':
			## apply wit damage to opp
			rng.randomize()
			var base_dmg = rng.randi_range(1, 3) 
			## TODO: declare "crits"
			# Deal damange to opp
			var damage = bc.damage_formula(combatant['stats']['wit'], opp['stats']['def'], base_dmg)
			opp['stats']["stam"] = clamp(opp['stats']["stam"] - damage, 0, INF)
			r_state['dmg'] = damage
		
		if combatant['choice'] == 'hat':
			## apply hat effects
			if combatant['choices']['hat'].has('cha'):
				var hat_effect = combatant['choices']['hat']['cha'].call(combatant['stats']['cha'])
				for stat in hat_effect.keys():
					combatant['stats'][stat] = clamp(combatant['stats'][stat] + hat_effect[stat], 0, INF)
					r_state['buffs'] = {'stat': stat, 'value': hat_effect[stat]}
			## apply hat dmg
			if combatant['choices']['hat'].has('dmg'):
				var hat_dmg = combatant['choices']['hat'].call(combatant['stats']['wit'], opp['stats']['def'])
				opp['stats']["stam"] = clamp(opp['stats']["stam"] - hat_dmg, 0, INF)
				r_state['dmg'] = hat_dmg
		
		r_state['stam'] = combatant['stats']['stam']
		# Check for winner
		if opp['stats']['stam'] == 0:
			winner = combatant
			loser = opp
			r_state['won'] = winner == combatant
			round_state.append(r_state)
			break
		
		round_state.append(r_state)
		
		
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
