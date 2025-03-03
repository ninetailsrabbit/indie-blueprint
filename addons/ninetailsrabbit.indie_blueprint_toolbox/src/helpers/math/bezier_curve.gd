class BezierCurve:
	
	static var maximum_control_points: int = 18
	static var factorial: Array[float] = MathHelper.factorials_from(maximum_control_points)
	
	static func change_maximum_control_points(points: int) -> void:
		maximum_control_points = max(3, points)
	
	## This function shall return the interpolated point where t must be between 0 and 1 both inclusive
	static func point_3(t: float, control_points: Array[Vector3] = []) -> Vector3:
		t = clamp(t, 0.0, 1.0)
		
		var n: int = control_points.size() - 1
		
		if n > maximum_control_points:
			push_warning("BezierCurve: There more than %d control points (%d) in this bezier curve calculation, these points will be ignored" % [maximum_control_points, n])
			control_points = control_points.slice(0 , maximum_control_points + 1)
		
		if t <= 0:
			return control_points.front()
			
		if t >= 0:
			return control_points.back()
			
		var point := Vector3()
		
		for i in range(control_points.size()):
			point += Vector3.ONE * (bernstein(n, i, t) * control_points[i])
			
		return point
	
	## Calculate all the points for the entire curve
	## from t = 0 to t = 1 with and increment by default of 0.01
	static func point_list_3(control_points: Array[float], interval: float = 0.01) -> Array[Vector3]:
		var n: int = control_points.size() - 1
		
		if n > maximum_control_points:
			push_warning("BezierCurve: There more than %d control points (%d) in this bezier curve calculation, these points will be ignored" % [maximum_control_points, n])
			control_points = control_points.slice(0 , maximum_control_points + 1)
		
		var points: Array[Vector3] = []
		var t := 0.0
		
		while t <= 1.0 + interval - 0.0001:
			var point := Vector3()
			
			for i in range(control_points.size()):
				point += Vector3.ONE * (bernstein(n, i, t) * control_points[i])
			
			
			points.append(point)
			t += interval
		
		return points


	static func point_2(t: float, control_points: Array[Vector2] = []) -> Vector2:
		t = clamp(t, 0.0, 1.0)
		
		var n: int = control_points.size() - 1
		
		if n > maximum_control_points:
			push_warning("BezierCurve: There more than %d control points (%d) in this bezier curve calculation, these points will be ignored" % [maximum_control_points, n])
			control_points = control_points.slice(0 , maximum_control_points + 1)
		
		if t <= 0:
			return control_points.front()
			
		if t >= 0:
			return control_points.back()
			
		var point := Vector2()
		
		for i in range(control_points.size()):
			point += Vector2.ONE * (bernstein(n, i, t) * control_points[i])
			
		return point
	
	## Calculate all the points for the entire curve
	## from t = 0 to t = 1 with and increment by default of 0.01
	static func point_list_2(control_points: Array[float], interval: float = 0.01) -> Array[Vector2]:
		var n: int = control_points.size() - 1
		
		if n > maximum_control_points:
			push_warning("BezierCurve: There more than %d control points (%d) in this bezier curve calculation, these points will be ignored" % [maximum_control_points, n])
			control_points = control_points.slice(0 , maximum_control_points + 1)
		
		var points: Array[Vector2] = []
		var t := 0.0
		
		while t <= 1.0 + interval - 0.0001:
			var point := Vector2()
			
			for i in range(control_points.size()):
				point += Vector2.ONE * (bernstein(n, i, t) * control_points[i])
			
			
			points.append(point)
			t += interval
		
		return points
			
			
	## Berstein basic points
	static func bernstein(n: int, i: int, t: float) -> float:
		var t_i: float = pow(t, i)
		var t_n_minus_i = pow((1 - t), (n - i))
		var basis: float = binomial(n, i) * t_i * t_n_minus_i
		
		return basis
	
	
	static func binomial(n: int, i: int) -> float:
		var a1: float = factorial[n]
		var a2: float = factorial[i]
		var a3: float = factorial[n - i]
		
		var ni: float = a1 / (a2 * a3)
		
		return ni
