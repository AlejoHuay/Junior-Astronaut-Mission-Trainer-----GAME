extends SceneTree

func _initialize() -> void:
	var file := FileAccess.open("res://build/GODOT-LICENSES.txt", FileAccess.WRITE)
	if file == null:
		quit(1)
		return
	file.store_string(Engine.get_license_text())
	file.store_string("\n\nTHIRD-PARTY COPYRIGHT NOTICES\n")
	file.store_string(JSON.stringify(Engine.get_copyright_info(), "\t"))
	file.store_string("\n\nTHIRD-PARTY LICENSE TEXTS\n")
	file.store_string(JSON.stringify(Engine.get_license_info(), "\t"))
	file.close()
	print("Engine license notices exported")
	quit(0)
