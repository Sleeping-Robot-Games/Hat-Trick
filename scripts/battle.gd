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
var previous_round_state = []
var current_round = 1

var insult_subsets

# Start of battle:
## Assign all relevant info to opponent and player dictionaries
### Stats, Name, Hats, Health, 
## Load dialogue options for player (called choices in playtest)
### These dialogue options come from the singleton bc (battle_constants.gd)
### In this script we will dyanmically create two pools of each dialogue option from bc for each combatant
### this way they don't speak the same insults to eachother

func start():
	assign_info()
	insult_subsets = initialize_insults()
	load_dialogue_options(player)
	load_dialogue_options(opponent)
	hud.update_dialogue()

func assign_info():
	p = hud.player
	o = hud.opponent
	player['stats'] = p.stats
	player['max_hp'] = p.stats.stam
	player['active_hat'] = p.hat_stack[0]
	player['name'] = p.player_name
	player['choices'] = {}
	player['is_player'] = p.is_player
	opponent['stats'] = o.stats
	opponent['max_hp'] = p.stats.stam
	opponent['active_hat'] = o.hat_stack[0]
	opponent['choices'] = {}
	opponent['name'] = o.npc_name
	opponent['is_player'] = o.is_player

func initialize_insults():
	var insults_copy = bc.WIT_INSULTS.duplicate(true)
	insults_copy.shuffle()
	var subset_1 = insults_copy.slice(0, insults_copy.size() / 2)
	var subset_2 = insults_copy.slice(insults_copy.size() / 2, insults_copy.size())
	return [subset_1, subset_2]

func load_dialogue_options(combatant):
	combatant['choices'] = {}
	
	var subset = 0 if combatant.name == player.name else 1
	var insult = insult_subsets[subset].pick_random()
	## calculated dmg
	combatant['choices']['wit'] = insult.duplicate(true)
	combatant['choices']['wit']['dialogue'] = insult.duplicate(true) # you dirty dog
	insult_subsets[subset].erase(insult)
	
	var cha_key = bc.HAT_CHA_POWERS[combatant['active_hat']]
	if previous_round_state.size() == 0:
		# Gives them a cha option at the start of the battle
		var cha_power = bc.CHA_POWERS[cha_key].call(combatant["stats"]["cha"])
		combatant['choices']['cha'] = cha_power
		combatant['choices']['cha']['dialogue'] = bc.CHA_DIALOGUE_OPTIONS[cha_key].pick_random()
	else:
		for r_state in previous_round_state:
			if r_state.name == combatant.name:
				if r_state.has('choice') and r_state['choice'] != 'cha':
					var cha_power = bc.CHA_POWERS[cha_key].call(combatant["stats"]["cha"])
					combatant['choices']['cha'] = cha_power
					combatant['choices']['cha']['dialogue'] = bc.CHA_DIALOGUE_OPTIONS[cha_key].pick_random()
		
	var hat_ability = bc.HAT_ABILITIES[combatant['active_hat']]
	combatant['choices']['hat'] = hat_ability
	combatant['choices']['hat']['dialogue'] = bc.hat_sayings[combatant['active_hat']]

func choose(choice):
	round_state = []
	player['choice'] = choice
	opponent['choice'] = opponent.choices.keys().pick_random()
	resolve_round()

func resolve_round():
	var init_array = determine_initiative()
	calculate_outcome(init_array)
	hud.update_hud(round_state) 
	adjust_cooldowns()
	# adjust_hat_order()
	previous_round_state = round_state
	

func new_round():
	load_dialogue_options(player)
	load_dialogue_options(opponent)
	hud.update_dialogue()

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
		r_state['node'] = p if combatant.name == player.name else o
		
		var opp = init_array[1 - i]  # Get the opp of combatant.
		
		r_state['choice'] = combatant['choice']
		if combatant['choice'] == 'cha':
			## apply cha buffs
			for stat in combatant['choices']['cha'].keys():
				if stat == 'dialogue':
					continue
				combatant['stats'][stat] = clamp(combatant['stats'][stat] + combatant['choices']['cha'][stat], 0, INF)
				if not r_state.has('cha_buffs'):
					r_state['cha_buffs'] = {}
				r_state['cha_buffs'][stat] = combatant['choices']['cha'][stat]
				
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
			if combatant['choices']['hat'].has('buff'):
				var hat_effect = combatant['choices']['hat']['buff'].call(combatant['stats']['cha'])
				for stat in hat_effect.keys():
					if stat == "stam": # Don't over heal
						r_state['heal'] = hat_effect[stat]
						combatant['stats'][stat] = clamp(combatant['stats'][stat] + hat_effect[stat], 0, combatant.max_hp)
					else:
						combatant['stats'][stat] = clamp(combatant['stats'][stat] + hat_effect[stat], 0, INF)
					if not r_state.has('hat_buffs'):
						r_state['hat_buffs'] = {}
					r_state['hat_buffs'][stat] = hat_effect[stat]
			## apply hat dmg
			if combatant['choices']['hat'].has('dmg'):
				var hat_dmg = combatant['choices']['hat']['dmg'].call(combatant['stats']['wit'], opp['stats']['def'])
				opp['stats']["stam"] = clamp(opp['stats']["stam"] - hat_dmg, 0, INF)
				r_state['dmg'] = hat_dmg
			## cycle hat to top of stack
			print('combatant: ', combatant)
			var cycled_hat = r_state['node'].hat_stack.pop_front()
			r_state['node'].hat_stack.push_back(cycled_hat)
			r_state['node'].active_hat = r_state['node'].hat_stack[0]
			combatant['active_hat'] = r_state['node'].active_hat
		
		r_state['stam'] = combatant['stats']['stam']
		# Check for winner
		if opp['stats']['stam'] == 0:
			winner = combatant
			loser = opp
			r_state['won'] = winner == combatant
			round_state.append(r_state)
			break
		
		round_state.append(r_state)

func adjust_cooldowns():
	for r_state in previous_round_state:
		if r_state.choice == 'cha':
			var combatant = player if player.name == r_state.name else opponent
			## reverse cha buffs
			for stat in r_state['cha_buffs'].keys():
				combatant['stats'][stat] = clamp(combatant['stats'][stat] + (r_state['cha_buffs'][stat]*-1), 0, INF)
				
# After dialogue option is chosen
## Determine round initiative (WIT + CHA), if tied random
## Calculate outcome
### In initiative order resolve the dialogues
#### Apply damage or buffs 
#### maybe into a state object then send up to UI in a function that will play it out in an animation similar to the test animtaion set now
### Check for winner, if so end round early and conclude battle

## Resolve round
### Set cooldowns for any CHA options used
### refresh cooldowns that were already set from previous round to make available again
### Adjust hat order if any HAT abilities were used, send up to UI

## Conclude battle
### If player won award hat, send up to UI
### If player lost send NPC to next room
### Clear any state to null for player, oppponent, p, o, round, winner, loser, etc
### Remove battle UI and set camera back to normal
