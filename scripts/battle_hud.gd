extends Control
var player = null
var opponent = null
@onready var battle = $Battle
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

func _ready():
	$Battle.start()

func update_dialog(player, opponent):
	var option_stats = {
		1: 'cha',
		2: 'wit',
		3: 'hat',
	}
	for i in range(1, 3):
		var option = get_node('OptionContainer/Option'+str(i))
		var stat = option_stats[i]
		option.visible = player.choices.has(stat)
		if option.visible:
			var dialogue = player.choices[stat].dialogue
			option.text = '['+stat.to_upper()+'] '+dialogue.short
			option.pressed.connect(_on_option_pressed.bind(stat, dialogue.long))

func update_hud(round_state):
	for state in round_state:
		state.node

func new_round():
	pass

func start_battle(pl, op):
	visible = true
	$AnimationPlayer.play('start')
	player = pl
	opponent = op
	
	# $Battle.start()
	## show proceed button?
	
	var player_hcount = player.hat_array.size()
	var opponent_hcount = opponent.hat_array.size()
	for i in g.max_hats:
		hat_nodes['player'][i].no_hat()
		hat_nodes['opponent'][i].no_hat()
	for i in g.max_hats:
		if i + 1 <= player_hcount:
			await get_tree().create_timer(.3).timeout
			g.play_sfx(get_parent(), 'pop')
			hat_nodes['player'][i].change_hat(player.hat_array[i])
		if i + 1 <= opponent_hcount:
			await get_tree().create_timer(.3).timeout
			g.play_sfx(get_parent(), 'pop')
			hat_nodes['opponent'][i].change_hat(opponent.hat_array[i])
	

	await get_tree().create_timer(3).timeout
	for option in $OptionContainer.get_children():
		if option.visible:
			option.grab_focus()
			await get_tree().create_timer(.5).timeout
			option.release_focus()

func _on_option_pressed(stat, long):
	for option in $OptionContainer.get_children():
		option.visible = false
	
	## show long text
	battle.choose(stat)
	# get opponent dialogue
	var opponent_choice = battle.opponent.choice
	var opponent_choice_data = battle.opponent.choices[opponent_choice]
	var opponent_long = opponent_choice_data.dialogue.long
	
	# show proceed button
	$ProceedButton.visible = true
	
	# render player text
	$SpriteHolder.flip_h()
	$SpriteHolder.show()
	$SpriteHolder.set_sprites({
		'sprite_state': player.get_node("SpriteHolder").sprite_state,
		'pallete_sprite_state': player.get_node("SpriteHolder").pallete_sprite_state
	})
	$DialogContainer/RichTextLabel.text = "[u]%s[/u][color=7fa6be]: %s[/color] " % [player.player_name, stat.to_upper()]
	for i in long:
		$DialogContainer/RichTextLabel.text += i
		await get_tree().create_timer(.03).timeout
	await get_tree().create_timer(1).timeout
	$SpriteHolder.hide()
	
	# render opponent text
	$SpriteHolder2.show()
	$SpriteHolder2.set_sprites({
		'sprite_state': opponent.get_node("SpriteHolder").sprite_state,
		'pallete_sprite_state': opponent.get_node("SpriteHolder").pallete_sprite_state
	})
	$DialogContainer/RichTextLabel2.text = "[right][u]%s[/u][color=7fa6be]: %s[/color] " % [opponent.npc_name, opponent_choice.to_upper()]
	for i in opponent_long:
		$DialogContainer/RichTextLabel2.text += i
		await get_tree().create_timer(.03).timeout
	await get_tree().create_timer(1).timeout
	$SpriteHolder2.hide()

func _on_proceed_button_pressed():
	$ProceedButton.visible = false
	## TODO: move option visibility to after chat bubble animation
	for option in $OptionContainer.get_children():
		option.visible = false
	battle.new_round()

## TESTING ONLY
func _on_option_2_button_up():
	$Battle.choose('wit')
	# SHOW LONG FORM OF DIALOGUE
	# PROCEED BUTTON
	return
	
	$OptionContainer.hide()
	
	$PlayerDialogBubble.show()
	$PlayerDialogBubble.play("fill")
	$OpponentDialogBubble.show()
	$OpponentDialogBubble.play("fill")
	
	var insult_1 = "You must have been born on a highway, because that's where most accidents happen."
	var insult_2 = "Keep talking, maybe one day you'll say something intelligent."
	$SpriteHolder.flip_h()
	$SpriteHolder.show()
	$SpriteHolder.set_sprites({
		'sprite_state': player.get_node("SpriteHolder").sprite_state,
		'pallete_sprite_state': player.get_node("SpriteHolder").pallete_sprite_state
	})
	$DialogContainer/RichTextLabel.text = "[u]%s[/u][color=7fa6be]: WIT[/color] " % player.player_name
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
	$DialogContainer/RichTextLabel2.text = "[right][u]%s[/u][color=7fa6be]: WIT[/color] " % opponent.npc_name
	for i in insult_2:
		$DialogContainer/RichTextLabel2.text += i
		await get_tree().create_timer(.03).timeout
	await get_tree().create_timer(1).timeout
	$SpriteHolder2.hide()
	
	await get_tree().create_timer(1).timeout
	
	# if opponent played wit
	# $AnimationPlayer.play('opp_shoot')
	# if player played wit
	# $AnimationPlayer.play('player_shoot')
