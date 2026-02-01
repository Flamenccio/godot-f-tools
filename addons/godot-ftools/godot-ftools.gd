@tool
extends EditorPlugin

const SINGLETON_DEBUG_DRAW = "FTool_DebugDraw"

func _enable_plugin() -> void:
	add_autoload_singleton(SINGLETON_DEBUG_DRAW, "res://addons/godot-ftools/scenes/debug_draw/debug_draw.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton(SINGLETON_DEBUG_DRAW)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
