func time_convert(time_in_sec):
	var seconds = time_in_sec%60
	var minutes = time_in_sec/60
	
	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d" % [minutes, seconds]

func sprite_region_from_tileset(index : int, width : int, base : int = 16, size : Vector2 = Vector2(16, 16)) -> Rect2:
	var tiles_per_row = width / base
	var tile_x = (index % tiles_per_row) * size.x
	var tile_y = (index / tiles_per_row) * size.y
	return Rect2(tile_x, tile_y, size.x, size.y)

func style_text(text : String):
	var regex = RegEx.new()
	regex.compile(r"[^a-zA-Z/\s.,]+")
	var matches = regex.search_all(text)
	var offset = 0
	for match in matches:
		var number = match.get_string()
		var start = match.get_start(0)
		var end = match.get_end(0)
		text = text.substr(0, start + offset) + "[color=white]" + number + "[/color]" + text.substr(end + offset)
		offset += "[color=white][/color]".length()

	return text
func exp_until_level(level):
	if level >= 1 and level <= 20:
		return 10 * level - 5
	elif level == 20:
		return 16 * level - 8
	elif level >= 21 and level <= 39:
		return 13 * level - 6
	elif level >= 40 and level <= 59:
		return 16 * level - 8
	elif level >= 60:
		return level * level
	else:
		return 0  # Handle any invalid level case

func subtractArr(a: Array, b: Array) -> Array:
	var result := []
	var bag := {}
	for item in b:
		if not bag.has(item):
			bag[item] = 0
		bag[item] += 1
	for item in a:
		if bag.has(item):
			bag[item] -= 1
			if bag[item] == 0:
				bag.erase(item)
		else:
			result.append(item)
	return result
