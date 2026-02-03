class_name FTool_InputManager
extends Node
## Serves as a foundation of an input manager.
##
## Extend from this class and create different inputs using the create_input methods.
## The input manager will automatically watch for changes of that input and emit signals when
## they change.

enum AxisUpdateType {
	## The input manager will constantly check for axis updates on [code]_process[/code].
	ON_PROCESS,

	## The input manager will constantly check for axis updates on [code]_physics_process[/code].
	ON_PHYSICS_PROCESS,

	## The input manager will only check for axis updates when the user inputs an action
	## (on [code]_input[/code]).
	ON_INPUT_EVENT,
}

signal button_down(button_name: StringName)
signal button_up(button_name: StringName)

signal axis_updated(axis_name: String, value: float)

signal vector_updated(vector_name: String, value: Vector2)

# Private
signal _input_occurred(event: InputEvent)
signal _process_called()
signal _physics_process_called()

var _inputs: Array[FTool_InputObserver]
var _input_values: Dictionary[StringName, Variant]

func _ready() -> void:
	_add_inputs()

func _input(event: InputEvent) -> void:
	_input_occurred.emit(event)

func _process(_delta: float) -> void:
	_process_called.emit()

func _physics_process(_delta: float) -> void:
	_physics_process_called.emit()

## Create a button input named [code]button_name[/code].[br]
## When the action is pressed, [code]button_down[/code] will emit with its name.[br]
## When the action is released, [code]button_down[/code] will emit with its name.[br]
func create_button_input(input_name: StringName, action_name: StringName) -> void:

	if input_name.is_empty():
		push_error("Unable to add button: input_name is empty.")
		return
	if _input_exists(input_name):
		push_error("Unable add button '{0}': an input with that name already exists.".format({"0": input_name}))
		return

	var f = func(event: InputEvent):
		if event.is_action_pressed(action_name):
			button_down.emit(input_name)
		elif event.is_action_released(action_name):
			button_up.emit(input_name)
	var new_observer := _create_observer(input_name, f, AxisUpdateType.ON_INPUT_EVENT)
	_inputs.append(new_observer)

## Create an axis input named [code]input_name[/code].[br]
## When the action named [code]positive_action_name[/code] is pressed, the axis's value increases.[br]
## When the action named [code]negative_action_name[/code] is pressed, the axis's value decreases.[br]
## Any time an axis's value is changed, [code]axis_updated[/code] is emitted with [code]input_name[/code] and
## the axis's new value.[br]
func create_axis_input(input_name: StringName, positive_action_name: StringName, negative_action_name: StringName, \
		update_type := AxisUpdateType.ON_INPUT_EVENT) -> void:

	if input_name.is_empty():
		push_error("Unable to add axis: input_name is empty.")
		return
	if _input_exists(input_name):
		push_error("Unable to add axis '{0}': an input with that name already exists.")
		return

	var f := func(_input: InputEvent):
		var v = Input.get_axis(negative_action_name, positive_action_name)
		if not is_equal_approx(_input_values.get(input_name, 0.0), v):
			_input_values.set(input_name, v)
			axis_updated.emit(input_name, v)
	var new_observer := _create_observer(input_name, f, update_type)
	_inputs.append(new_observer)

## Create a vector 2 input named [code]input_name[/code].[br]
## The [b]positive[/b] actions increase the value of their respective axes.[br]
## The [b]negative[/b] actions decrease the value of their respective axes.[br]
## Any time a vector is changed, [code]vector_updated[/code] is emitted with [code]input_name[/code] and
## the vector's new value.[br]
func create_vector_input(input_name: StringName, positive_x_action: StringName, negative_x_action: StringName, \
		positive_y_action: StringName, negative_y_action: StringName, update_type := AxisUpdateType.ON_INPUT_EVENT) -> void:

	if input_name.is_empty():
		push_error("Unable to add vector input: input_name is empty.")
		return
	if _input_exists(input_name):
		push_error("Unable to add vector input '{0}': input with that name already exists.")
		return

	var f = func(_input: InputEvent):
		var v := Input.get_vector(negative_x_action, positive_x_action, negative_y_action, positive_y_action)
		if not _input_values.get(input_name, Vector2.ZERO).is_equal_approx(v):
			_input_values.set(input_name, v)
			vector_updated.emit(input_name, v)
	var new_observer := _create_observer(input_name, f, update_type)
	_inputs.append(new_observer)

## Create a throttle input named [code]input_name[/code].[br]
## The value of a throttle input depends solely on the strength of the action [code]action_name[/code].[br]
## For example, think of the triggers of an XBox controller.[br]
## Any time a throttle's value is changed, [code]axis_updated[/code] is emitted with [code]input_name[/code] and
## the throttle's new value.
func create_throttle_input(input_name: StringName, action_name: StringName, update_type := AxisUpdateType.ON_INPUT_EVENT) -> void:

	if input_name.is_empty():
		push_error("Unable to add vector input: vector_name is empty.")
		return
	if _input_exists(input_name):
		push_error("Unable to add throttle input '{0}': input with that name already exists.")
		return

	var f := func(_input: InputEvent):
		var v = Input.get_action_strength(action_name)
		if not is_equal_approx(v, _input_values.get(input_name, 0.0)):
			_input_values.set(input_name, v)
			axis_updated.emit(input_name, v)
	var new_observer := _create_observer(input_name, f, update_type)
	_inputs.append(new_observer)


## Attempts to remove a previously created input named [code]input_name[/code].
## Does nothing if the input does not exist.
func remove_input(input_name: StringName) -> void:

	var idx = _inputs.find_custom(func(i: FTool_InputObserver): return i.action_name == input_name)
	if idx < 0:
		push_warning("Unable to remove input '{0}': input with that name does not exist.".format({"0": input_name}))
		return

	var i = _inputs[idx]
	_inputs.remove_at(idx)
	match i.update_type:
		AxisUpdateType.ON_INPUT_EVENT:
			if _input_occurred.is_connected(i.check_input):
				_input_occurred.disconnect(i.check_input)
		AxisUpdateType.ON_PROCESS:
			if _process_called.is_connected(i.check_input):
				_process_called.disconnect(i.check_input)
		AxisUpdateType.ON_PHYSICS_PROCESS:
			if _physics_process_called.is_connected(i.check_input):
				_physics_process_called.disconnect(i.check_input)
	
	i.call_deferred("free")

func _input_exists(input_name: StringName) -> bool:
	return _inputs.any(func(i: FTool_InputObserver): return i.action_name == input_name)

func _create_observer(input_name: StringName, on_check_input: Callable, update_type: AxisUpdateType) -> FTool_InputObserver:

	var new_observer := FTool_InputObserver.new()
	new_observer.action_name = input_name
	new_observer.update_type = update_type
	match update_type:
		AxisUpdateType.ON_INPUT_EVENT:
			new_observer.check_input = on_check_input
			_input_occurred.connect(new_observer.check_input)
		AxisUpdateType.ON_PROCESS:
			new_observer.check_input = on_check_input.unbind(1)
			_process_called.connect(new_observer.check_input)
		AxisUpdateType.ON_PHYSICS_PROCESS:
			new_observer.check_input = on_check_input.unbind(1)
			_physics_process_called.connect(new_observer.check_input)

	return new_observer

## Override this method's body with input creation methods.
func _add_inputs() -> void:
	return
