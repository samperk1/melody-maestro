extends Node2D

@export var balloon_scene: PackedScene
@onready var keyboard = $CanvasLayer/PianoKeyboard
@onready var spawner_timer = $SpawnerTimer
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var maestro = $CanvasLayer/MaestroCharacter
@onready var progress_bar = $CanvasLayer/ProgressBar
@onready var music_staff = $CanvasLayer/MusicStaff
@onready var restart_button = $CanvasLayer/Controls/RestartButton
@onready var exit_button = $CanvasLayer/Controls/ExitButton
@onready var pause_button = $CanvasLayer/Controls/PauseButton
@onready var level_clear_panel = $CanvasLayer/LevelClearPanel
@onready var level_clear_label = $CanvasLayer/LevelClearPanel/VBoxContainer/LevelLabel
@onready var continue_button = $CanvasLayer/LevelClearPanel/VBoxContainer/ContinueButton
@onready var pause_panel = $CanvasLayer/PausePanel
@onready var resume_button = $CanvasLayer/PausePanel/VBoxContainer/ResumeButton
@onready var pause_quit_button = $CanvasLayer/PausePanel/VBoxContainer/QuitButton
@onready var lives_label = $CanvasLayer/LivesLabel
@onready var background = $Background

var _game_started: bool = false
var active_balloons = []
var current_song_data = {}
var song_index = 0
var balloons_popped = 0
var streak = 0
var is_celebrating: bool = false
var strikes = 0
var lives = 3
var is_paused: bool = false

var _bg_base_color: Color = Color(0.15, 0.2, 0.3)
var _bg_time: float = 0.0

