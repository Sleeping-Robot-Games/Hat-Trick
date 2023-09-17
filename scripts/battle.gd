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
var round_history = [] # array of prev round_states
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
	initialize_combatant_state()
	insult_subsets = initialize_insults()
	load_dialogue_options(player)
	load_dialogue_options(opponent)
	hud.render_options()

func initialize_combatant_state():
	p = hud.player
	o = hud.opponent
	player['stats'] = p.stats
	player['cur_hp'] = p.stats['stam']
	player['max_hp'] = p.stats['stam']
	player['hat_stack'] = p.hat_stack.duplicate(true)
	player['active_hat'] = p.hat_stack[0]
	player['name'] = p.player_name
	player['choices'] = {}
	player['is_player'] = p.is_player
	player['is_winner'] = false
	player['cha_buffs'] = {}
	player['hat_buffs'] = {}
	player['dmg'] = 0
	player['crit'] = false
	opponent['stats'] = o.stats
	opponent['cur_hp'] = o.stats['stam']
	opponent['max_hp'] = o.stats['stam']
	opponent['hat_stack'] = o.hat_stack.duplicate(true)
	opponent['active_hat'] = o.hat_stack[0]
	opponent['choices'] = {}
	opponent['name'] = o.npc_name
	opponent['is_player'] = o.is_player
	opponent['is_winner'] = false
	opponent['cha_buffs'] = {}
	opponent['hat_buffs'] = {}
	opponent['dmg'] = 0
	opponent['crit'] = false

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
	combatant['choices']['wit'] = {}
	combatant['choices']['wit']['dialogue'] = insult.duplicate(true) # you dirty dog
	insult_subsets[subset].erase(insult)
	# determine if cha and hat options are available
	var cha_key = bc.HAT_CHA_POWERS[combatant['active_hat']]
	var hat_choice = 'hat_'+combatant['active_hat']
	var give_hat_choice = true
	var give_cha_choice = true
	for i in range(round_history.size()):
		for prev_combatant_state in round_history[i]:
			if prev_combatant_state.is_player != combatant.is_player:
				continue
			if prev_combatant_state['choice'] == 'cha' and i <= bc.cha_cooldown-1:
				give_cha_choice = false
			if prev_combatant_state['choice'] == hat_choice and i <= bc.hat_cooldown-1:
				give_hat_choice = false
	if give_cha_choice:
		var cha_power = bc.CHA_POWERS[cha_key].call(bc.stat_calc(combatant, 'cha'))
		combatant['choices']['cha'] = cha_power
		combatant['choices']['cha']['dialogue'] = bc.CHA_DIALOGUE_OPTIONS[cha_key].pick_random()
	if give_hat_choice:
		var hat_ability = bc.HAT_ABILITIES[combatant['active_hat']]
		combatant['choices'][hat_choice] = hat_ability
		combatant['choices'][hat_choice]['dialogue'] = bc.hat_sayings[combatant['active_hat']]

func choose(choice):
	player['choice'] = 'hat_'+player['active_hat'] if choice == 'hat' else choice
	opponent['choice'] = opponent.choices.keys().pick_random()
	resolve_round()

func reset_stale_state(combatant):
	combatant.dmg = 0
	combatant.crit = false

func new_round():
	round_state = []
	reset_stale_state(player)
	reset_stale_state(opponent)
	adjust_cooldowns()
	load_dialogue_options(player)
	load_dialogue_options(opponent)
	hud.render_options()
	## Show Buffs / Dmg for current round
	## Hide Buffs from prev round
	#hud.update_hud(round_state.duplicate(true))

func resolve_round():
	var init_array = determine_initiative()
	calculate_outcome(init_array)
	hud.update_hud(round_state.duplicate(true))
	
	# adjust_hat_order()
	round_history.push_front(round_state.duplicate(true))
	if round_history.size() > bc.hat_cooldown:
		round_history.resize(bc.hat_cooldown)

func determine_initiative():
	var first_player
	var second_player
	
	var p_init = bc.stat_calc(player, 'wit') + bc.stat_calc(player, 'cha')
	var o_init = bc.stat_calc(opponent, 'wit') + bc.stat_calc(opponent, 'cha')
	
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
	# first pass: update player and opponent state accordingly
	for i in range(init_array.size()):
		var combatant = init_array[i] # combatant battle state
		var opp = init_array[1 - i]  # oponent of combatant battle state		
		if combatant['choice'] == 'cha':
			## apply cha buffs
			for stat in combatant['choices']['cha'].keys():
				if stat == 'dialogue':
					continue
				combatant['cha_buffs'][stat] = combatant['choices']['cha'][stat]
		combatant['dmg'] = 0
		combatant['crit'] = false
		if combatant['choice'] == 'wit':
			## apply wit damage to opp
			rng.randomize()
			var base_dmg = rng.randi_range(1, 3) 
			if base_dmg == 3:
				combatant['crit'] = true
			# Deal damange to opp
			var damage = bc.damage_formula(bc.stat_calc(combatant, 'wit'), bc.stat_calc(opp, 'def'), base_dmg)
			opp['cur_hp'] = clamp(opp['cur_hp'] - damage, 0, opp['max_hp'])
			combatant['dmg'] = damage
		var hat_choice = 'hat_'+combatant['active_hat']
		if combatant['choice'] == hat_choice:
			## apply hat effects
			if combatant['choices'][hat_choice].has('buff'):
				var hat_effect = combatant['choices'][hat_choice]['buff'].call(bc.stat_calc(combatant, 'cha'))
				for stat in hat_effect.keys():
					if not combatant['hat_buffs'].has(hat_choice):
						combatant['hat_buffs'][hat_choice] = {}
					combatant['hat_buffs'][hat_choice][stat] = hat_effect[stat]
			## apply hat dmg
			if combatant['choices'][hat_choice].has('dmg'):
				var hat_dmg = combatant['choices'][hat_choice]['dmg'].call(bc.stat_calc(combatant, 'wit'), bc.stat_calc(opp, 'def'))
				opp['cur_hp'] = clamp(opp['cur_hp'] - hat_dmg, 0, INF)
				combatant['dmg'] = hat_dmg
			## cycle hat to top of stack
			var cycled_hat = combatant.hat_stack.pop_front()
			combatant.hat_stack.push_back(cycled_hat)
			combatant.active_hat = combatant.hat_stack[0]
		# Check for winner
		if opp['cur_hp'] == 0:
			combatant['is_winner'] = true
			opp['is_winner'] = false
			break
	
	# second pass: update round state with battle state
	for i in range(init_array.size()):
		var combatant = init_array[i].duplicate(true) # combatant battle state
		round_state.append(combatant)
	
	# return round state for HUD updates
	return round_state

func adjust_cooldowns():
	for i in range(round_history.size()):
		for prev_combatant_state in round_history[i]:
			var combatant = player if prev_combatant_state.is_player else opponent
			# cha
			if i == bc.cha_cooldown \
			and prev_combatant_state['choice'] == 'cha':
				combatant['cha_buffs'] = {}
			# hats
			if i == bc.hat_cooldown \
			and combatant['hat_buffs'].has(prev_combatant_state['choice']):
				combatant['hat_buffs'].erase(prev_combatant_state['choice'])
	# update hud buffs
	var temp_state = [player.duplicate(true), opponent.duplicate(true)]
	hud.update_hud(temp_state)

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
