extends Node2D

@export var max_hp = 20
@export var hp_lowest = 1
@export var iframes = 0.2
@export var display_damage_text : bool = true
@export var HeartsNode : Node

var hp

var invincible = false

signal damaged
signal dead
var timer : Timer
func _ready():
	hp = max_hp
	if HeartsNode: HeartsNode.set_health(hp, max_hp)
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = iframes
	timer.one_shot = true
	timer.start()
	
func receive_damage(damage: float, healed : bool = false) -> void:

	if timer.time_left>0: return
	hp -= damage + -1*int(healed)
	hp = min(hp, max_hp)
	damaged.emit(damage, healed)
	_damage_text(int(damage), healed)
	timer.start()
	if HeartsNode: HeartsNode.set_health(hp, max_hp)
	if hp <= 0:
		dead.emit()
		return
	
@onready var DamageText = preload("res://scene/damage_text.tscn")
func _damage_text(damage : int, healed : bool):
	if !display_damage_text: return
	var node : Node2D = DamageText.instantiate()
	node.get_child(0).text = str(damage)
	if healed: 
		node.get_child(0).text = "+"+str(abs(damage))
	node.global_position = global_position
	node.global_position.x += randi_range(-16,16)
	var target_position = node.global_position + Vector2(0, -32)
	var tween = create_tween().bind_node(node)
	tween.tween_property(node, "position", target_position, 1.5)
	if !healed: tween.tween_property(node, "modulate", Color("f8f8f2", 0.0), 1.5)
	else: tween.tween_property(node, "modulate", Color("a6e22e", 0.0), 1.5)
	
	get_parent().add_sibling(node)
	tween.connect("finished", func(): node.queue_free())
	
	
	
func set_max_hp(health : int):
	var prev = max_hp
	max_hp = hp_lowest + health
	hp += max_hp-prev
	if HeartsNode: HeartsNode.set_health(hp, max_hp)
	
