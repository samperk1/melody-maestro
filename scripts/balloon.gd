extends Area2D

signal popped(note: int)

var target_note: int = 60 # Middle C
var speed: float = 100.0

@onready var label = $Label

func setup(note: int, start_pos: Vector2, _speed: float):
	target_note = note
	position = start_pos
	speed = _speed
	label.text = _get_note_name(note)

func _process(delta):
	position.y -= speed * delta
	if position.y < -50:
		queue_free()

func pop():
	# Animation could go here
	popped.emit(target_note)
	queue_free()

func _get_note_name(note: int) -> String:
	var names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	return names[note % 12] + str(note / 12 - 1)
