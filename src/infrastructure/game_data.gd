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
	var catalog_file := FileAccess.open("res://data/events/scenarios.json", FileAccess.READ)
	if catalog_file == null:
		error = "No se pudo abrir el catálogo de escenarios."
		return {}
	var catalog = JSON.parse_string(catalog_file.get_as_text())
	if not catalog is Dictionary or not validate_events(catalog, int(parsed.mission_sols)):
		error = "El catálogo de eventos no es válido."
		return {}
	parsed["events"] = catalog.events
	parsed["scenarios"] = catalog.scenarios
	return parsed

func validate_balance(value: Dictionary) -> bool:
	for key in ["mission_sols", "battery_capacity", "solar_per_sol", "oxygen_per_sol", "food_per_sol", "crop_turns", "harvest_food", "communication_delay", "advice_oxygen_bonus", "panel_fault_loss", "science_goal"]:
		if not _positive_integer(value.get(key)):
			return false
	if not value.get("initial") is Dictionary or not value.get("actions") is Dictionary:
		return false
	if not value.get("outcomes") is Dictionary:
		return false
	for code in ["success", "safety", "oxygen", "food", "oxygen_food"]:
		if not value.outcomes.get(code) is String or value.outcomes[code].is_empty():
			return false
	for key in ["energy", "oxygen", "food", "materials"]:
		if not _positive_integer(value.initial.get(key)):
			return false
	if value.crop_turns < 2 or value.crop_turns > value.mission_sols:
		return false
	for key in ["support", "research", "grow", "shelter", "reinforce", "eva", "radio", "repair"]:
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
		var work = action.get("work_energy", 0)
		if not _number(work) or work < 0 or cost + work > value.battery_capacity:
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

func validate_events(catalog: Dictionary, sols: int) -> bool:
	if not catalog.get("events") is Dictionary or not catalog.get("scenarios") is Dictionary:
		return false
	for event_id in ["clear", "dust", "solar", "failure"]:
		var event = catalog.events.get(event_id)
		if not event is Dictionary or not event.get("label") is String or not event.get("description") is String:
			return false
		if not _number(event.get("solar")) or event.solar < 0 or event.solar > 1000:
			return false
	for scenario_id in ["training", "demo", "exploration"]:
		if not catalog.scenarios.has(scenario_id):
			return false
	for scenario in catalog.scenarios.values():
		if not scenario is Dictionary or not scenario.get("label") is String or not scenario.get("description") is String:
			return false
		if not scenario.get("timeline") is Array or scenario.timeline.size() != sols:
			return false
		for entry in scenario.timeline:
			if entry is String:
				if not catalog.events.has(entry):
					return false
			elif entry is Array and not entry.is_empty():
				for choice in entry:
					if not choice is String or choice not in ["clear", "dust", "failure"]:
						return false
			else:
				return false
	return true

func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

func _positive_integer(value: Variant) -> bool:
	return _number(value) and value > 0 and value <= 1000
