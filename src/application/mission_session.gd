class_name MissionSession
extends RefCounted

signal changed
signal message(text: String)

var rules: MissionRules
var state: MissionState
var store: MissionStore
var storage_notice: String = ""

func _init(settings: Dictionary, storage: MissionStore = null) -> void:
	rules = MissionRules.new(settings)
	store = storage

func start(seed_value: int = 214, scenario_id: String = "demo") -> void:
	state = rules.start(seed_value, scenario_id)
	_save()
	changed.emit()

func choose(action_id: String, expected_sol: int) -> void:
	if state == null:
		return
	var result := rules.resolve(state, action_id, expected_sol)
	if not result.ok:
		message.emit(result.reason)
		return
	_save()
	changed.emit()

func _save() -> void:
	if store != null:
		store.write_save({"version": MissionStore.VERSION, "state": state.snapshot()})
		storage_notice = store.error

func restore() -> bool:
	if store == null:
		return false
	var document := store.read_save()
	storage_notice = store.error
	if document.is_empty():
		return false
	var saved = document.get("state")
	if not saved is Dictionary:
		return _invalid_save()
	if not saved.get("seed") is String or not saved.seed.is_valid_int():
		return _invalid_save()
	if not saved.get("scenario_id") is String or not rules.config.scenarios.has(saved.scenario_id):
		return _invalid_save()
	if not saved.get("history") is Array or saved.history.size() > int(rules.config.mission_sols):
		return _invalid_save()
	# Replay validates every field, including pending effects and the exact 64-bit RNG string.
	# The live session is replaced only after the entire document has been verified.
	var verifier := MissionRules.new(rules.config)
	var candidate := verifier.start(int(saved.seed), saved.scenario_id)
	for entry in saved.history:
		if not entry is Dictionary or not entry.get("action") is String:
			return _invalid_save()
		if not verifier.resolve(candidate, entry.action, candidate.sol).ok:
			return _invalid_save()
	if JSON.parse_string(JSON.stringify(candidate.snapshot())) != saved:
		return _invalid_save()
	state = candidate
	return true

func _invalid_save() -> bool:
	storage_notice = "El guardado no coincide con las reglas actuales. Puedes comenzar otra misión."
	return false
