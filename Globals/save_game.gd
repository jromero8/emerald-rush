extends Node

func normalize_save_path(path : String) -> String:
	if !path.contains("user://"):
		path = "user://" + path
	if !path.contains(".save"):
		path = path + ".save"
	return path

func save_data(object_name : String, value : Variant) -> void:
	var path : String = normalize_save_path(object_name)
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var val : String = var_to_str(value)
	file.store_var(val)
	file.close()

func load_data(object_name : String) -> Variant:
	var value : Dictionary
	var path : String = normalize_save_path(object_name)
	if (FileAccess.file_exists(path)):
		var file : FileAccess = FileAccess.open(path, FileAccess.READ)
		var val : Variant = file.get_var(false)
		var sval := ""
		if typeof(val) == TYPE_STRING:
			sval = str(val)
		value = str_to_var(sval)
		file.close()
	return value
