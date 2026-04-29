extends Node2D

func setup(start_pos: Vector2, end_pos: Vector2):
	position = start_pos
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", end_pos, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	tween.finished.connect(queue_free)

func _draw():
	var c = Color.YELLOW
	# Note head
	draw_circle(Vector2(0, 0), 6.0, c)
	# Stem going up from right side of head
	draw_line(Vector2(5.5, 0.0), Vector2(5.5, -20.0), c, 2.0)
	# Flag (eighth-note hook)
	draw_line(Vector2(5.5, -20.0), Vector2(13.0, -12.0), c, 2.0)
	draw_line(Vector2(13.0, -12.0), Vector2(10.0, -6.0), c, 2.0)
