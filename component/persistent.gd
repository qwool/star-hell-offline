var json_structure := {
	"points": 0,
	"upgrades":[],
	"gun_parts": [0,0,0,0],
	"class": 0
}
var path = "user://main.save"

func set_key(key : String, value, addition := false):
	var current = get_save()
	if !addition: current[key] = value
	else: current[key] += value

	var save = FileAccess.open(path, FileAccess.WRITE)

	var json_file = JSON.stringify(current)
	save.store_string(json_file)
	save.close()
	
func init_save():
	var save = FileAccess.open(path, FileAccess.WRITE)

	var json_file = JSON.stringify(json_structure)
	save.store_string(json_file)
	save.close()
	
func get_save():
	var dict
	
	if !FileAccess.file_exists(path):
		init_save()
	var json = JSON.new()
	var save = FileAccess.open(path, FileAccess.READ)
	

		
	var err = json.parse(save.get_as_text())
	if err != OK:
		return null
	else:
		dict = json.data
		
	return dict
