extends Area2D

signal popped(note: int)

var target_note: int = 60
var speed: float = 120.0
var direction: Vector2 = Vector2.DOWN
var is_monster: bool = false
var elapsed_time: float = 0.0
var drift_x: float = 0.0
var level: int = 1

@onready var label = $Label
@onready var panel = $Panel
@onready var string_line = $String
@onready var eyes = $Panel/Eyes
@onready var mouth = $Panel/Mouth

# Monster color cache (computed once in setup)
var _body_col: Color
var _dark_col: Color
var _eye_col: Color

func setup(note: int, start_pos: Vector2, _speed: float, _is_monster: bool = false, _level: int = 1):
	target_note = note
	position = start_pos
	speed = _speed
	is_monster = _is_monster
	level = _level
	label.text = _get_note_name(note)

	if is_monster:
		# Hide the balloon scene nodes — monster is drawn entirely via _draw()
		panel.hide()
		string_line.hide()
		eyes.hide()
		mouth.hide()

		# Body colour: green → dark crimson over 30 levels
		var t = clamp(float(level) / 30.0, 0.0, 1.0)
		_body_col = Color(0.12, 0.55, 0.14).lerp(Color(0.44, 0.04, 0.04), t)
		_dark_col = _body_col.darkened(0.32)
		_eye_col   = Color(1.0, 0.85, 0.0) if level < 12 else Color(1.0, 0.08, 0.08)

		# Note label: large yellow text with heavy black outline for high contrast
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
		label.add_theme_font_size_override("font_size", 30)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constants_override("outline_size", 12)

		# Bigger at higher levels
		if level > 25:
			scale = Vector2(1.28, 1.28)
		elif level > 15:
			scale = Vector2(1.12, 1.12)
	else:
		var balloon_colors = [
			Color(1.0, 1.0, 1.0),   # White
			Color(1.0, 0.88, 0.2),  # Yellow
			Color(0.4, 0.9, 1.0),   # Sky blue
			Color(1.0, 0.5, 0.8),   # Pink
			Color(0.5, 1.0, 0.55),  # Mint green
			Color(0.85, 0.6, 1.0),  # Lavender
			Color(1.0, 0.65, 0.3),  # Orange
			Color(0.4, 1.0, 0.88),  # Teal
			Color(1.0, 0.4, 0.4),   # Coral
		]
		panel.self_modulate = balloon_colors.pick_random()
		string_line.visible = true
		eyes.hide()
		mouth.hide()

func _process(delta):
	elapsed_time += delta
	var current_pos = position
	current_pos += direction * speed * delta

	if is_monster:
		# Slight side-to-side stomp as it walks
		var wsp = 5.5 + float(level) * 0.28
		current_pos.x += sin(elapsed_time * wsp * 0.45) * 2.2

		# Jitter for very high levels
		if level > 20:
			current_pos += Vector2(randf_range(-0.6, 0.6), randf_range(-0.3, 0.3))

		queue_redraw()
	elif direction == Vector2.UP:
		current_pos.x += drift_x * delta

	position = current_pos

	if position.y > 760 or position.y < -120:
		queue_free()

