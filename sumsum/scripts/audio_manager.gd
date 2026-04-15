extends Node

## Procedural audio: chiptune SFX and background music.
## All sounds generated at startup — no external files needed.

var sounds: Dictionary = {}  # name → AudioStreamWAV
var _music_stream: AudioStreamWAV
var _music_player: AudioStreamPlayer

var music_volume_db: float = -12.0
var sfx_volume_db: float = -6.0
var music_enabled := true
var sfx_enabled := true

const SAMPLE_RATE := 22050

func _ready() -> void:
	_generate_sfx()
	_generate_music()

	_music_player = AudioStreamPlayer.new()
	_music_player.stream = _music_stream
	_music_player.volume_db = music_volume_db
	add_child(_music_player)

# --- Public API ---

func play_sfx(sfx_name: String) -> void:
	if not sfx_enabled or not sounds.has(sfx_name):
		return
	var player := AudioStreamPlayer.new()
	player.stream = sounds[sfx_name]
	player.volume_db = sfx_volume_db
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_music() -> void:
	if music_enabled and not _music_player.playing:
		_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func toggle_music() -> void:
	music_enabled = not music_enabled
	if music_enabled:
		play_music()
	else:
		stop_music()

func toggle_sfx() -> void:
	sfx_enabled = not sfx_enabled

# --- Sound generation ---

func _generate_sfx() -> void:
	sounds["place"] = _make_tone(660.0, 0.06, 0.3, "sine", 0.005, 0.03)
	sounds["delete"] = _make_sweep(440.0, 220.0, 0.12, 0.25, "triangle")
	sounds["rotate"] = _make_tone(550.0, 0.05, 0.2, "sine", 0.005, 0.02)
	sounds["compute"] = _make_arpeggio([523.0, 659.0], 0.08, 0.25, "square")
	sounds["win"] = _make_arpeggio([523.0, 659.0, 784.0, 1047.0], 0.15, 0.3, "square")
	sounds["error"] = _make_tone(150.0, 0.2, 0.2, "square", 0.01, 0.1)
	sounds["arrive"] = _make_tone(880.0, 0.03, 0.1, "sine", 0.003, 0.015)

func _make_tone(freq: float, duration: float, volume: float,
		wave: String = "sine", attack: float = 0.01, release: float = 0.05) -> AudioStreamWAV:
	var num_samples := int(duration * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(num_samples * 2)
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var sample: float = _oscillator(wave, freq, t) * volume
		sample *= _envelope(t, duration, attack, release)
		_write_sample(data, i, sample)
	return _make_stream(data)

func _make_sweep(freq_start: float, freq_end: float, duration: float,
		volume: float, wave: String = "sine") -> AudioStreamWAV:
	var num_samples := int(duration * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(num_samples * 2)
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var progress: float = t / duration
		var freq: float = lerpf(freq_start, freq_end, progress)
		var sample: float = _oscillator(wave, freq, t) * volume
		sample *= _envelope(t, duration, 0.005, duration * 0.4)
		_write_sample(data, i, sample)
	return _make_stream(data)

func _make_arpeggio(freqs: Array, note_dur: float, volume: float,
		wave: String = "square") -> AudioStreamWAV:
	var total_dur: float = note_dur * freqs.size()
	var num_samples := int(total_dur * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(num_samples * 2)
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var note_idx: int = mini(int(t / note_dur), freqs.size() - 1)
		var note_t: float = fmod(t, note_dur)
		var freq: float = freqs[note_idx]
		var sample: float = _oscillator(wave, freq, t) * volume
		sample *= _envelope(note_t, note_dur, 0.005, note_dur * 0.3)
		_write_sample(data, i, sample)
	return _make_stream(data)

# --- Music generation ---

func _generate_music() -> void:
	var bpm := 110.0
	var beats := 32  # 8 bars of 4/4
	var beat_dur: float = 60.0 / bpm
	var total_dur: float = beats * beat_dur
	var num_samples := int(total_dur * SAMPLE_RATE)

	# Pentatonic scale (C major pentatonic)
	var melody_notes := [523.0, 587.0, 659.0, 784.0, 880.0, 1047.0]
	# Melody pattern (index into scale, per eighth note)
	var melody := [
		0, -1, 2, -1, 4, -1, 3, -1,  2, -1, 0, -1, 1, -1, 2, -1,
		3, -1, 4, -1, 5, -1, 4, -1,  2, -1, 3, -1, 1, -1, 0, -1,
		0, -1, 1, -1, 2, -1, 4, -1,  3, -1, 2, -1, 0, -1, 1, -1,
		2, -1, 3, -1, 4, -1, 2, -1,  1, -1, 0, -1, 2, -1, 0, -1,
	]
	# Bass notes (per beat)
	var bass := [
		131.0, 131.0, 196.0, 196.0,  165.0, 165.0, 196.0, 196.0,
		175.0, 175.0, 196.0, 196.0,  131.0, 131.0, 196.0, 196.0,
		131.0, 131.0, 196.0, 196.0,  165.0, 165.0, 196.0, 196.0,
		175.0, 175.0, 131.0, 131.0,  196.0, 196.0, 131.0, 131.0,
	]

	var eighth_dur: float = beat_dur / 2.0
	var data := PackedByteArray()
	data.resize(num_samples * 2)

	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var beat: float = t / beat_dur
		var eighth: int = int(t / eighth_dur) % melody.size()
		var beat_idx: int = int(beat) % bass.size()

		# Melody (square wave, quiet)
		var mel_sample := 0.0
		var mel_idx: int = melody[eighth]
		if mel_idx >= 0:
			var mel_freq: float = melody_notes[mel_idx]
			mel_sample = _oscillator("square", mel_freq, t) * 0.06
			# Per-note envelope
			var note_pos: float = fmod(t, eighth_dur)
			mel_sample *= _envelope(note_pos, eighth_dur, 0.005, eighth_dur * 0.4)

		# Bass (triangle wave)
		var bass_freq: float = bass[beat_idx]
		var bass_sample: float = _oscillator("triangle", bass_freq, t) * 0.08
		var bass_pos: float = fmod(t, beat_dur)
		bass_sample *= _envelope(bass_pos, beat_dur, 0.01, beat_dur * 0.3)

		var sample: float = mel_sample + bass_sample
		_write_sample(data, i, sample)

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = num_samples
	_music_stream = stream

# --- Low-level helpers ---

func _oscillator(wave: String, freq: float, t: float) -> float:
	var phase: float = fmod(freq * t, 1.0)
	match wave:
		"sine":
			return sin(TAU * freq * t)
		"square":
			return 1.0 if fmod(freq * t, 1.0) < 0.5 else -1.0
		"triangle":
			return asin(sin(TAU * freq * t)) * 2.0 / PI
		"noise":
			# Deterministic noise based on sample position
			return fmod(sin(t * 12345.6789 + freq) * 43758.5453, 1.0) * 2.0 - 1.0
	return 0.0

func _envelope(t: float, duration: float, attack: float, release: float) -> float:
	if t < attack:
		return t / attack if attack > 0.0 else 1.0
	if t > duration - release:
		return (duration - t) / release if release > 0.0 else 0.0
	return 1.0

func _write_sample(data: PackedByteArray, idx: int, sample: float) -> void:
	var s16: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
	data[idx * 2] = s16 & 0xFF
	data[idx * 2 + 1] = (s16 >> 8) & 0xFF

func _make_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.data = data
	return stream
