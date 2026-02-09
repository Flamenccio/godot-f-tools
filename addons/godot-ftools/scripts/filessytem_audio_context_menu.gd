@tool
class_name FTool_FileSystemAudioContextMenu
extends EditorContextMenuPlugin

const _CACHE_DIRECTORY = "res://addons/godot-ftools/cache/"
const _BANK_FILE = "audio_bank.res"

var audio_bank: FTool_AudioBank

func _popup_menu(paths: PackedStringArray) -> void:

	# If selection has folders, or has only audio files
	var has_audio := false
	var has_folder := false
	for p in paths:
		has_audio = has_audio or p.ends_with(".mp3") or p.ends_with(".wav") or \
				p.ends_with(".ogg")
		has_folder = has_folder or p.ends_with("/")

	if has_audio or has_folder:
		add_context_menu_item("Add audio to audio_bank", _handle_paths)

func _handle_paths(args: Array) -> void:
	for a: String in args:
		# If a folder, call recursively with sub-paths
		if a.ends_with("/"):
			var sub_dirs := Array(DirAccess.get_directories_at(a))
			for i in range(sub_dirs.size()):
				sub_dirs[i] = a.path_join(sub_dirs[i]) + "/"
			var sub_files := Array(DirAccess.get_files_at(a))
			for i in range(sub_files.size()):
				sub_files[i] = a.path_join(sub_files[i])
			sub_dirs.append_array(sub_files)
			_handle_paths(sub_dirs)
			continue
		# Skip if not audio file
		if not a.ends_with(".mp3") and not a.ends_with(".wav") \
				and not a.ends_with(".ogg"):
			continue
		# Skip if audio file is already added
		if audio_bank.is_audio_file_added(a):
			continue
		audio_bank.add_audio_data(load(a), _path_to_id(a))
	ResourceSaver.save(audio_bank, audio_bank.resource_path)

func _path_to_id(path: String) -> String:
	var res := path
	if path.is_absolute_path():
		res = res.trim_prefix("res://")
	res = res.trim_suffix(".mp3")
	res = res.trim_suffix(".wav")
	res = res.trim_suffix(".ogg")
	return res
