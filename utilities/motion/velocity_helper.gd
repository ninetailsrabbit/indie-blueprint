class_name VelocityHelper

enum SpeedUnit {
	KilometersPerHour,
	MilesPerHour,
}


static func current_speed_on(speed_unit: SpeedUnit, velocity) -> float:
		match speed_unit:
			VelocityHelper.SpeedUnit.KilometersPerHour:
				return current_speed_on_kilometers_per_hour(velocity)
			VelocityHelper.SpeedUnit.MilesPerHour:
				return current_speed_on_miles_per_hour(velocity)
			_:
				return 0.0


static func current_speed_on_miles_per_hour(velocity) -> float:
	if velocity is Vector2:
		return roundf(velocity.length() * MathHelper.MetersPerSecondToMilePerHourFactor)
	elif velocity is Vector3:
		return roundf(Vector3(velocity.x, 0, velocity.z).length() * MathHelper.MetersPerSecondToMilePerHourFactor)
	elif velocity is float: ## We assume we received the velocity length
		return roundf(velocity * MathHelper.MetersPerSecondToMilePerHourFactor)
	else:
		return 0.0


static func current_speed_on_kilometers_per_hour(velocity) -> float:
	if velocity is Vector2:
		return roundf(velocity.length() * MathHelper.MetersPerSecondToKilometersPerHourFactor)
	elif velocity is Vector3:
		return roundf(Vector3(velocity.x, 0, velocity.z).length() * MathHelper.MetersPerSecondToKilometersPerHourFactor)
	elif velocity is float: ## We assume we received the velocity length
		return roundf(velocity * MathHelper.MetersPerSecondToKilometersPerHourFactor)
	else:
		return 0.0
	
	
