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
	for key in ["mission_sols", "battery_capacity", "solar_per_sol", "oxygen_per_sol", "food_per_sol", "crop_turns", "harvest_food"]:
		if not _positive_integer(value.get(key)):
			return false
	if not value.get("initial") is Dictionary or not value.get("actions") is Dictionary:
		return false
	for key in ["energy", "oxygen", "food", "materials"]:
		if not _positive_integer(value.initial.get(key)):
			return false
	if value.crop_turns < 2 or value.crop_turns > value.mission_sols:
		return false
	for key in ["support", "research", "grow", "shelter", "reinforce", "eva"]:
		if not value.actions.get(key) is Dictionary:
			return false
	for action in value.actions.values():
		if not action is Dictionary or not action.get("allocation") is Dictionary:
			return false
		if action.allocation.size() != 3:
			return false
		var cost: int = 0
		for system in ["life_support", "science", "greenhouse"]:
			var amount = action.allocation.get(system)
			if not _number(amount) or amount < 0 or amount > value.battery_capacity:
				return false
			cost += int(amount)
		if cost > value.battery_capacity:
			return false
		if not action.get("label") is String or not action.get("description") is String:
			return false
		for key in ["oxygen", "science", "materials", "extra_oxygen"]:
			if action.has(key) and (not _number(action[key]) or action[key] < 0 or action[key] > 1000):
				return false
		if action.get("oxygen", 0) > 0 and action.allocation.life_support == 0:
			return false
		if action.get("science", 0) > 0 and action.allocation.science == 0:
			return false
		if action.get("location", "inside") not in ["inside", "outside", "shelter"]:
			return false
		if not action.get("reinforce", false) is bool:
			return false
		if action.get("reinforce", false) and action.get("materials", 0) <= 0:
			return false
	if not value.actions.has("reserve"):
		return false
	var reserve: Dictionary = value.actions.reserve
	if reserve.allocation.life_support != 0 or reserve.allocation.science != 0 or reserve.allocation.greenhouse != 0 or reserve.get("oxygen", 0) != 0 or reserve.get("science", 0) != 0:
		return false
	if value.actions.grow.allocation.greenhouse <= 0:
		return false
	return value.initial.energy <= value.battery_capacity

func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

func _positive_integer(value: Variant) -> bool:
	return _number(value) and value > 0 and value <= 1000
