extends Control

var player = null
var opponent = null
var is_talking = false
var skip_talking = false
var opponent_is_big = false

var tool_tip_scene = load("res://scenes/tool_tip.tscn")
var current_tool_tip

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
@onready var stat_tool_tip_data = {
	'def': {
		'header': 'Defense',
		'content': 'This score reduces incoming damage',
		'node': $Def
	},
	'cha': {
		'header': 'Charisma',
		'content': 'This score is how powerful your CHA and HAT buffs are.  \n Increases speed.',
		'node': $Cha
	},
	'wit': {
		'header': 'Wit',
		'content': 'This score is how damaging your insults are to your opponent. \n Increases speed.',
		'node': $Wit
	}
}

func _ready():
	$OptionContainer/Option1.pressed.connect(_on_option_pressed.bind('cha'))
	$OptionContainer/Option2.pressed.connect(_on_option_pressed.bind('wit'))
	$OptionContainer/Option3.pressed.connect(_on_option_pressed.bind('hat'))
	
	$OptionContainer/Option1.mouse_entered.connect(_on_option_one_mouse_entered)
	$OptionContainer/Option1.mouse_exited.connect(_on_tooltip_mouse_exited)
	$OptionContainer/Option3.mouse_entered.connect(_on_option_three_mouse_entered)
	$OptionContainer/Option3.mouse_exited.connect(_on_tooltip_mouse_exited)
	
	$Def.mouse_entered.connect(_on_stat_mouse_entered.bind('def'))
	$Cha.mouse_entered.connect(_on_stat_mouse_entered.bind('cha'))
	$Wit.mouse_entered.connect(_on_stat_mouse_entered.bind('wit'))

	$Def.mouse_exited.connect(_on_tooltip_mouse_exited)
	$Cha.mouse_exited.connect(_on_tooltip_mouse_exited)
	$Wit.mouse_exited.connect(_on_tooltip_mouse_exited)
	
	for hat_stack in $PlayerHatStack.get_children():
		hat_stack.mouse_entered.connect(_on_hat_mouse_entered.bind(hat_stack))
		hat_stack.mouse_exited.connect(_on_tooltip_mouse_exited)
	

func _input(event):
	if event is InputEventKey and event.pressed and is_talking and not skip_talking:
		skip_talking = true
		
func _on_stat_mouse_entered(stat):
	var new_tool_tip = tool_tip_scene.instantiate()
	new_tool_tip.get_node('Header').text = stat_tool_tip_data[stat].header
	new_tool_tip.get_node('Content').text = stat_tool_tip_data[stat].content
	add_child(new_tool_tip)
	new_tool_tip.global_position.y = stat_tool_tip_data[stat].node.global_position.y - 100
	new_tool_tip.global_position.x = stat_tool_tip_data[stat].node.global_position.x + 100
	current_tool_tip = new_tool_tip
	
func _on_option_one_mouse_entered():
	var cha_explanation = bc.CHA_POWERS_EXPLAINATION[bc.HAT_CHA_POWERS[player.hat_stack[0]]]
	var new_tool_tip = tool_tip_scene.instantiate()
	new_tool_tip.get_node('Header').text = bc.HAT_CHA_POWERS[player.hat_stack[0]]
	new_tool_tip.get_node('Content').text = cha_explanation
	add_child(new_tool_tip)
	new_tool_tip.global_position.y = $OptionContainer/Option1.global_position.y - 150  #=  $HatDetail/ChaLabel.global_position.y - 150
	new_tool_tip.global_position.x = $OptionContainer/Option1.global_position.x #= $HatDetail/ChaLabel.global_position.x + 50
	current_tool_tip = new_tool_tip

