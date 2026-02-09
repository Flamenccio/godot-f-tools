extends Node

const _CACHE_DIRECTORY = "res://addons/godot-ftools/cache/"
const _BANK_FILE = "audio_bank.res"

const _MAIN_POLYPHONY = 32

var _main_player: AudioStreamPlayer
var _audio_bank: FTool_AudioBank
var _positional_players: Array[AudioStreamPlayer2D]

func _ready() -> void:

	# Load audio bank
	var full_path := _CACHE_DIRECTORY.path_join(_BANK_FILE)
	if not FileAccess.file_exists(full_path):
		push_error("Unable to load sounds: no audio bank exists!")
		return
	
	_audio_bank = load(full_path)
	_main_player = AudioStreamPlayer.new()
	_main_player.max_polyphony = _MAIN_POLYPHONY
	add_child(_main_player)

func _exit_tree() -> void:
	ResourceSaver.save(_audio_bank, _CACHE_DIRECTORY.path_join(_BANK_FILE))

## Plays non-positional audio from [code]from[/code] seconds.
func play_audio(audio_id: String, bus: StringName, from := 0.0, to := -1.0) -> void:
	var stream = _audio_bank.get_audio_stream(audio_id)
	if not _main_player.has_stream_playback():
		var poly_stream = AudioStreamPolyphonic.new()
		_main_player.stream = poly_stream
		_main_player.play()
	var playback := _main_player.get_stream_playback()
	playback.play_stream(stream, from, 0.0, 1.0, 0, bus)

## Plays positional audio at global position [code]at[/code], and from [code]from[/code] seconds.[br]
## if [code]custom_parent[/code] is set, attempts to add the audio player as a child of [code]custom_parent[/code].
func play_audio_at(at: Vector2, audio_id: String, bus: StringName, from := 0.0, custom_parent: Node2D = null) -> void:

	var new_player := AudioStreamPlayer2D.new()
	var stream := _audio_bank.get_audio_stream(audio_id)
	new_player.stream = stream
	new_player.global_position = at

	if custom_parent != null:
		custom_parent.call_deferred("add_child", new_player)
	else:
		add_child(new_player)
	_positional_players.append(new_player)
	new_player.play(from)
	new_player.finished.connect(_on_positional_player_finished.bind(new_player))

func _on_positional_player_finished(player: AudioStreamPlayer2D) -> void:
	player.queue_free()
	_positional_players.erase(player)

static func get_audio_id(audio_file: AudioStream) -> String:
	if audio_file == null:
		push_error("Audio file is null")
		return ""
	var p := audio_file.resource_path
	if p.is_empty():
		push_error("Audio file {0} does not have a valid path".format({"0": audio_file}))
		return ""
	return p