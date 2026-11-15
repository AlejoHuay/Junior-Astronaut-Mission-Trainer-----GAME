class_name ScienceData
extends RefCounted

var error: String = ""

func load_catalog(path: String = "res://data/nasa/curated/catalog.json") -> Dictionary:
	error = ""
	if not FileAccess.file_exists(path):
		error = "No se encontró el catálogo científico."
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not validate(parsed):
		error = "Catálogo científico inválido."
		return {}
	return parsed

func validate(value: Variant) -> bool:
	if not value is Dictionary or value.get("schema_version") != 1 or not value.get("records") is Array:
		return false
	var ids: Array[String] = []
	for record in value.records:
		if not record is Dictionary:
			return false
		for key in ["id", "title", "url", "retrieved", "context", "observation", "lesson", "limits", "raw_path"]:
			if not record.get(key) is String or record[key].is_empty():
				return false
		if record.id in ids or not record.url.begins_with("https://") or record.get("historical") != true:
			return false
		if not record.raw_path.begins_with("res://data/nasa/raw/") or ".." in record.raw_path:
			return false
		ids.append(record.id)
	return not ids.is_empty()

func find_record(catalog: Dictionary, id: String) -> Dictionary:
	for record in catalog.get("records", []):
		if record.id == id:
			return record
	return {}
