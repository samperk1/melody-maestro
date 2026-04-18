extends Node

var player_name: String = "Maestro"
var input_type: String = "MIDI Keyboard"
var keys_count: int = 88
var score: int = 0
var current_level_index: int = 0
var leaderboard: Array = []  # [{name, score}, ...] top 3 sorted descending

const SAVE_PATH = "user://save_game.dat"

# 30 songs — levels 0-29 each get a unique piece, loosely ordered easy→hard
var songs = [
	# ── BEGINNER (0-4) ──────────────────────────────────────────────────────
	{
		"name": "Mary Had a Little Lamb",
		"notes": [64,62,60,62,64,64,64,62,62,62,64,67,67,64,62,60,62,64,64,64,64,62,62,64,62,60],
		"type": "balloon"
	},
	{
		"name": "Twinkle Twinkle Little Star",
		"notes": [60,60,67,67,69,69,67,65,65,64,64,62,62,60,67,67,65,65,64,64,62,67,67,65,65,64,64,62,60,60,67,67,69,69,67,65,65,64,64,62,62,60],
		"type": "balloon"
	},
	{
		"name": "Hot Cross Buns",
		"notes": [64,62,60,64,62,60,60,60,60,60,62,62,62,62,64,62,60],
		"type": "balloon"
	},
	{
		"name": "Row Row Row Your Boat",
		"notes": [60,60,60,62,64,64,62,64,65,67,72,72,72,67,67,67,64,64,64,60,60,60,67,65,64,62,60],
		"type": "balloon"
	},
	{
		"name": "Old MacDonald Had a Farm",
		"notes": [67,67,67,62,64,64,62,71,71,69,69,67,62,67,67,67,62,64,64,62,71,71,69,69,67],
		"type": "balloon"
	},
	# ── EASY (5-9) ──────────────────────────────────────────────────────────
	{
		"name": "Fly Me to the Moon  (Jazz)",
		"notes": [69,64,69,71,72,69,67,64,62,64,65,64,62,60,59,59,64,59,64,66,67,64,62,59,60,62,64,62,60,59,57,57],
		"type": "balloon"
	},
	{
		"name": "Jingle Bells",
		"notes": [64,64,64,64,64,64,64,67,60,62,64,65,65,65,65,65,64,64,64,64,62,62,64,62,67],
		"type": "balloon"
	},
	{
		"name": "You Are My Sunshine",
		"notes": [60,64,67,67,67,67,69,67,64,60,60,64,67,67,67,67,69,67,64,64,64,67,69,69,69,69,72,69,67,64,67,67,64,64,62,64,60],
		"type": "balloon"
	},
	{
		"name": "Havana  (Camila Cabello)",
		"notes": [67,70,72,70,67,65,63,65,67,70,72,70,67,65,63,72,70,67,65,63,65,67,70,72,70,67,65,63,65],
		"type": "balloon"
	},
	{
		"name": "Shape of You  (Ed Sheeran)",
		"notes": [69,69,67,64,67,69,67,64,65,65,64,60,64,65,64,60,65,65,64,60,64,65,67,69,69,67,64,67,69],
		"type": "balloon"
	},
	# ── INTERMEDIATE (10-14) ────────────────────────────────────────────────
	{
		"name": "Amazing Grace",
		"notes": [67,72,76,72,76,74,72,69,72,76,79,76,76,72,76,74,72,69,67,67,72,76],
		"type": "balloon"
	},
	{
		"name": "Ode to Joy",
		"notes": [64,64,65,67,67,65,64,62,60,60,62,64,64,62,62,64,64,65,67,67,65,64,62,60,60,62,64,62,60,60],
		"type": "balloon"
	},
	{
		"name": "Minuet in G  (Bach)",
		"notes": [74,67,69,71,72,74,67,67,76,72,74,76,78,79,67,67,72,74,72,71,69,71,72,71,69,67,66,67,69,71,67,69,62,62],
		"type": "balloon"
	},
	{
		"name": "Greensleeves",
		"notes": [57,60,62,64,65,64,62,59,55,57,59,60,57,60,64,65,67,65,64,62,65,69,69,67,65,64,67,59,59,57],
		"type": "balloon"
	},
	{
		"name": "Fur Elise  (Beethoven)",
		"notes": [76,75,76,75,76,71,74,72,69,60,64,69,71,64,68,71,72,76,75,76,75,76,71,74,72,69,60,64,69,71,72,71,69],
		"type": "balloon"
	},
	# ── ADVANCED (15-19) ────────────────────────────────────────────────────
	{
		"name": "Moonlight Sonata  (Beethoven)",
		"notes": [73,71,69,68,69,71,73,74,76,74,73,71,69,68,66,64,66,68,69,71,73,71,69,68,69],
		"type": "balloon"
	},
	{
		"name": "Turkish March  (Mozart)",
		"notes": [69,68,69,68,69,64,68,71,69,60,64,69,71,64,68,71,76,69,68,69,68,69],
		"type": "balloon"
	},
	{
		"name": "Eine Kleine Nachtmusik  (Mozart)",
		"notes": [79,78,76,74,79,78,76,74,79,74,71,67,74,72,71,69,74,72,71,69,74,69,66,62,67,69,71,72,74,79,79],
		"type": "balloon"
	},
	{
		"name": "Canon in D  (Pachelbel)",
		"notes": [78,76,74,73,71,69,71,73,74,73,71,69,67,66,67,69,71,69,67,66,64,66,67,69,74,76,78,79,81,83,81,79],
		"type": "balloon"
	},
	{
		"name": "Spring  (Vivaldi)",
		"notes": [64,66,68,64,64,66,68,64,68,69,71,68,69,71,71,73,71,69,68,69,68,66,64],
		"type": "monster"
	},
	# ── EXPERT (20-24) ──────────────────────────────────────────────────────
	{
		"name": "Imperial March  (Star Wars)",
		"notes": [67,67,67,63,70,67,63,70,67,74,74,74,75,70,66,63,70,67,79,67,67,79,78,77,76,75],
		"type": "monster"
	},
	{
		"name": "Super Mario Bros Theme",
		"notes": [76,76,76,72,76,79,67,72,67,64,69,71,70,69,67,76,79,81,77,79,76,72,74,71],
		"type": "monster"
	},
	{
		"name": "Tetris Theme  (Korobeiniki)",
		"notes": [76,71,72,74,72,71,69,69,72,76,74,72,71,72,74,76,72,69,69,74,77,81,79,77,76,72,76,74,72,71,71,72,74,76,72,69,69],
		"type": "monster"
	},
	{
		"name": "Hedwig's Theme  (Harry Potter)",
		"notes": [71,76,79,78,76,83,81,78,81,80,73,76,79,78,75,83,71,71,77,81,84,83,81,76,74,72,76,74,72,71],
		"type": "monster"
	},
	{
		"name": "Pirates of the Caribbean",
		"notes": [62,64,65,67,69,70,69,67,65,67,69,62,64,65,67,69,67,65,64,65,67,69,67,65,64,62,64,65,64,65,67,69,70,69],
		"type": "monster"
	},
	# ── MASTER (25-29) ──────────────────────────────────────────────────────
	{
		"name": "Game of Thrones Theme",
		"notes": [67,60,63,65,67,60,63,65,68,67,60,67,60,63,65,67,60,63,65,65,67,63,60],
		"type": "monster"
	},
	{
		"name": "Hotline Bling  (Drake)",
		"notes": [62,65,67,69,67,65,62,62,62,65,67,69,67,65,62,62,65,67,69,67,65,62,62,65,67,69,65,62,62,62],
		"type": "monster"
	},
	{
		"name": "Beethoven's 5th Symphony",
		"notes": [67,67,67,63,65,65,65,62,67,67,67,63,65,65,65,62,63,63,63,60,62,62,62,58,67,67,67,63,65,65,65,62],
		"type": "monster"
	},
	{
		"name": "Flight of the Bumblebee  (Rimsky-Korsakov)",
		"notes": [71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,53,52,67,66,65,64,63,62,61,60],
		"type": "monster"
	},
	{
		"name": "Autumn Leaves  (Jazz)",
		"notes": [64,69,74,67,60,59,57,55,64,69,74,67,60,59,59,67,72,65,58,63,62,55,55,64,69,74,67,60,59,57,55],
		"type": "monster"
	},
]

