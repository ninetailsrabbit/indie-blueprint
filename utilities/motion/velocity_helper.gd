class_name VelocityHelper

enum SpeedUnit {
	KilometersPerHour,
	MilesPerHour,
}

const MetersPerSecondToMilePerHourFactor: float = 2.23694
const MetersPerSecondToKilometersPerHourFactor: float = 3.6


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
		return roundf(velocity.length() * MetersPerSecondToMilePerHourFactor)
	elif velocity is Vector3:
		return roundf(Vector3(velocity.x, 0, velocity.z).length() * MetersPerSecondToMilePerHourFactor)
	else:
		return 0.0


static func current_speed_on_kilometers_per_hour(velocity) -> float:
	if velocity is Vector2:
		return roundf(velocity.length() * MetersPerSecondToKilometersPerHourFactor)
	elif velocity is Vector3:
		return roundf(Vector3(velocity.x, 0, velocity.z).length() * MetersPerSecondToKilometersPerHourFactor)
	else:
		return 0.0
	
	
