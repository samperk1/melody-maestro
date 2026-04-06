extends Control

@onready var dialogue_label = $Panel/DialogueLabel
@onready var animation_player = $AnimationPlayer

var dialogues = {
	"welcome": "Welcome, Maestro! I am your muse. Ready to play some piano?",
	"good_job": "Excellent timing! You've got the rhythm!",
	"missed": "Don't worry, keep trying! The music is in you.",
	"groove_start": "I'm feeling the groove! Let's add some drums!",
}

func say(key: String):
	if dialogues.has(key):
		dialogue_label.text = dialogues[key]
		# animation_player.play("talk")
