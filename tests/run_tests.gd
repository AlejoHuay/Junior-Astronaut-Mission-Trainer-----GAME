extends SceneTree

var failures: int = 0
var assertions: int = 0

func check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", message)

func _initialize() -> void:
	var data := GameData.new()
	var config := data.load_balance()
	check(not config.is_empty(), "Balance loads")
	if config.is_empty():
		quit(1)
		return
	var rules := MissionRules.new(config)
	var first := rules.start(214)
	var second := rules.start(214)
	for action in ["grow", "grow", "support", "research", "support", "research", "support"]:
		check(rules.resolve(first, action, first.sol).ok, "Action resolves")
		rules.resolve(second, action, second.sol)
	check(first.snapshot() == second.snapshot(), "Same seed/actions reproduce all state")
	check(first.phase == MissionState.Phase.FINISHED and first.oxygen > 0, "Seven sols finish")
	check(not rules.resolve(first, "support", first.sol).ok, "Finished mission cannot resolve")
	var poor := rules.start(1)
	poor.energy = 1
	var unchanged := poor.snapshot()
	check(not rules.resolve(poor, "support", 1).ok and poor.snapshot() == unchanged, "Rejected action is atomic")
	var duplicate := rules.start(2)
	rules.resolve(duplicate, "support", 1)
	check(not rules.resolve(duplicate, "support", 1).ok, "Stale sol cannot resolve twice")
	var bad := config.duplicate(true)
	bad.oxygen_per_sol = -1
	check(not data.validate_balance(bad), "Malformed balance rejected")
	test_energy_budget(config, data)
	test_crops(config, data)
	test_protection(config)
	test_events_and_radio(config, data)
	test_phase_two_strategies(config)
	print("Tests: %d assertions, %d failures" % [assertions, failures])
	quit(1 if failures else 0)

func test_energy_budget(config: Dictionary, data: GameData) -> void:
	var rules := MissionRules.new(config)
	var state := rules.start(214)
	var original := state.snapshot()
	var plan := rules.preview(state, "combined")
	check(plan.cost == 6 and plan.energy_after == 6 and plan.oxygen_after == 8, "Combined plan splits six energy and depletes battery by two")
	check(state.snapshot() == original, "Preview preserves resources, history, seed and RNG")
	rules.resolve(state, "combined", 1)
	check(state.energy == plan.energy_after and state.oxygen == plan.oxygen_after and state.food == plan.food_after, "Preview matches resolved known effects")
	rules.resolve(state, "combined", 2)
	check(state.energy == 4 and not rules.preview(state, "combined").ok, "Repeated combined work becomes unaffordable")
	var rejected := state.snapshot()
	check(not rules.resolve(state, "combined", 3).ok and state.snapshot() == rejected, "Cannot borrow future sunlight; rejection leaves state unchanged")
	check(rules.preview(state, "combined").reason.contains("Faltan 2"), "Insufficient energy explains exact shortfall")
	rules.resolve(state, "reserve", 3)
	check(state.energy == 8 and state.oxygen == 7 and state.science == 4, "Reserve restores energy but costs oxygen and science opportunity")
	state.energy = 12
	plan = rules.preview(state, "reserve")
	check(plan.solar_stored == 0 and plan.solar_spilled == 4 and plan.energy_after == 12, "Full battery cannot store surplus sunlight")
	state.energy = 11
	plan = rules.preview(state, "reserve")
	check(plan.solar_stored == 1 and plan.solar_spilled == 3, "Partial charging accounts for overflow")
	state.energy = 0
	check(rules.preview(state, "reserve").ok, "Zero energy retains a recovery action")
	check(not rules.preview(state, "support").ok, "Solar recharge cannot pay an earlier action")
	state.energy = 4
	state.oxygen = 1
	rules.resolve(state, "support", state.sol)
	check(state.oxygen == 4 and state.energy == 4, "Exact-cost action works; oxygen production precedes consumption")
	state = rules.start(214)
	for index in range(4):
		rules.resolve(state, "research", state.sol)
	check(state.oxygen == 0 and state.phase == MissionState.Phase.FINISHED, "Oxygen exhaustion finishes mission")
	check(not rules.preview(state, "reserve").ok, "Cannot recover after mission ends")
	for energy in range(13):
		for action_id in config.actions:
			var sample := rules.start(214)
			sample.energy = energy
			var estimate := rules.preview(sample, action_id)
			if estimate.ok:
				var result := rules.resolve(sample, action_id, 1)
				check(sample.energy >= 0 and sample.energy <= 12 and sample.energy == estimate.energy_after, "Battery bounds and preview agree across all affordable plans")
				check(result.budget.solar_stored + result.budget.solar_spilled == 4, "Solar energy is accounted for")
	for invalid in [-1, 0.5, "4", 13]:
		var bad := config.duplicate(true)
		bad.actions.support.allocation.life_support = invalid
		check(not data.validate_balance(bad), "Invalid energy allocation rejected")
	var free_production := config.duplicate(true)
	free_production.actions.support.allocation.life_support = 0
	check(not data.validate_balance(free_production), "Free oxygen production rejected")
	var broken_reserve := config.duplicate(true)
	broken_reserve.actions.reserve.allocation.science = 1
	check(not data.validate_balance(broken_reserve), "Recovery action must remain available at zero energy")

