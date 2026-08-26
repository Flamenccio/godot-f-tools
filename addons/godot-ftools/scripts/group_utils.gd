class_name FTool_GroupUtils
extends RefCounted
## Helper functions pertaining to Godot's groups.
##
## Has methods to perform some group functions such as [code]set_group[/code] or [code]call_group[/code]
## that only affect nodes that are the children of a specified node.

## Functions similarly to [method SceneTree.set_group], except acts exclusively on children
## of [param node].[br]
## - [param node]: node whose children will be acted on[br]
## - [param group_name]: name of group to affect[br]
## - [param property_name]: name of the propery to change[br]
## - [param property_value]: value of the property[br]
## - [param recursive]: if [code]true[/code], also acts on the children of children[br]
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

## Functions similarly to [method SceneTree.call_group], except acts exclusively on children
## of [param node].[br]
## - [param node]: node whose children will be acted on[br]
## - [param group_name]: name of group to affect[br]
## - [param method_node]: name of the method to call[br]
## - [param recursive]: if [code]true[/code], also acts on the children of children[br]
## - [param args]: method arguments to pass to children[br]
static func children_call_group(node: Node, group_name: String, method_name: String, recursive := false, ... args: Array) -> void:

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

