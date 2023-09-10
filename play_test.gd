extends Control

var rng = RandomNumberGenerator.new()

var winner
var loser

var player_1_initial_state = {
	"name": "p1",
	"display_name": "Bronsky",
	"hats": [],
	"avail_hats": [],
	"STAM": 6,
	"DEF": 1,
	"CHA": 2,
	"WIT": 3,
	"base_dmg": 2,
	'current_choice': null,
	'choices': [],
	'applied_choices': [],
	'cooldowns': {'CHA': 0, 'WIT': 0},
}

var captivate_options = [
"Your energy lights up the room.",
"Your presence brings a sense of wonder.",
"There's something magical about the way you carry yourself.",
"I'm truly mesmerized by you."
]

var empower_self_options = [
"Who needs coffee when I'm this fabulous?",
"Self-high-five!",
"I'm basically a limited edition.",
"Woke up like this. #Flawless"
]

var insult_options = [
"If brains were dynamite, you wouldn't have enough to blow your nose.",
"You're a few sandwiches short of a picnic, aren't you?",
"Was that the best you could come up with?",
"If I wanted to hear from an idiot, I'd watch a mirror.",
"Your elevator doesn't go all the way to the top floor, does it?",
"You bring joy to everyone... when you leave the room.",
"If I had a penny for every brain cell you have, I'd have one cent.",
"You're not the sharpest tool in the shed, are you?",
"Your family tree must be a cactus because everyone on it is a prick.",
"You're the reason we have instructions on shampoo bottles.",
"If I wanted a joke, I would've just looked at your face.",
"You're like a broken pencil: pointless.",
"You must have been born on a highway, because that's where most accidents happen.",
"Keep talking, maybe one day you'll say something intelligent.",
"I'd love to see things from your perspective, but I just can't put my head that far up my butt.",
"You're proof that evolution can go in reverse.",
"It's hard to get the big picture when you have a small screen.",
"If brains were dynamite, you wouldn't have enough to blow your hat off.",
"Why don't you slip into something more comfortable? Like a coma.",
"The only way you'll ever get laid is if you climb up a chicken's backside and wait.",
"Your secrets are always safe with me. I never even listen when you tell me them.",
"You have the perfect face... for radio.",
"When they were handing out brains, you thought they said trains and took the next one out of town.",
"You're not stupid; you just have a lot of bad luck thinking.",
]

var fedora_options = [
"M'lady.",
"This hat isn't just a fashion statement, it's a lifestyle.",
"Tip of the fedora to you!",
"It's not about the hat, it's about the attitude."
]

var cowboy_options = [
"Howdy, partner!",
"This town ain't big enough for the two of us.",
"Giddy up!",
"Ride 'em, cowboy!"
]

var witch_options = [
"Brewing up some mischief?",
"Toil and trouble!",
"A dash of magic.",
"Feel the spells in the air?"
]

var p1
var p2 
var npcs = [
	{
		"name": "p2",
		"display_name": "The Witch",
		"hats": ["Witch"],
		"avail_hats": ["Witch"],
		"STAM": 6,
		"DEF": 2,
		"CHA": 1,
		"WIT": 2,
		"base_dmg": 2,
		'current_choice': null,
		'choices': [],
		'applied_choices': [],
		'cooldowns': {'CHA': 0, 'WIT': 0},
	},
	{
		"name": "p2",
		"display_name": "Emmett",
		"hats": ["Cowboy"],
		"avail_hats": ["Cowboy"],
		"STAM": 6,
		"DEF": 2,
		"CHA": 3,
		"WIT": 1,
		"base_dmg": 2,
		'current_choice': null,
		'choices': [],
		'applied_choices': [],
		'cooldowns': {'CHA': 0, 'WIT': 0},
	}
]

var round = 1

var outcome_summary = []

func _ready():
	p1 = player_1_initial_state.duplicate(true)
	p1.hats = ['Fedora']
	p1.avail_hats = p1.hats.duplicate()
	p2 = npcs.pick_random().duplicate(true)
	
	$p1_display_name.text = p1.display_name
	$p2_display_name.text = p2.display_name
	
	$p1_health_bar.max_value = p1.STAM
	$p2_health_bar.max_value = p2.STAM
	
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
			'rounds': 1,
			'dialog': captivate_options.pick_random(),
		},
		{
			'type': 'CHA',
			'label': '[CHA] Empower - CHA/WIT Bonus',
			'self': true,
			'stats': {'CHA': player['CHA'], 'WIT': player['CHA']},
			'damage': func(): return 0,
			'rounds': 1,
			'dialog': empower_self_options.pick_random()
		}]
	var wit_choices = [{
			'type': 'WIT',
			'label': '[WIT] Insult - Damage',
			'self': false,
			'stats': {},
			'damage': func(): return player['WIT'] + player['base_dmg'],
			'rounds': 0,
			'dialog': insult_options.pick_random()
		}]
	var hat_choices = [
		{
			'type': 'HAT',
			'hat_type': 'Fedora',
			'label': '[HAT] Fedora Hat Envy',
			'self': true,
			'stats': {"WIT": 3, "DEF": -2},
			'damage': func(): return 0,
			'rounds': -1,
			'dialog': fedora_options.pick_random()
		},
		{
			'type': 'HAT',
			'hat_type': 'Cowboy',
			'label': '[HAT] Cowboy Charm',
			'self': true,
			'stats': {"CHA": 2, "DEF": 1},
			'damage': func(): return 0,
			'rounds': -1,
			'dialog': cowboy_options.pick_random()
		},
		{
			'type': 'HAT',
			'hat_type': 'Witch',
			'label': '[HAT] Witch Curse',
			'self': false,
			'stats': {},
			'damage': func(): return player['WIT'] + player['base_dmg'] * 2,
			'rounds': -1,
			'dialog': witch_options.pick_random()
		},
	]
	
	if player.cooldowns["CHA"] == 0:
		player.choices.append_array(cha_choices)
	if player.cooldowns["WIT"] == 0:
		player.choices.append_array(wit_choices)
	if player.avail_hats.size() > 0:
		for hat in hat_choices:
			if player.avail_hats[0] == hat.hat_type:
				player.choices.append(hat)

