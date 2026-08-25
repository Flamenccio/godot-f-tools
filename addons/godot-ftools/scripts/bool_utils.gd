class_name FTool_BoolUtils
extends RefCounted
## Some extra boolean functions, mostly for syntactic sugar.

## Exclusive OR. Returns [code]true[/code] if and only if
## one of [param a] or [param b] is [code]true[/code].
## Otherwise returns [code]false[/code].
static func xor(a: bool, b: bool) -> bool:
	return (a and not b) or (b and not a)

