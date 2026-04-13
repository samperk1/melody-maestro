extends Control

@onready var note_head = $NoteHead

func _ready():
	# Initial position: Middle C
	set_note(60)

func set_note(midi_note: int):
	# Calculate vertical offset based on staff position
	# MIDI 60 (C4) is on the first ledger line below the treble staff
	# Treble staff lines: E4 (64), G4 (67), B4 (71), D5 (74), F5 (77)
	# For simplicity, we'll just map roughly
	var base_y = 100.0 # Middle of the control
	var note_step = 10.0 # Distance between notes
	
	# Mapping C4 (60) to a specific staff position
	# This is a very basic visual approximation
	var offset = (midi_note - 60) * -note_step / 2.0
	note_head.position.y = base_y + offset
	
	# Change color if it's a sharp
	var is_sharp = (midi_note % 12) in [1, 3, 6, 8, 10]
	note_head.modulate = Color.GOLD if is_sharp else Color.WHITE

func _draw():
	# Draw the 5 staff lines
	var line_color = Color(0.8, 0.8, 0.8, 1.0)
	var line_width = 2.0
	var line_spacing = 20.0
	var start_y = 60.0
	
	for i in range(5):
		var y = start_y + i * line_spacing
		draw_line(Vector2(0, y), Vector2(size.x, y), line_color, line_width)
