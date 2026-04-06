extends Node2D

@export var balloon_scene: PackedScene
@onready var keyboard = $CanvasLayer/PianoKeyboard
@onready var spawner_timer = $SpawnerTimer
@onready var score_label = $CanvasLayer/ScoreLabel

var active_balloons = []
var current_song = [64, 62, 60, 62, 64, 64, 64, 62, 62, 62, 64, 67, 67] # Mary Had a Little Lamb
var song_index = 0

func _ready():
	keyboard.setup_keyboard(GameManager.keys_count)
	InputHandler.note_on.connect(_on_note_on)
	InputHandler.note_off.connect(_on_note_off)
	
	spawner_timer.timeout.connect(_spawn_next_balloon)
	spawner_timer.start(2.0)
	
	GameManager.reset_game()
	update_ui()

func _on_note_on(note: int):
	keyboard.press_key(note)
	_check_balloon_popped(note)

func _on_note_off(note: int):
	keyboard.release_key(note)

func _spawn_next_balloon():
	if song_index >= current_song.size():
		song_index = 0 # Loop for now
		
	var note = current_song[song_index]
	var x_pos = randf_range(200, 1000)
	var balloon = balloon_scene.instantiate()
	add_child(balloon)
	balloon.setup(note, Vector2(x_pos, 750), 100.0)
	active_balloons.append(balloon)
	
	song_index += 1

func _check_balloon_popped(note: int):
	for i in range(active_balloons.size() - 1, -1, -1):
		var b = active_balloons[i]
		if b.target_note == note:
			b.pop()
			active_balloons.remove_at(i)
			GameManager.score += 10
			update_ui()
			return

func update_ui():
	score_label.text = "Score: " + str(GameManager.score) + " | Player: " + GameManager.player_name
