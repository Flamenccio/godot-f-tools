@tool
extends ScrollContainer

var selected_item := -1
var audio_bank: FTool_AudioBank
var _displayed_data: Array[FTool_AudioBankData]

@onready var _item_list := %BankList
@export var _active := false

func _ready() -> void:
	if not _active:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	else:
		process_mode = Node.PROCESS_MODE_PAUSABLE
	audio_bank.bank_updated.connect(update_bank_display)
	update_bank_display()

func update_bank_display() -> void:

	if not _active:
		return

	# Update and add from bank
	var bank := audio_bank.audio_bank
	for i in range(bank.size()):
		if i >= _displayed_data.size(): # Add more
			_item_list.add_item(bank[i].audio_id)
			_displayed_data.append(bank[i])
		else: # Update current
			_item_list.set_item_text(i, bank[i].audio_id)
			_displayed_data[i] = bank[i]

	# Remove trailing	
	for i in range(bank.size(), _displayed_data.size()):
		_item_list.remove_item(i)
	_displayed_data.assign(_displayed_data.slice(0, bank.size()))

func _on_list_item_selected(index: int) -> void:
	if not _active:
		return
	%SaveButton.disabled = false
	%BankItemEditor.visible = true
	%AudioIdLine.text = _displayed_data[index].audio_id
	%FilePathLine.text = _displayed_data[index].audio_stream.resource_path
	selected_item = index

func _on_list_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	if not _active:
		return
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		_deselect_item()

func _on_audio_id_line_text_updated(new_text: String) -> void:
	if _displayed_data.any(func(x: FTool_AudioBankData): return x.audio_id == new_text):
		%SaveButton.disabled = true
	elif %SaveButton.disabled:
		%SaveButton.disabled = false

func _on_save_button_pressed() -> void:
	if selected_item < 0:
		return
	_displayed_data[selected_item].audio_id = %AudioIdLine.text
	_save_audio_bank()
	update_bank_display()

func _on_remove_button_pressed() -> void:
	if selected_item < 0:
		return
	audio_bank.remove_audio_data(_displayed_data[selected_item].audio_id)
	_deselect_item()
	_save_audio_bank()

func _deselect_item() -> void:
	selected_item = -1
	_item_list.deselect_all()
	%BankItemEditor.visible = false
	%AudioIdLine.text = ""
	%FilePathLine.text = ""

func _save_audio_bank() -> void:
	ResourceSaver.save(audio_bank, audio_bank.resource_path)
