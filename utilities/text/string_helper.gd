class_name StringHelper

const AsciiAlphanumeric = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
const AsciiLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const AsciiLowercase = "abcdefghijklmnopqrstuvwxyz"
const AsciiUppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const AsciiDigits = "0123456789"
const AsciiHexdigits = "0123456789ABCDEF"
const AsciiPunctuation =  "!\"#$%&'()*+, -./:;<=>?@[\\]^_`{|}~"
const bar = "█"

static var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()


static func generate_random_string(length: int = 25, characters: String = AsciiAlphanumeric) -> String:
	var result := ""
	
	if(not characters.is_empty() && length > 0):
		for character in range(length):
			result += characters[random_number_generator.randi() % characters.length()]
			
	return result
	
## Converts PascalCaseString into pascal_case_string
static func camel_to_snake(camel_string: String) -> String:
	var snake_string := ""
	var previous_char := ""
	
	for c in camel_string:
		if c.to_upper() == c and previous_char != "" and previous_char.to_upper() != previous_char:
			snake_string += "_"
		snake_string += c.to_lower()
		previous_char = c
	
	return snake_string

## Converts pascal_case_string into PascalCaseString
static func snake_to_camel_case(screaming_snake_case: String) -> String:
	var words := screaming_snake_case.split("_")
	var camel_case := ""
	
	for i in range(words.size()):
		camel_case += words[i].capitalize()
	
	return camel_case

## Clean a string by removing characters that are not letters (uppercase or lowercase) or spaces, tabs or newlines.
static func clean(string: String) -> String:
	var regex = RegEx.new()
	regex.compile("[\\p{L} ]*")
	
	var result = ""
	var matches = regex.search_all(string)
	
	for m in matches:
		for s in m.strings:
			result += s
			
	return result

## This function wraps the provided text into multiple lines if it exceeds the specified max_line_length
static func wrap_text(text: String = "", max_line_length: int = 120):
	if text.is_empty() or text.length() <= max_line_length:
		return text
	else:
		var final_text: String = ""
		var words: PackedStringArray = text.split(" ")
		var current_line: String = ""
		
		for word: String in words:
			if current_line != "":
				if (current_line + word).length() + 1 > max_line_length:
					final_text += current_line + "\n"
					current_line = ""
				else:
					current_line += " "
					
			current_line += word
			
		final_text += current_line
		
		return final_text


static func integer_to_ordinal(number: int) -> String:
	var middle := number % 100
	var suffix := ""
	
	if middle >= 11 and middle <= 13:
		suffix = "th"
	else:
		suffix = {1: "st", 2: "nd", 3: "rd"}.get(number % 10, "th")
		
	return str(number) + suffix
	
	
static func pretty_number(number: float, suffixes: Array[String] = ["", "K", "M", "B", "T"]) -> String:
	var prefix_sign = "-" if sign(number) == -1 else ""
	
	number = absf(number)

	var exponent = 0

	while number >= 1000.0:
		number /= 1000.0  # Divide by 1000 for each exponent level
		exponent += 1

	# Round to one decimal place using snapped
	var formatted_number = str(snappedf(number, 0.001))

	return prefix_sign + formatted_number + suffixes[exponent]


static func to_binary_string(num: int) -> String:
	var binary_string := ""
	var number: = num
	
	while number > 0:
		binary_string = str(number & 1) + binary_string
		number = number >> 1
	
	return binary_string


static func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	
	return regex.sub(source, "", true)


static func strip_filepaths(source: String) -> String:
	var regex = RegEx.new()
	regex.compile("res://([^ ])+")
	
	return regex.sub(source, "", true)


static func str_replace(target: String, regex: RegEx, cb: Callable) -> String:
	var result = ""
	var last_position = 0
	
	for regex_match in regex.search_all(target):
		var start := regex_match.get_start()
		result += target.substr(last_position, start - last_position)
		result += str(cb.call(regex_match.get_string()))
		last_position = regex_match.get_end()
		
	result += target.substr(last_position)
	
	return result
	

static func case_insensitive_comparison(one: String, two: String) -> bool:
	return one.strip_edges().to_lower() == two.strip_edges().to_lower()
	
	
static func is_whitespace(text: String) -> bool:
	var whitespace_regex: RegEx = RegEx.new()
	whitespace_regex.compile(r"\s+")
	
	if whitespace_regex.search(text):
		return true
	
	return false
	
	
static func remove_whitespaces(text: String) -> String:
	var whitespace_regex: RegEx = RegEx.new()
	whitespace_regex.compile(r"\s+")
	
	return StringHelper.str_replace(text, whitespace_regex, func(_text: String): return "")


static func repeat(text: String, times: int) -> String:
	var result: String = ""
	
	for i: int in range(times):
		result += text
		
	return result


static func bars(amount: int) -> String:
	return repeat(bar, amount)
