class_name RaycastResult extends RefCounted

var collider: Node
var collider_id: int
var origin: Vector3
var target: Vector3
var normal: Vector3
var distance: float
var position: Vector3
var face_index: int
var shape: int
var rid: RID

var property_keys: Array[String] = [
	"collider",
	"collider_id",
	"origin",
	"target",
	"normal",
	"distance",
	"position",
	"face_index",
	"shape",
	"rid"
]

func _init(from: Vector3, to: Vector3, _distance: float, hitscan_result: Dictionary) -> void:
	for key: String in property_keys:
		if hitscan_result.has(key):
			self[key] = hitscan_result[key]
			
	origin = from
	target = to
	distance = _distance


func collided() -> bool:
	return collider != null


func projection() -> Vector3:
	if normal.is_zero_approx():
		return origin.direction_to(target) * distance
	
	
	return origin * normal * distance
	

func as_dict() -> Dictionary:
	return {
		"collider": collider,
		"collider_id": collider_id,
		"origin": origin,
		"target": target,
		"normal": normal,
		"distance": distance,
		"position": position,
		"face_index": face_index,
		"shape": shape,
		"rid": rid,
	}
