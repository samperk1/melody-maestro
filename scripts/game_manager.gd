extends Node

var player_name: String = "Maestro"
var input_type: String = "MIDI Keyboard"
var keys_count: int = 88
var score: int = 0
var streak: int = 0
var groove_level: int = 0

func reset_game():
	score = 0
	streak = 0
	groove_level = 0
