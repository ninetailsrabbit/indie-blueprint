class_name RaycastResult extends RefCounted

var collider: Node
var collider_id: int
var normal: Vector3
var position: Vector3
var face_index: int
var shape: int
var rid: RID

var property_keys: Array[String] = [
	"collider",
	"collider_id",
	"normal",
	"position",
	"face_index",
	"shape",
	"rid"
]

func _init(hitscan_result: Dictionary) -> void:
	for key: String in property_keys:
		if hitscan_result.has(key):
			self[key] = hitscan_result[key]


func collided() -> bool:
	return collider != null
	
	
func as_dict() -> Dictionary:
	return {
		"collider": collider,
		"collider_id": collider_id,
		"normal": normal,
		"position": position,
		"face_index": face_index,
		"shape": shape,
		"rid": rid,
	}
