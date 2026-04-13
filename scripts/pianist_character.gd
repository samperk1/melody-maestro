extends Control

var body_bob: float = 0.0
var r_hand_y: float = 0.0
var l_hand_y: float = 0.0
var head_nod: float = 0.0

func _ready():
	_start_animation()

func _start_animation():
	# Gentle body bob while playing
	var tween = get_tree().create_tween().set_loops()
	tween.tween_method(func(v): body_bob = v, 0.0, -5.0, 0.55).set_trans(Tween.TRANS_SINE)
	tween.tween_method(func(v): body_bob = v, -5.0, 0.0, 0.55).set_trans(Tween.TRANS_SINE)

	# Hands alternate pressing keys
	var rh = get_tree().create_tween().set_loops()
	rh.tween_method(func(v): r_hand_y = v, 0.0, 6.0, 0.28).set_trans(Tween.TRANS_SINE)
	rh.tween_method(func(v): r_hand_y = v, 6.0, 0.0, 0.28).set_trans(Tween.TRANS_SINE)
	rh.tween_interval(0.3)

	var lh = get_tree().create_tween().set_loops()
	lh.tween_interval(0.28)
	lh.tween_method(func(v): l_hand_y = v, 0.0, 6.0, 0.28).set_trans(Tween.TRANS_SINE)
	lh.tween_method(func(v): l_hand_y = v, 6.0, 0.0, 0.28).set_trans(Tween.TRANS_SINE)
	lh.tween_interval(0.3)

	# Head nod
	var hn = get_tree().create_tween().set_loops()
	hn.tween_method(func(v): head_nod = v, 0.0, 5.0, 0.45).set_trans(Tween.TRANS_SINE)
	hn.tween_method(func(v): head_nod = v, 5.0, 0.0, 0.45).set_trans(Tween.TRANS_SINE)

func _process(_delta):
	queue_redraw()

