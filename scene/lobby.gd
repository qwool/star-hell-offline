extends Control

var data = preload("res://component/persistent.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	print(data.get_save())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file.bind("res://scene/main.tscn").call_deferred()
