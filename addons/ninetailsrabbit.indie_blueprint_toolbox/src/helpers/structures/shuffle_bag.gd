class_name ShuffleBag extends RefCounted

var initial: Array[Variant] = []
var bag: Array[Variant] = []


func _init(array: Array[Variant]) -> void:
	populate(array)


func populate(array: Array[Variant]) -> void:
	initial = array
	reshuffle()
	
	
func reshuffle() -> void:
	bag = initial.duplicate()
	bag.shuffle()
	

func pick_random() -> Variant:
	if bag.is_empty():
		reshuffle()
		
	return bag.pop_front()


func pick_randoms(amount: int) -> Variant:
	var result: Array[Variant] = []
	
	for i in amount:
		result.append(pick_random())
		
	return result
