class_name MathHelper

const CommonEpsilon = 0.000001  # 1.0e-6
const PreciseEpsilon = 0.00000001  # 1.0e-8

const E = 2.71828182845904523536028747135266249775724709369995
const δ = 4.6692016091 # FEIGENBAUM CONSTANT, period-doubling bifurcation. This bifurcation describes the behavior of a system that exhibits a doubling of its periodic cycle when a certain parameter is gradually changed
const FeigenbaumAlpha = 2.5029078750  # FEIGENBAUM ALPHA, another bifurcation constant
const AperyConstant = 1.2020569031  # APERY'S CONSTANT, related to zeta function
const GoldenRatio = 1.6180339887  # GOLDEN RATIO, (1 + sqrt(5)) / 2
const EulerMascheroniConstant = 0.5772156649  # EULER-MASCHERONI CONSTANT, gamma minus harmonic series
const KhinchinsConstant = 2.6854520010  # KHINCHIN'S CONSTANT, optimal embedding dimension
const GaussKuzminWirsingConstant = 0.3036630028  # GAUSS-KUZMIN-WIRSING CONSTANT, sphere packing
const BernstensConstant = 0.2801694990  # BERNSTEIN'S CONSTANT, derivative of Dirichlet eta function
const HafnerSarnakMcCurleyConstant = 0.3532363718  # HAFNER-SARNAK-MCCURLEY CONSTANT, number theory
const MeisselMertensConstant = 0.2614972128  # MEISSEL-MERTENS CONSTANT, prime number distribution
const GlaisherKinkelinConstant = 1.2824271291  # GLAISHER-KINKELIN CONSTANT, zeta function
const Omega = 0.5671432904  # OMEGA CONSTANT, alternating harmonic series
const GolombDickmanConstant = 0.6243299885  # GOLOMB-DICKMAN CONSTANT, prime number distribution
const CahensConstant = 0.6434105462  # CAHEN'S CONSTANT, Diophantine approximation
const TwinPrime = 0.6601618158  # TWIN PRIME CONSTANT, probability of twin prime
const LaplaceLimit = 0.6627434193  # LAPLACE LIMIT, cosmic microwave background radiation
const LandauRamanujanConstant = 0.7642236535  # LANDAU-RAMANUJAN CONSTANT, constant in quantum field theory
const CatalansConstant = 0.9159655941  # CATALAN'S CONSTANT, sum of reciprocals of squares
const ViswanathsConstant = 1.13198824  # VISWANATH'S CONSTANT, number theory
const ConwaysConstant = 1.3035772690  # CONWAY'S CONSTANT, sphere packing
const MillsConstant = 1.3063778838  # MILLS' CONSTANT, normal number
const PlasticConstant = 1.3247179572  # PLASTIC CONSTANT, golden raio analogue
const RamanujanSoldnerConstant = 1.4513692348  # RAMANUJAN-SOLDNE CONSTANT, elliptic integrals
const BackhouseConstant = 1.4560749485  # BACKHOUSE'S CONSTANT, gamma function
const PortersConstant = 1.4670780794  # PORTER'S CONSTANT, geometry
const LiebsSquareIceConstant = 1.5396007178  # LIEB'S SQUARE ICE CONSTANT, statistical mechanics
const ErdosBorweinConstant = 1.6066951524  # ERDOS-BORWEIN CONSTANT, normal number
const NivensConstant = 1.7052111401  # NIVENS' CONSTANT, number theory
const UniversalParabolicConstant = 2.2955871493  # UNIVERSAL PARABOLIC CONSTANT, reflection coefficient
const SierpinskisConstant = 2.5849817595  # SIERPINSKI'S CONSTANT, Sierpinski triangle fractal

const FransenRobinsonConstant = 2.807770
const HexCharacters = "0123456789ABCDEF"

## "x": This is the input value between 0 and 1 that you want to apply the bias to. 
## It could represent a probability, a random number between 0 and 1, or any other value in that range.
## "bias": This is the bias factor, also between 0 and 1. It controls how much the function pushes the x value away from 0.5 (the center).
## Example:
## By adjusting the bias value, you can control how much the dice is skewed towards higher numbers. 
## A bias of 0.5 would result in a fair die roll. A bias closer to 1 would make it more likely to roll higher numbers.
static func bias(x : float, _bias : float) -> float:
	var f := 1.0 - _bias
	var k := pow(f, 3)
	
	return (x * k) / (x * k - x + 1)
	
	
static func sigmoid(x: float, scaling_factor: float = 0.0) -> float:
	if scaling_factor == 0:
		return 1 / (1 + exp(-x))
	
	return 1 - 1 / (1 + pow(E, - 10 * (x / scaling_factor - 0.5)))


static func factorial(number):
	if number == 0 or number == 1:
		return 1
	else:
		return number * factorial(number - 1)


