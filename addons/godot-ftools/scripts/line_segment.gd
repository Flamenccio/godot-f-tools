class_name FTool_LineSegment
extends RefCounted
## Represents a line [code]AB[/code] that pass through two points.
##
## Define the line by setting [member point_a] and [member point_b].

var point_a := Vector2.ZERO
var point_b := Vector2.ZERO


## Returns the slope of the line passing through [member point_a] and [member point_b].
## If the slope is a vertical line, returns [code]NAN[/code].
func get_slope() -> float:
	return (point_b.y - point_a.y) / (point_b.x - point_a.x)


## Returns the inverted slope of the line passing through [code]point_a[/code] and [code]point_b[/code].
## If the slope is a horizontal line, returns [code]NAN[/code].
func get_inverted_slope() -> float:
	return (point_b.x - point_a.x) / (point_b.y - point_a.y)


## Returns the y-intercept of the line passing through [param point_a] and [param point_b].
func get_y_intercept() -> float:
	return (point_a.y - get_slope() * point_a.x)


## Returns the x-intercept of the line passing through [param point_a] and [param point_b].
func get_x_intercept() -> float:
	return (point_a.x - get_inverted_slope() * point_a.y)


## Returns [code]true[/code] if this line and [param line] intersect,
## [code]false[/code] otherwise.[br]
func intersects_line(line: FTool_LineSegment) -> bool:
	return intersects_line_from_points(line.point_a, line.point_b)


## Returns [code]true[/code] if this line and the line [code]CD[/code] intersect.
func intersects_line_from_points(point_c: Vector2, point_d: Vector2) -> bool:
	var a1 = point_a
	var a2 = point_b
	var b1 = point_c
	var b2 = point_d
	var det = (a2.x - a1.x) * -(b2.y - b1.y) - -(b2.x - b1.x) * (a2.y - a1.y)
	var det_t = (b1.x - a1.x) * -(b2.y - b1.y) - -(b2.x - b1.x) * (b1.y - a1.y)
	var det_u = (a2.x - a1.x) * (b1.y - a1.y) - (b1.x - a1.x) * (a2.y - a1.y)
	var t = det_t / det
	var u = det_u / det
	return t >= 0 and t <= 1 and u >= 0 and u <= 1


## Returns the intersection point between this line and [param line].
## Make sure to verify if the lines intersect using [method intersects_line].
func get_intersection_point(line: FTool_LineSegment) -> Vector2:
	return get_intersection_point_from_points(line.point_a, line.point_b)


## Returns the intersection point of this line and line [code]CD[/code].
## Make sure to verify if the lines intersect using [code]intersects_line[/code].
func get_intersection_point_from_points(point_c: Vector2, point_d: Vector2) -> Vector2:
	var a1 = point_a
	var a2 = point_b
	var b1 = point_c
	var b2 = point_d
	var det = (a2.x - a1.x) * -(b2.y - b1.y) - -(b2.x - b1.x) * (a2.y - a1.y)
	var det_t = (b1.x - a1.x) * -(b2.y - b1.y) - -(b2.x - b1.x) * (b1.y - a1.y)
	var det_u = (a2.x - a1.x) * (b1.y - a1.y) - (b1.x - a1.x) * (a2.y - a1.y)
	var t = det_t / det
	var u = det_u / det
	return Vector2(a1.x + t * (a2.x - a1.x), a1.y + t * (a2.y - a1.y))

