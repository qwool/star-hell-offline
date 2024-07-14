extends Area2D

@export var SPEED = 70
@export var dmg = 1
@export var ExperienceDropped = 1

@onready var HP = $HP

@export var funcs = []
var ice_texture = preload("res://assets/ice.png")

var frozen = false
var Player
var Ice : Sprite2D
# freeze_explode

# Called when the node enters the scene tree for the first time.
func _ready():
	$MobSpecific.init()
	Player = get_parent().get_parent().get_node("Player")
	Ice = Sprite2D.new()
	Ice.texture = ice_texture
	Ice.scale = Vector2(1.3,1.3)
	Ice.visible = false
	add_child(Ice)
	
func init(hp: int):
	$HP.max_hp = hp
	$HP.hp = hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !frozen: position = position.move_toward(Player.position, delta * SPEED)


func get_shot(damage : int, elemental = {}, _funcs = []):
	funcs = _funcs
	print("ouch")
	print(elemental)
	if !frozen and elemental.has("freeze"):
		if randi_range(1,100) < elemental["freeze"]:
			if funcs.has("freeze_ultimate"):
				$HP.receive_damage(10)
			frozen = true
			Ice.visible = true

			await get_tree().create_timer(1.5).timeout
			frozen = false
			Ice.visible = false
	$HP.receive_damage(damage)

@onready var ExperienceOrb :PackedScene = ResourceLoader.load("res://scene/experience.tscn")
func _on_hp_dead():
	if frozen and funcs.has("freeze_explode"):
		var expl = preload("res://scene/explosion.tscn").instantiate()
		expl.global_position = global_position
		expl.damage = 15
		call_deferred("add_sibling", expl)
	var orb = ExperienceOrb.instantiate()
	if frozen and funcs.has("freeze_xp_boost"):
		orb.set_meta("value", 2)
	orb.global_position = global_position
	get_parent().add_child.call_deferred(orb)
	queue_free()
