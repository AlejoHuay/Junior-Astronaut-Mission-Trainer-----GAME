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
	for action in ["support", "research", "support", "research", "support", "research", "support"]:
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
	print("Tests: %d assertions, %d failures" % [assertions, failures])
	quit(1 if failures else 0)
