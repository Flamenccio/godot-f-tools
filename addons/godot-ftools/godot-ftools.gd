@tool
extends EditorPlugin

const SINGLETON_DEBUG_DRAW = "FTool_DebugDraw"
const SINGLETON_AUDIO_MANAGER = "FTool_AudioManager"

const AUDIO_DOCK_SCENE = "res://addons/godot-ftools/scenes/audio_bank_dock/audio_bank_dock.tscn"
const DEBUG_DRAW_SCIRPT = "res://addons/godot-ftools/scenes/debug_draw/debug_draw.gd"
const AUDIO_MANAGER_SCRIPT = "res://addons/godot-ftools/scenes/audio_manager/audio_manager.gd"

const AUDIO_CACHE_DIRECTORY = "res://addons/godot-ftools/cache/"
const AUDIO_BANK_FILE = "audio_bank.res"

var audio_dock: EditorDock
var audio_context_menu: EditorContextMenuPlugin
var audio_bank: FTool_AudioBank

func _enable_plugin() -> void:

	add_autoload_singleton(SINGLETON_DEBUG_DRAW, DEBUG_DRAW_SCIRPT)
	add_autoload_singleton(SINGLETON_AUDIO_MANAGER, AUDIO_MANAGER_SCRIPT)

func _disable_plugin() -> void:
	remove_autoload_singleton(SINGLETON_DEBUG_DRAW)
	remove_autoload_singleton(SINGLETON_AUDIO_MANAGER)

func _enter_tree() -> void:

	# Load audio bank, inject into classes
	var full_path := AUDIO_CACHE_DIRECTORY.path_join(AUDIO_BANK_FILE)
	if not DirAccess.dir_exists_absolute(AUDIO_CACHE_DIRECTORY):
		DirAccess.make_dir_recursive_absolute(AUDIO_CACHE_DIRECTORY)
	if not FileAccess.file_exists(full_path):
		audio_bank = FTool_AudioBank.new()
		ResourceSaver.save(audio_bank, full_path)
	else:
		audio_bank = load(full_path)

	audio_bank.self_start()
	#print("bank: ", audio_bank)

	# Audio dock
	audio_dock = EditorDock.new()
	var dock_scene := preload(AUDIO_DOCK_SCENE).instantiate()
	dock_scene.set("_active", true)
	dock_scene.set("audio_bank", audio_bank)
	audio_dock.add_child(dock_scene)
	audio_dock.title = "FTool Audio Bank"
	audio_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	audio_dock.available_layouts = EditorDock.DOCK_LAYOUT_HORIZONTAL
	add_dock(audio_dock)

	# Audio context menu
	audio_context_menu = FTool_FileSystemAudioContextMenu.new()
	audio_context_menu.set("audio_bank", audio_bank)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, audio_context_menu)

func _exit_tree() -> void:

	# Audio dock
	remove_dock(audio_dock)
	audio_dock.queue_free()

	# Audio context menu
	remove_context_menu_plugin(audio_context_menu)
	audio_context_menu.free.call_deferred()
