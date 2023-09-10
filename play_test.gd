extends Control

var status = {
	"Overconfident": {
		"stats": {
			"WIT": 2,
			"DEF": -2
		},
		"self": true
	},
	"Hat Envy": {
		"stats": {
			"WIT": -2,
			"CHA": -2
		},
		"self": false
	},
}

var p1_stats = {
	"Hats": "Fedora +1 WIT",
	"STAM": 6,
	"DEF": 1,
	"CHA": 2,
	"WIT": 3,
	"HatTips": "Overconfident",
	"BaseDmg": 2
}

var p2_stats = {
	"Hats": "Cowboy +1 DEF",
	"STAM": 6,
	"DEF": 3,
	"CHA": 2,
	"WIT": 1,
	"HatTips": "Hat Envy",
	"BaseDmg": 2
}

var round = 1
var p1_chose = false
var p2_chose = false
## TODO: Make dictionaries with choice logic
var p1_choices = [
	'[CHA] Allure - DEF bonus',
	'[CHA] Empower - CHA/WIT Bonus',
	'[WIT] Insult - Damage',
	'[WIT] Quick Retort - Damage*'
]
var p2_choices = [
	'[CHA] Allure - DEF bonus',
	'[CHA] Empower - CHA/WIT Bonus',
	'[WIT] Insult - Damage',
	'[WIT] Quick Retort - Damage*'
]

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

func update_player_stat_labels():
	for stat in $P1Stats.get_children():
		stat.get_node('Value').text = str(p1_stats[stat.name])
		
	for stat in $P2Stats.get_children():
		stat.get_node('Value').text = str(p2_stats[stat.name])

func populate_choices():
	for choice in p1_choices:
		var button = Button.new()
		button.text = choice
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.button_up.connect(on_choice_button_up.bind('p1', choice))
		$P1Choices.add_child(button)
	
	for choice in p2_choices:
		var button = Button.new()
		button.text = choice
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.button_up.connect(on_choice_button_up.bind('p2', choice))
		$P2Choices.add_child(button)

func on_choice_button_up(player, choice):
	## TODO: Check if other player has chosen, if so start outcome
	print(player)
	print(choice)
	
func calculate_outcome():
	## TODO: Calculate outcome first based on intitiave then choices
	## TODO: Apply changes to player stat state then call update_player_stat_labels()
	## TODO: Increment round then repopulate choices 
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

