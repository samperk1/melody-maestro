extends Node2D

# Manages animated sky: fluffy clouds, birds, storm clouds, and lightning.
# Reads GameManager.current_level_index directly to smoothly shift atmosphere.

const SW = 1280.0
const SH = 720.0

var _clouds: Array = []
var _birds: Array = []
var _time: float = 0.0
var _lightning_alpha: float = 0.0
var _lightning_timer: float = 0.0

func _ready():
	z_index = 0
	_lightning_timer = randf_range(5.0, 12.0)

	for i in range(10):
		_add_cloud(randf_range(0.0, SW), true)
	for i in range(6):
		_add_bird()

func _process(delta):
	_time += delta
	var lv = GameManager.current_level_index

	# Drift clouds left to right (some slower in bg, some faster in fg)
	for c in _clouds:
		c.x += c.spd * delta
		if c.x - c.r * 2.5 > SW + 60:
			c.x = -c.r * 2.5 - 20
			c.y = randf_range(30.0, 360.0)
			# Upgrade to storm cloud at higher levels
			c.storm = lv >= 10 and randf() < clamp(float(lv - 8) / 16.0, 0.0, 1.0)

	# Move birds (they flee as monsters increase)
	for b in _birds:
		b.x += b.vx * delta
		b.wing += b.frate * delta
		if b.vx > 0 and b.x > SW + 130:
			b.x = -130.0
			b.y = randf_range(50.0, 310.0)
		elif b.vx < 0 and b.x < -130:
			b.x = SW + 130.0
			b.y = randf_range(50.0, 310.0)

	# Lightning flashes during storm levels
	if lv >= 14:
		_lightning_timer -= delta
		if _lightning_timer <= 0.0:
			_lightning_timer = randf_range(3.5, 11.0)
			_lightning_alpha = 0.6
		_lightning_alpha = move_toward(_lightning_alpha, 0.0, delta * 5.5)
	else:
		_lightning_alpha = move_toward(_lightning_alpha, 0.0, delta * 3.0)

	queue_redraw()

func _add_cloud(x: float, spread: bool = false):
	var lv = GameManager.current_level_index if GameManager else 0
	var r = randf_range(28.0, 70.0)
	_clouds.append({
		"x": x,
		"y": randf_range(30.0, 360.0) if spread else randf_range(30.0, 200.0),
		"r": r,
		"spd": randf_range(7.0, 26.0),
		"storm": lv >= 10 and randf() < 0.4,
		"bolt_ox": randf_range(-0.5, 0.5),  # fixed lightning offset (fraction of r)
		"bolt_oy": randf_range(0.2, 0.55),
	})

func _add_bird():
	var go_right = randf() > 0.5
	_birds.append({
		"x": randf_range(0.0, SW),
		"y": randf_range(50.0, 310.0),
		"vx": randf_range(32.0, 80.0) * (1.0 if go_right else -1.0),
		"wing": randf() * TAU,
		"frate": randf_range(2.8, 5.5),
		"sz": randf_range(4.0, 8.5),
	})

func _draw():
	var lv = GameManager.current_level_index

	for c in _clouds:
		_draw_cloud(c, lv)

	# Birds fade out as monster chaos increases
	var bird_a = clamp(1.0 - float(lv - 10) / 8.0, 0.0, 1.0)
	if bird_a > 0.01:
		for b in _birds:
			_draw_bird(b, bird_a)

	# Lightning flash overlay
	if _lightning_alpha > 0.01:
		draw_rect(Rect2(0, 0, SW, SH), Color(1.0, 1.0, 0.82, _lightning_alpha * 0.2))

func _draw_cloud(c: Dictionary, lv: int):
	var storm_t = clamp(float(lv - 8) / 16.0, 0.0, 1.0)
	var is_storm = c.storm or storm_t > 0.6

	var col: Color
	if is_storm:
		var dark_t = clamp(float(lv - 12) / 16.0, 0.0, 1.0)
		col = Color(0.65, 0.65, 0.72, 0.84).lerp(Color(0.16, 0.13, 0.22, 0.93), dark_t)
	else:
		var mix_t = clamp(storm_t * 1.8, 0.0, 1.0)
		col = Color(1.0, 1.0, 1.0, 0.80).lerp(Color(0.70, 0.70, 0.76, 0.80), mix_t)

	var r = c.r
	var x = c.x
	var y = c.y

	# Five overlapping circles create the cloud puff shape
	draw_circle(Vector2(x, y), r, col)
	draw_circle(Vector2(x - r * 0.60, y + r * 0.30), r * 0.72, col)
	draw_circle(Vector2(x + r * 0.60, y + r * 0.30), r * 0.72, col)
	draw_circle(Vector2(x - r * 0.28, y - r * 0.30), r * 0.56, col)
	draw_circle(Vector2(x + r * 0.28, y - r * 0.30), r * 0.56, col)

	# Flat base to ground the cloud
	var base_col = col.darkened(0.11)
	draw_rect(Rect2(x - r * 1.32, y + r * 0.10, r * 2.64, r * 0.65), base_col)

	# Lightning bolt hanging from storm clouds
	if is_storm and lv >= 13:
		var bx = x + c.bolt_ox * r * 2.0
		var by = y + c.bolt_oy * r * 2.0
		var bc = Color(1.0, 0.95, 0.22, 0.88)
		# Zigzag: top → kink → bottom
		var pts = PackedVector2Array([
			Vector2(bx + 4,  by),
			Vector2(bx - 4,  by + 14),
			Vector2(bx + 1,  by + 14),
			Vector2(bx - 7,  by + 32),
		])
		draw_polyline(pts, bc, 2.5)

func _draw_bird(b: Dictionary, alpha: float):
	var s = b.sz
	var col = Color(0.05, 0.05, 0.08, alpha * 0.88)
	var cx = b.x
	var cy = b.y
	var flap = sin(b.wing)  # -1 to 1

	# Each wing: two segments (body→mid, mid→tip)
	# The mid-joint dips slightly, tip sweeps up/down with flap
	var l_mid = Vector2(cx - s * 1.5, cy + flap * s * 0.3)
	var l_tip = Vector2(cx - s * 3.1, cy - flap * s * 0.9)
	var r_mid = Vector2(cx + s * 1.5, cy + flap * s * 0.3)
	var r_tip = Vector2(cx + s * 3.1, cy - flap * s * 0.9)

	draw_line(Vector2(cx, cy), l_mid, col, s * 0.52)
	draw_line(l_mid, l_tip,          col, s * 0.42)
	draw_line(Vector2(cx, cy), r_mid, col, s * 0.52)
	draw_line(r_mid, r_tip,          col, s * 0.42)
	draw_circle(Vector2(cx, cy), s * 0.38, col)
