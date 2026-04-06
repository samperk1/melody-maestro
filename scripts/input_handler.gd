extends Node

signal note_on(note_index: int)
signal note_off(note_index: int)

var use_midi: bool = true
var analyzer: AudioEffectSpectrumAnalyzerInstance

func _ready():
	# MIDI setup
	OS.open_midi_inputs()
	
	# Audio setup (Spectrum Analyzer should be on Bus "Record" or similar)
	var bus_index = AudioServer.get_bus_index("Record")
	if bus_index != -1:
		analyzer = AudioServer.get_bus_effect_instance(bus_index, 0)

func _input(event):
	if not use_midi: return
	
	if event is InputEventMIDI:
		if event.message == MIDI_MESSAGE_NOTE_ON:
			note_on.emit(event.pitch)
		elif event.message == MIDI_MESSAGE_NOTE_OFF:
			note_off.emit(event.pitch)

func _process(_delta):
	if use_midi or not analyzer: return
	
	# Simple pitch detection logic (Very basic)
	# In a real scenario, this would involve autocorrelation or better FFT analysis
	var freq = _get_peak_frequency()
	if freq > 0:
		var note = _freq_to_midi(freq)
		# emit note_on/off based on threshold
		pass

func _get_peak_frequency() -> float:
	# This is a placeholder for actual FFT analysis
	return 0.0

func _freq_to_midi(f: float) -> int:
	return int(round(69 + 12 * log(f / 440.0) / log(2)))
