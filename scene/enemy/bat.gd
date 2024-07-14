extends Node2D

@onready var Bat = get_parent()

func init():
	Bat.get_node("Sprite2D").play("default")
