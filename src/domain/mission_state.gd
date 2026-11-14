class_name MissionState
extends RefCounted

enum Phase { PREPARATION, DECISION, RESOLUTION, FINISHED }

var phase: Phase = Phase.PREPARATION
var sol: int = 1
var energy: int = 0
var oxygen: int = 0
var food: int = 0
var science: int = 0
var crop_progress: int = 0
var materials: int = 0
var reinforced: bool = false
var solar_alert: bool = false
var sheltered: bool = false
var safety_stop: bool = false
var mission_seed: int = 0
var rng_state: int = 0
var history: Array[Dictionary] = []
var outcome: String = ""

func snapshot() -> Dictionary:
	return {"phase": phase, "sol": sol, "energy": energy, "oxygen": oxygen,
		"food": food, "science": science, "crop_progress": crop_progress,
		"materials": materials, "reinforced": reinforced, "solar_alert": solar_alert,
		"sheltered": sheltered, "safety_stop": safety_stop,
		"seed": str(mission_seed), "rng": str(rng_state),
		"history": history.duplicate(true), "outcome": outcome}
