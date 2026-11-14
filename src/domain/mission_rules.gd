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
	state.phase = MissionState.Phase.DECISION
	return state

func preview(state: MissionState, action_id: String) -> Dictionary:
	if state.phase != MissionState.Phase.DECISION:
		return {"ok": false, "reason": "La misión ya terminó."}
	if not config.actions.has(action_id):
		return {"ok": false, "reason": "Acción desconocida."}
	var action: Dictionary = config.actions[action_id]
	var cost := int(action.allocation.life_support) + int(action.allocation.science)
	if state.energy < cost:
		return {"ok": false, "reason": "Necesitas %d de energía; tienes %d. Faltan %d. La recarga solar llega después del trabajo." % [cost, state.energy, cost - state.energy]}
	# Only known effects: no RNG draws or state changes while considering a plan.
	var stored := mini(int(config.solar_per_sol), int(config.battery_capacity) - (state.energy - cost))
	return {"ok": true, "reason": action.description, "cost": cost,
		"allocation": action.allocation.duplicate(), "oxygen_produced": int(action.get("oxygen", 0)),
		"oxygen_consumed": int(config.oxygen_per_sol), "food_consumed": int(config.food_per_sol),
		"solar_generated": int(config.solar_per_sol), "solar_stored": stored,
		"solar_spilled": int(config.solar_per_sol) - stored,
		"science_gained": int(action.get("science", 0)),
		"energy_after": state.energy - cost + stored,
		"oxygen_after": maxi(0, state.oxygen + int(action.get("oxygen", 0)) - int(config.oxygen_per_sol)),
		"food_after": maxi(0, state.food - int(config.food_per_sol))}

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
	state.science += int(check.science_gained)
	if state.oxygen == 0 or state.food == 0:
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
