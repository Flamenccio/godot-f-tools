extends Node2D

func _test_random_point() -> void:
	var v = $FTool_AreaPointGenerator.get_random_area_point()
	#print("RANDOM POINT: " + str(v))
	var s := Sprite2D.new()
	s.texture = load("res://icon.svg")
	s.global_position = v
	add_child(s)
