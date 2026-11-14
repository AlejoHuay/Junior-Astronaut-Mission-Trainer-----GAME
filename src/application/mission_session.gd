class_name MissionSession
extends RefCounted

signal changed
signal message(text: String)

var rules: MissionRules
var state: MissionState

func _init(settings: Dictionary) -> void:
	rules = MissionRules.new(settings)

func start(seed_value: int = 214, scenario_id: String = "demo") -> void:
	state = rules.start(seed_value, scenario_id)
	changed.emit()

func choose(action_id: String, expected_sol: int) -> void:
	if state == null:
		return
	var result := rules.resolve(state, action_id, expected_sol)
	if not result.ok:
		message.emit(result.reason)
		return
	changed.emit()
