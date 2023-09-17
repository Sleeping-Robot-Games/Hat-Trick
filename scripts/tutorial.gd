extends Node2D

@onready var right_light_pulse = $Outside/right_sign_light/AnimationPlayer
@onready var left_light_pulse = $Outside/left_sign_light/AnimationPlayer
@onready var scrolling_hats_sign = $Outside/hats_scrolling_sign
@onready var top_hat_sign = $Outside/top_hat_sign

@onready var hud = $BattleHUD
@onready var next_button = $InteractButton

var battle_pos_offset = 80
var battle_pos_y = 150

var step = 0
var ready_for_next_step = false
var steps = [
	'[center]This is a "Hat Dispute", where you battle an opponent for the right of their [color=%s]%s[/color]' % [g.get_stat_color('hat'), 'HAT'],
	"[center]You have 3 available dialog options",
	"[color=%s]%s[/color] based dialog option for buffing yourself" % [g.get_stat_color('cha'), 'Charisma'],
	"[color=%s]%s[/color] based insult dialog option that damages the opponent" % [g.get_stat_color('wit'), 'Wit'],
	"[color=%s]%s[/color] power of the [color=%s]%s[/color] you're currently wearing" % [ g.get_stat_color('hat'), 'Hat', g.get_stat_color('hat'), 'Active Hat'],
	"[center]Choose your [color=%s]%s[/color] insult first to start, it's always available" % [g.get_stat_color('wit'), 'Damage'],
	"[center]The damage you do is partly based on your [color=%s]%s[/color] score minus the opponents [color=%s]%s[/color]" % [g.get_stat_color('wit'), 'Wit', g.get_stat_color('def'), 'Defense'],
	"[center]If your [color=%s]%s[/color] score plus your [color=%s]%s[/color] score is larger than your opponent you will go first in the round" % [g.get_stat_color('wit'), 'Wit', g.get_stat_color('cha'), 'Charisma'],
	"[center]Each [color=%s]%s[/color] carries it's own [color=%s]%s[/color] dialog option that is made available to you, if you switch [color=%s]%s[/color] your [color=%s]%s[/color] option may be different" % [g.get_stat_color('hat'), 'Hat', g.get_stat_color('cha'), 'Charisma', g.get_stat_color('hat'), 'Hats', g.get_stat_color('cha'), 'Charisma'],
	"[center]Now choose your [color=%s]%s[/color] ability, this will buff you until the end of the next round, during which the option will be on cooldown." % [g.get_stat_color('cha'), 'Charisma'],
	"[center][color=%s]%s[/color] are usually the most powerful option, but each hat power has a cooldown of 3 rounds"  % [g.get_stat_color('hat'), 'Hat Powers'],
	"[center]If you have multiple [color=%s]%s[/color] using your [color=%s]%s[/color] will force your current [color=%s]%s[/color] to the top of your [color=%s]%s[/color] to be cycled."  % [g.get_stat_color('hat'), 'Hats', g.get_stat_color('hat'), 'Hat Power', g.get_stat_color('hat'), 'Active Hat', g.get_stat_color('hat'), 'Hat Stack'],
	"[center]The more [color=%s]%s[/color] you have the more health you get!"  % [g.get_stat_color('hat'), 'Hats'],
	"[center]Finish this battle to enter TOP HAT"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	$TutorialLabels/Step.text = ""
	$InteractButton.play()
	
	right_light_pulse.play("Light Pulse")
	left_light_pulse.play("Light Pulse")
	scrolling_hats_sign.play("Hats Scrolling Sign")
	top_hat_sign.play("Top Hat Sign")

func _input(event):
	if ready_for_next_step and Input.is_action_just_pressed("interact"):
		next_button.hide()
		ready_for_next_step = false
		if step >= 0 and step <= 4:
			next_step()
		if step == 5:
			set_disable_option(hud.get_node('OptionContainer/Option1'))
			set_disable_option(hud.get_node('OptionContainer/Option2'), false)
			set_disable_option(hud.get_node('OptionContainer/Option3'))
			next_button.hide()
			ready_for_next_step = false
		if step >= 6 and step <= 8:
			next_step()
		if step == 9:
			set_disable_option(hud.get_node('OptionContainer/Option1'), false)
			set_disable_option(hud.get_node('OptionContainer/Option2'))
			set_disable_option(hud.get_node('OptionContainer/Option3'))
			ready_for_next_step = false
			next_button.hide()
		if step >= 10 and step <= 13:
			next_step()


func next_step():
	step += 1
	ready_for_next_step = true
	next_button.show()
	if step == 14:
		$TutorialLabels/Step.text = ""
		set_disable_option(hud.get_node('OptionContainer/Option1'), false)
		set_disable_option(hud.get_node('OptionContainer/Option2'), false)
		set_disable_option(hud.get_node('OptionContainer/Option3'), false)
		next_button.hide()
		return
	$TutorialLabels/Step.text = steps[step]

func proceed_round():
	if step == 5:
		set_disable_all_options()
		next_step()
	if step == 9:
		set_disable_all_options()
		next_step()

func option_selected():
	if step == 5:
		$TutorialLabels/Step.text = ""
		next_button.hide()
	if step == 9:
		$TutorialLabels/Step.text = ""
		next_button.hide()
	
func set_disable_option(option, disable = true):
	option.disabled = disable
	
func set_disable_all_options(disable = true):
	for option in hud.get_node('OptionContainer').get_children():
		set_disable_option(option, disable)

func hat_fight(player, opponent):
	g.stop_bgm('background')
	g.play_bgm('Battle_Music_Main', -5)
	g.unfocus_current()
	set_disable_all_options()
	## TODO: REMEMBER TO TURN THEM BACK ON AFTER THE FIGHT
	$Outside/left_sign_light.hide()
	$Outside/right_sign_light.hide()
	var player_pos = get_left_battle_pos()
	var opponent_pos = get_right_battle_pos()
	player.start_fighting(player_pos)
	opponent.start_fighting(opponent_pos)

	$BattleHUD.opponent_is_big = true
	$BattleHUD.start_battle(player, opponent)
	
	await get_tree().create_timer(3).timeout
	
	$TutorialLabels/Step.text = steps[step]
	await get_tree().create_timer(1).timeout
	next_button.show()
	ready_for_next_step = true

func get_left_battle_pos():
	var half_viewport = get_viewport_rect().size.x / 2
	var screen_center = half_viewport
	var left_pos =( screen_center - half_viewport + battle_pos_offset)/3
	return Vector2(left_pos, battle_pos_y)

func get_right_battle_pos() -> Vector2:
	var half_viewport = get_viewport_rect().size.x / 2
	var screen_center = half_viewport
	var right_pos = (screen_center + half_viewport - battle_pos_offset)/3
	return Vector2(right_pos, battle_pos_y)

func battle_over():
	$Outside/left_sign_light.show()
	$Outside/right_sign_light.show()
	$BigGuy.get_node('SpeechBubble').set_text("Go ahead, you're ready")
	g.stop_bgm('Battle_Music_Main')
	g.play_bgm('background')

func _on_start_button_up():
	hat_fight($Player, $BigGuy)

func _on_skip_button_up():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
