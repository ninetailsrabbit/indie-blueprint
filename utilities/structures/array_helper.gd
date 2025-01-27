class_name ArrayHelper


static func sum(values: Array[int]) -> int:
	var result: int = 0

	for value in values:
		result += value

	return result


static func sum_floats(values: Array[float]) -> float:
	var result: float = 0.0

	for value in values:
		result += value

	return result
	

static func repeat(element: Variant, times: int) -> Array[Variant]:
	var result: Array[Variant] = []
	
	for _time: int in times:
		result.append(element.duplicate())
		
	return result

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
	var result: Array[Variant] = []
	var target = flatten(array.duplicate())
	target.shuffle()
	
	items_to_pick = mini(target.size(), items_to_pick)
	
	for i in range(items_to_pick):
		var item = target.pick_random()
		result.append(item)

		if not duplicates:
			target.erase(item)
		
	return result
	

static func remove_duplicates(array: Array[Variant]) -> Array[Variant]:
	var cleaned_array: Array[Variant] = []
	
	for element in array:
		if not cleaned_array.has(element):
			cleaned_array.append(element)
		
	return cleaned_array
	
	
static func remove_falsy_values(array: Array[Variant]) -> Array[Variant]:
	var cleaned_array: Array[Variant] = []
	
	for element in array:
		if element:
			cleaned_array.append(element)
		
	return cleaned_array
	
	
static func middle_element(array: Array[Variant]):
	if array.size() > 2:
		return array[floor(array.size() / 2.0)]
		
	return null
	

## This method works in a circular way, this means that is the value is the last, it returns the first one in the array
static func next_element_from_value(array: Array[Variant], value: Variant) -> Variant:
	if array.is_empty() or not array.has(value):
		return null
	
	elif array.size() > 1 and array.has(value):
		var from_value_index = array.find(value)
		
		if from_value_index != -1 and from_value_index + 1 < array.size():
			return array[from_value_index + 1]
		else:
			return array.front()
		
	return null
	
## Return a dictionary with the array value as key and the frequency count as value
static func frequency(array: Array[Variant]) -> Dictionary:
	var result: Dictionary = {}
	
	for element: Variant in array:
		result[element] = result.get(element, 0) + 1
		
	return result
	

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

##Separates an Array into smaller array:
## argument 1: array that is going to be converted
## argument 2: size of these smaller arrays
## argument 3: writes smaller arrays even if they aren't full
## Example:
## ArrayHelper.chunk[[1,2,3,4,5,6,7,8,9], 3]
## [1,2,3,4,5,6,7,8,9] -> [[1,2,3], [4,5,6], [7,8,9]]
## Example 2:
## ArrayHelper.chunk([1,2,3,4,5,6,7,8,9], 4)
## [1,2,3,4,5,6,7,8,9] -> [[1, 2, 3, 4], [5, 6, 7, 8], [9]]
static func chunk(array: Array[Variant], size: int, only_chunks_with_same_size: bool = false):
	var result = []
	var i = 0
	var j = -1
	
	if only_chunks_with_same_size:
		@warning_ignore("integer_division")
		array = array.slice(0, floor(array.size() / size) * size)
	
	for element in array:
		if i % size == 0:
			result.push_back([])
			j += 1
			
		result[j].push_back(element)
		i += 1
		
	return result