static func factorials_from(number) -> Array[float]:
	var result: Array[float] = []
	
	for i in range(number + 1):
		result.append(MathHelper.factorial(i))
		
	return result

## Only for radians
static func quantize_angle_to_90(target_angle: float) -> float:
	return roundf(fmod(target_angle, TAU) / (PI / 2)) * (PI / 2)


static func angle_is_between(angle: float, start_angle: float, end_angle: float) -> bool:
	if start_angle == end_angle or abs(start_angle) == PI and abs(end_angle) == PI:
		return true
		
	# adapted from from https://stackoverflow.com/questions/42246870/clamp-angle-to-arbitrary-range
	var n_min = wrapf(start_angle - angle, -PI, PI)
	var n_max = wrapf(end_angle - angle, -PI, PI)
	
	return n_min <= 0.0 and n_max >= 0.0

## Quaternions are a mathematical representation commonly used in 3D graphics to represent rotations.
## Axis-angle representation specifies a rotation by an axis vector and the angle of rotation around that axis
## Useful for Animation or Inverse Kinematics, Gimbal lock (when rotations get stuck or limited), Data storage or Transmission
static func quaternion_to_axis_angle(quaternion : Quaternion) -> Quaternion:
	var axis_angle := Quaternion(0, 0, 0, 0)

	if quaternion.w > 1: 
		quaternion = quaternion.normalized()

	axis_angle.w = sqrt(1 - quaternion.w * quaternion.w)

	if axis_angle.w < CommonEpsilon:
		axis_angle.x = quaternion.x
		axis_angle.y = quaternion.y
		axis_angle.z = quaternion.z
	else:
		axis_angle.x = quaternion.x / axis_angle.w
		axis_angle.y = quaternion.y / axis_angle.w
		axis_angle.z = quaternion.z / axis_angle.w

	return axis_angle


