extends Control

var player = null
var opponent = null
var is_talking = false
var skip_talking = false
var opponent_is_big = false

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
	$OptionContainer/Option1.pressed.connect(_on_option_pressed.bind('cha'))
	$OptionContainer/Option2.pressed.connect(_on_option_pressed.bind('wit'))
	$OptionContainer/Option3.pressed.connect(_on_option_pressed.bind('hat'))

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
			var label = battle.player.choices[stat].dialogue.short
			option.text = '['+stat.to_upper()+'] '+label

func update_hud(round_state):
	hide_buff_values()
	for state in round_state:
		var is_player = state.node.is_player
		print('-----------------------------')
		print('state: ', state)
		if is_player:
			print('player: ', player, ' ', player.name, ' ', player.stats)
		else:
			print('opponent: ', opponent, ' ', opponent.name, ' ', opponent.stats)
		# update player's stats
		if is_player:
			print('base_stats: ', player.stats)
			var hud_stats = {
				'def': {
					'base': player.stats['def'],
					'cha_buff': state.cha_buffs.def if state.has('cha_buffs') and state.cha_buffs.has('def') else 0,
					'hat_buff': state.hat_buffs.def if state.has('hat_buffs') and state.hat_buffs.has('def') else 0,
				},
				'cha': {
					'base': player.stats['cha'],
					'cha_buff': state.cha_buffs.cha if state.has('cha_buffs') and state.cha_buffs.has('cha') else 0,
					'hat_buff': state.hat_buffs.cha if state.has('hat_buffs') and state.hat_buffs.has('cha') else 0,
				},
				'wit': {
					'base': player.stats['wit'],
					'cha_buff': state.cha_buffs.wit if state.has('cha_buffs') and state.cha_buffs.has('wit') else 0,
					'hat_buff': state.hat_buffs.wit if state.has('hat_buffs') and state.hat_buffs.has('wit') else 0,
				}
			}
			for stat in hud_stats.keys():
				var capitalized = stat.capitalize()
				get_node(capitalized+'/Value').text = str(clamp(hud_stats[stat]['base'] + hud_stats[stat]['cha_buff'] + hud_stats[stat]['hat_buff'],0,INF))
				get_node(capitalized+'/Base').text = '= '+str(hud_stats[stat]['base'])
				if hud_stats[stat]['cha_buff'] != 0:
					var signed_buff = '+'+str(hud_stats[stat]['cha_buff']) if hud_stats[stat]['cha_buff'] > 0 else str(hud_stats[stat]['cha_buff'])
					get_node(capitalized+'/ChaBuff').text = signed_buff
					get_node(capitalized+'/ChaBuff').show()
					get_node(capitalized+'/Base').show()
				if hud_stats[stat]['hat_buff'] != 0:
					var signed_buff = '+'+str(hud_stats[stat]['hat_buff']) if hud_stats[stat]['hat_buff'] > 0 else str(hud_stats[stat]['hat_buff'])
					get_node(capitalized+'/HatBuff').text = signed_buff
					get_node(capitalized+'/HatBuff').show()
					get_node(capitalized+'/Base').show()
		# lower hp bar and show floating dmg text
		if state.choice == 'hat':
			if state.has('dmg'):
				var hpbar = $HealthBarPlayer if is_player else $HealthBarOpponenet
				var floater = $HealthBarPlayer/FloatTextSpawner if is_player else $HealthBarOpponenet/FloatTextSpawner
				hpbar.value = clamp(hpbar.value - state['dmg'], 0, INF)
				floater.float_text("-"+str(state['dmg']), Color.RED)

func new_round():
	pass

func hide_buff_values():
	$Def/Base.hide()
	$Def/ChaBuff.hide()
	$Def/HatBuff.hide()
	$Cha/Base.hide()
	$Cha/ChaBuff.hide()
	$Cha/HatBuff.hide()
	$Wit/Base.hide()
	$Wit/ChaBuff.hide()
	$Wit/HatBuff.hide()

func start_battle(pl, op):
	visible = true
	$AnimationPlayer.play('start')
	player = pl
	opponent = op
	player.get_node('HatHolder').z_as_relative = false # TODO: reset after battle ends
	hide_buff_values()
	$Def/Value.text = str(player.stats['def'])
	$Cha/Value.text = str(player.stats['cha'])
	$Wit/Value.text = str(player.stats['wit'])
	$Battle.start()
	draw_hats()
	# cycle through button focus so spacebar guy doesn't get confused B)
	await get_tree().create_timer(1).timeout
	for option in $OptionContainer.get_children():
		if option.visible:
			option.grab_focus()
			await get_tree().create_timer(.25).timeout
			option.release_focus()

func cycle_hats(is_player):
	var hcount = player.hat_stack.size() if is_player else opponent.hat_stack.size()
	var node_name = 'player' if is_player else 'opponent'
	var node = player if is_player else opponent
	for i in g.max_hats:
		if i + 1 <= hcount:
			hat_nodes[node_name][i].change_hat(node.hat_stack[i], false)
			if i == 0:
				var hat_path = 'res://assets/sprites/hat/'+node.hat_stack[0]+'.png'
				node.get_node('SpriteHolder').set_sprite_texture('hat', hat_path)

func draw_hats(delay=0.3, play_sfx=true):
	var player_hcount = player.hat_stack.size()
	var opponent_hcount = opponent.hat_stack.size()
	for i in g.max_hats:
		hat_nodes['player'][i].no_hat()
		hat_nodes['opponent'][i].no_hat()
	for i in g.max_hats:
		if i + 1 <= player_hcount:
			await get_tree().create_timer(delay).timeout
			hat_nodes['player'][i].change_hat(player.hat_stack[i], play_sfx)
		if i + 1 <= opponent_hcount:
			await get_tree().create_timer(delay).timeout
			hat_nodes['opponent'][i].change_hat(opponent.hat_stack[i], play_sfx)

func _on_option_pressed(stat):
	for option in $OptionContainer.get_children():
		option.visible = false
	battle.choose(stat)
	
	# get dialogue
	var long = battle.player.choices[stat].dialogue.long
	var opponent_choice = battle.opponent.choice
	var opponent_choice_data = battle.opponent.choices[opponent_choice]
	var opponent_long = opponent_choice_data.dialogue.long
	
	# show dialogue bubbles
	show_speech_bubbles()
	
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
	
	if opponent_is_big:
		$BigGuyHolder.show()
	else:
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
	
	# play dialogue bubbles animation

	
	# if opponent played wit
	# $AnimationPlayer.play('opp_shoot')
	# if player played wit
	# $AnimationPlayer.play('player_shoot')

func show_speech_bubbles():
	$PlayerDialogBubble.show()
	$PlayerDialogBubble.play("fill")
	$OpponentDialogBubble.show()
	$OpponentDialogBubble.play("fill")

func play_speech_bubbles_animation():
	## TODO: Play animation of speech bubbles smacking into opponents are raises stats
	$PlayerDialogBubble.hide()
	$OpponentDialogBubble.hide()

func _on_proceed_button_pressed():
	$ProceedButton.visible = false
	$DialogContainer/RichTextLabel.text = ''
	$DialogContainer/RichTextLabel2.text = ''
	$SpriteHolder.hide()
	$SpriteHolder2.hide()
	play_speech_bubbles_animation()
	cycle_hats(true)
	cycle_hats(false)
	## TODO: move option visibility to after chat bubble animation
	for option in $OptionContainer.get_children():
		option.visible = false
	battle.new_round()
