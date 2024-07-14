extends Control

signal request_upgrade

@onready var Buffs = preload("res://component/buffs.gd")
@onready var buffs = Buffs.new()
var upgrades

var test_upgrades

var upgrade_selected : Node
var current_upgrades 
var upgrade_hovered = 0

func _on_player_upgrade_called():
	upgrades = buffs.convert_for_wheel()
	get_tree().paused = true
	show()
	current_upgrades = roll_upgrades(upgrades)

func roll_upgrades(passed_upgrades):
	var shown_upgrades = []
	var available_upgrades = passed_upgrades.duplicate()
	
	while len(shown_upgrades) < 4:
		var index = randi() % available_upgrades.size()
		shown_upgrades.append(available_upgrades[index])
		available_upgrades.pop_at(index)
	_set_upgrade_sprites(shown_upgrades)
	return shown_upgrades

func _set_upgrade_sprites(upgrades):
	var current = 0
	for child in %Wheel.get_children():
		child.get_child(0).texture.region = upgrades[current][3]
		current += 1

func _ready():
	upgrades = buffs.convert_for_wheel()
	current_upgrades = roll_upgrades(upgrades)
	for child in $Wheel.get_children():
		var scale_up = func():
			child.scale = Vector2(10,10)
			upgrade_selected = child
			upgrade_hovered = int(child.name.trim_prefix("Upgrade"))
			_set_upgrade_text(upgrade_hovered)
		var scale_down = func():
			child.scale = Vector2(8,8)
		child.connect("mouse_entered", scale_up)
		child.connect("mouse_exited", scale_down)
		child.connect("gui_input", _upgrade_selected)

func _set_upgrade_text(index):
	var upgrade = current_upgrades[index]
	$UpgradeName.text = upgrade[1]
	$UpgradeDescription.text = upgrade[2]

func _upgrade_selected(x : InputEvent):
	if x.is_pressed():
		var upgrade = current_upgrades[upgrade_hovered]
		emit_signal("request_upgrade", upgrade)
		get_tree().paused = false
		hide()
		
