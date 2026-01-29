class_name FTool_ResourceCollectionLoader
extends RefCounted
## Loads lists of Resources from the filesystem.
##
## Users can specify whether the Resource is of a specified class, or if
## Resources in sub-directories should be loaded.

## Loads all Resources of class [code]resource_class_name[/code] from [code]path[/code], and returns
## them in an array of Resources.[br]
## - [code]path[/code]: absolute path to load Resources from[br]
## - [code]resource_class_name[/code]: [code]class_name[/code] the Resource must or inherit from be to be loaded. 
## If left blank, any Resource is loaded.[br]
## - [code]recursive[/code]: if [code]true[/code], loads Resources from sub-directories too
static func load_resources(path: String, resource_class_name := "", recursive := true) -> Array[Resource]:
	var result: Array[Resource]
	if DirAccess.dir_exists_absolute(path):
		push_error("Path '{path}' doesn't exist".format({"path": path}))
		return result
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var current = dir.get_next()
	while current != "":
		var full_path = dir.get_current_dir().path_join(current)
		if dir.current_is_dir() and recursive:
			result.append_array(load_resources(full_path, resource_class_name, recursive))
		elif not dir.current_is_dir():
			var res = load(full_path)
			if res == null:
				continue
			var res_script := res.get_script() as Script
			var is_resource_class := res_script.get_global_name() == resource_class_name or \
					res_script.get_base_script().get_global_name() == resource_class_name
			if resource_class_name.is_empty() or is_resource_class:
				result.append(res)
		current = dir.get_next()
	return result
