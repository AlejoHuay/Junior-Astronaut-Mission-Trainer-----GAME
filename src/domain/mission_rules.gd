class_name MissionRules
extends RefCounted

var config: Dictionary
var rng := RandomNumberGenerator.new()

func _init(settings: Dictionary) -> void:
	config = settings.duplicate(true)

func start(seed_value: int) -> MissionState:
	var state := MissionState.new()
	state.mission_seed = seed_value
	rng.seed = seed_value
	state.rng_state = rng.state
	state.energy = int(config.initial.energy)
	state.oxygen = int(config.initial.oxygen)
	state.food = int(config.initial.food)
	state.materials = int(config.initial.materials)
	state.phase = MissionState.Phase.DECISION
	return state

func preview(state: MissionState, action_id: String) -> Dictionary:
	if state.phase != MissionState.Phase.DECISION:
		return {"ok": false, "reason": "La misión ya terminó."}
	if not config.actions.has(action_id):
		return {"ok": false, "reason": "Acción desconocida."}
	var action: Dictionary = config.actions[action_id]
	if action.get("reinforce", false) and state.reinforced:
		return {"ok": false, "reason": "La base ya tiene el refuerzo instalado."}
	if state.materials < int(action.get("materials", 0)):
		return {"ok": false, "reason": "No quedan materiales suficientes para este trabajo."}
	var cost := int(action.allocation.life_support) + int(action.allocation.science) + int(action.allocation.greenhouse)
	if state.energy < cost:
		return {"ok": false, "reason": "Necesitas %d de energía; tienes %d. Faltan %d. La recarga solar llega después del trabajo." % [cost, state.energy, cost - state.energy]}
	# Only known effects: no RNG draws or state changes while considering a plan.
	var stored := mini(int(config.solar_per_sol), int(config.battery_capacity) - (state.energy - cost))
	var crop := _crop_budget(state, int(action.allocation.greenhouse) > 0)
	var location: String = action.get("location", "inside")
	var protected := location == "shelter" or (state.reinforced and location == "inside")
	var oxygen_used := int(config.oxygen_per_sol) + int(action.get("extra_oxygen", 0))
	return {"ok": true, "reason": action.description, "cost": cost,
		"materials_used": int(action.get("materials", 0)), "protected": protected,
		"sheltered": location == "shelter", "safety_stop": state.solar_alert and not protected,
		"crop": crop,
		"allocation": action.allocation.duplicate(), "oxygen_produced": int(action.get("oxygen", 0)),
		"oxygen_consumed": oxygen_used, "food_consumed": int(config.food_per_sol),
		"solar_generated": int(config.solar_per_sol), "solar_stored": stored,
		"solar_spilled": int(config.solar_per_sol) - stored,
		"science_gained": int(action.get("science", 0)),
		"energy_after": state.energy - cost + stored,
		"oxygen_after": maxi(0, state.oxygen + int(action.get("oxygen", 0)) - oxygen_used),
		"food_after": maxi(0, state.food + int(crop.harvest) - int(config.food_per_sol))}

func _crop_budget(state: MissionState, powered: bool) -> Dictionary:
	var progress := state.crop_progress + 1 if powered else 0
	var harvested := progress >= int(config.crop_turns)
	return {"progress_after": 0 if harvested else progress,
		"harvest": int(config.harvest_food) if harvested else 0,
		"interrupted": state.crop_progress > 0 and not powered,
		"remaining": int(config.crop_turns) - progress if powered and not harvested else 0,
		"due_sol": state.sol + int(config.crop_turns) - progress if powered and not harvested else 0}

func resolve(state: MissionState, action_id: String, expected_sol: int) -> Dictionary:
	if expected_sol != state.sol:
		return {"ok": false, "reason": "Este turno ya fue resuelto."}
	var check := preview(state, action_id)
	if not check.ok:
		return check
	state.phase = MissionState.Phase.RESOLUTION
	var before := state.snapshot()
	state.energy = int(check.energy_after)
	state.oxygen = int(check.oxygen_after)
	state.food = int(check.food_after)
	state.crop_progress = int(check.crop.progress_after)
	state.science += int(check.science_gained)
	state.materials -= int(check.materials_used)
	state.sheltered = bool(check.sheltered)
	state.safety_stop = bool(check.safety_stop)
	if config.actions[action_id].get("reinforce", false):
		state.reinforced = true
	if state.safety_stop:
		state.outcome = "Misión detenida por seguridad: durante una alerta solar necesitas refugio o protección interior instalada antes del sol. No es una predicción médica."
	elif state.oxygen == 0 or state.food == 0:
		state.outcome = "La base necesita una pausa: se agotaron las reservas. Prueba otro plan."
	elif state.sol == int(config.mission_sols):
		state.outcome = "¡Completaste los 7 soles! Tu equipo mantuvo la base en marcha."
	state.phase = MissionState.Phase.FINISHED if not state.outcome.is_empty() else MissionState.Phase.DECISION
	var report := {"ok": true, "sol": state.sol, "action": action_id,
		"energy": state.energy - int(before.energy), "oxygen": state.oxygen - int(before.oxygen),
		"food": state.food - int(before.food), "science": state.science - int(before.science),
		"budget": check.duplicate(true)}
	state.history.append(report)
	if state.phase != MissionState.Phase.FINISHED:
		state.sol += 1
	return report
