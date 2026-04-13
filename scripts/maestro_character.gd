extends Control

@onready var dialogue_label = $Panel/DialogueLabel

var dialogues = {
	"welcome": "Welcome, Maestro! I am your muse. Ready to play some piano?",
	"good_job": "Excellent timing! You've got the rhythm!",
	"missed": "Don't worry, keep trying! The music is in you.",
	"groove_start": "I'm feeling the groove! Let's add some drums!",
}

var is_talking: bool = false

func say(key: String):
	if dialogues.has(key) and not is_talking:
		dialogue_label.text = ""
		var text = dialogues[key]
		_type_out(text)

func _type_out(text: String):
	is_talking = true
	for char in text:
		dialogue_label.text += char
		# Voice sound call removed based on user feedback
		await get_tree().create_timer(0.05).timeout
	is_talking = false
