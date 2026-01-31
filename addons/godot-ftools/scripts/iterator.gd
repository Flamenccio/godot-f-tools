class_name FTool_Iterator
extends RefCounted
## Iterates through a given array. The array can be traversed
## through the [code]get_next[/code] and [code]get_previous[/code]
## methods.

var iterated_array: Array
var iteration_index = 0
var iterating := false

## Begin iterating through the given [code]array[/code].
## Sets the index to 0.
func begin_iteration(array: Array = []) -> void:
	if not array.is_empty():
		iterated_array.assign(array)
	if iterated_array.is_empty():
		return
	iterating = true
	iteration_index = 0

## End the current iteration. Does nothing if not currently iterating.
## Resets the index to 0.
func end_iteration() -> void:
	iterating = false
	iteration_index = 0

## Move to the next value in the array, and return it or [code]default_null[/code] if at the end.
func get_next(default_null: Variant = null) -> Variant:
	if not iterating:
		return default_null
	if iteration_index >= iterated_array.size():
		return default_null
	var v = iterated_array[iteration_index]
	iteration_index += 1
	return v

## Move to the previous value in the array, and return it or [code]default_null[/code] if at the beginning.
func get_previous(default_null: Variant = null) -> Variant:
	if not iterating:
		return default_null
	if iteration_index <= 0:
		return default_null
	iteration_index -= 1
	return iterated_array[iteration_index]