func _on_option_three_mouse_entered():
	var hat_explanation = bc.HAT_ABILITY_EXPLAINATION[player.hat_stack[0]] 
	var new_tool_tip = tool_tip_scene.instantiate()
	new_tool_tip.get_node('Header').text = player.hat_stack[0].to_upper()
	new_tool_tip.get_node('Content').text = "HAT POWER: " + hat_explanation
	add_child(new_tool_tip)
	new_tool_tip.global_position.y = $OptionContainer/Option1.global_position.y - 150  #=  $HatDetail/ChaLabel.global_position.y - 150
	new_tool_tip.global_position.x = $OptionContainer/Option1.global_position.x #= $HatDetail/ChaLabel.global_position.x + 50
	current_tool_tip = new_tool_tip
	
func _on_tooltip_mouse_exited():
	if current_tool_tip:
		current_tool_tip.queue_free()
	current_tool_tip = null

func _on_hat_mouse_entered(hat_stack):
	var hat = hat_stack.hat_name
	var power = 'Power: ' + bc.HAT_ABILITY_EXPLAINATION[hat] 
	var cha_option = 'CHA option: ' + bc.HAT_CHA_POWERS[hat].to_lower().capitalize()
	var new_tool_tip = tool_tip_scene.instantiate()
	new_tool_tip.get_node('Header').text = hat.capitalize()
	new_tool_tip.get_node('Content').text = power + '\n\n' + cha_option 
	add_child(new_tool_tip)
	new_tool_tip.global_position.y = hat_stack.position.y #=  $HatDetail/ChaLabel.global_position.y - 150
	new_tool_tip.global_position.x = hat_stack.position.x + 100 #= $HatDetail/ChaLabel.global_position.x + 50
	current_tool_tip = new_tool_tip

func update_dialogue():
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
			option.text = '[%s] ' % get_stat_type(stat).to_upper() + label

func get_stat_type(stat):
	var stat_type = ""
	if stat == 'cha':
		stat_type = bc.HAT_CHA_POWERS[player.hat_stack[0]]
	if stat == 'wit':
		stat_type = 'DAMAGE'
	if stat == 'hat':
		stat_type = 'HAT POWER'
	return stat_type

func get_stat_color(stat):
	var stat_color = ""
	if stat == 'cha':
		stat_color = 'ad8ec2'
	if stat == 'wit':
		stat_color = '7fa6be'
	if stat == 'hat':
		stat_color = 'caba71'
	return stat_color

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
				get_node(capitalized+'/Equals').hide()
				if hud_stats[stat]['cha_buff'] != 0:
					var signed_buff = '+'+str(hud_stats[stat]['cha_buff']) if hud_stats[stat]['cha_buff'] > 0 else str(hud_stats[stat]['cha_buff'])
					get_node(capitalized+'/ChaBuff').text = signed_buff
					get_node(capitalized+'/ChaBuff').show()
					get_node(capitalized+'/Equals').show()
				if hud_stats[stat]['hat_buff'] != 0:
					var signed_buff = '+'+str(hud_stats[stat]['hat_buff']) if hud_stats[stat]['hat_buff'] > 0 else str(hud_stats[stat]['hat_buff'])
					get_node(capitalized+'/HatBuff').text = signed_buff
					get_node(capitalized+'/HatBuff').show()
					get_node(capitalized+'/Equals').show()
		# lower hp bar and show floating dmg text
		if state.has('dmg'):
			var hpbar = $HealthBarOpponent if is_player else $HealthBarPlayer
			var floater = $HealthBarOpponent/FloatTextSpawner if is_player else $HealthBarPlayer/FloatTextSpawner
			hpbar.value = clamp(hpbar.value - state['dmg'], 0, INF)
			floater.float_text("-"+str(state['dmg']), Color.RED)
		if state.has('heal'):
			var hpbar = $HealthBarPlayer if is_player else $HealthBarOpponent
			var floater = $HealthBarPlayer/FloatTextSpawner if is_player else $HealthBarOpponent/FloatTextSpawner
			hpbar.value = clamp(state['stam'], 0, INF)
			floater.float_text("-"+str(state['heal']), Color.GREEN)

