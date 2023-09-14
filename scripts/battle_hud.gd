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
	},
	'opponent': {
		0: $OpponentHatStack/HatStackItem0,
		1: $OpponentHatStack/HatStackItem1,
		2: $OpponentHatStack/HatStackItem2,
		3: $OpponentHatStack/HatStackItem3,
		4: $OpponentHatStack/HatStackItem4,
		5: $OpponentHatStack/HatStackItem5,
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
	
	await get_tree().create_timer(1).timeout
	for option in $OptionContainer.get_children():
		option.grab_focus()
		await get_tree().create_timer(.5).timeout
		option.release_focus()


## TESTING ONLY
func _on_option_2_button_up():
	# clear prev dialogs
	for dialog in $DialogContainer.get_children():
		dialog.text = ""
	
	var insult_1 = "You must have been born on a highway, because that's where most accidents happen."
	var insult_2 = "Keep talking, maybe one day you'll say something intelligent."
	$SpriteHolder.flip_h()
	$SpriteHolder.show()
	$SpriteHolder.set_sprites({
		'sprite_state': player.get_node("SpriteHolder").sprite_state,
		'pallete_sprite_state': player.get_node("SpriteHolder").pallete_sprite_state
	})
	for i in insult_1:
		$DialogContainer/RichTextLabel.text += i
		await get_tree().create_timer(.03).timeout
	await get_tree().create_timer(1).timeout
	$SpriteHolder.hide()
	
	$SpriteHolder2.show()
	$SpriteHolder2.set_sprites({
		'sprite_state': opponent.get_node("SpriteHolder").sprite_state,
		'pallete_sprite_state': opponent.get_node("SpriteHolder").pallete_sprite_state
	})
	for i in insult_2:
		$DialogContainer/RichTextLabel2.text += i
		await get_tree().create_timer(.03).timeout
	await get_tree().create_timer(1).timeout
	$SpriteHolder2.hide()
