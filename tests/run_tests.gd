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
