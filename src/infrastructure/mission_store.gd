class_name MissionStore
extends RefCounted

const VERSION := 1
const MAX_BYTES := 262144
var path: String
var error: String = ""

func _init(file_path: String = "user://mission.save") -> void:
	path = file_path

func write_save(document: Dictionary) -> bool:
	error = ""
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		error = "No se pudo guardar. Puedes seguir jugando; no cierres esta pestaña."
		return false
	file.store_string(JSON.stringify(document))
	file.flush()
	var result := file.get_error()
	file.close()
	if result != OK or DirAccess.rename_absolute(path + ".tmp", path) != OK:
		error = "No se pudo actualizar el guardado. Puedes seguir jugando."
		return false
	return true

func read_save() -> Dictionary:
	error = ""
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		error = "El almacenamiento no está disponible. Puedes comenzar otra misión."
		return {}
	if file.get_length() > MAX_BYTES:
		error = "Guardado demasiado grande; no se cargó."
		return {}
	var parser := JSON.new()
	var parse_result := parser.parse(file.get_as_text())
	file.close()
	if parse_result != OK:
		error = "Guardado inválido. Puedes comenzar otra misión."
		return {}
	var parsed = parser.data
	if not parsed is Dictionary or parsed.get("version") != VERSION:
		error = "Guardado inválido o de otra versión. Puedes comenzar otra misión."
		return {}
	return parsed