func test_crops(config: Dictionary, data: GameData) -> void:
	var rules := MissionRules.new(config)
	var state := rules.start(214)
	var before := state.snapshot()
	var preview := rules.preview(state, "grow")
	check(preview.crop.harvest == 0 and preview.crop.due_sol == 2, "Planting forecasts conditional harvest without immediate food")
	check(state.snapshot() == before, "Crop preview preserves state")
	rules.resolve(state, "grow", 1)
	check(state.food == 4 and state.crop_progress == 1 and state.energy == 9, "First care costs energy and food without a harvest")
	preview = rules.preview(state, "grow")
	check(preview.crop.harvest == 4 and preview.food_after == 7, "Mature harvest preview includes consumption")
	rules.resolve(state, "grow", 2)
	check(state.food == 7 and state.crop_progress == 0, "Second consecutive care harvests once and resets cycle")
	before = state.snapshot()
	check(not rules.resolve(state, "grow", 2).ok and state.snapshot() == before, "Duplicate turn cannot duplicate harvest")
	rules.resolve(state, "support", 3)
	check(state.food == 6 and state.history.back().budget.crop.harvest == 0, "No automatic repeated harvest")
	state = rules.start(214)
	rules.resolve(state, "grow", 1)
	preview = rules.preview(state, "support")
	check(preview.crop.interrupted and preview.crop.progress_after == 0, "Changing task warns about lost crop")
	rules.resolve(state, "support", 2)
	check(state.crop_progress == 0 and state.food == 3 and state.energy == 9, "Interruption loses progress without refund")
	rules.resolve(state, "grow", 3)
	check(state.crop_progress == 1 and state.food == 2, "Restart needs the entire growth cycle")
	state.energy = 0
	before = state.snapshot()
	check(not rules.resolve(state, "grow", 4).ok and state.snapshot() == before, "Unaffordable care does not advance or destroy crop")
	rules.resolve(state, "reserve", 4)
	check(state.crop_progress == 0 and state.food == 1, "Choosing to reserve interrupts cultivation")
	state = rules.start(214)
	state.food = 1
	state.crop_progress = 1
	rules.resolve(state, "grow", 1)
	check(state.food == 4 and state.phase == MissionState.Phase.DECISION, "Harvest arrives before daily consumption and rescues low food")
	state = rules.start(214)
	state.food = 1
	rules.resolve(state, "grow", 1)
	check(state.food == 0 and state.phase == MissionState.Phase.FINISHED, "Starting cultivation too late does not prevent shortage")
	state = rules.start(214)
	state.sol = 7
	preview = rules.preview(state, "grow")
	check(preview.crop.due_sol == 8, "Late planting explicitly forecasts beyond mission end")
	for invalid in [0, 1, 8, 2.5, "2"]:
		var bad := config.duplicate(true)
		bad.crop_turns = invalid
		check(not data.validate_balance(bad), "Invalid growth duration rejected")
	var bad_yield := config.duplicate(true)
	bad_yield.harvest_food = -4
	check(not data.validate_balance(bad_yield), "Invalid yield rejected")
	var free_crop := config.duplicate(true)
	free_crop.actions.grow.allocation.greenhouse = 0
	check(not data.validate_balance(free_crop), "Free cultivation rejected")

