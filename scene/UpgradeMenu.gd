extends Control

signal request_upgrade

@onready var Buffs = preload("res://component/buffs.gd")
@onready var buffs = Buffs.new()
@onready var Functions = preload("res://component/functions.gd")
@onready var fn = Functions.new()

var upgrade_pathes = []
var player_upgrade_pathes = []

var upgrades
var available_upgrades

var option_selected : Node
var current_upgrades 
var current_upgrade_path = []
var upgrade_hovered = 0

func _unhandled_key_input(event):
	if event.is_action_released("select_upgrade"):
		_upgrade_selected()

	if event.is_action_pressed("move_left"):
		_set_wheel_child_focus(0)
	elif event.is_action_pressed("move_right"):
		_set_wheel_child_focus(2)
	elif event.is_action_pressed("move_up"):
		_set_wheel_child_focus(1)
	elif event.is_action_pressed("move_down"):
		_set_wheel_child_focus(3)
		
func _set_wheel_child_focus(index: int, focus : bool = true):
	for child in %Wheel.get_children():
		var child_index = int(child.name.trim_prefix("Upgrade"))
		child.scale = Vector2(8,8)
		if focus and child_index == index:
			child.scale = Vector2(10,10)
			option_selected = child
			upgrade_hovered = int(child.name.trim_prefix("Upgrade"))
			_set_upgrade_text()

func _on_player_upgrade_called(passed_upgrades):
	upgrades = buffs.convert_for_wheel()
	get_tree().paused = true
	show()
	player_upgrade_pathes = passed_upgrades
	current_upgrades = _roll_upgrades(available_upgrades)
	_set_upgrade_sprites(current_upgrades)
	_set_wheel_child_focus(0)

func _ready():
	upgrades = buffs.convert_for_wheel()
	available_upgrades = upgrades.duplicate()
	
	current_upgrades = _roll_upgrades(available_upgrades)
	_set_upgrade_sprites(current_upgrades)
	
	for child in $Wheel.get_children():
		var index = int(child.name.trim_prefix("Upgrade"))
		child.connect("mouse_entered", func(): _set_wheel_child_focus(index))
	_set_wheel_child_focus(0)

func _roll_upgrades(passed_upgrades : Dictionary) -> Array:
	current_upgrade_path = []
	
	var available_upgrades = passed_upgrades.duplicate()
	var shown_upgrades = []
	for upgrade in player_upgrade_pathes:
		if len(player_upgrade_pathes[upgrade]) >= 4:
			available_upgrades.erase(upgrade)
	
	while len(shown_upgrades) < 4:
		if available_upgrades.is_empty(): break
		var trees = available_upgrades.keys()
		var tree_index = trees[randi() % trees.size()]
		var picked_tree = available_upgrades[tree_index]
		var valid_indices = [0]
		if player_upgrade_pathes.has(tree_index):
			valid_indices = _get_avail_upgrades(player_upgrade_pathes[tree_index])
			print(player_upgrade_pathes[tree_index])
		var upgrade_index = valid_indices.pick_random()
		#print(tree_index, valid_indices)
		#print(tree_index, valid_indices)

		
		current_upgrade_path.push_front([tree_index, upgrade_index])
		shown_upgrades.push_front(picked_tree[upgrade_index])
		available_upgrades.erase(tree_index)
		
		
	while len(shown_upgrades) < 4:
		shown_upgrades.push_back({
			"name": "heal",
			"description": "+1 HP",
			"sprite": 6
		})
		current_upgrade_path.push_back(["hp", 0]) # doesnt matter what i put in here
	if shown_upgrades[0]["name"] == "heal": _upgrade_selected() 
	
	return shown_upgrades 
	
func _set_upgrade_sprites(_upgrades : Array):
	var sprites = []

	for upgrade in _upgrades:
		sprites.push_back(fn.sprite_region_from_tileset(upgrade["sprite"], 128))
	for index in len(sprites):
		var sprite = %Wheel.get_child(index).get_child(0)
		sprite.texture.region = sprites[index]
func _get_avail_upgrades(_upgrades : Array) -> Array:
	var current = _upgrades.duplicate()
	current.sort()
	
	match current:
		[0]: return [1,2]
		[0,1]: return [2,3]
		[0,2]: return [1,3]
		[0,1,2]: return [3]
		[0,1,3]: return [2]
		[0,2,3]: return [1]
		[0,1,2,3]: return []
	
	return [0]
	
	
func _upgrade_selected():
	hide()
	emit_signal("request_upgrade", [current_upgrades[upgrade_hovered], current_upgrade_path[upgrade_hovered]])
	get_tree().paused = false
	
func _set_upgrade_text():
	var sel_upgrade = current_upgrades[upgrade_hovered]
	$UpgradeName.text = sel_upgrade["name"]
	var stats = ""
	var desc = ""
	if sel_upgrade.has("description"):
		desc = sel_upgrade["description"]
	
	if sel_upgrade.has("stats"):
		for stat in sel_upgrade["stats"]:
			stats+=stat+" "+str(sel_upgrade["stats"][stat])+" "
		stats += "\n"
	$UpgradeDescription.text = fn.style_text(stats + desc)
	$UpgradeIcon.texture.region = fn.sprite_region_from_tileset(sel_upgrade["sprite"],128)

func _on_wheel_gui_input(event):
	if event.is_pressed():
		_upgrade_selected()
