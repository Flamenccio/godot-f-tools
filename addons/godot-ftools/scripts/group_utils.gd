class_name FTool_GroupUtils
extends RefCounted
## Helper functions pertaining to Godot's groups.
##
## Has methods to perform some group functions such as [code]set_group[/code] or [code]call_group[/code]
## that only affect nodes that are the children of a specified node.

## Functions similarly to [code]SceneTree.set_group[/code], except acts exclusively on children
## of [code]node[/code].[br]
## - [code]node[/code]: node whose children will be acted on[br]
## - [code]group_name[/code]: name of group to affect[br]
## - [code]property_name[/code]: name of the propery to change[br]
## - [code]property_value[/code]: value of the property[br]
## - [code]recursive[/code]: if [code]true[/code], also acts on the children of children[br]
static func children_set_group(node: Node, group_name: String, property_name: String, property_value: Variant, recursive := false) -> void:

	if node == null:
		push_warning("Node is null")
		return
	if group_name.is_empty():
		push_warning("No group name given")
		return
	if property_name.is_empty():
		push_warning("No property name given")
		return
	
	var children := _get_children(node, recursive)
	
	for c in children:
		if c.is_in_group(group_name):
			c.set(property_name, property_value)

## Functions similarly to [code]SceneTree.call_group[/code], except acts exclusively on children
## of [code]node[/code].[br]
## - [code]node[/code]: node whose children will be acted on[br]
## - [code]group_name[/code]: name of group to affect[br]
## - [code]method_name[/code]: name of the method to call[br]
## - [code]args[/code]: method arguments to pass to children[br]
## - [code]recursive[/code]: if [code]true[/code], also acts on the children of children[br]
static func children_call_group(node: Node, group_name: String, method_name: String, args: Array = [], recursive := false) -> void:

	if node == null:
		push_warning("Node is null")
		return
	if group_name.is_empty():
		push_warning("No group name given")
		return
	if method_name.is_empty():
		push_warning("No method name")
		return
	
	var children := _get_children(node, recursive)

	for c in children:
		if c.is_in_group(group_name):
			if args.size() == 0:
				c.call(method_name)
			else:
				c.callv(method_name, args)

static func _get_children(node: Node, recursive: bool) -> Array[Node]:
	if recursive:
		return node.find_children("*")
	return node.get_children()