func test_protection(config: Dictionary) -> void:
	var rules := MissionRules.new(config)
	var state := rules.start(214)
	state.solar_alert = true
	var plan := rules.preview(state, "shelter")
	check(plan.cost == 0 and plan.protected and not plan.safety_stop and plan.science_gained == 0, "Passive shelter protects at cost of work, not electricity")
	rules.resolve(state, "shelter", 1)
	check(state.sheltered and state.phase == MissionState.Phase.DECISION and state.oxygen == 4, "Shelter consumes oxygen, transfer oxygen and food")
	state = rules.start(214)
	rules.resolve(state, "reinforce", 1)
	check(state.reinforced and state.materials == 0, "Reinforcement spends limited materials and turn")
	check(not rules.preview(state, "reinforce").ok, "Upgrade cannot be repeated")
	state.solar_alert = true
	check(not rules.preview(state, "support").safety_stop, "Prior reinforcement protects indoor work")
	check(rules.preview(state, "eva").safety_stop, "Interior shielding does not protect outside work")
	state = rules.start(214)
	state.solar_alert = true
	check(rules.preview(state, "reinforce").safety_stop, "Cannot install shielding retroactively during alert")
	rules.resolve(state, "eva", 1)
	check(state.safety_stop and state.phase == MissionState.Phase.FINISHED, "Unsafe EVA stops mission without clinical model")
	state = rules.start(214)
	rules.resolve(state, "eva", 1)
	check(state.science == 3 and state.oxygen == 4, "EVA rewards science but consumes extra suit oxygen")
	state = rules.start(214)
	state.materials = 1
	var before := state.snapshot()
	check(not rules.resolve(state, "reinforce", 1).ok and state.snapshot() == before, "Insufficient materials rejected atomically")

func test_events_and_radio(config: Dictionary, data: GameData) -> void:
	var rules := MissionRules.new(config)
	var state := rules.start(214, "demo")
	rules.resolve(state, "grow", 1)
	rules.resolve(state, "grow", 2)
	check(state.current_event == "dust" and state.next_solar_alert, "Dust and advance solar warning appear at start of sol three")
	check(rules.preview(state, "support").solar_generated == 2, "Dust reduces actual generation")
	rules.resolve(state, "support", 3)
	check(state.solar_alert and state.current_event == "solar", "Alert starts before fourth decision")
	rules.resolve(state, "shelter", 4)
	rules.resolve(state, "support", 5)
	check(state.panel_fault and state.current_event == "failure", "Fault persists until repaired")
	var repair := rules.preview(state, "repair")
	check(repair.solar_generated == 4 and repair.materials_used == 1 and repair.cost == 1, "Repair restores current charging with local cost")
	rules.resolve(state, "repair", 6)
	check(not state.panel_fault and state.materials == 1 and not rules.preview(state, "repair").ok, "Repair clears fault once")
	state = rules.start(214)
	var before := state.snapshot()
	rules.preview(state, "radio")
	check(state.snapshot() == before, "Radio preview never queues a request")
	rules.resolve(state, "radio", 1)
	check(state.pending.size() == 1 and state.pending[0].due_sol == 3 and not state.advice_ready, "Request waits two sols")
	check(state.materials == 2 and state.food == 4 and state.oxygen == 5, "Radio does not deliver resources instantly")
	check(not rules.preview(state, "radio").ok, "Duplicate request rejected")
	rules.resolve(state, "support", 2)
	check(state.advice_ready and state.pending.is_empty(), "Reply delivered once at start of due sol")
	check(rules.preview(state, "support").oxygen_produced == 7, "Advice improves a local operation")
	rules.resolve(state, "support", 3)
	check(not state.advice_ready and rules.preview(state, "support").oxygen_produced == 5, "Advice bonus consumed once")
	state = rules.start(214)
	state.sol = 7
	check(rules.preview(state, "radio").radio_due_sol == 9, "Late radio request remains beyond mission horizon")
	var a := rules.start(77, "exploration")
	var b := rules.start(77, "exploration")
	for action in ["grow", "grow", "support", "shelter", "support", "research", "support"]:
		var snapshot := a.snapshot()
		rules.preview(a, action)
		rules.preview(a, action)
		check(a.snapshot() == snapshot, "Uncertain events are not drawn by preview")
		rules.resolve(a, action, a.sol)
		rules.resolve(b, action, b.sol)
	check(a.snapshot() == b.snapshot(), "Interleaved missions preserve independent RNG state")
	var bad := {"events": config.events.duplicate(true), "scenarios": config.scenarios.duplicate(true)}
	bad.scenarios.demo.timeline[0] = "invented"
	check(not data.validate_events(bad, 7), "Unknown event rejected")
	bad.scenarios.demo.timeline[0] = ["solar"]
	check(not data.validate_events(bad, 7), "Unannounced random solar alerts rejected")