@warning_ignore("integer_division")
static func integer_to_roman_number(number: int) -> String:
	number = absi(number)
	
	var roman_digits = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"]
	var tens_place = ["", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"]
	var hundreds_place = ["", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"]
	var thousands_place = ["", "M", "MM", "MMM"]
	
	var thousands := number / 1000
	var hundreds := number % 1000 / 100
	var tens := number % 100 / 10
	var ones := number % 10
	
	var roman_number = "%s%s%s%s" % [thousands_place[thousands], hundreds_place[hundreds], tens_place[tens], roman_digits[ones]]
	
	return roman_number


static func roman_number_to_integer(roman_number: String) -> int:
	var roman_to_int_map = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000}
	
	var result = 0
	var previous_value = 0
	
	for i in range(roman_number.length() - 1, -1, -1):
		var current_value = roman_to_int_map[roman_number[i]]
		
		if current_value < previous_value:
			result -= current_value
		else:
			result += current_value
		
		previous_value = current_value

	return result


static func hexadecimal_to_decimal(hex: String) -> int:
	var decimal_value := 0.0
	var power := 0.0
	var val := 0.0
	
	for character in hex.strip_edges().reverse():
		val = HexCharacters.find(character.to_upper())  # Find decimal value of uppercase char
		
		if val == -1:
			return -1  
	
		decimal_value += val * (16.0 ** power)
		power += 1

	return ceil(decimal_value)


static func decimal_to_hexadecimal(decimal: int) -> String:
	var remaining = decimal
	var hex_string = ""

	while remaining > 0:
		var remainder_hex = remaining % 16
		hex_string = HexCharacters[remainder_hex] + hex_string
		remaining /= 16  # Integer division to discard remainder

	return hex_string
	
	
static func value_is_between(number: int, min_value: int, max_value: int, inclusive: = true) -> bool:
	if inclusive:
		return number >= min(min_value, max_value) and number <= max(min_value, max_value)
	else :
		return number > min(min_value, max_value) and number < max(min_value, max_value)


static func decimal_value_is_between(number: float, min_value: float, max_value: float, inclusive: = true, precision: float = 0.00001) -> bool:
	if inclusive:
		min_value -= precision
		max_value += precision

	return number >= min(min_value, max_value) and number <= max(min_value, max_value)


static func add_thousand_separator(number) -> String:
	var number_as_text = str(number)
	var mod = number_as_text.length() % 3
	var result := ""
	
	for index in range(0, number_as_text.length()):
		if index != 0 and index % 3 == mod:
			result += ","
			
		result += number_as_text[index]
		
	return result


static func volume_of_sphere(radius: float) -> float:
	return (4.0 / 3.0) * PI * pow(radius, 3)
	

static func volume_of_hollow_sphere(outer_radius: float, inner_radius: float) -> float:
	return (4.0 / 3.0) * PI *  (pow(outer_radius, 3) - pow(inner_radius, 3))
	

static func area_of_circle(radius: float) -> float:
	return PI * pow(radius, 2) 


static func area_of_triangle(base: float, perpendicular_height: float) -> float:
	return (base * perpendicular_height) / 2.0


## This function assumes that the cardinal direction is in radians unit.
## https://en.wikipedia.org/wiki/Cardinal_direction
static func angle_from_cardinal_direction(cardinal_direction: float) -> float:
	var half_pi = PI / 2.0
	
	while(abs(cardinal_direction)) > PI / 4.0:
		if cardinal_direction > 0:
			cardinal_direction -= half_pi
		else:
			cardinal_direction += half_pi
			
	return cardinal_direction


static func limit_horizontal_angle(direction: Vector2, limit_angle: float) -> Vector2:
	var angle = direction.angle()
	
	if abs(angle) > limit_angle and abs(angle) < PI - limit_angle:
		if abs(angle) < PI / 2:
			angle = limit_angle*sign(angle)
		else:
			angle = (PI - limit_angle) * sign(angle)
			
	return Vector2(cos(angle), sin(angle))


# https://stackoverflow.com/questions/1073336/circle-line-segment-collision-detection-algorithm
static func segment_circle_intersects(start, end, center, radius) -> Array:
	var d = end - start
	var f = start - center
	
	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - radius * radius
	var disc = b * b - 4 * a * c
	
	if disc < 0:
		return []
	
	disc = sqrt(disc)
	var candidates = [(-b - disc) / (2 * a), (-b + disc) / (2 * a)]
	
	var intersects = []
	
	for t in candidates:
		if t >= 0.0 and t <= 1.0:
			intersects.append((1 - t) * start + t * end)
		
	return intersects
				
# Returns intersection point(s) of a segment from 'a' to 'b' with a given rect, in order of increasing distance from 'a'
static func segment_rect_intersects(a, b, rect) -> Array:
	var points := []
	var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	
	for i in range(4):
		var intersect = Geometry2D.segment_intersects_segment(a, b, corners[i - 1], corners[i])
		
		if intersect:
			if not points.is_empty() and intersect.distance_squared_to(a) < points[0].distance_squared_to(a):
				points.push_front(intersect)
			else:
				points.append(intersect)
				
			if points.size() == 2:
				break
				
	return points
	
#https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Rectangle_difference	
static func rect_difference(r1: Rect2, r2: Rect2) -> Array:
	var result = []
	var top_height = r2.position.y - r1.position.y
	
	if top_height > 0:
		result.append(Rect2(r1.position.x, r1.position.y, r1.size.x, top_height))
		
	var bottom_y = r2.position.y + r2.size.y
	var bottom_height = r1.size.y - (bottom_y - r1.position.y)
	
	if bottom_height > 0 and bottom_y < r1.position.y + r1.size.y:
		result.append(Rect2(r1.position.x, bottom_y, r1.size.x, bottom_height))
		
	var y1 = max(r1.position.y, r2.position.y)
	var y2 = min(bottom_y, (r1.position.y + r1.size.y))
	var lr_height = y2 - y1
	
	var left_width = r2.position.x - r1.position.x
	
	if left_width > 0 and lr_height > 0:
		result.append(Rect2(r1.position.x, y1, left_width, lr_height))
		
	var right_x = r2.position.x + r2.size.x
	var right_width = r1.size.x - (right_x - r1.position.x)
	
	if right_width > 0 and lr_height > 0:
		result.append(Rect2(right_x, y1, right_width, lr_height))
	
	return result


static func average(numbers: Array = []) -> float:
	if numbers.is_empty():
		return 0

	return numbers.reduce(func(accum, element): return accum + element, 0.0) / numbers.size()


static func spread(scale: float = 1.0) -> float:
	return (randf() - 0.5) * 2.0 * scale


static func get_percentage(max_value: int, value: int) -> int:
	return roundi((float(value) / float(max_value)) * 100)


static func chance(probability_chance: float = 0.5, less_than: bool = true) -> bool:
	probability_chance = clamp(probability_chance, 0.0, 1.0)
	
	return randf() < probability_chance if less_than else randf() > probability_chance


static func big_round(num: int) -> int:
	if num >= 10_000_000_000_000:
		return floori(float(num) / 1_000_000_000_000) * 1_000_000_000_000
	
	elif num >= 10_000_000_000:
		return floori(float(num) / 1_000_000_000) * 1_000_000_000
	
	elif num >= 10_000_000:
		return floori(float(num) / 1_000_000) * 1_000_000
	
	elif num >= 10_000:
		return floori(float(num) / 1_000) * 1_000
	
	return num
	

static func random_byte() -> int:
	randomize()

	return randi() % 256


static func logbi(x: int, base: int = 10) -> int:
	return int(log(float(x)) / log(float(base)))
	
	
static func logb(x: float, base: float = 10.0) -> float:
	return log(x) / log(base)


static func generate_random_seed(seed_range: int = 10) -> String:
	randomize()
	var rnd_seed : String = ""
	
	for index in range(seed_range):
		rnd_seed += char(int(randi_range(40,127)))
		
	return(rnd_seed)
