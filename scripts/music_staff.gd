extends Control

@onready var note_head = $NoteHead

# Treble clef staff: lines at E4(64) G4(67) B4(71) D5(74) F5(77)
const LINE_SPACING = 20.0
const START_Y = 60.0
const BOTTOM_LINE_Y = 140.0  # E4 sits on the bottom (5th) staff line
const STEP_PX = 10.0         # pixels per diatonic step (half a line gap)
# Maps chromatic pitch class → diatonic step within octave (C=0 … B=6)
const CHROMA_TO_DIATONIC = {0:0, 1:0, 2:1, 3:1, 4:2, 5:3, 6:3, 7:4, 8:4, 9:5, 10:5, 11:6}
# E4 = MIDI 64: pitch class 4 → diatonic 2, octave-group = 64/12 = 5 → 2 + 5*7 = 37
const E4_DIATONIC = 37
const NOTE_NAMES = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]

var _current_midi: int = 60
var _note_label: Label

func _ready():
	_note_label = Label.new()
	_note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_note_label.add_theme_font_size_override("font_size", 16)
	_note_label.add_theme_color_override("font_color", Color.WHITE)
	_note_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_note_label.offset_top = -30
	add_child(_note_label)
	set_note(60)

func _midi_center_y(midi_note: int) -> float:
	var diatonic = CHROMA_TO_DIATONIC[midi_note % 12] + (midi_note / 12) * 7
	return BOTTOM_LINE_Y - (diatonic - E4_DIATONIC) * STEP_PX

func set_note(midi_note: int):
	_current_midi = midi_note
	var center_y = _midi_center_y(midi_note)
	# position.y sets the top-left of NoteHead; NoteHead is 40 px tall so subtract 20 for center
	note_head.position.y = center_y - 20.0

	var is_sharp = (midi_note % 12) in [1, 3, 6, 8, 10]
	note_head.modulate = Color.GOLD if is_sharp else Color.WHITE

	var octave = (midi_note / 12) - 1  # MIDI standard: C4=60 → octave 4
	_note_label.text = NOTE_NAMES[midi_note % 12] + str(octave)

	queue_redraw()

func _draw():
	var line_color = Color(0.8, 0.8, 0.8, 1.0)
	var line_width = 2.0

	# 5 treble-clef staff lines
	for i in range(5):
		var y = START_Y + i * LINE_SPACING
		draw_line(Vector2(0, y), Vector2(size.x, y), line_color, line_width)

	# Ledger lines for notes outside the staff (e.g. middle C below, high notes above)
	var center_y = _midi_center_y(_current_midi)
	var ledger_x0 = size.x * 0.35
	var ledger_x1 = size.x * 0.65
	# Below the staff: draw a ledger line for each staff-line position below bottom line
	var y = BOTTOM_LINE_Y + LINE_SPACING
	while center_y >= y - STEP_PX:
		draw_line(Vector2(ledger_x0, y), Vector2(ledger_x1, y), line_color, line_width)
		y += LINE_SPACING
	# Above the staff: draw ledger lines above the top line
	y = START_Y - LINE_SPACING
	while center_y <= y + STEP_PX:
		draw_line(Vector2(ledger_x0, y), Vector2(ledger_x1, y), line_color, line_width)
		y -= LINE_SPACING
