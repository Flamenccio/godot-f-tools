class_name FTool_FlexibleTimer
extends Node
## Functions similarly to the built-in [code]Timer[/code] node, but allows
## its progress to be altered as it's processing.

## Emits when the timer ends.
signal timeout()

## If [code]true[/code], the timer starts once it enters the tree.
var autostart := false

## If [code]true[/code], the timer stops on timeout.
var one_shot := false

## If [code]true[/code], the timer will stop processing until
## [code]paused[/code] is [code]false[/code]
var paused := true

## If [code]true[/code], the timer will always process in realtime,
## ignoring [code]Engine.time_scale[/code].
var ignore_time_scale := false

## Time required for the timer to end, in seconds.
var wait_time := 1.0:
	set(value):
		wait_time = max(0.0, value)

## Time left until the timer ends, in seconds. This value is readonly, but
## can be changed through [code]change_time_left[/code].
var time_left := 0.0:
	set(value):
		return
	get:
		return _time_left

var _time_left := 0.0
var _stopped := false

func _enter_tree() -> void:
	if autostart:
		start()

func _physics_process(delta: float) -> void:
	if paused or _stopped:
		return
	if _time_left <= 0.0:
		timeout.emit()
		if one_shot:
			_stopped = true
		else:
			_time_left = wait_time
	
	if not ignore_time_scale:
		_time_left -= delta
	else:
		_time_left -= (delta / Engine.time_scale)

## Start the timer. If [code]time[/code] is more than 0.0,
## sets [code]wait_time[/code] to [code]time[/code], overwriting it.[br]
## If the timer is already started, restarts the timer.
func start(time := -1.0) -> void:
	if time > 0.0:
		wait_time = time
	_time_left = wait_time
	_stopped = false

## Stops the timer, setting [code]time_left[/code] back to [code]wait_time[/code]
func stop() -> void:
	_time_left = wait_time
	_stopped = true

## Changes the timer's [code]time_left[/code]. Does not change
## [code]wait_time[/code], and cannot drop below 0.
func change_time_left(change: float) -> void:
	_time_left = max(0.0, _time_left + change)
