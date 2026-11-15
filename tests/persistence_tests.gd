extends SceneTree

var checks := 0
var failures := 0

func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: " + description)

func _initialize() -> void:
	var config := GameData.new().load_balance()
	var store := MissionStore.new("user://persistence-test.save")
	for scenario in config.scenarios:
		for seed_value in [1, 214, 999999]:
			for strategy in [["grow", "grow", "support", "shelter", "combined", "eva", "support"], ["grow", "grow", "support", "shelter", "radio", "support", "support"], ["research", "research", "research"]]:
				var uninterrupted := MissionSession.new(config)
				var resumed := MissionSession.new(config, store)
				uninterrupted.start(seed_value, scenario)
				resumed.start(seed_value, scenario)
				for action in strategy:
					var loaded := MissionSession.new(config, store)
					check(loaded.restore(), "restore valid save")
					if loaded.state == null:
						quit(1)
						return
					check(loaded.state.snapshot() == resumed.state.snapshot(), "all state preserved")
					resumed = loaded
					var sol := resumed.state.sol
					uninterrupted.choose(action, uninterrupted.state.sol)
					resumed.choose(action, sol)
					check(uninterrupted.state.snapshot() == resumed.state.snapshot(), "continuation identical")
					if resumed.state.sol != sol:
						resumed.choose(action, sol)
						check(uninterrupted.state.snapshot() == resumed.state.snapshot(), "duplicate rejected after load")
					if resumed.state.phase == MissionState.Phase.FINISHED:
						var final_load := MissionSession.new(config, store)
						check(final_load.restore() and final_load.state.snapshot() == resumed.state.snapshot(), "final persisted")
						break
	var session := MissionSession.new(config, store)
	session.start(214, "demo")
	var original := session.state.snapshot()
	for field in ["rng", "pending", "energy", "history", "phase", "seed", "scenario_id"]:
		var corrupt := original.duplicate(true)
		corrupt[field] = "invalid"
		store.write_save({"version": 1, "state": corrupt})
		check(not session.restore(), "reject corrupt " + field)
		check(session.state.snapshot() == original, "invalid load leaves mission intact")
	for raw in ["{", "[]", "null", "{\"version\":99}"]:
		var file := FileAccess.open(store.path, FileAccess.WRITE)
		file.store_string(raw)
		file.close()
		check(not session.restore(), "reject invalid format")
	var unavailable := MissionSession.new(config, MissionStore.new("user://nonexistent-directory/mission.save"))
	unavailable.start(214)
	unavailable.choose("grow", 1)
	check(unavailable.state.sol == 2 and not unavailable.storage_notice.is_empty(), "storage failure does not stop play")
	DirAccess.remove_absolute(store.path)
	print("Persistence: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
