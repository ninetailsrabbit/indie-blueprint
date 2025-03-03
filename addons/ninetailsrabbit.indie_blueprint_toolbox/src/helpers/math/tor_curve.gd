class_name TorCurve
	
	
static func pinch(v):
	return pow(v, 2) * (-1 if v < 0.5 else 1)


static func run(x: float, a: float = 0.0, b: float = 0.5, c: float = 0.0) -> float:
	c = pinch(c)
	x = max(0, min(1, x))
	
	var epsilon = 0.00001
	var s = exp(a)
	var s2 = 1.0 / (s + epsilon)
	var t = max(0, min(1, b))
	var u = c
	var result = 0
	var c1 = 0
	var c2 = 0
	var c3 = 0
	
	if(x < t):
		c1 = (t * x) / ( x + s * (t - x) + epsilon)
		c2 = t - pow(1 / (t + epsilon), s2 - 1) * pow(abs(x - t), s2)
		
		c3 = pow(1 / (t + epsilon), s - 1) * pow(x, s)
	else:
		c1 = (1 - t)*(x - 1) / (1 - x - s * (t - x) + epsilon) + 1
		c2 = pow(1 / ( (1 - t) + epsilon), s2 - 1) * pow(abs(x - t), s2) + t
		c3 = 1 - pow(1 / ( (1 - t) + epsilon), s - 1) * pow(1 - x, s)
		
	if(u <= 0):
		result = (-u) * c2 + (1 + u) * c1
	else:
		result = (u) * c3 + (1 - u) * c1
		
	return result
