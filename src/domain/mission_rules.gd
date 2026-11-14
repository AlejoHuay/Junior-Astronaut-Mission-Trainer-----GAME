class_name MissionRules
extends RefCounted

var config: Dictionary
var rng := RandomNumberGenerator.new()

func _init(settings: Dictionary) -> void:
	config = settings.duplicate(true)

func start(seed_value: int, scenario_id: String = "training") -> MissionState:
	var state := MissionState.new()
	state.mission_seed = seed_value
	rng.seed = seed_value
	state.rng_state = rng.state
	state.energy = int(config.initial.energy)
	state.oxygen = int(config.initial.oxygen)
	state.food = int(config.initial.food)
	state.materials = int(config.initial.materials)
	state.scenario_id = scenario_id if config.scenarios.has(scenario_id) else "training"
	state.phase = MissionState.Phase.DECISION
	_prepare_sol(state)
	return state

func _prepare_sol(state: MissionState) -> void:
	# Random draws happen only when an uncertain event becomes current, never in preview.
	rng.state = state.rng_state
	var timeline: Array = config.scenarios[state.scenario_id].timeline
	var entry = timeline[state.sol - 1]
	state.current_event = str(entry[rng.randi_range(0, entry.size() - 1)]) if entry is Array else str(entry)
	state.rng_state = rng.state
	state.solar_alert = state.current_event == "solar"
	state.solar_output = int(config.events[state.current_event].solar)
	state.next_solar_alert = state.sol < timeline.size() and timeline[state.sol] is String and timeline[state.sol] == "solar"
	if state.current_event == "failure":
		state.panel_fault = true
	var remaining: Array[Dictionary] = []
	for effect in state.pending:
		if int(effect.due_sol) <= state.sol:
			state.advice_ready = true
			state.radio_message = "Llegó el consejo: optimiza una producción local de oxígeno (+%d). No son suministros enviados desde la Tierra." % config.advice_oxygen_bonus
		else:
			remaining.append(effect)
	state.pending = remaining

func preview(state: MissionState, action_id: String) -> Dictionary:
	if state.phase != MissionState.Phase.DECISION:
		return {"ok": false, "reason": "La misión ya terminó."}
	if not config.actions.has(action_id):
		return {"ok": false, "reason": "Acción desconocida."}
	var action: Dictionary = config.actions[action_id]
	if action_id == "radio" and state.radio_sent:
		return {"ok": false, "reason": "Ya enviaste la consulta de esta misión. Revisa la radio y el sol de respuesta."}
	if action_id == "repair" and not state.panel_fault:
		return {"ok": false, "reason": "Los paneles no tienen avería que reparar."}
	if action.get("reinforce", false) and state.reinforced:
		return {"ok": false, "reason": "La base ya tiene el refuerzo instalado."}
	if state.materials < int(action.get("materials", 0)):
		return {"ok": false, "reason": "No quedan materiales suficientes para este trabajo."}
	var cost := int(action.allocation.life_support) + int(action.allocation.science) + int(action.allocation.greenhouse) + int(action.get("work_energy", 0))
	if state.energy < cost:
		return {"ok": false, "reason": "Necesitas %d de energía; tienes %d. Faltan %d. La recarga solar llega después del trabajo." % [cost, state.energy, cost - state.energy]}
	# Only known effects: no RNG draws or state changes while considering a plan.
	var solar := maxi(0, state.solar_output - (int(config.panel_fault_loss) if state.panel_fault and action_id != "repair" else 0))
	var stored := mini(solar, int(config.battery_capacity) - (state.energy - cost))
	var oxygen_produced := int(action.get("oxygen", 0))
	var uses_advice := state.advice_ready and oxygen_produced > 0
	if uses_advice:
		oxygen_produced += int(config.advice_oxygen_bonus)
	var crop := _crop_budget(state, int(action.allocation.greenhouse) > 0)
	var location: String = action.get("location", "inside")
	var protected := location == "shelter" or (state.reinforced and location == "inside")
	var oxygen_used := int(config.oxygen_per_sol) + int(action.get("extra_oxygen", 0))
	return {"ok": true, "reason": action.description, "cost": cost,
		"work_energy": int(action.get("work_energy", 0)), "uses_advice": uses_advice,
		"radio_due_sol": state.sol + int(config.communication_delay) if action_id == "radio" else 0,
		"materials_used": int(action.get("materials", 0)), "protected": protected,
		"sheltered": location == "shelter", "safety_stop": state.solar_alert and not protected,
		"crop": crop,
		"allocation": action.allocation.duplicate(), "oxygen_produced": oxygen_produced,
		"oxygen_consumed": oxygen_used, "food_consumed": int(config.food_per_sol),
		"solar_generated": solar, "solar_stored": stored,
		"solar_spilled": solar - stored,
		"science_gained": int(action.get("science", 0)),
		"energy_after": state.energy - cost + stored,
		"oxygen_after": maxi(0, state.oxygen + oxygen_produced - oxygen_used),
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
	if check.uses_advice:
		state.advice_ready = false
		state.radio_message = "Consejo aplicado a una producción local. No queda bonificación pendiente."
	if action_id == "radio":
		state.radio_sent = true
		state.pending.append({"kind": "advice", "due_sol": int(check.radio_due_sol)})
		state.radio_message = "Consulta enviada. Respuesta al inicio del sol %d; decide con reservas locales mientras esperas." % check.radio_due_sol
	if action_id == "repair":
		state.panel_fault = false
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
		"event": state.current_event, "materials_used": check.materials_used,
		"energy": state.energy - int(before.energy), "oxygen": state.oxygen - int(before.oxygen),
		"food": state.food - int(before.food), "science": state.science - int(before.science),
		"budget": check.duplicate(true)}
	state.history.append(report)
	if state.phase != MissionState.Phase.FINISHED:
		state.sol += 1
		_prepare_sol(state)
	return report