func new_round():
	pass

func hide_buff_values():
	$Def/Equals.hide()
	$Def/ChaBuff.hide()
	$Def/HatBuff.hide()
	$Cha/Equals.hide()
	$Cha/ChaBuff.hide()
	$Cha/HatBuff.hide()
	$Wit/Equals.hide()
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
	_on_tooltip_mouse_exited()
	
	# get dialogue
	var long = battle.player.choices[stat].dialogue.long
	var opponent_choice = battle.opponent.choice
	var opponent_choice_data = battle.opponent.choices[opponent_choice]
	var opponent_long = opponent_choice_data.dialogue.long
	
	# show speech bubbles
	show_speech_bubbles()
	
	if stat == 'wit':
		## fling speech bubble at enemey
		print(opponent.global_position)
		print($OpponentSpeechBubble)
	
	if stat == 'hat':
		g.play_random_hat_sfx(self, player.hat_stack[player.hat_stack.size()-1])
	# render player text
	is_talking = true
	$SpriteHolder.flip_h()
	$SpriteHolder.show()
	$SpriteHolder.set_sprites({
		'sprite_state': player.get_node("SpriteHolder").sprite_state,
		'pallete_sprite_state': player.get_node("SpriteHolder").pallete_sprite_state
	})
	$DialogueContainer/RichTextLabel.text = "[u]%s[/u]: [color=%s]%s[/color] " % [player.player_name, get_stat_color(stat), get_stat_type(stat)]
	for i in long:
		if skip_talking:
			$DialogueContainer/RichTextLabel.text = "[u]%s[/u]: [color=%s]%s[/color] %s" % [player.player_name, get_stat_color(stat), get_stat_type(stat), long]
			break
		$DialogueContainer/RichTextLabel.text += i
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
	
	if opponent_choice == 'hat':
		g.play_random_hat_sfx(self, opponent.hat_stack[0])
	$DialogueContainer/RichTextLabel2.text = "[right][u]%s[/u]: [color=%s]%s[/color] " % [opponent.npc_name, get_stat_color(opponent_choice), get_stat_type(opponent_choice)]
	for i in opponent_long:
		if skip_talking:
			$DialogueContainer/RichTextLabel2.text = "[right][u]%s[/u]: [color=%s]%s[/color] %s" % [opponent.npc_name, get_stat_color(opponent_choice), get_stat_type(opponent_choice), opponent_long]
			break
		$DialogueContainer/RichTextLabel2.text += i
		await get_tree().create_timer(.03).timeout
	if not skip_talking:
		await get_tree().create_timer(1).timeout
	
	
	# show proceed button
	$ProceedButton.visible = true
	skip_talking = false
	is_talking = false
	
	# play speech bubbles animation

	
	# if opponent played wit
	# $AnimationPlayer.play('opp_shoot')
	# if player played wit
	# $AnimationPlayer.play('player_shoot')

func show_speech_bubbles():
	$PlayerSpeechBubble.show()
	$PlayerSpeechBubble.play("fill")
	$OpponentSpeechBubble.show()
	$OpponentSpeechBubble.play("fill")

func play_speech_bubbles_animation():
	## TODO: Play animation of speech bubbles smacking into opponents are raises stats
	$PlayerSpeechBubble.hide()
	$OpponentSpeechBubble.hide()

func _on_proceed_button_pressed():
	$ProceedButton.visible = false
	$DialogueContainer/RichTextLabel.text = ''
	$DialogueContainer/RichTextLabel2.text = ''
	$SpriteHolder.hide()
	$SpriteHolder2.hide()
	play_speech_bubbles_animation()
	cycle_hats(true)
	cycle_hats(false)
	## TODO: move option visibility to after speech bubble animation
	for option in $OptionContainer.get_children():
		option.visible = false
	battle.new_round()
