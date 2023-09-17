extends Control

func set_text(text, duration=2):
	$MarginContainer/MarginContainer/Label.text = text
	show()
	await get_tree().create_timer(duration).timeout
	hide()

