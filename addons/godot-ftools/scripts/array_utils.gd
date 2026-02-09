class_name FTool_ArrayUtils
extends RefCounted
## Extra helper methods for arrays.
##
## Includes some function for set theory, returning pseudo-sets.

## Get the union of sets [code]a[/code] and [code]b[/code].[br]
## The union of two sets contains all elements from both,
## with no duplicates.
static func union_set(a: Array, b: Array) -> Array:
	var un := a.duplicate()
	un.append_array(b)
	return to_set(un)

## Get the intersection of sets [code]a[/code] and [code]b[/code].[br]
## The intersection of two sets contains only elements present in both.
static func get_intersection(a: Array, b: Array) -> Array:
	var big := a if a.size() > b.size() else b
	var small := b if big == a else a
	var intersection: Array
	for element in big:
		if small.has(element):
			intersection.append(element)
	return to_set(intersection)

## Get the symmetric difference of sets [code]a[/code] and [code]b[/code].[br]
## The symmetric difference of two sets contains all elements that both do
## not share.
static func get_symmetric_difference(a: Array, b: Array) -> Array:
	var diff: Array
	diff.append_array(get_set_difference(a, b))
	diff.append_array(get_set_difference(b, a))
	return diff

## Get the set difference from set [code]a[/code] to set [code]b[/code].[br]
## The set difference from set [code]a[/code] to set [code]b[/code] contains
## all elements of [code]a[/code] that are not in [code]b[/code].
static func get_set_difference(a: Array, b: Array) -> Array:
	var diff: Array
	for element in a:
		if not b.has(element):
			diff.append(element)
	return to_set(diff)

## Return the array with no duplicate items.
static func to_set(a: Array) -> Array:
	var set: Array
	for element in a:
		if set.count(element) == 0:
			set.append(element)
	return set
