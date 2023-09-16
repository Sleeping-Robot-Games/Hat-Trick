extends Control
var player = null
var opponent = null
var is_talking = false
var skip_talking = false
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

func _input(event):
	if event is InputEventKey and event.pressed and is_talking and not skip_talking:
		skip_talking = true

func update_dialog():
	var option_stats = {
		1: 'cha',
		2: 'wit',
		3: 'hat',
	}
	for i in range(1, 4):
		var option = get_node('OptionContainer/Option'+str(i))
		var stat = option_stats[i]
		option.visible = battle.player.choices.has(stat)
		if option.visible:
			var dialogue = battle.player.choices[stat].dialogue
			option.text = '['+stat.to_upper()+'] '+dialogue.short
			option.pressed.connect(_on_option_pressed.bind(stat, dialogue.long))

func update_hud(round_state):
	for state in round_state:
		var is_player = state.name == player.name
		if state.choice == 'hat' and state.has('dmg'):
			var hpbar = $HealthBarPlayer if is_player else $HealthBarOpponenet
			var floater = $HealthBarPlayer/FloatTextSpawner if is_player else $HealthBarOpponenet/FloatTextSpawner
			hpbar.value = clamp(hpbar.value - state['dmg'], 0, INF)
			floater.float_text("-"+str(state['dmg']), Color.RED)
		print('state: ', state)

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
	
	await get_tree().create_timer(1).timeout
	show_speech_bubbles()
	for option in $OptionContainer.get_children():
		if option.visible:
			option.grab_focus()
			await get_tree().create_timer(.25).timeout
			option.release_focus()

func _on_option_pressed(stat, long):
	for option in $OptionContainer.get_children():
		option.visible = false
	battle.choose(stat)
	
	# get opponent dialogue
	var opponent_choice = battle.opponent.choice
	var opponent_choice_data = battle.opponent.choices[opponent_choice]
	var opponent_long = opponent_choice_data.dialogue.long
	
	# hide dialogue bubbles
	$PlayerDialogBubble.hide()
	$OpponentDialogBubble.hide()
	
	# render player text
	is_talking = true
	$SpriteHolder.flip_h()
	$SpriteHolder.show()
	$SpriteHolder.set_sprites({
		'sprite_state': player.get_node("SpriteHolder").sprite_state,
		'pallete_sprite_state': player.get_node("SpriteHolder").pallete_sprite_state
	})
	$DialogContainer/RichTextLabel.text = "[u]%s[/u][color=7fa6be]: %s[/color] " % [player.player_name, stat.to_upper()]
	for i in long:
		if skip_talking:
			$DialogContainer/RichTextLabel.text = "[u]%s[/u][color=7fa6be]: %s[/color] %s" % [player.player_name, stat.to_upper(), long]
			break
		$DialogContainer/RichTextLabel.text += i
		await get_tree().create_timer(.03).timeout
	if not skip_talking:
		await get_tree().create_timer(1).timeout
	
	# render opponent text
	$SpriteHolder2.show()
	$SpriteHolder2.set_sprites({
		'sprite_state': opponent.get_node("SpriteHolder").sprite_state,
		'pallete_sprite_state': opponent.get_node("SpriteHolder").pallete_sprite_state
	})
	$DialogContainer/RichTextLabel2.text = "[right][u]%s[/u][color=7fa6be]: %s[/color] " % [opponent.npc_name, opponent_choice.to_upper()]
	for i in opponent_long:
		if skip_talking:
			$DialogContainer/RichTextLabel2.text = "[right][u]%s[/u][color=7fa6be]: %s[/color] %s" % [opponent.npc_name, opponent_choice.to_upper(), opponent_long]
			break
		$DialogContainer/RichTextLabel2.text += i
		await get_tree().create_timer(.03).timeout
	if not skip_talking:
		await get_tree().create_timer(1).timeout
	
	
	# show proceed button
	$ProceedButton.visible = true
	skip_talking = false
	is_talking = false
	
	# if opponent played wit
	# $AnimationPlayer.play('opp_shoot')
	# if player played wit
	# $AnimationPlayer.play('player_shoot')

func show_speech_bubbles():
	$PlayerDialogBubble.show()
	$PlayerDialogBubble.play("fill")
	$OpponentDialogBubble.show()
	$OpponentDialogBubble.play("fill")

func _on_proceed_button_pressed():
	$ProceedButton.visible = false
	$DialogContainer/RichTextLabel.text = ''
	$DialogContainer/RichTextLabel2.text = ''
	$SpriteHolder.hide()
	$SpriteHolder2.hide()
	show_speech_bubbles()
	## TODO: move option visibility to after chat bubble animation
	for option in $OptionContainer.get_children():
		option.visible = false
	battle.new_round()
