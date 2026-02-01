class_name FTool_AreaPointShape
extends Resource

@export var shape: Shape2D
@export var local_position: Vector2

## Saves the collider's shape and position data. Overwrites existing data.
func save_shape(collider: CollisionShape2D) -> void:
	if collider.shape == null:
		push_warning("Collider '{0}' has no shape. Not saved.".format({"0": collider}))
		return
	shape = collider.shape
	local_position = collider.position
