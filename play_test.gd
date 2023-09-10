extends Control

var rng = RandomNumberGenerator.new()

var p1 = {
	"name": "p1",
	"hats": ["Fedora", "Cowboy"],
	"STAM": 6,
	"DEF": 1,
	"CHA": 2,
	"WIT": 3,
	"HatTips": "Overconfident",
	"BaseDmg": 2,
	'current_choice': null,
	'choices': [],
	'applied_choices': [],
	'cooldowns': {'CHA': 0, 'WIT': 0},
}

var p2 = {
	"name": "p2",
	"hats": ["Witch"],
	"STAM": 6,
	"DEF": 3,
	"CHA": 2,
	"WIT": 1,
	"HatTips": "Hat Envy",
	"BaseDmg": 2,
	'current_choice': null,
	'choices': [],
	'applied_choices': [],
	'cooldowns': {'CHA': 0, 'WIT': 0},
}

var round = 1

var outcome_summary = []

## PLAY TEST GAME FLOW ##
# Each player selects a choice
# After a choice is selected they disappear (hide)
# After both players pick a choice the Outcome appears
## Outcome shows as follows
### Declare any stat changes
### Declare any damage
### Show Quotes of acutal dialog
# After outcome is shown player stats update in state and labels
# Choices are repopulated
# Repeat

func _ready():
	update_player_stat_labels()
	$Round/Value.text = str(round)
	populate_choices()

func add_choices_to_player(player):
	var cha_choices = [{
			'type': 'CHA',
			'label': '[CHA] Captivate - DEF bonus',
			'self': true,
			'stats': {'DEF': player['CHA']},
			'damage': func(): return 0,
			'rounds': 1
		},
		{
			'type': 'CHA',
			'label': '[CHA] Empower - CHA/WIT Bonus',
			'self': true,
			'stats': {'CHA': player['CHA'], 'WIT': player['CHA']},
			'damage': func(): return 0,
			'rounds': 1
		}]
	var wit_choices = [{
			'type': 'WIT',
			'label': '[WIT] Insult - Damage',
			'self': false,
			'stats': {},
			'damage': func(): return player['WIT'] + player['BaseDmg'],
			'rounds': 0
		}]
	var hat_choices = [
		{
			'type': 'HAT',
			'hat_type': 'Fedora',
			'label': '[HAT] Fedora Hat Envy',
			'self': true,
			'stats': {"WIT": 3, "DEF": -2},
			'damage': func(): return 0,
			'rounds': -1
		},
		{
			'type': 'HAT',
			'hat_type': 'Cowboy',
			'label': '[HAT] Cowboy Charm',
			'self': true,
			'stats': {"CHA": 2, "DEF": 1},
			'damage': func(): return 0,
			'rounds': -1
		},
		{
			'type': 'HAT',
			'hat_type': 'Witch',
			'label': '[HAT] Witch Curse',
			'self': false,
			'stats': {},
			'damage': func(): return player['WIT'] + player['BaseDmg'] * 2,
			'rounds': -1
		},
	]
	
	if player.cooldowns["CHA"] == 0:
		player.choices.append_array(cha_choices)
	if player.cooldowns["WIT"] == 0:
		player.choices.append_array(wit_choices)
	if player.hats.size() > 0:
		for hat in hat_choices:
			if player.hats[0] == hat.hat_type:
				player.choices.append(hat)

func update_player_stat_labels():
	for stat in $P1Stats.get_children():
		stat.get_node('Value').text = str(p1[stat.name])
		
	for stat in $P2Stats.get_children():
		stat.get_node('Value').text = str(p2[stat.name])
	
	$Round/Value.text = str(round)

func populate_choices():
	add_choices_to_player(p1)
	for choice in p1.choices:
		var button = Button.new()
		button.text = choice.label
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.button_up.connect(on_choice_button_up.bind('p1', choice))
		$P1Choices.add_child(button)
	
	add_choices_to_player(p2)
	for choice in p2.choices:
		var button = Button.new()
		button.text = choice.label
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.button_up.connect(on_choice_button_up.bind('p2', choice))
		$P2Choices.add_child(button)

func remove_choices(player):
	player.choices = []
	for choice in get_node(player.name.to_upper()+'Choices').get_children():
		get_node(player.name.to_upper()+'Choices').remove_child(choice)

