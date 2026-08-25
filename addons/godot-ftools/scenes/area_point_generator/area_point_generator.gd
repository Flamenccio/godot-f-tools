@tool
class_name FTool_AreaPointGenerator
extends Node2D
## Generates randomized points in areas composed of [CollisionShape2D]s.
##
## These collision shapes are not actually used for collision, and are used
## as a way to easily edit the areas' shape and position.[br]
## On [method _ready], this node removes its [CollisionShape2D] children.[br]
## For best results, ensure minimal overlap between shapes.[br]

const _META_AREA_POINT_SHAPE = "area_point_shape"

@export_tool_button("Save shapes") var save_shapes_button := save_shapes
@export_tool_button("Create new shape") var create_shape_button := create_shape
@export_tool_button("Clear shapes") var clear_shapes_button := clear_shapes
@export_tool_button("Hide shapes") var hide_shapes_button := hide_shapes
@export_tool_button("Restore shapes") var restore_shapes_button := restore_shapes
@export_storage var shapes: Array[FTool_AreaPointShape]

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		#set_editable_instance(self, true)
		pass

func _ready() -> void:
	if not Engine.is_editor_hint():
		hide_shapes()

## Get a random point in a random shape area.
func get_random_area_point() -> Vector2:
	if get_areas() == 0:
		return global_position
	var r = randi_range(0, get_areas() - 1)
	return get_random_area_point_in_area(r)


## Get a random point in a specific shape area.[br]
## See [method get_areas] to get the number of saved areas.
func get_random_area_point_in_area(area_idx: int) -> Vector2:
	if area_idx >= get_areas():
		return global_position

	var area := shapes[area_idx]
	var selected_shape := area.shape

	# Handle shape types
	# Circle
	if selected_shape is CircleShape2D:
		var a := randf_range(0, 2 * PI)
		var r := randf_range(0, selected_shape.radius)
		return (Vector2.from_angle(a) * r) + self.to_global(area.local_position)

	# Rectangle
	elif selected_shape is RectangleShape2D:
		var half_size = selected_shape.size / 2.0
		return Vector2(randf_range(-half_size.x, half_size.x), randf_range(-half_size.y, half_size.y)) + \
				self.to_global(area.local_position)

	# Concave polygon
	elif selected_shape is ConcavePolygonShape2D:
		var bounds := selected_shape.get_rect()
		var random_y := bounds.position.y - randf_range(-bounds.size.y, 0)

		# Find intersections
		var point_idx := 0
		var segments = selected_shape.segments.size()
		var intersections: Array[Vector2]
		var horizontal_line = FTool_LineSegment.new()
		horizontal_line.point_a = Vector2(bounds.position.x, random_y)
		horizontal_line.point_b = Vector2(bounds.position.x + bounds.size.x, random_y)
		while point_idx < segments:
			var next_point_idx = (point_idx + 1) % segments
			if selected_shape.segments[point_idx] == selected_shape.segments[next_point_idx]:
				point_idx += 1
				continue
			var point_c = selected_shape.segments[point_idx]
			var point_d = selected_shape.segments[next_point_idx]
			if horizontal_line.intersects_line_from_points(point_c, point_d):
				intersections.append(horizontal_line.get_intersection_point_from_points(point_c, point_d))
			point_idx += 1
		
		if intersections.size() <= 1:
			push_warning("Could not find a point in polygon")
			return global_position

		# Find random point
		intersections.sort_custom(func(v_a: Vector2, v_b: Vector2): return v_a.x < v_b.x)
		var pairs := floori(intersections.size() / 2.0)
		var pair := randi_range(0, pairs - 1.0)
		var random_x = randf_range(intersections[2 * pair].x, intersections[2 * pair + 1].x)
		return Vector2(random_x, random_y)
	else:
		push_error("Shape2D of type '{0}' not yet supported!".format({"0": selected_shape}))

	return global_position


## Return the amount of shape areas this area point generator has saved.
func get_areas() -> int:
	return shapes.size()


func save_shapes() -> void:
	shapes.clear()
	for c in _get_area_point_shape_children():
		var new_point_shape := FTool_AreaPointShape.new()
		new_point_shape.save_shape(c)
		shapes.append(new_point_shape)
		print("Saved shape: " + c.name)

func create_shape() -> void:
	if not Engine.is_editor_hint():
		return
	var new_shape := CollisionShape2D.new()
	add_child(new_shape)
	new_shape.owner = get_tree().edited_scene_root
	new_shape.set_meta(_META_AREA_POINT_SHAPE, true)
	print("Created new shape " + new_shape.name)

func clear_shapes() -> void:
	if not Engine.is_editor_hint():
		return
	shapes.clear()
	for c in _get_area_point_shape_children():
		remove_child(c)
	print("Cleared all shapes")

func hide_shapes() -> void:
	for c in _get_area_point_shape_children():
		remove_child(c)

func restore_shapes() -> void:
	if not Engine.is_editor_hint():
		return
	for s in shapes:
		var new_shape := CollisionShape2D.new()
		new_shape.shape = s.shape
		new_shape.position = s.local_position
		add_child(new_shape)
		new_shape.set_meta(_META_AREA_POINT_SHAPE, true)
		new_shape.owner = get_tree().edited_scene_root
	print("Restored saved shapes")

func _get_area_point_shape_children() -> Array[Node]:
	var children = get_children()
	for c in children:
		if not c.get_meta(_META_AREA_POINT_SHAPE, false):
			children.erase(c)
	return children
