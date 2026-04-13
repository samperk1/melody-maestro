extends Node

signal note_on(note_index: int)
signal note_off(note_index: int)

var use_midi: bool = true
var use_computer_keyboard: bool = false
var analyzer: AudioEffectSpectrumAnalyzerInstance

# Map keys to notes (starting at C4 = 60)
# White keys (Home row): A=C4, S=D4, D=E4, F=F4, G=G4, H=A4, J=B4, K=C5, L=D5, Semicolon=E5
# Black keys (QWERTY row): W=C#4, E=D#4, T=F#4, Y=G#4, U=A#4, O=C#5, P=D#5
const KEY_TO_NOTE = {
	KEY_A: 60, # C4
	KEY_W: 61, # C#4
	KEY_S: 62, # D4
	KEY_E: 63, # D#4
	KEY_D: 64, # E4
	KEY_F: 65, # F4
	KEY_T: 66, # F#4
	KEY_G: 67, # G4
	KEY_Y: 68, # G#4
	KEY_H: 69, # A4
	KEY_U: 70, # A#4
	KEY_J: 71, # B4
	KEY_K: 72, # C5
	KEY_O: 73, # C#5
	KEY_L: 74, # D5
	KEY_P: 75, # D#5
	KEY_SEMICOLON: 76, # E5
}

var pressed_keys = {}

func _ready():
	print("[InputHandler] Initializing...")
	# MIDI setup
	if OS.has_feature("midi") or OS.get_name() == "Linux":
		OS.open_midi_inputs()
		print("[InputHandler] MIDI inputs opened. Connected devices: ", OS.get_connected_midi_inputs())
	else:
		print("[InputHandler] MIDI feature not reported by OS.")
	
	_setup_analyzer()

func _setup_analyzer():
	var bus_index = AudioServer.get_bus_index("Record")
	if bus_index != -1:
		for i in range(AudioServer.get_bus_effect_count(bus_index)):
			var effect = AudioServer.get_bus_effect(bus_index, i)
			if effect is AudioEffectSpectrumAnalyzer:
				analyzer = AudioServer.get_bus_effect_instance(bus_index, i)
				print("[InputHandler] Spectrum Analyzer linked.")
				break

func _input(event):
	if event is InputEventMIDI:
		print("[InputHandler] MIDI Event: msg=%d pitch=%d vel=%d channel=%d" % [event.message, event.pitch, event.velocity, event.channel])
		if not use_midi: return
		
		# MIDIMessage.NOTE_ON is 9
		if event.message == 9:
			if event.velocity > 0:
				note_on.emit(event.pitch)
			else:
				note_off.emit(event.pitch)
		# MIDIMessage.NOTE_OFF is 8
		elif event.message == 8:
			note_off.emit(event.pitch)
	
	elif event is InputEventKey and use_computer_keyboard:
		if event.is_echo(): return # Ignore key repeats
		
		if KEY_TO_NOTE.has(event.keycode):
			var note = KEY_TO_NOTE[event.keycode]
			if event.pressed:
				if not pressed_keys.has(event.keycode):
					pressed_keys[event.keycode] = true
					note_on.emit(note)
			else:
				if pressed_keys.has(event.keycode):
					pressed_keys.erase(event.keycode)
					note_off.emit(note)

var last_mic_note: int = -1
var mic_timer: float = 0.0
const MIC_THRESHOLD = -40.0 # dB

func _process(delta):
	if use_midi or use_computer_keyboard or not analyzer: return
	
	mic_timer += delta
	if mic_timer < 0.05: return # Limit sampling rate
	mic_timer = 0.0

	var freq = _get_dominant_frequency()
	if freq > 0:
		var note = int(round(69.0 + 12.0 * log(freq / 440.0) / log(2.0)))
		if note >= 21 and note <= 108: # Standard piano range
			if note != last_mic_note:
				if last_mic_note != -1:
					note_off.emit(last_mic_note)
				note_on.emit(note)
				last_mic_note = note
	else:
		if last_mic_note != -1:
			note_off.emit(last_mic_note)
			last_mic_note = -1

func _get_dominant_frequency() -> float:
	var max_mag = -100.0
	var dom_freq = 0.0
	
	# Sample common piano range: ~27Hz to ~4186Hz
	for i in range(10, 200): 
		var f_min = i * 20.0
		var f_max = (i + 1) * 20.0
		var mag = analyzer.get_magnitude_for_frequency_range(f_min, f_max).length()
		mag = linear_to_db(mag)
		
		if mag > max_mag:
			max_mag = mag
			dom_freq = (f_min + f_max) / 2.0
			
	if max_mag > MIC_THRESHOLD:
		return dom_freq
	return 0.0

func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)
