extends Node

var players = []
var max_players = 48
var beep_stream: AudioStreamWAV
var pop_stream: AudioStreamWAV
var maestro_stream: AudioStreamWAV
var drum_stream: AudioStreamWAV
var bass_stream: AudioStreamWAV

func _ready():
	print("[SoundManager] Initializing sound engine...")
	_generate_beep()
	_generate_pop()
	_generate_maestro_voice()
	_generate_drum_beat()
	_generate_bass_pulse()
	
	for i in range(max_players):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		players.append(p)

func _generate_beep():
	var sample_rate = 44100
	var duration = 0.4
	var freq = 440.0
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var decay = exp(-4.0 * float(i) / num_samples)
		var s1 = sin(i * freq * TAU / sample_rate)
		var s2 = sin(i * freq * 2.0 * TAU / sample_rate) * 0.5
		var value = int((s1 + s2) * 10000 * decay)
		data.encode_s16(i * 2, value)
	
	beep_stream = AudioStreamWAV.new()
	beep_stream.data = data
	beep_stream.format = AudioStreamWAV.FORMAT_16_BITS
	beep_stream.mix_rate = sample_rate

func _generate_pop():
	var sample_rate = 44100
	var duration = 0.1
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var decay = 1.0 - float(i) / num_samples
		var value = int((randf() * 2.0 - 1.0) * 12000 * decay)
		data.encode_s16(i * 2, value)
	
	pop_stream = AudioStreamWAV.new()
	pop_stream.data = data
	pop_stream.format = AudioStreamWAV.FORMAT_16_BITS
	pop_stream.mix_rate = sample_rate

func _generate_maestro_voice():
	var sample_rate = 44100
	var duration = 0.15
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var f1 = 440.0
		var s1 = sin(i * f1 * TAU / sample_rate)
		var s2 = sin(i * f1 * 1.5 * TAU / sample_rate) * 0.5
		var s3 = (randf() * 2.0 - 1.0) * 0.1
		
		var value = int((s1 + s2 + s3) * 8000)
		var env = sin(float(i) / num_samples * PI)
		data.encode_s16(i * 2, int(value * env))
	
	maestro_stream = AudioStreamWAV.new()
	maestro_stream.data = data
	maestro_stream.format = AudioStreamWAV.FORMAT_16_BITS
	maestro_stream.mix_rate = sample_rate

func _generate_drum_beat():
	var sample_rate = 44100
	var duration = 0.1
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	for i in range(num_samples):
		# Kick-like sound
		var freq = 100.0 * (1.0 - float(i) / num_samples)
		var value = int(sin(i * freq * TAU / sample_rate) * 15000 * (1.0 - float(i) / num_samples))
		data.encode_s16(i * 2, value)
	drum_stream = AudioStreamWAV.new()
	drum_stream.data = data
	drum_stream.format = AudioStreamWAV.FORMAT_16_BITS
	drum_stream.mix_rate = sample_rate

func _generate_bass_pulse():
	var sample_rate = 44100
	var duration = 0.2
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	for i in range(num_samples):
		var freq = 55.0 # Low A
		var value = int(sin(i * freq * TAU / sample_rate) * 12000 * exp(-2.0 * float(i) / num_samples))
		data.encode_s16(i * 2, value)
	bass_stream = AudioStreamWAV.new()
	bass_stream.data = data
	bass_stream.format = AudioStreamWAV.FORMAT_16_BITS
	bass_stream.mix_rate = sample_rate

func play_note(midi_note: int):
	var freq = 440.0 * pow(2.0, (midi_note - 69.0) / 12.0)
	var player = _get_free_player()
	player.stream = beep_stream
	player.pitch_scale = freq / 440.0
	player.play()

func play_pop():
	var player = _get_free_player()
	player.stream = pop_stream
	player.pitch_scale = randf_range(0.9, 1.1)
	player.play()

func play_maestro_voice():
	var player = _get_free_player()
	player.stream = maestro_stream
	var pitch = 0.8 + (randf() * 0.6)
	player.pitch_scale = pitch
	player.play()

func play_drum():
	var player = _get_free_player()
	player.stream = drum_stream
	player.play()

func play_bass():
	var player = _get_free_player()
	player.stream = bass_stream
	player.play()

func _get_free_player():
	for p in players:
		if not p.playing:
			return p
	return players[0]
