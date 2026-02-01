class_name FTool_DebugDrawProcess
extends Object

var time_to_live: float
var draw_call: Callable
var destroy: Callable
var is_destroying := false

func count_down(delta: float) -> void:
	if is_destroying:
		return
	if time_to_live <= 0:
		destroy.call(self)
		is_destroying = true
		return
	time_to_live -= delta

