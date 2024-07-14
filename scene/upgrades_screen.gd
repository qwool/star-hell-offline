extends Control

enum PARTS {MAGAZINE, BARREL, HAMMER, TRIGGER}

var hovered_upgrade = []
var hovered_class = ""

var current_parts = [0,0,0,0]
var current_class = 0
var upgrades = [
	[ # magazine
		{
			"name": "none",
			"description": "huh"
		},
		{
			"name": "default",
			"description": "infinite ammo, -10 speed"
		},
		{
			"name": "elemental",
			"description": "infinite ammo, -10 speed"
		},
	], #magazine end
	[ # barrel
		{
			"name": "none",
			"description": "huh"
		},
		{
			"name": "default",
			"description": "nothing :("
		},
		{
			"name": "elemental",
			"description": "nothing :("
		},
	], #barrel end
	[ # hammer
		{
			"name": "none",
			"description": "huh"
		},
		{
			"name": "default",
			"description": "nothing :("
		},
		{
			"name": "elemental",
			"description": "nothing :("
		},
	], #hammer end
	[ # trigger
		{
			"name": "none",
			"description": "huh"
		},
		{
			"name": "default",
			"description": "nothing :("
		},
		{
			"name": "elemental",
			"description": "nothing :("
		},
	], #trigger end
]

var atlas_texture = preload("res://assets/gun-parts.png")
@onready var fn = preload("res://component/functions.gd").new()
@onready var bl = preload("res://component/buffs.gd").new()
@onready var data = preload("res://component/persistent.gd").new()

func _input(event):
	if Input.is_action_just_released("select_upgrade"):
		if hovered_upgrade != []:
			_set_gun_part(PARTS[hovered_upgrade[0]], hovered_upgrade[1])
	elif Input.is_action_just_pressed("fuck_you"):
		get_tree().change_scene_to_file("res://scene/main.tscn")

func _construct_icon(sprite: int) -> Node:
	var icon = TextureRect.new()
	icon.texture = AtlasTexture.new()
	icon.texture.atlas = atlas_texture
	icon.texture.region = Rect2(0,0,16,16)
	return icon

func _add_items_to_list():
	for current in PARTS:
		for part in atlas_texture.get_width()/16-1:
			part += 1
			var column = %PartContainer.get_child(PARTS[current])
			var icon = _construct_icon(part)
			icon.texture.region.position = Vector2(part*16, PARTS[current]*16)
			icon.connect("mouse_entered", func():
				hovered_upgrade=[current, part]
				var unwrapped = upgrades[PARTS[hovered_upgrade[0]]][hovered_upgrade[1]]
				%UpgradeName.text = unwrapped["name"]
				%UpgradeExplanation.text = unwrapped["description"]
				icon.scale = Vector2(1.2,1.2)
			)
			icon.connect("mouse_exited", func():
				hovered_upgrade=[]
				icon.scale = Vector2(1,1)
			)
			icon.modulate = Color("848484")
			
			column.add_child(icon)
enum CLASSES {XI,LAMBDA,THETA}
func _select_class(index):
	for child in $Classes.get_children():
		child.modulate = Color("848484")
	
	if index is StringName:
		index = CLASSES[index]
	
	var child = $Classes.get_child(index)
	child.modulate = Color.BLACK

func _ready():
	#_select_class(data.get_save()["class"])
	#_select_class("LAMBDA")
	
	for element in $Classes.get_children():
		element.modulate = Color("848484")
		element.connect("mouse_entered", func():
			_select_class(element.get_name())
			var desc = bl.elements[element.name]["description"]
			%ClassExplanation.text = fn.style_text(desc)
			element.modulate = Color.WHITE
		)
		element.connect("mouse_exited", func():
			element.modulate = Color("848484")
		)
	
	print(data.get_save())
	current_parts = data.get_save()["gun_parts"]
	%Points.text = "[color=white]* [color=yellow]"+str(data.get_save()["points"])
	_add_items_to_list()
	for x in 4:
		_set_gun_part(x,current_parts[x])
func _set_gun_part(part : PARTS, index : int = 0):
	var part_node = %Gun.get_child(part)
	
	current_parts[part] = index
	for other in %PartContainer.get_child(part).get_children():
		other.modulate = Color("848484")
	%PartContainer.get_child(part).get_child(index-1).modulate = Color.WHITE
	data.set_key("gun_parts", current_parts)
	part_node.texture.region.position.x = index * 16


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scene/main.tscn")