# ── Custom monster drawing ───────────────────────────────────────────────────
func _draw():
	if not is_monster:
		return

	var wsp   = 5.5 + float(level) * 0.28
	var walk  = sin(elapsed_time * wsp)           # -1 … 1  (stride phase)
	var stomp = abs(sin(elapsed_time * wsp))       # 0 … 1  (both feet)
	var by    = -stomp * 3.0                       # body lifts a little each step

	# ── Horns (two curved spikes on top) ────────────────────────────────────
	draw_polygon(
		PackedVector2Array([Vector2(-22, -40 + by), Vector2(-16, -62 + by), Vector2(-8, -40 + by)]),
		PackedColorArray([_dark_col])
	)
	draw_polygon(
		PackedVector2Array([Vector2(8, -40 + by), Vector2(16, -62 + by), Vector2(22, -40 + by)]),
		PackedColorArray([_dark_col])
	)
	# Central spine spike
	draw_polygon(
		PackedVector2Array([Vector2(-7, -40 + by), Vector2(0, -56 + by), Vector2(7, -40 + by)]),
		PackedColorArray([_dark_col])
	)

	# ── Body ────────────────────────────────────────────────────────────────
	draw_rect(Rect2(-30, -40 + by, 60, 62), _body_col)

	# Belly shading (slightly darker lower half)
	var belly = _body_col.darkened(0.18)
	belly.a = 0.55
	draw_rect(Rect2(-30, -6 + by, 60, 28), belly)

	# ── Left arm ────────────────────────────────────────────────────────────
	var arm_swing = sin(elapsed_time * wsp + PI) * 6.0
	draw_rect(Rect2(-56, -20 + by + arm_swing, 27, 13), _body_col)
	# Three claws at the end
	for j in range(3):
		var cy = -20 + by + arm_swing + j * 5 - 3
		draw_line(Vector2(-56, cy + 5), Vector2(-67, cy - 3), _dark_col.lightened(0.18), 2.2)

	# ── Right arm ───────────────────────────────────────────────────────────
	draw_rect(Rect2(29, -20 + by - arm_swing, 27, 13), _body_col)
	for j in range(3):
		var cy = -20 + by - arm_swing + j * 5 - 3
		draw_line(Vector2(56, cy + 5), Vector2(67, cy - 3), _dark_col.lightened(0.18), 2.2)

	# ── Walking legs ────────────────────────────────────────────────────────
	var leg_l = 25 + walk * 7    # left leg extends when striding forward
	var leg_r = 25 - walk * 7
	draw_rect(Rect2(-27, 22 + by, 17, leg_l), _body_col)
	draw_rect(Rect2(10,  22 + by, 17, leg_r), _body_col)
	# Feet (chunky blocks)
	draw_rect(Rect2(-31, 22 + by + leg_l, 26, 9), _dark_col)
	draw_rect(Rect2(6,   22 + by + leg_r, 26, 9), _dark_col)

	# ── Note label backdrop (dark pill so text is always readable) ──────────
	draw_rect(Rect2(-28, -14, 56, 26), Color(0.0, 0.0, 0.0, 0.70), true)
	draw_rect(Rect2(-28, -14, 56, 26), Color(1.0, 1.0, 0.0, 0.35), false, 1.5)

	# ── Eyes ────────────────────────────────────────────────────────────────
	# Glow aura on high levels
	if level >= 18:
		var glow = _eye_col
		glow.a = 0.22
		draw_circle(Vector2(-13, -16 + by), 15.0, glow)
		draw_circle(Vector2(13,  -16 + by), 15.0, glow)

	# Sclera
	draw_circle(Vector2(-13, -16 + by), 10.5, Color.WHITE)
	draw_circle(Vector2(13,  -16 + by), 10.5, Color.WHITE)
	# Iris
	draw_circle(Vector2(-11, -14 + by), 6.5, _eye_col)
	draw_circle(Vector2(15,  -14 + by), 6.5, _eye_col)
	# Pupil
	draw_circle(Vector2(-10, -13 + by), 3.0, Color(0.04, 0.0, 0.0))
	draw_circle(Vector2(16,  -13 + by), 3.0, Color(0.04, 0.0, 0.0))

	# ── Angry brows ─────────────────────────────────────────────────────────
	draw_line(Vector2(-23, -27 + by), Vector2(-4,  -21 + by), _dark_col, 3.5)
	draw_line(Vector2(4,   -21 + by), Vector2(23,  -27 + by), _dark_col, 3.5)

	# ── Mouth ───────────────────────────────────────────────────────────────
	draw_rect(Rect2(-22, -3 + by, 44, 15), Color(0.06, 0.01, 0.01))
	# Upper teeth
	for i in range(5):
		draw_rect(Rect2(-20 + i * 9, -3 + by, 7, 9), Color(0.94, 0.94, 0.94))
	# Lower teeth (offset)
	for i in range(4):
		draw_rect(Rect2(-15 + i * 10, 5 + by, 7, 7), Color(0.90, 0.90, 0.90))

	# ── Glowing outline for master-level monsters ────────────────────────────
	if level >= 25:
		var glow_col = _eye_col
		glow_col.a = 0.30
		draw_rect(Rect2(-32, -42 + by, 64, 66), glow_col, false, 2.5)

# ── Pop / explode ────────────────────────────────────────────────────────────
func pop():
	if is_monster:
		_monster_explode()
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.1)
		tween.finished.connect(queue_free)

func _monster_explode():
	var piece_count = 10 + level / 2
	for i in range(piece_count):
		var bit = ColorRect.new()
		var sz = randf_range(6.0, 13.0 + level / 3.0)
		bit.size = Vector2(sz, sz)
		# Mix body colour with eye colour for gory variety
		bit.color = _body_col if randf() > 0.35 else _eye_col
		bit.position = position
		get_parent().add_child(bit)

		var angle  = randf() * TAU
		var dist   = randf_range(55.0, 125.0 + level)
		var target = position + Vector2(cos(angle), sin(angle)) * dist

		var tw = get_tree().create_tween()
		tw.tween_property(bit, "position", target, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(bit, "scale", Vector2.ZERO, 0.45)
		tw.finished.connect(bit.queue_free)

	queue_free()

# ── Helpers ──────────────────────────────────────────────────────────────────
func _get_note_name(note: int) -> String:
	if note == 0: return ""
	var names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	return names[note % 12] + str(note / 12 - 1)
