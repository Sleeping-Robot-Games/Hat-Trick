extends Label

func float_text(value: String, color: Color, travel: Vector2, duration: int, spread: float):
	# Set the text value and color
	text = value
	set("theme_override_colors/font_color", color)
	# For scaling, set the pivot offset to the center
	pivot_offset = size / 2
	var movement: Vector2 = travel.rotated(randf_range(-spread/2, spread/2))
	var tween = get_tree().create_tween().set_parallel(true)
	# Animate the position
	tween.tween_property(self, "position", position + movement, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	# Animate the fade-out
	tween.tween_property(self, "modulate:a", 1.0, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	# Cleanup
	tween.chain().tween_callback(queue_free)
	