func on_choice_button_up(player, choice):
	if player == 'p1':
		p1['current_choice'] = choice
		remove_choices(p1)
		if p2['current_choice']:
			calculate_outcome()
	
	if player == 'p2':
		p2['current_choice'] = choice
		remove_choices(p2)
		if p1['current_choice']:
			calculate_outcome()

func determine_initiative():
	var first_player
	var second_player
	
	var p1_init = p1['WIT'] + p1['CHA']
	var p2_init = p2['WIT'] + p2['CHA']
	
	if p1_init > p2_init:
		first_player = p1
		second_player = p2
	if p2_init > p1_init: 
		first_player = p2
		second_player = p1
	if p1_init == p2_init:
		var players = [p1, p2]
		players.shuffle()
		return players
	
	return [first_player, second_player]

	
func calculate_outcome():
	outcome_summary = []
	show_outcome_summary()
	var players = determine_initiative()
	#PLAYER
#	{
#	"name": "p2",
#	"Hats": "Cowboy +1 DEF",
#	"STAM": 6,
#	"DEF": 3,
#	"CHA": 2,
#	"WIT": 3,
#	"HatTips": "Hat Envy",
#	"BaseDmg": 2,
#	'choice': null
#	}
	#CHOICE
#	{
#		'label': '[CHA] Allure - DEF bonus',
#		'self': true,
#		'stats': [{'DEF': p2_stats['CHA']}],
#		'damage': 0
#	}
	for i in range(players.size()):
		var player = players[i]
		add_outcome('Player 1' if (player.name == 'p1') else 'Player 2')
		add_outcome(player.current_choice.label)
		if player.current_choice.self:
			apply_changes(player, player.current_choice)
		else:
			var other_player = players[1 - i]  # Get the other player.
			apply_changes(other_player, player.current_choice)
			
		# Keep track of choices
		player.applied_choices.append(player.current_choice)
		
		# Apply cooldowns as normal
		if player.current_choice.rounds >= 0:
			player.cooldowns[player.current_choice.type] = player.current_choice.rounds
		else:
			# If rounds is -1, player.current_choice can't be used again
			player.cooldowns[player.current_choice.type] = 999 # some large number to effectively disable it
		
		# If a hat choice was made, move the hat to the end of the hats array and reset CD if more hats are avail
		if player.current_choice.type == "HAT":
			player.hats.pop_front()  # Remove the first hat (used hat)
		
	round = round + 1
	await show_outcome_summary()
	await get_tree().create_timer(1).timeout
	p1.current_choice = null
	p2.current_choice = null
	populate_choices()
	
	update_cooldowns(p1)
	update_cooldowns(p2)
	
	update_player_stat_labels()
	

func show_outcome_summary():
	for outcome_node in $Outcomes.get_children():
		$Outcomes.remove_child(outcome_node)
	for outcome in outcome_summary:
		var outcome_label = Label.new()
		outcome_label.text = outcome
		await get_tree().create_timer(.5).timeout
		$Outcomes.add_child(outcome_label)

func add_outcome(msg):
	outcome_summary.append(msg)

func apply_changes(player, choice):
	for stat in choice['stats'].keys():
		var old_stat = player[stat]
		player[stat] = clamp(player[stat] + choice['stats'][stat], 0, INF)
		add_outcome("%s %s + %s = %s %s" % [stat, old_stat, str(choice['stats'][stat]), stat, player[stat]])
	var damage = choice['damage'].call() - player["DEF"]
	var true_damage = clamp(damage, 0, INF)
	player["STAM"] = clamp(player["STAM"] - true_damage, 0, INF)
	if choice['damage'].call() != 0:
		add_outcome("Dmg %s - DEF %s" % [choice['damage'].call(), player["DEF"]])
		add_outcome("Dealt %s to %s" % [str(true_damage), player.name])

func update_cooldowns(player):
	# Reverse effects for choices that have ended their cooldown
	for choice in player.applied_choices:
		if player.cooldowns[choice.type] == 0:
			for stat in choice.stats.keys():
				player[stat] = clamp(player[stat] - choice.stats[stat], 0, INF)
			player.applied_choices.erase(choice)

	for type in player.cooldowns.keys():
		if player.cooldowns[type] > 0:
			player.cooldowns[type] -= 1
