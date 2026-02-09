@tool
class_name FTool_AudioBank
extends Resource

signal bank_updated()

@export var audio_bank: Array[FTool_AudioBankData]

func self_start() -> void:
	_check_files()
	EditorInterface.get_file_system_dock().file_removed.connect(_on_file_system_dock_file_removed)

func add_audio_data(stream: AudioStream, audio_id: String) -> void:
	if audio_bank.any(_match_audio_id.bind(audio_id)):
		push_warning("Could not add audio with ID '{0}': ID already taken.".format({"0": audio_id}))
		return
	var new_data = FTool_AudioBankData.new()
	new_data.audio_stream = stream
	new_data.audio_id = audio_id
	audio_bank.append(new_data)
	bank_updated.emit()

func remove_audio_data(audio_id: String) -> void:
	var idx = audio_bank.find_custom(_match_audio_id.bind(audio_id))
	if idx < 0:
		push_error("Could not remove audio with ID '{0}': doesn't exist.".format({"0": audio_id}))
		return
	audio_bank.remove_at(idx)
	bank_updated.emit()

func get_audio_data(audio_id: String) -> FTool_AudioBankData:
	var idx = audio_bank.find_custom(_match_audio_id.bind(audio_id))
	if idx < 0:
		push_error("Could not retrieve audio with ID '{0}': doesn't exist.".format({"0": audio_id}))
		return null
	return audio_bank[idx]

func get_audio_stream(audio_id: StringName) -> AudioStream:
	var idx = audio_bank.find_custom(_match_audio_id.bind(audio_id))
	if idx < 0:
		push_error("Could not retrieve audio with ID '{0}': doesn't exist.".format({"0": audio_id}))
		return null
	return audio_bank[idx].audio_stream

func is_audio_file_added(path: String) -> bool:
	return audio_bank.any(func(a: FTool_AudioBankData): 
		return a.audio_stream.resource_path == path
	)

func _check_files() -> void:
	var cleaned: Array[FTool_AudioBankData]
	#print("size: ", audio_bank.size())
	for i in range(audio_bank.size()):
		#print("{0}: {1}".format({"0": i, "1": audio_bank[i]}))
		#print("{0}: {1}".format({"0": i, "1": audio_bank[i].get("audio_stream")}))
		var current = audio_bank[i]
		if current != null and current.audio_stream != null and \
				not current.audio_stream.resource_path.is_empty():
			cleaned.append(current)
	audio_bank.assign(cleaned)
	ResourceSaver.save(self, resource_path)
	bank_updated.emit()

func _match_audio_id(bank_data: FTool_AudioBankData, id: String, ) -> bool:
	return id == bank_data.audio_id

func _on_file_system_dock_file_removed(_file_path: String) -> void:
	_check_files()
