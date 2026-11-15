extends SceneTree

# Exercises real presentation callbacks; the CLI runner also rejects script errors in the log.
func _initialize() -> void:
	call_deferred("exercise_scene")

func exercise_scene() -> void:
	var packed := load("res://scenes/menus/main.tscn") as PackedScene
	var screen = packed.instantiate()
	root.add_child(screen)
	await process_frame
	# Preferences exercise both rendering paths without claiming audible/visual review.
	for child in screen.content.get_children():
		if child is CheckButton:
			child.button_pressed = true
	if not screen.reduced_motion or not screen.sound_enabled:
		printerr("FAIL: presentation preference controls")
		quit(1)
		return
	screen.session.store = null # Scene checks must not overwrite a real local mission.
	screen.session.start(214, "demo")
	for action in ["grow", "grow", "support", "shelter", "combined", "eva", "support"]:
		for index in range(screen.action_picker.item_count):
			if screen.action_picker.get_item_metadata(index) == action:
				screen.action_picker.select(index)
				screen._action_selected(index)
		screen.execute_button.pressed.emit()
		await process_frame
	if screen.session.state.outcome_code != "success" or screen.session.state.science != 5:
		printerr("FAIL: presentation controls did not complete the scientific strategy")
		quit(1)
		return
	screen._show_sources()
	await process_frame
	screen._show_help()
	await process_frame
	var recap: String = screen._learning_summary()
	if not recap.contains(screen.learning.harvest_lesson) or recap.contains(screen.learning.radio_lesson):
		printerr("FAIL: recap must match actual decisions")
		quit(1)
		return
	screen._show_menu()
	await process_frame
	screen.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	print("Scene smoke: scenario menu, plan selector, preview, execution, alert, objectives, result and sources loaded")
	quit(0)
