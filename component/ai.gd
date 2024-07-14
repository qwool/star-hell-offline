extends Area2D

@export var SPEED = 100
@export var hp = 20
@export var dmg = 10
@export var ExperienceDropped = 1

@onready var HP = $HP


var Player
# Called when the node enters the scene tree for the first time.
func _ready():
	Player = get_parent().get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.move_toward(Player.position, delta * SPEED)


func _on_hp_dead():
	var experience = preload("res://scene/experience.tscn")
	experience.instantiate()

	for x in ExperienceDropped:
		$root.add_child(experience)
	queue_free()
