extends Node2D

func _test_random_point() -> void:
	var v = $FTool_AreaPointGenerator.get_random_area_point()
	FTool_DebugDraw.debug_draw_circle(3.0, v, 2.0, Color.RED)

func _test_debug_draw() -> void:
	FTool_DebugDraw.debug_draw_circle(3.0, Vector2.ZERO, 6.0, Color.RED)

func _test_sound() -> void:
	FTool_AudioManager.play_audio("gain_powerup", "Master")

func _test_arrays() -> void:
	var a: Array[int] = [1, 2, 3]
	var b: Array = [1, 2, "3"]
	print("a == b: ", a == b)

