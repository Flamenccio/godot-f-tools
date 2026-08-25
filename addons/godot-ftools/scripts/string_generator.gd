class_name FTool_StringGenerator
extends RefCounted
## Generates randomized strings.
##
## Users can choose what characters appear in the generated
## string by passing unions of [enum CharFlags].[br]
## Note that symbols include the following: [code]!#$%^&*?/+_-=[/code]

const _LATIN_UNICODE_MIN = 65
const _LAITN_UNICODE_MAX = 122

const _NUMERAL_UNICODE_MIN = 48
const _NUMERAL_UNICODE_MAX = 57

const _SYMBOLS = "!#$%^&*?/+_-="

static var _latin_chars: String
static var _numbers: String
static var _symbols := _SYMBOLS

enum CharFlags {
	LATIN_ALPHABET = 1,
	NUMBERS = 2,
	SYMBOLS = 4,
}

## Generate a string of [param length] characters.[br]
## [param char_flags] determines what characters can be generated. Use bitwise [code]OR[/code]
## between [enum CharFlags] values to choose.[br]
## By default, generates latin alphabet, numbers, and symbols.
static func generate_string(length := 8, char_flags := CharFlags.LATIN_ALPHABET | CharFlags.NUMBERS | CharFlags.SYMBOLS) -> String:

	# Checks
	var result_string := ""
	if length <= 0:
		return result_string
	if char_flags == 0:
		return result_string
	if _latin_chars.length() == 0 or _numbers.length() == 0:
		_generate_chars()

	# Get chosen chars
	var available := ""
	if char_flags & CharFlags.LATIN_ALPHABET > 0:
		available += _latin_chars
	if char_flags & CharFlags.NUMBERS > 0:
		available += _numbers
	if char_flags & CharFlags.SYMBOLS > 0:
		available += _symbols

	# Generate string
	var available_length := available.length() - 1
	for i in range(length):
		var r := randi_range(0, available_length)
		result_string += available[r]

	return result_string

static func _generate_chars() -> void:
	_latin_chars = ""
	for i in range(_LATIN_UNICODE_MIN, _LAITN_UNICODE_MAX + 1):
		_latin_chars += char(i)
	_numbers = ""
	for i in range(_NUMERAL_UNICODE_MIN, _NUMERAL_UNICODE_MAX + 1):
		_numbers += char(i)