func _ready():
	spawner_timer.timeout.connect(_spawn_next_balloon)
	restart_button.pressed.connect(_on_restart_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	pause_button.pressed.connect(_toggle_pause)
	resume_button.pressed.connect(_toggle_pause)
	pause_quit_button.pressed.connect(_on_exit_pressed)
	if not continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.connect(_on_continue_pressed)
	level_clear_panel.visible = false
	pause_panel.visible = false

	var sky = Node2D.new()
	sky.set_script(load("res://scripts/sky_manager.gd"))
	add_child(sky)

	_show_welcome_overlay()

func _show_welcome_overlay():
	_game_started = false
	var layer = CanvasLayer.new()
	layer.layer = 100
	layer.name = "WelcomeLayer"
	var welcome = load("res://scenes/welcome_screen.tscn").instantiate()
	layer.add_child(welcome)
	add_child(layer)
	welcome.game_start.connect(_on_welcome_complete)

func _on_welcome_complete():
	var layer = get_node_or_null("WelcomeLayer")
	if layer:
		layer.hide()
	_game_started = true
	InputHandler.use_midi = (GameManager.input_type == "MIDI Keyboard")
	InputHandler.use_computer_keyboard = (GameManager.input_type == "Computer Keyboard")
	keyboard.setup_keyboard(GameManager.keys_count)
	if not InputHandler.note_on.is_connected(_on_note_on):
		InputHandler.note_on.connect(_on_note_on)
	if not InputHandler.note_off.is_connected(_on_note_off):
		InputHandler.note_off.connect(_on_note_off)
	_start_level()

func _process(delta):
	if is_celebrating:
		_spawn_celebration_balloon()
	_animate_background(delta)

func _start_level():
	is_celebrating = false
	current_song_data = GameManager.get_current_song()
	song_index = 0
	balloons_popped = 0
	streak = 0
	strikes = 0
	
	for b in active_balloons:
		if is_instance_valid(b): b.queue_free()
	active_balloons.clear()
	
	_update_atmosphere()
	update_ui()
	
	await get_tree().create_timer(1.0).timeout
	maestro.say("welcome")
	if current_song_data["notes"].size() > 0:
		var initial_note = current_song_data["notes"][0]
		if initial_note is Array:
			music_staff.set_note(initial_note[0])
		else:
			music_staff.set_note(initial_note)
	spawner_timer.start(1.5)

func _update_atmosphere():
	var level = GameManager.current_level_index
	var factor = clamp(float(level) / 30.0, 0.0, 1.0)
	_bg_base_color = Color(0.15, 0.2, 0.3).lerp(Color(0.2, 0.05, 0.05), factor)
	background.color = _bg_base_color

func _animate_background(delta: float):
	_bg_time += delta

	# Gentle color wave that pulses on top of the base level color
	var pulse = sin(_bg_time * 0.5) * 0.03
	var wr = sin(_bg_time * 0.7 + 1.0) * 0.02
	var wg = sin(_bg_time * 0.4 + 2.1) * 0.015
	var wb = sin(_bg_time * 0.6 + 0.5) * 0.025
	background.color = Color(
		clamp(_bg_base_color.r + wr + pulse, 0.0, 1.0),
		clamp(_bg_base_color.g + wg, 0.0, 1.0),
		clamp(_bg_base_color.b + wb + pulse, 0.0, 1.0)
	)


func _unhandled_input(event: InputEvent):
	if _game_started and event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_panel.visible = is_paused
	pause_button.text = "RESUME" if is_paused else "PAUSE"

func _on_restart_pressed():
	lives = 3
	strikes = 0
	GameManager.reset_game()
	GameManager.save_game()
	if continue_button.pressed.is_connected(_on_restart_pressed):
		continue_button.pressed.disconnect(_on_restart_pressed)
	if not continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.connect(_on_continue_pressed)
	level_clear_panel.visible = false
	_start_level()

func _on_exit_pressed():
	get_tree().paused = false
	GameManager.save_game()
	GameManager.reset_game()
	spawner_timer.stop()
	for b in active_balloons:
		if is_instance_valid(b): b.queue_free()
	active_balloons.clear()
	var existing = get_node_or_null("WelcomeLayer")
	if existing:
		existing.show()
		var ws = existing.get_child(0)
		if ws and ws.has_method("_update_high_score_display"):
			ws._update_high_score_display()
	else:
		_show_welcome_overlay()

func _on_continue_pressed():
	level_clear_panel.visible = false
	_start_level()

func _on_note_on(note: int):
	SoundManager.play_note(note)
	keyboard.press_key(note)
	
	var found = _check_balloon_popped(note)
	
	if not found and not is_celebrating:
		_on_strike()

func _on_strike():
	strikes += 1
	streak = 0
	if strikes >= 3:
		_on_lose_life()
	else:
		maestro.say("missed")
		update_ui()

func _on_lose_life():
	lives -= 1
	strikes = 0
	if lives <= 0:
		_game_over()
	else:
		_fail_restart()

func _game_over():
	spawner_timer.stop()
	for b in active_balloons:
		if is_instance_valid(b): b.queue_free()
	active_balloons.clear()
	
	level_clear_label.text = "GAME OVER MAN!"
	continue_button.text = "TRY AGAIN"
	level_clear_panel.visible = true
	maestro.say("missed")
	
	if continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.disconnect(_on_continue_pressed)
	continue_button.pressed.connect(_on_restart_pressed)

func _fail_restart():
	streak = 0
	song_index = 0
	balloons_popped = 0
	for b in active_balloons:
		if is_instance_valid(b): b.queue_free()
	active_balloons.clear()
	spawner_timer.stop()
	maestro.say("missed")
	update_ui()
	await get_tree().create_timer(1.5).timeout
	spawner_timer.start(1.5)

func _on_note_off(note: int):
	keyboard.release_key(note)

func _spawn_next_balloon():
	if song_index >= current_song_data["notes"].size():
		spawner_timer.stop()
		return
		
	var notes = current_song_data["notes"][song_index]
	var current_level = GameManager.current_level_index
	
	# Monster probability logic: Increases by level
	var monster_prob = clamp(float(current_level) * 0.05, 0.0, 1.0)
	
	# Tempo scaling
	var current_speed = 90.0 + (current_level * 5.0)
	
	if notes is Array:
		for note in notes:
			var roll_monster = randf() < monster_prob
			_create_balloon(note, current_speed, roll_monster)
	else:
		var roll_monster = randf() < monster_prob
		_create_balloon(notes, current_speed, roll_monster)
	
	song_index += 1
	if song_index < current_song_data["notes"].size():
		var next_notes = current_song_data["notes"][song_index]
		if next_notes is Array:
			music_staff.set_note(next_notes[0])
		else:
			music_staff.set_note(next_notes)

func _create_balloon(note: int, speed: float, is_monster: bool):
	var x_pos = keyboard.get_key_x(note)
	var balloon = balloon_scene.instantiate()
	add_child(balloon)
	# Pass the level to the balloon for menacing visuals
	balloon.setup(note, Vector2(x_pos, -50), speed, is_monster, GameManager.current_level_index)
	active_balloons.append(balloon)

func _check_balloon_popped(note: int) -> bool:
	for i in range(active_balloons.size() - 1, -1, -1):
		var b = active_balloons[i]
		if is_instance_valid(b) and b.target_note == note:
			_spawn_projectile(note, b.position)
			b.pop()
			SoundManager.play_pop()
			active_balloons.remove_at(i)
			GameManager.score += 10
			balloons_popped += 1
			streak += 1
			_handle_groove()
			update_ui()
			
			var total_notes = 0
			for n in current_song_data["notes"]:
				if n is Array: total_notes += n.size()
				else: total_notes += 1
				
			if balloons_popped >= total_notes:
				_on_level_cleared()
			
			if streak % 5 == 0:
				maestro.say("good_job")
			return true
	return false

func _handle_groove():
	if streak >= 4:
		SoundManager.play_drum()
	if streak >= 8:
		SoundManager.play_bass()

func _on_level_cleared():
	is_celebrating = true
	GameManager.current_level_index += 1
	GameManager.save_game()
	level_clear_label.text = "LEVEL " + str(GameManager.current_level_index) + " CLEARED!"
	continue_button.text = "CONTINUE"
	level_clear_panel.visible = true

func _spawn_celebration_balloon():
	if randf() > 0.85:
		var x = randf_range(0, 1280)
		var b = balloon_scene.instantiate()
		add_child(b)
		var colors = [Color.RED, Color.YELLOW, Color.CYAN, Color.MAGENTA, Color.ORANGE, Color.LIME_GREEN, Color.DEEP_SKY_BLUE]
		b.setup(0, Vector2(x, 750), randf_range(250, 500), false)
		b.direction = Vector2.UP
		b.drift_x = randf_range(-50, 50)
		b.panel.self_modulate = colors.pick_random()
		active_balloons.append(b)

func _spawn_projectile(note: int, target_pos: Vector2):
	if keyboard.keys.has(note):
		var key = keyboard.keys[note]
		var start_pos = key.global_position + Vector2(key.size.x / 2.0, 0)
		var script = load("res://scripts/note_projectile.gd")
		var projectile = Node2D.new()
		projectile.set_script(script)
		add_child(projectile)
		projectile.setup(start_pos, target_pos)

func update_ui():
	var song_name = current_song_data.get("name", "Unknown")
	score_label.text = "Score: " + str(GameManager.score) + " | " + song_name
	
	var total_notes = 0
	for n in current_song_data["notes"]:
		if n is Array: total_notes += n.size()
		else: total_notes += 1
		
	progress_bar.value = float(balloons_popped) / float(total_notes) * 100.0
	lives_label.text = "Lives: %d | Strikes: %d/3" % [lives, strikes]
