extends Control

signal game_start

@onready var player_name_input = $VBoxContainer/PlayerNameInput
@onready var input_type_option = $VBoxContainer/InputTypeOption
@onready var keys_option = $VBoxContainer/KeysOption
@onready var start_button = $VBoxContainer/StartButton
@onready var high_score_label = $VBoxContainer/HighScoreLabel

const MENU_MELODY = [
	60, 64, 67, 64, 69, 67, 64, 62,
	60, 65, 69, 65, 71, 69, 65, 62,
	60, 64, 67, 71, 72, 71, 69, 67,
	65, 64, 62, 60, 62, 64, 65, 67
]
var _melody_idx: int = 0
var _note_timer: Timer

func _ready():
	input_type_option.add_item("MIDI Keyboard")
	input_type_option.add_item("Computer Keyboard")
	input_type_option.add_item("Microphone (Acoustic)")

	keys_option.add_item("25 Keys")
	keys_option.add_item("49 Keys")
	keys_option.add_item("61 Keys")
	keys_option.add_item("88 Keys")

	start_button.pressed.connect(_on_start_button_pressed)

	_update_high_score_display()
	_start_menu_music()

func _start_menu_music():
	_note_timer = Timer.new()
	_note_timer.wait_time = 0.42
	_note_timer.timeout.connect(_play_menu_note)
	add_child(_note_timer)
	_note_timer.start()

func _play_menu_note():
	SoundManager.play_note(MENU_MELODY[_melody_idx], -22.0)
	_melody_idx = (_melody_idx + 1) % MENU_MELODY.size()

func _update_high_score_display():
	if not high_score_label:
		return
	var lb = GameManager.leaderboard
	if lb.is_empty():
		high_score_label.text = "No scores yet — be the first!"
		return
	var medals = ["1st", "2nd", "3rd"]
	var lines = ["Top Scores:"]
	for i in range(lb.size()):
		lines.append("%s  %s — %d" % [medals[i], lb[i].name, lb[i].score])
	high_score_label.text = "\n".join(lines)

func _on_start_button_pressed():
	var player_name = player_name_input.text
	if player_name.strip_edges() == "":
		player_name = "Maestro"
	GameManager.player_name = player_name
	GameManager.input_type = input_type_option.get_item_text(input_type_option.selected)
	GameManager.keys_count = keys_option.get_item_text(keys_option.selected).to_int()
	_note_timer.stop()
	game_start.emit()
