extends Area2D

@export var SPEED = 70
@export var dmg = 1
@export var ExperienceDropped = 1

@onready var HP = $HP

@export var funcs = []

var frozen = false
var Player
# freeze_explode
func freeze():
	if !frozen:
		if funcs.has("freeze_ultimate"):
			$HP.receive_damage(floor($HP.max_hp/5))
		frozen = true
		await get_tree().create_timer(1.5).timeout
		frozen = false

func pass_funcs(passed : Array):
	funcs = passed

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.play("default")
	Player = get_parent().get_parent().get_node("Player")
	
func init(hp: int):
	$HP.max_hp = hp
	$HP.hp = hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var _prev = position
	if !frozen: position = position.move_toward(Player.position, delta * SPEED)
	$Sprite2D.flip_h = (position - _prev).x < 0
	
@onready var ExperienceOrb :PackedScene = ResourceLoader.load("res://scene/experience.tscn")
func _on_hp_dead():
	var orbs_dropped = 1
	if frozen and funcs.has("freeze_xp_boost"):
		orbs_dropped = 1
	var expl = preload("res://scene/explosion.tscn").instantiate()
	expl.global_position = global_position
	expl.damage = 15
	call_deferred("add_sibling", expl)
	for __ in orbs_dropped:
		var orb = ExperienceOrb.instantiate()
		orb.global_position = global_position
		get_parent().add_child.call_deferred(orb)
		queue_free()
