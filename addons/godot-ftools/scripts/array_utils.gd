class_name FTool_ArrayUtils
extends RefCounted
## Extra helper methods for arrays.
##
## Includes some function for set theory, returning pseudo-sets.

## Get the union of sets [param a] and [param b].[br]
## The union of two sets contains all elements from both,
## with no duplicates.
static func union_set(a: Array, b: Array) -> Array:
	var un := a.duplicate()
	un.append_array(b)
	return to_set(un)


## Get the intersection of sets [param a] and [param b].[br]
## The intersection of two sets contains only elements present in both.
static func get_intersection(a: Array, b: Array) -> Array:
	var big := a if a.size() > b.size() else b
	var small := b if big == a else a
	var intersection: Array
	for element in big:
		if small.has(element):
			intersection.append(element)
	return to_set(intersection)


## Get the symmetric difference of sets [param a] and [param b].[br]
## The symmetric difference of two sets contains all elements that both do
## not share.
static func get_symmetric_difference(a: Array, b: Array) -> Array:
	var diff: Array
	diff.append_array(get_set_difference(a, b))
	diff.append_array(get_set_difference(b, a))
	return diff


## Get the set difference from set [param a] to set [param b].[br]
## The set difference from set [param a] to set [param b] contains
## all elements of [param a] that are not in [param b].
static func get_set_difference(a: Array, b: Array) -> Array:
	var diff: Array
	for element in a:
		if not b.has(element):
			diff.append(element)
	return to_set(diff)


## Return the array [param a] with no duplicate items.
static func to_set(a: Array) -> Array:
	var set: Array
	for element in a:
		if set.count(element) == 0:
			set.append(element)
	return set


## Returns [code]true[/code] when [param e] is [b]not[/b]
## in [param a].[br]
## This is equivalent to [code]not a.has(e)[/code].[br]
static func not_has(a: Array, e: Variant) -> bool:
	return not a.has(e)


## Returns [code]true[/code] when [param f] returns [code]false[/code]
## For all elements of [param a].[br]
## Like [method Array.any], [param f] should take one [Variant] parameter
## and return a [bool].
## This is equivalent to [code]not a.any(f)[/code].
static func none(a: Array, f: Callable) -> bool:
	return not a.any(f)


## Returns an [Array] of indices of [param a] to which [param f] returns [code]true[/code].[br]
## [param f] should take a [Variant] parameter.
static func find_all_custom(a: Array, f: Callable, from := 0) -> Array[int]:
	var idxs: Array[int]
	for i in range(from, a.size()):
		if f.call(a[i]):
			idxs.append(i)
	return idxs


## Returns an [Array] of indices of [param a] to which [param what] is equal to.[br]
static func find_all(a: Array, what: Variant, from := 0) -> Array[int]:
	var idxs: Array[int]
	for i in range(from, a.size()):
		if a[i] == what:
			idxs.append(i)
	return idxs

