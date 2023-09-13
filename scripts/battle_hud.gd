extends Control
var player = null
var opponent = null

func start_battle(pl, op):
	visible = true
	player = pl
	opponent = op
	for i in player.hat_array.size():
		if i < g.max_hats:
			print(player.hat_array[i])
