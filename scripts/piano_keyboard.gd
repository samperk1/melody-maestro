extends HBoxContainer

@export var white_key_scene: PackedScene
@export var black_key_scene: PackedScene

var keys = {}      # note -> Control (container)
var key_rects = {} # note -> ColorRect (background, for color changes)

const NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

func setup_keyboard(num_keys: int):
	for child in get_children():
		child.queue_free()
	keys.clear()
	key_rects.clear()

	var start_note = 21 if num_keys == 88 else 48

	for i in range(num_keys):
		var note = start_note + i
		var key = _create_key(note)
		add_child(key)
		keys[note] = key

func _get_note_name(note: int) -> String:
	var name = NOTE_NAMES[note % 12]
	# Replace # with the sharp symbol
	return name.replace("#", "♯")

func _create_key(note: int) -> Control:
	var is_black = _is_note_black(note)

	var container = Control.new()
	container.custom_minimum_size = Vector2(25 if not is_black else 15, 150 if not is_black else 100)
	container.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg = ColorRect.new()
	bg.color = Color.WHITE if not is_black else Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(bg)
	key_rects[note] = bg

	var label = Label.new()
	label.text = _get_note_name(note)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 11 if is_black else 14)
	label.add_theme_color_override("font_color", Color.BLACK if not is_black else Color.WHITE)
	container.add_child(label)

	container.gui_input.connect(_on_key_input.bind(note))

	return container

func _on_key_input(event: InputEvent, note: int):
	if event is InputEventMouseButton:
		if event.pressed:
			InputHandler.note_on.emit(note)
		else:
			InputHandler.note_off.emit(note)

func _is_note_black(note: int) -> bool:
	var m = note % 12
	return m in [1, 3, 6, 8, 10]

func press_key(note: int):
	if key_rects.has(note):
		key_rects[note].color = Color.GOLD

func release_key(note: int):
	if key_rects.has(note):
		var is_black = _is_note_black(note)
		key_rects[note].color = Color.WHITE if not is_black else Color.BLACK

func get_key_x(note: int) -> float:
	if keys.has(note):
		return keys[note].global_position.x + (keys[note].size.x / 2.0)
	return 640.0 # Default center