func test_phase_two_strategies(config: Dictionary) -> void:
	var fixtures: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/strategies.json"))
	var results: Dictionary = {}
	for scenario in ["training", "demo", "exploration"]:
		for seed_value in [1, 77, 214, 999]:
			for strategy in fixtures:
				var rules := MissionRules.new(config)
				var state := rules.start(seed_value, scenario)
				for action in fixtures[strategy]:
					check(rules.resolve(state, action, state.sol).ok, "%s/%s/%d action resolves" % [scenario, strategy, seed_value])
				check(state.outcome_code == "success" and state.history.size() == 7, "%s/%s/%d survives seven sols" % [scenario, strategy, seed_value])
				if scenario == "demo" and seed_value == 214:
					results[strategy] = state
					print("Strategy %s: energy=%d oxygen=%d food=%d science=%d materials=%d" % [strategy, state.energy, state.oxygen, state.food, state.science, state.materials])
	check(results.scientific.science > results.cautious.science and results.scientific.oxygen < results.cautious.oxygen, "More science sacrifices oxygen reserves")
	check(results.reinforced.materials == 0 and results.cautious.materials == 2, "Working inside during alert costs upgrade materials")
	check(results.radio.science == 0 and results.radio.oxygen > results.cautious.oxygen, "Waiting for advice trades science for later oxygen")
	var rules := MissionRules.new(config)
	check(rules.summary(results.scientific).science_goal and rules.summary(results.scientific).sample_goal, "Scientific strategy earns optional goals")
	check(not rules.summary(results.cautious).science_goal and rules.summary(results.cautious).success, "Optional science never gates survival victory")
	var food_failure := rules.start(214)
	for index in range(5):
		rules.resolve(food_failure, "support", food_failure.sol)
	check(food_failure.outcome_code == "food", "Food shortage has a specific ending")
	var oxygen_failure := rules.start(214)
	for index in range(4):
		rules.resolve(oxygen_failure, "research", oxygen_failure.sol)
	check(oxygen_failure.outcome_code == "oxygen", "Oxygen shortage has a specific ending")
	var unsafe := rules.start(214)
	unsafe.sol = 7
	unsafe.solar_alert = true
	rules.resolve(unsafe, "eva", 7)
	check(unsafe.outcome_code == "safety", "Safety failure takes precedence over last-sol victory")
	var expired := rules.start(214)
	expired.sol = 7
	expired.food = 1
	rules.resolve(expired, "support", 7)
	check(expired.outcome_code == "food", "Reserve failure takes precedence over last-sol victory")
	var before := expired.snapshot()
	check(not rules.resolve(expired, "grow", 7).ok and expired.snapshot() == before, "Final state remains immutable to new decisions")
	var variants: Dictionary = {}
	for seed_value in range(1, 21):
		var state := rules.start(seed_value, "exploration")
		rules.resolve(state, "grow", 1)
		rules.resolve(state, "grow", 2)
		variants[state.current_event] = true
	check(variants.size() > 1, "Different seeds actually change uncertain events")
