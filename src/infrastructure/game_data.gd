class_name GameData
extends RefCounted

var error: String = ""

func load_balance(path: String = "res://data/balance/mission.json") -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		error = "No se pudo abrir el balance."
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or not validate_balance(parsed):
		error = "El archivo de balance no es válido."
		return {}
	return parsed

func validate_balance(value: Dictionary) -> bool:
	for key in ["mission_sols", "battery_capacity", "solar_per_sol", "oxygen_per_sol", "food_per_sol"]:
		if not _positive_integer(value.get(key)):
			return false
	if not value.get("initial") is Dictionary or not value.get("actions") is Dictionary:
		return false
	for key in ["energy", "oxygen", "food"]:
		if not _positive_integer(value.initial.get(key)):
			return false
	for key in ["support", "research"]:
		if not value.actions.get(key) is Dictionary:
			return false
	for action in value.actions.values():
		if not action is Dictionary or not _positive_integer(action.get("energy")):
			return false
		if not action.get("label") is String or not action.get("description") is String:
			return false
		for key in ["oxygen", "science"]:
			if action.has(key) and (not _number(action[key]) or action[key] < 0):
				return false
	return value.initial.energy <= value.battery_capacity

func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

func _positive_integer(value: Variant) -> bool:
	return _number(value) and value > 0 and value <= 1000
