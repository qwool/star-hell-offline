extends Control

func _ready():
	$AnimationPlayer.play("init")

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scene/lobby.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
