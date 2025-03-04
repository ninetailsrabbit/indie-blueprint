## https://semver.org/
class_name SemanticVersion extends RefCounted

var major: int
var minor: int
var patch: int

## Here can goes the definition after the number like "-rc.1" or "-alpha.2"
## Examples: 1.0.0-rc.1 or 1.0.2-alpha.2
var state: String = ""

func _init(_major: int, _minor: int, _patch: int, _state: String = "") -> void:
	major = _major
	minor = _minor
	patch = _patch
	state = _state


static func parse(value: String) -> SemanticVersion:
	var regex: = RegEx.new()
	regex.compile("[a-zA-Z:,-]+")
	
	var cleaned: String = regex.sub(value, "", true)
	var parts: PackedStringArray = cleaned.split(".")
	var major: int = parts[0].to_int()
	var minor: int = parts[1].to_int()
	var patch: int = parts[2].to_int() if parts.size() > 2 else 0
	
	return SemanticVersion.new(major, minor, patch)


func equals(other: SemanticVersion) -> bool:
	return major == other.major and minor == other.minor and patch == other.patch


func is_greater(other: SemanticVersion) -> bool:
	if major > other.major:
		return true
		
	if major == other.major and minor > other.minor:
		return true
		
	return major == other.major and minor == other.minor and patch > other.patch


func _to_string() -> String:
	return "v%d.%d.%d%s" % [major, minor, patch, state]
