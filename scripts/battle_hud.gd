extends Control

var player = null
var opponent = null
var is_talking = false
var skip_talking = false
var opponent_is_big = false

var tool_tip_scene = load("res://scenes/tool_tip.tscn")
var current_tool_tip
var battle_over = null
var can_exit_battle = false
var ready_to_proceed = false
var current_round_state = {}

var round_order = {
	'first': 'player',
	'second': 'opponent'
}

@onready var game = get_parent()
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
	if ready_to_proceed and Input.is_action_just_pressed("interact"):
		ready_to_proceed = false
		proceed()
	if event is InputEventKey and event.pressed and is_talking and not skip_talking:
		skip_talking = true
	if can_exit_battle and Input.is_action_just_pressed("interact"):
		end_battle()
		can_exit_battle = false
		battle_over = null

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

func render_options():
	var option_stats = {
		1: 'cha',
		2: 'wit',
		3: 'hat_'+battle.player['active_hat'],
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
	if 'hat' in stat:
		stat_type = 'HAT POWER'
	return stat_type

func signed_buff(num: int) -> String:
	if num >= 0:
		return '+'+str(num)
	else:
		return str(num)

func update_hud(round_state):
	current_round_state = round_state.duplicate(true)


func resolve_battle(state):
	hide_buff_values()
	battle_over = null
	update_hats(state)
	var is_player = state.is_player
	if is_player:
		var hud_stats = {}
		for stat in ['def', 'cha', 'wit']:
			hud_stats[stat] = {
				'total': bc.stat_calc(state, stat, true, true, true),
				'base': bc.stat_calc(state, stat, true, false, false),
				'cha_buff': bc.stat_calc(state, stat, false, true, false),
				'hat_buff': bc.stat_calc(state, stat, false, false, true),
			}
		for stat in hud_stats.keys():
			var capitalized = stat.capitalize()
			get_node(capitalized+'/Value').text = str(hud_stats[stat]['total'])
			if hud_stats[stat]['cha_buff'] != 0:
				get_node(capitalized+'/HBox/ChaBuff').text = signed_buff(hud_stats[stat]['cha_buff'])
				get_node(capitalized+'/HBox/ChaBuff').show()
				get_node(capitalized+'/Equals').show()
			if hud_stats[stat]['hat_buff'] != 0:
				get_node(capitalized+'/HBox/HatBuff').text = signed_buff(hud_stats[stat]['hat_buff'])
				get_node(capitalized+'/HBox/HatBuff').show()
				get_node(capitalized+'/Equals').show()
	# ensure hp bars are updated
	var hpbar = $HealthBarPlayer if is_player else $HealthBarOpponent
	var hptext = $HealthBarPlayer/Value if is_player else $HealthBarOpponent/Value
	hptext.text = str(state['cur_hp'])+'/'+str(state['max_hp'])
	hpbar.value = clamp(state['cur_hp'], 0, state['max_hp'])
	# if dmg was done show floater dmg text over opponent's hp bar
	if state.dmg > 0:
		var opp_floater = $HealthBarOpponent/FloatTextSpawner if is_player else $HealthBarPlayer/FloatTextSpawner
		opp_floater.float_text("-"+str(state['dmg']), Color.RED)
	if state.heal > 0:
		var floater = $HealthBarPlayer/FloatTextSpawner if is_player else $HealthBarOpponent/FloatTextSpawner
		floater.float_text("+"+str(state['heal']), Color.GREEN)
		
	if state.is_winner:
		if is_player:
			battle_over = 'victory'
		else:
			battle_over = 'defeat'
	current_round_state = {}

func hide_buff_values():
	$Def/Equals.hide()
	$Def/HBox/ChaBuff.hide()
	$Def/HBox/HatBuff.hide()
	$Cha/Equals.hide()
	$Cha/HBox/ChaBuff.hide()
	$Cha/HBox/HatBuff.hide()
	$Wit/Equals.hide()
	$Wit/HBox/ChaBuff.hide()
	$Wit/HBox/HatBuff.hide()

func start_battle(pl, op):
	$LargeInteractButton.hide()
	$Victory.hide()
	$Defeat.hide()
	can_exit_battle = false
	battle_over = null
	visible = true
	$AnimationPlayer.play('start')
	player = pl
	opponent = op
	player.get_node('HatHolder').z_as_relative = false
	opponent.get_node('HatHolder').z_as_relative = false
	hide_buff_values()
	# ensure correct initial stat values in HUD
	$Def/Value.text = str(player.stats['def'])
	$Cha/Value.text = str(player.stats['cha'])
	$Wit/Value.text = str(player.stats['wit'])
	$HealthBarPlayer/Value.text = str(player.stats['stam'])+'/'+str(player.stats['stam'])
	$HealthBarOpponent/Value.text = str(opponent.stats['stam'])+'/'+str(opponent.stats['stam'])
	# kick off battle script and draw hats
	$Battle.start()
	draw_hats()
	# cycle through button focus so spacebar guy doesn't get confused B)
	await get_tree().create_timer(1).timeout
	for option in $OptionContainer.get_children():
		if option.visible:
			option.grab_focus()
			await get_tree().create_timer(.25).timeout
			option.release_focus()

func end_battle():
	player.get_node('HatHolder').z_as_relative = true
	opponent.get_node('HatHolder').z_as_relative = false
	player.stop_fighting()
	opponent.stop_fighting(battle_over == 'defeat')
	var cam = get_parent().get_node('Camera')
	cam.follow_player = true
	hide()
	game.battle_over()

# for initial battle hat population w/ delays between hat icons appearing etc
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

# for cycling hats midbattle
func update_hats(state):
	var hcount = state.hat_stack.size()
	var node_name = 'player' if state.is_player else 'opponent'
	var node = player if state.is_player else opponent
	for i in g.max_hats:
		if i + 1 <= hcount:
			hat_nodes[node_name][i].change_hat(state.hat_stack[i], false)
			if i == 0:
				var hat_path = 'res://assets/sprites/hat/'+state.hat_stack[0]+'.png'
				node.get_node('SpriteHolder').set_sprite_texture('hat', hat_path)
	# ensure actual player node hat stack is also updated for post-battle
	if state.is_player:
		node.refresh_stack(state.hat_stack.duplicate(true))

func _on_option_pressed(stat):
	if game.name == 'Tutorial':
		game.option_selected()
		
	var selected = 'hat_'+battle.player['active_hat'] if stat == 'hat' else stat
	for option in $OptionContainer.get_children():
		option.visible = false
	battle.choose(selected)
	_on_tooltip_mouse_exited()
	
	# get dialogue
	var long = battle.player.choices[selected].dialogue.long
	var opponent_choice = battle.opponent.choice
	var opponent_choice_data = battle.opponent.choices[opponent_choice]
	var opponent_long = opponent_choice_data.dialogue.long
	
	# show speech bubbles
	show_speech_bubbles()
	
	if stat == 'wit':
		## fling speech bubble at enemey
		#print(opponent.global_position)
		#print($OpponentSpeechBubble)
		pass
	
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
	$DialogueContainer/RichTextLabel.text = "[u]%s[/u]: [color=%s]%s[/color] " % [player.player_name, g.get_stat_color(stat), get_stat_type(stat)]
	for i in long:
		if skip_talking:
			$DialogueContainer/RichTextLabel.text = "[u]%s[/u]: [color=%s]%s[/color] %s" % [player.player_name, g.get_stat_color(stat), get_stat_type(stat), long]
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
	
	if 'hat' in opponent_choice:
		g.play_random_hat_sfx(self, opponent.hat_stack[0])
	$DialogueContainer/RichTextLabel2.text = "[right][u]%s[/u]: [color=%s]%s[/color] " % [opponent.npc_name, g.get_stat_color(opponent_choice), get_stat_type(opponent_choice)]
	for i in opponent_long:
		if skip_talking and not game.name == 'Tutorial':
			$DialogueContainer/RichTextLabel2.text = "[right][u]%s[/u]: [color=%s]%s[/color] %s" % [opponent.npc_name, g.get_stat_color(opponent_choice), get_stat_type(opponent_choice), opponent_long]
			break
		$DialogueContainer/RichTextLabel2.text += i
		await get_tree().create_timer(.03).timeout
	if not skip_talking:
		await get_tree().create_timer(1).timeout
	
	
	# show proceed button
	# $ProceedButton.visible = true
	$InteractButton.show()
	ready_to_proceed = true
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
	$PlayerSpeechBubble.modulate = Color(1,1,1,1)
	$OpponentSpeechBubble.show()
	$OpponentSpeechBubble.play("fill")
	$OpponentSpeechBubble.modulate = Color(1,1,1,1)

func launch_bubble(bubble, round_state, opp_round_state, target, launch_dur, shake_dur, shake_mag):
	var dealing_dmg = round_state.dmg > 0
	var target_pos
	if dealing_dmg:
		target_pos = Vector2(target.position.x, target.position.y+50)
	else:
		target_pos = Vector2(bubble.position.x, bubble.position.y-100)
	
	# bubble.show()
	bubble.z_index = 2
	var starting_pos = bubble.position
	if dealing_dmg:
		## shake
		bubble.shake(shake_dur, shake_mag)
		await get_tree().create_timer(shake_dur).timeout
		
		## launch
		var tween = get_tree().create_tween()
		tween.tween_property(bubble, 'position', target_pos, launch_dur)
		
		await get_tree().create_timer(launch_dur).timeout
		game.get_node('Camera').shake_camera(.5, 4)
		
		target.modulate = Color(1, 0, 0, 1)
		await get_tree().create_timer(.1).timeout
		target.modulate = Color(1, 1, 1, 1)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(bubble, 'position', target_pos, launch_dur)
		tween.tween_property(bubble, 'modulate', Color(1,1,1,0), launch_dur)
		await get_tree().create_timer(launch_dur*2).timeout
		
	
	resolve_battle(opp_round_state)
	
	bubble.modulate = Color(1,1,1,1)
	bubble.hide()
	bubble.position = starting_pos
	bubble.z_index = 0

func play_speech_bubbles_animation(launch_dur, shake_dur, shake_mag):
	## TODO: Play animation of speech bubbles smacking into opponents are raises stats
#	$PlayerSpeechBubble.hide()
#	$OpponentSpeechBubble.hide()
	
	var player_round_state
	var opp_round_state
	for state in current_round_state:
		if state.is_player:
			player_round_state = state
		else:
			opp_round_state = state
			
	if round_order.first == 'player':
		launch_bubble($PlayerSpeechBubble, player_round_state, opp_round_state, opponent, launch_dur, shake_dur, shake_mag)
		await get_tree().create_timer(launch_dur + shake_dur).timeout
		launch_bubble($OpponentSpeechBubble, opp_round_state, player_round_state, player, launch_dur, shake_dur, shake_mag)
	else:
		launch_bubble($OpponentSpeechBubble, opp_round_state, player_round_state, player, launch_dur, shake_dur, shake_mag)
		await get_tree().create_timer(launch_dur + shake_dur).timeout
		launch_bubble($PlayerSpeechBubble, player_round_state, opp_round_state, opponent, launch_dur, shake_dur, shake_mag)
	
	

func proceed():
	$InteractButton.hide()
	$DialogueContainer/RichTextLabel.text = ''
	$DialogueContainer/RichTextLabel2.text = ''
	$SpriteHolder.hide()
	$SpriteHolder2.hide()
	var launch_dur = .3
	var shake_dur = .5
	var shake_mag = 1
	play_speech_bubbles_animation(launch_dur, shake_dur, shake_mag)
	await get_tree().create_timer((launch_dur + shake_dur) *2).timeout
	if opponent_is_big:
		$BigGuyHolder.hide()
	## TODO: move option visibility to after speech bubble animation
	for option in $OptionContainer.get_children():
		option.visible = false
	if battle_over:
		if battle_over == 'victory':
			$Victory.show()
		elif battle_over == 'defeat':
			$Defeat.show()
		$LargeInteractButton.show()
		$LargeInteractButton.play()
		await get_tree().create_timer(1.5).timeout
		can_exit_battle = true
		return
	battle.new_round()
	
	if game.name == 'Tutorial':
		game.proceed_round()

func _on_proceed_button_pressed():
	proceed()
