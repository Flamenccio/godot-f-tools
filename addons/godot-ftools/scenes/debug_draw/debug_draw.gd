extends Node2D
## Draws simple geometery intended for testing and debugging. Do not use
## this in the finished project!

signal processed(delta)
signal draw_called()

var _draws: Array[DrawProcess]
var _draws_size := 0

func _process(delta: float) -> void:
	if _draws_size > 0:
		processed.emit(delta)
		queue_redraw()
	else:
		process_mode = Node.PROCESS_MODE_DISABLED

func _draw() -> void:
	draw_called.emit()

## Draw a circle at [code]position[/code] for [code]duration[/code] seconds.
func debug_draw_circle(duration: float, position: Vector2, radius: float, color: Color, filled := true, \
		width := -1.0, antialiased := false) -> void:
	_create_draw_process(func(): 
		draw_circle(to_global(position), radius, color, filled, -1, antialiased), 
		duration
	)

## Draw a rectangle defined by [code]rect[/code] for [code]duration[/code] seconds.
func debug_draw_rect(duration: float, rect: Rect2, color: Color, filled := true, width := -1.0, \
		antialiased := false) -> void:
	_create_draw_process(func():
		draw_rect(rect, color, filled, width, antialiased),
		duration
	)

## Draw an arc at [code]center[/code] for [code]duration[/code] seconds.
func debug_draw_arc(duration: float, center: Vector2, radius: float, start_angle: float, \
		end_angle: float, point_count: int, color: Color, width := -1.0, antialiased := false) -> void:
	_create_draw_process(func():
		draw_arc(center, radius, start_angle, end_angle, point_count, color, width, antialiased),
		duration
	)

## Draw a single-colored polygon defined by [code]points[/code] for [code]duration[/code] seconds.
func debug_draw_colored_polygon(duration: float, points: PackedVector2Array, color: Color, \
		uvs := PackedVector2Array(), texture: Texture2D = null) -> void:
	_create_draw_process(func():
		draw_colored_polygon(points, color, uvs, texture),
		duration
	)

## Draw an ellipse at [code]position[/code] for [code]duration[/code] seconds.
func debug_draw_ellipse(duration: float, position: Vector2, major: float, minor: float, \
		color: Color, filled := true, width := 1.0, antialiased := false) -> void:
	_create_draw_process(func():
		draw_ellipse(position, major, minor, color, filled, width, antialiased),
		duration
	)

## Draw a partial ellipse centered at [code]center[/code] for [code]duration[/code] seconds.
func debug_draw_ellipse_arc(duration: float, center: Vector2, major: float, minor: float, \
		start_angle: float, end_angle: float, point_count: int, color: Color, width := -1.0, \
		antialiased := false) -> void:
	_create_draw_process(func():
		draw_ellipse_arc(center, major, minor, start_angle, end_angle, point_count, color, \
				width, antialiased),
		duration
	)

## Draw a line that passes through points [code]from[/code] and [code]to[/code] 
## for [code]duration[/code] seconds.
func debug_draw_line(duration: float, from: Vector2, to: Vector2, color: Color, \
		width := -1.0, antialiased := false) -> void:
	_create_draw_process(func():
		draw_line(from, to, color, width, antialiased),
		duration
	)

## Draw multiple disconnected lines of the same width and color for [code]duration[/code] seconds.
## For connected lines, see [code]debug_draw_polyline[/code].
func debug_draw_multiline(duration: float, points: PackedVector2Array, color: Color, \
		width := -1.0, antialiased := false) -> void:
	_create_draw_process(func():
		draw_multiline(points, color, width, antialiased),
		duration
	)

## Draw interconnected lines of the same width and color for [code]duration[/code] seconds.
## For disconnected lines, see [code]debug_draw_multiline[/code].
func debug_draw_polyline(duration: float, points: PackedVector2Array, color: Color, \
		width := -1.0, antialiased := false) -> void:
	_create_draw_process(func():
		draw_polyline(points, color, width, antialiased),
		duration
	)

func _create_draw_process(draw_call: Callable, duration: float) -> DrawProcess:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	var new_process := DrawProcess.new()
	new_process.time_to_live = duration
	new_process.draw_call = draw_call
	new_process.destroy = _destroy_process
	processed.connect(new_process.count_down)
	draw_called.connect(new_process.draw_call)
	_draws.append(new_process)
	_draws_size += 1
	return new_process

func _destroy_process(process: DrawProcess) -> void:
	processed.disconnect(process.count_down)
	draw_called.disconnect(process.draw_call)
	queue_redraw()
	_draws_size -= 1
	_draws.erase(process)

class DrawProcess:

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
