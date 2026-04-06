extends Control

@onready var player_name_input = $VBoxContainer/PlayerNameInput
@onready var input_type_option = $VBoxContainer/InputTypeOption
@onready var keys_option = $VBoxContainer/KeysOption
@onready var start_button = $VBoxContainer/StartButton

func _ready():
	input_type_option.add_item("MIDI Keyboard")
	input_type_option.add_item("Microphone (Acoustic)")
	
	keys_option.add_item("25 Keys")
	keys_option.add_item("49 Keys")
	keys_option.add_item("61 Keys")
	keys_option.add_item("88 Keys")
	
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	var player_name = player_name_input.text
	if player_name.strip_edges() == "":
		player_name = "Maestro"
		
	var input_type = input_type_option.get_item_text(input_type_option.selected)
	var keys_count = keys_option.get_item_text(keys_option.selected).to_int()
	
	GameManager.player_name = player_name
	GameManager.input_type = input_type
	GameManager.keys_count = keys_count
	
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
