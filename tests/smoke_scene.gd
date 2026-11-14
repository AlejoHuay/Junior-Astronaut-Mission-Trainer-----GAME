extends SceneTree

# Exercises real presentation callbacks; the CLI runner also rejects script errors in the log.
func _initialize() -> void:
	call_deferred("exercise_scene")

func exercise_scene() -> void:
	var packed := load("res://scenes/menus/main.tscn") as PackedScene
	var screen = packed.instantiate()
	root.add_child(screen)
	await process_frame
	screen.session.start(214, "training")
	for action in ["grow", "grow", "support", "grow", "support", "research", "support"]:
		screen.session.choose(action, screen.session.state.sol)
		await process_frame
	if screen.session.state.phase != MissionState.Phase.FINISHED:
		printerr("FAIL: scene did not reach the mission result")
		quit(1)
		return
	screen._show_sources()
	await process_frame
	screen._show_menu()
	await process_frame
	screen.queue_free()
	await process_frame
	print("Scene smoke: menu, cultivation, harvest, interruption, result and sources loaded")
	quit(0)
