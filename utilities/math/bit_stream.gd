class_name BitStream extends RefCounted

var bits: Array
var current_bit = 0


func bits_left():
	return bits.size() - current_bit
	

func push(value: int, range_max: int):
	var num_bits = ceil(log2(range_max))
	
	for digit in range(num_bits - 1, - 1, - 1):
		var bit = value & (1 << digit)
		push_bit(bit > 0)


func push_bit(bit: bool):
	bits.push_back(bit)

	
func pull(range_max:int)->int:
	var num_bits = ceil(log2(range_max))
	var value = 0
	
	for digit in range(num_bits - 1, - 1, - 1):
		var bit_state = int(bits[current_bit])
		current_bit += 1
		
		value += bit_state << digit
		
	return value


func to_godot_string()-> String:
	var string = ""
	var byteArray = to_byte_array()
	
	for byte in byteArray:
		string += char(byte + 65)
		
	return string
	
func from_godot_string(string: String):
	var byteArray = PackedByteArray()
	
	for c in string:
		byteArray.push_back(c.unicode_at(0) - 65)
		
	from_byte_array(byteArray)


func pprint():
	var string = ""
	
	for bit in bits:
		if bit:
			string += "1"
		else :
			string += "0"
			
	return string


func to_byte_array():
	var byte_array = PackedByteArray()
	var digit_count = 0
	var value = 0
	
	for bit in bits:
		digit_count += 1
		value = (value << 1) + int(bit)
		
		if digit_count == 8:
			digit_count = 0
			byte_array.append(value)
			value = 0
			
	if digit_count > 0:
		byte_array.append(value << (8 - digit_count))
	
	return byte_array


func from_byte_array(byte_array: PackedByteArray):
	bits.clear()
	
	for byte in byte_array:
		for digit in range(7, - 1, - 1):
			push_bit(byte & (1 << digit))
			
	return self


func to_utf8() -> String:
	var byte_array = to_byte_array()
	
	var file = FileAccess.open(OS.get_user_data_dir() + "/bitstream.dat", FileAccess.WRITE_READ)
	file.store_buffer(byte_array)
	
	var utf8_string = file.get_as_text(false)
	file.close()
	
	return utf8_string


func from_utf8(utf8_string: String):
	from_byte_array(utf8_string.to_utf8_buffer())

	
func to_ascii_string()-> String:
	var byte_array = to_byte_array()
	return byte_array.get_string_from_ascii()


func from_ascii_string(string: String):
	from_byte_array(string.to_ascii_buffer())
	

func from_string(string):
	bits.clear()
	
	for s in string:
		if s == "1":
			push_bit(1)
		else :
			push_bit(0)


func log2(number):
	return log(number) / log(2)
