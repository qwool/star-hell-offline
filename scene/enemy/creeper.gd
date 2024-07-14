extends Node2D

@onready var Creeper = get_parent()

func init():
	Creeper.get_node("Sprite2D").play("default")
