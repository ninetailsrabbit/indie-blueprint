class_name ArrayHelper

	
## Flatten any array with n dimensions recursively
static func flatten(array: Array[Variant]):
	var result := []
	
	for i in array.size():
		if typeof(array[i]) >= TYPE_ARRAY:
			result.append_array(flatten(array[i]))
		else:
			result.append(array[i])

	return result


static func pick_random_values(array: Array[Variant], items_to_pick: int = 1, duplicates: bool = true) -> Array[Variant]:
	var result := []
	var target = flatten(array.duplicate())
	target.shuffle()
	
	items_to_pick = min(target.size(), items_to_pick)
	
	for i in range(items_to_pick):
		var item = target.pick_random()
		result.append(item)

		if not duplicates:
			target.erase(item)
		
	return result
	

static func remove_duplicates(array: Array[Variant]) -> Array[Variant]:
	var cleaned_array := []
	
	for element in array:
		if not cleaned_array.has(element):
			cleaned_array.append(element)
		
	return cleaned_array
	
	
static func remove_falsy_values(array: Array[Variant]) -> Array[Variant]:
	var cleaned_array := []
	
	for element in array:
		if element:
			cleaned_array.append(element)
		
	return cleaned_array
	
	
static func middle_element(array: Array[Variant]):
	if array.size() > 2:
		return array[floor(array.size() / 2.0)]
		
	return null
	

## To detect if a contains elements of b
static func intersects(a: Array[Variant], b: Array[Variant]) -> bool:
	for e: Variant in a:
		if b.has(e):
			return true
			
	return false


static func intersected_elements(a: Array[Variant], b: Array[Variant]) -> Array[Variant]:
	if intersects(a, b):
		return a.filter(func(element): return element in b)
		
	return []
	

static func merge_unique(first: Array[Variant], second: Array[Variant]) -> Array[Variant]:
	var merged_array: Array[Variant] = remove_duplicates(first)

	for element in remove_duplicates(second):
		if not merged_array.has(element):
			merged_array.append(element)
			
	return merged_array


static func chunk(array: Array[Variant], size: int):
	var result = []
	var i = 0
	var j = -1
	
	for element in array:
		if i % size == 0:
			result.push_back([])
			j += 1
			
		result[j].push_back(element)
		i += 1
		
	return result
