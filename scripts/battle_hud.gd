extends Control
var player = null
var opponent = null
@onready var hat_nodes = {
	'player': {
		0: $PlayerHatStack/HatStackItem0,
		1: $PlayerHatStack/HatStackItem1,
		2: $PlayerHatStack/HatStackItem2,
		3: $PlayerHatStack/HatStackItem3,
		4: $PlayerHatStack/HatStackItem4,
		5: $PlayerHatStack/HatStackItem5,
		6: $PlayerHatStack/HatStackItem6,
	},
	'opponent': {
		0: $OpponentHatStack/HatStackItem0,
		1: $OpponentHatStack/HatStackItem1,
		2: $OpponentHatStack/HatStackItem2,
		3: $OpponentHatStack/HatStackItem3,
		4: $OpponentHatStack/HatStackItem4,
		5: $OpponentHatStack/HatStackItem5,
		6: $OpponentHatStack/HatStackItem6,
	},
}

func start_battle(pl, op):
	visible = true
	player = pl
	opponent = op
	var player_hcount = player.hat_array.size()
	var opponent_hcount = opponent.hat_array.size()
	for i in g.max_hats:
		if i + 1 <= player_hcount:
			hat_nodes['player'][i].change_hat(player.hat_array[i])
		else:
			hat_nodes['player'][i].no_hat()
		
		if i + 1 <= opponent_hcount:
			hat_nodes['opponent'][i].change_hat(opponent.hat_array[i])
		else:
			hat_nodes['opponent'][i].no_hat()