func _ready():
	load_game()

func goto_game(from: Node):
	print("GOTO_GAME called")
	from.hide()
	var new_scene = load("res://scenes/main_game.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	from.queue_free()

func goto_menu(from: Node):
	get_tree().paused = false
	from.hide()
	var new_scene = load("res://scenes/welcome_screen.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	from.queue_free()

func reset_game():
	score = 0
	current_level_index = 0

func get_current_song():
	if current_level_index < songs.size():
		return songs[current_level_index]

	# Beyond the song library: gradually introduce chords
	var beyond = current_level_index - songs.size()
	return {
		"name": "Expert Mode - Level " + str(current_level_index + 1),
		"notes": _generate_progressive_sequence(20, beyond),
		"type": "monster"
	}

# Smoothly ramps up from single notes → intervals → full chords over many levels
func _generate_progressive_sequence(length: int, difficulty: int) -> Array:
	var sequence = []

	# Notes from C major + pentatonic extensions
	var scale = [60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 79, 81]

	# Two-note intervals (minor 3rd, major 3rd, perfect 4th, perfect 5th)
	var intervals = [3, 4, 5, 7]

	# Three-note chords
	var chords = [
		[60, 64, 67], [65, 69, 72], [67, 71, 74],
		[62, 65, 69], [64, 67, 71], [69, 72, 76]
	]

	# interval_prob: 0% at diff 0, peaks at 50% by diff 8
	var interval_prob = clamp(float(difficulty) / 8.0 * 0.5, 0.0, 0.5)
	# chord_prob: 0% until diff 4, rises to 40% by diff 12
	var chord_prob = clamp(float(difficulty - 4) / 8.0 * 0.4, 0.0, 0.4)

	for i in range(length):
		var roll = randf()
		if roll < chord_prob:
			sequence.append(chords.pick_random())
		elif roll < chord_prob + interval_prob:
			var root = scale.pick_random()
			sequence.append([root, root + intervals.pick_random()])
		else:
			sequence.append(scale.pick_random())

	return sequence

func save_game():
	# Add current run to leaderboard, keep top 3
	if score > 0:
		leaderboard.append({"name": player_name, "score": score})
		leaderboard.sort_custom(func(a, b): return a.score > b.score)
		if leaderboard.size() > 3:
			leaderboard.resize(3)

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"leaderboard": leaderboard}))
		file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var data = JSON.parse_string(content)
			if data:
				if data.has("leaderboard"):
					leaderboard = data.get("leaderboard", [])
				elif data.has("high_score"):
					# Migrate old single-entry format
					var hs = data.get("high_score", 0)
					var hp = data.get("high_score_player", "None")
					if hs > 0:
						leaderboard = [{"name": hp, "score": hs}]
			file.close()