func add_choices_to_scene(parent, choices):
	for choice in choices:
		var button = Button.new()
		button.text = choice.label + " - " + choice.dialog
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.button_up.connect(on_choice_button_up.bind(choice))
		parent.add_child(button)

func update_player_stat_labels():
	for stat in $P1Stats.get_children():
		stat.get_node('Value').text = str(p1[stat.name])
	
	for stat in $P2Stats.get_children():
		stat.get_node('Value').text = str(p2[stat.name])
		
	# Set health bars
	var p1_health_bar = get_node(p1.name + '_health_bar')
	p1_health_bar.value = p1.STAM
	
	var p2_health_bar = get_node(p2.name + '_health_bar')
	p2_health_bar.value = p2.STAM
	
	$Round/Value.text = str(round)

func populate_choices():
	add_choices_to_player(p1)
	add_choices_to_scene($P1Choices, p1.choices)
	
	add_choices_to_player(p2)
	add_choices_to_scene($P2Choices, p2.choices)

func remove_choices(player):
	player.choices = []
	for choice in get_node(player.name.to_upper()+'Choices').get_children():
		get_node(player.name.to_upper()+'Choices').remove_child(choice)

func on_choice_button_up(choice):
	p1['current_choice'] = choice
	remove_choices(p1)
	
	# NPC picks their choice
	p2['current_choice'] = p2.choices.pick_random()
	remove_choices(p2)
	
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
	
	for i in range(players.size()):
		var player = players[i]
		add_outcome("[u]"+player.display_name)
		add_outcome(player.current_choice.label)
		add_outcome("[b]"+player.current_choice.dialog)
		if player.current_choice.self:
			apply_changes(player, player.current_choice)
		else:
			var other_player = players[1 - i]  # Get the other player.
			apply_changes(other_player, player.current_choice)
			
			# Check for winner
			if other_player.STAM == 0:
				print(player.display_name + " is the winner")
				winner = player
				loser = other_player
				break
				
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
			player.avail_hats.pop_front()  # Remove the first hat (used hat)
	
	
	round = round + 1
	await show_outcome_summary()
	await get_tree().create_timer(1).timeout
	
	p1.current_choice = null
	p2.current_choice = null
	
	update_player_stat_labels()
	
	if winner:
		$BattleOver.text = winner.display_name + " Wins!"
		$BattleOver.show()
		$Button.show()
		return
	
	populate_choices()
	
	update_cooldowns(p1)
	update_cooldowns(p2)
	

func start_new_battle():
	reset_battle()
	outcome_summary = []
	show_outcome_summary()
	populate_choices()
	update_player_stat_labels()

func reset_battle():
	print("BATTLE OVER RESET STATE")
	
	round = 1
	# Reset to initial state besides hats
	var p1_hats = p1.hats
	p1 = player_1_initial_state.duplicate(true)
	p1.hats.append_array(p1_hats)
	p1.avail_hats = p1.hats.duplicate()
	if winner.name == 'p1':
		p1.hats.append(loser.hats[0])
		p1.avail_hats = p1.hats.duplicate()
		# Remove NPC from array
		for npc in npcs:
			if npc.display_name == loser.display_name:
				npcs.erase(npc)
	# Reset NPC to inital state by picking a new one
	if npcs.size() > 0:
		p2 = npcs.pick_random().duplicate(true)
	else:
		print("GAME OVER")
		$GameOver.show()
		return
	
	winner = null
	loser = null
	
	$BattleOver.hide()
	$Button.hide()
	
	$p1_display_name.text = p1.display_name
	$p2_display_name.text = p2.display_name
	
	$p1_health_bar.max_value = p1.STAM
	$p2_health_bar.max_value = p2.STAM
	
	$Round/Value.text = str(round)


func show_outcome_summary():
	for outcome_node in $Outcomes.get_children():
		$Outcomes.remove_child(outcome_node)
	for outcome in outcome_summary:
		var outcome_label = RichTextLabel.new()
		outcome_label.bbcode_enabled = true
		outcome_label.text = outcome
		outcome_label.custom_minimum_size.x = 600
		outcome_label.custom_minimum_size.y = 30
		await get_tree().create_timer(.5).timeout
		$Outcomes.add_child(outcome_label)

func add_outcome(msg):
	outcome_summary.append(msg)

func apply_changes(player, choice):
	for stat in choice['stats'].keys():
		var old_stat = player[stat]
		player[stat] = clamp(player[stat] + choice['stats'][stat], 0, INF)
		#add_outcome("%s %s + %s = %s %s" % [stat, old_stat, str(choice['stats'][stat]), stat, player[stat]])
		if choice['stats'][stat] > 0:
			add_outcome("%s rises!" % stat)
		else:
			add_outcome("%s falls.." % stat)
	var damage = choice['damage'].call() - player["DEF"]
	var true_damage = clamp(damage, 0, INF)
	player["STAM"] = clamp(player["STAM"] - true_damage, 0, INF)
	if choice['damage'].call() != 0:
		#add_outcome("Dmg %s - DEF %s" % [choice['damage'].call(), player["DEF"]])
		add_outcome("Dealt [color=#FF0000]%s[/color] to %s" % [str(true_damage), player.display_name])

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


func _on_button_button_up():
	start_new_battle()
