extends HBoxContainer

@export var white_key_scene: PackedScene
@export var black_key_scene: PackedScene

var keys = {}

func setup_keyboard(num_keys: int):
	# Clear existing
	for child in get_children():
		child.queue_free()
	
	# Start MIDI note (e.g., A0 = 21 for 88 keys)
	var start_note = 21 if num_keys == 88 else 48 # 48 is C3
	
	for i in range(num_keys):
		var note = start_note + i
		var key = _create_key(note)
		add_child(key)
		keys[note] = key

func _create_key(note: int) -> Control:
	var is_black = _is_note_black(note)
	# For simplicity, we'll just use ColorRects in this example
	var key = ColorRect.new()
	key.custom_minimum_size = Vector2(25 if not is_black else 15, 150 if not is_black else 100)
	key.color = Color.WHITE if not is_black else Color.BLACK
	return key

func _is_note_black(note: int) -> bool:
	var m = note % 12
	return m in [1, 3, 6, 8, 10]

func press_key(note: int):
	if keys.has(note):
		keys[note].color = Color.GOLD

func release_key(note: int):
	if keys.has(note):
		var is_black = _is_note_black(note)
		keys[note].color = Color.WHITE if not is_black else Color.BLACK
