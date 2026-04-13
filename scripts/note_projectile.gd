extends Node2D

func setup(start_pos: Vector2, end_pos: Vector2):
	position = start_pos
	var label = Label.new()
	label.text = "♫"
	label.add_theme_font_size_override("font_size", 32)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", end_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	tween.finished.connect(queue_free)