func _draw():
	var by = body_bob
	var tux      = Color(0.08, 0.08, 0.13)
	var tux_dark = Color(0.05, 0.05, 0.09)
	var skin     = Color(0.90, 0.73, 0.56)
	var hair     = Color(0.12, 0.08, 0.04)
	var wood     = Color(0.46, 0.28, 0.10)
	var dark_wood= Color(0.30, 0.16, 0.05)

	# ── Piano stool ─────────────────────────────────────────────────────────
	draw_rect(Rect2(-32, 56 + by, 64, 7), wood)
	draw_rect(Rect2(-26, 63 + by, 8, 18), dark_wood)
	draw_rect(Rect2(18,  63 + by, 8, 18), dark_wood)

	# ── Piano fallboard + keys ───────────────────────────────────────────────
	draw_rect(Rect2(-58, 34 + by, 116, 25), Color(0.10, 0.08, 0.07))
	for k in range(9):
		draw_rect(Rect2(-55 + k * 12, 36 + by, 10, 20), Color(0.95, 0.94, 0.90))
	for k in [1, 2, 4, 5, 6, 8]:
		draw_rect(Rect2(-55 + k * 12 - 4, 36 + by, 7, 13), Color(0.08, 0.08, 0.10))

	# ── Trousers ─────────────────────────────────────────────────────────────
	draw_rect(Rect2(-20, 22 + by, 14, 36), tux)
	draw_rect(Rect2(6,   22 + by, 14, 36), tux)
	# Trouser crease stripe
	draw_line(Vector2(-13, 22 + by), Vector2(-13, 56 + by), Color(0.2, 0.2, 0.28), 1.5)
	draw_line(Vector2(13,  22 + by), Vector2(13,  56 + by), Color(0.2, 0.2, 0.28), 1.5)
	# Shoes
	draw_rect(Rect2(-24, 55 + by, 22, 6), Color(0.06, 0.05, 0.07))
	draw_rect(Rect2(2,   55 + by, 22, 6), Color(0.06, 0.05, 0.07))

	# ── Jacket body ──────────────────────────────────────────────────────────
	draw_rect(Rect2(-27, -12 + by, 54, 36), tux)

	# White dress shirt bib
	draw_polygon(PackedVector2Array([
		Vector2(-5, -10 + by), Vector2(5, -10 + by),
		Vector2(4,  22 + by),  Vector2(-4, 22 + by)
	]), PackedColorArray([Color(0.95, 0.95, 0.97)]))

	# Shirt stud buttons
	for i in range(3):
		draw_circle(Vector2(0, -2 + i * 8 + by), 1.3, Color(0.75, 0.75, 0.80))

	# Satin lapels
	var lapel = Color(0.18, 0.18, 0.24)
	draw_polygon(PackedVector2Array([
		Vector2(-5, -10 + by), Vector2(-27, -12 + by), Vector2(-13, 10 + by)
	]), PackedColorArray([lapel]))
	draw_polygon(PackedVector2Array([
		Vector2(5,  -10 + by), Vector2(27, -12 + by), Vector2(13, 10 + by)
	]), PackedColorArray([lapel]))

	# Red bow tie
	var bt = Color(0.88, 0.12, 0.15)
	draw_polygon(PackedVector2Array([
		Vector2(-9, -8 + by), Vector2(0, -4 + by), Vector2(-9, 0 + by)
	]), PackedColorArray([bt]))
	draw_polygon(PackedVector2Array([
		Vector2(9,  -8 + by), Vector2(0, -4 + by), Vector2(9,  0 + by)
	]), PackedColorArray([bt]))
	draw_circle(Vector2(0, -4 + by), 2.2, bt.darkened(0.3))

	# Jacket pocket square (tiny white puff)
	draw_rect(Rect2(-24, -8 + by, 8, 5), Color(0.93, 0.93, 0.95))
	draw_line(Vector2(-22, -8 + by), Vector2(-20, -4 + by), Color(0.8, 0.8, 0.85), 1.0)

	# ── Arms & hands ─────────────────────────────────────────────────────────
	# Right sleeve
	draw_rect(Rect2(24, -5 + by, 32, 12), tux)
	draw_rect(Rect2(52, -5 + by, 9, 12), Color(0.93, 0.93, 0.96))   # cuff
	# Right hand + fingers
	var rhy = r_hand_y
	draw_rect(Rect2(57, 6 + by + rhy, 15, 9), skin)
	for f in range(4):
		draw_rect(Rect2(57 + f * 3, 14 + by + rhy, 3, 5), skin)

	# Left sleeve
	draw_rect(Rect2(-56, -5 + by, 32, 12), tux)
	draw_rect(Rect2(-61, -5 + by, 9, 12), Color(0.93, 0.93, 0.96))  # cuff
	# Left hand + fingers
	var lhy = l_hand_y
	draw_rect(Rect2(-72, 6 + by + lhy, 15, 9), skin)
	for f in range(4):
		draw_rect(Rect2(-72 + f * 3, 14 + by + lhy, 3, 5), skin)

	# ── Neck ─────────────────────────────────────────────────────────────────
	draw_rect(Rect2(-5, -16 + by, 10, 8), skin)

	# ── Head ─────────────────────────────────────────────────────────────────
	var hy = head_nod + by
	draw_rect(Rect2(-18, -52 + hy, 36, 38), skin)
	# Ears
	draw_rect(Rect2(-23, -44 + hy, 6, 12), skin)
	draw_rect(Rect2(17,  -44 + hy, 6, 12), skin)
	draw_circle(Vector2(-20, -38 + hy), 2.5, skin.darkened(0.18))
	draw_circle(Vector2(20,  -38 + hy), 2.5, skin.darkened(0.18))

	# Hair
	draw_rect(Rect2(-18, -52 + hy, 36, 14), hair)
	draw_rect(Rect2(-18, -38 + hy, 5,  10), hair)  # left sideburn
	draw_rect(Rect2(13,  -38 + hy, 5,  10), hair)  # right sideburn
	# Side part
	draw_line(Vector2(-2, -52 + hy), Vector2(-5, -38 + hy), hair.lightened(0.2), 1.5)

	# Eyebrows
	draw_line(Vector2(-14, -34 + hy), Vector2(-4, -33 + hy), hair, 2.5)
	draw_line(Vector2(4,   -33 + hy), Vector2(14, -34 + hy), hair, 2.5)

	# Eyes
	draw_circle(Vector2(-8,  -27 + hy), 4.5, Color(1, 1, 1))
	draw_circle(Vector2(8,   -27 + hy), 4.5, Color(1, 1, 1))
	draw_circle(Vector2(-7,  -27 + hy), 2.8, Color(0.25, 0.18, 0.10))
	draw_circle(Vector2(9,   -27 + hy), 2.8, Color(0.25, 0.18, 0.10))
	draw_circle(Vector2(-5,  -28 + hy), 1.1, Color(1, 1, 1))
	draw_circle(Vector2(11,  -28 + hy), 1.1, Color(1, 1, 1))

	# Dapper mustache
	draw_rect(Rect2(-11, -18 + hy, 9, 5), hair)
	draw_rect(Rect2(2,   -18 + hy, 9, 5), hair)

	# Smile
	draw_arc(Vector2(0, -12 + hy), 7, deg_to_rad(15), deg_to_rad(165), 10, skin.darkened(0.45), 2.0)

	# ── Top hat ───────────────────────────────────────────────────────────────
	draw_rect(Rect2(-24, -54 + hy, 48, 5),  tux_dark)              # brim
	draw_rect(Rect2(-15, -88 + hy, 30, 36), tux_dark)              # crown
	draw_rect(Rect2(-15, -56 + hy, 30, 4),  Color(0.85, 0.1, 0.1)) # red band
	draw_line(Vector2(-8, -86 + hy), Vector2(-8, -60 + hy),        # shine
		Color(1, 1, 1, 0.10), 3.5)
