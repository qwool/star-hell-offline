extends Node2D
var Bat : PackedScene = preload("res://scene/enemy/bat.tscn")
var Creeper : PackedScene = preload("res://scene/enemy/creeper.tscn")
var Experience : PackedScene = preload("res://scene/experience.tscn")

var mob_cap = 200
var global_speed = 1
var current_difficulty
var internal_timer = 0

var func_upgrades = []

@onready var Player = $Player
#region scripted values
var difficulties = {
	0: {
		Bat: {
			"hp": 26,
			"count": 4,
			"frequency": 3
		},
	},
	60: {
		Bat: {
			"hp": 30,
			"count": 10,
			"frequency": 4
		},
		Creeper: {
			"hp": 30,
			"count": 1,
			"frequency": 4
		},
	},
	120: {
		Bat: {
			"hp": 46,
			"count": 7,
			"frequency": 2
		},
		Creeper: {
			"hp": 30,
			"count": 2,
			"frequency": 5
		},
	}
}

var events = {
	0: func():
		#summon_multiple(Experience, -1, 10, 256)
		summon_multiple(Bat, 26, 3, 512)
}
#endregion

@onready var spawnRadius = (get_viewport_rect().size.x+get_viewport_rect().size.y)/4

func _ready():
	
	events[0].call()

func _generate_summon_position(radius):
	return Player.global_position + Vector2.RIGHT.rotated(randf_range(0,360))*radius
	
func summon_multiple(node, health : int = -1, count : int = 1, radius : int = spawnRadius):
	if $Enemies.get_child_count() < mob_cap :for x in count:
		var Enemy = node.instantiate()
		if health!=-1: Enemy.init(health)
		$Enemies.add_child(Enemy)
		
		Enemy.global_position = _generate_summon_position(radius)*randf_range(0.9,1.3)

func _set_difficulty(difficulty : Dictionary):
	for child in %spawners.get_children():
		child.queue_free()
	for entity in difficulty:
		var props = difficulty[entity]
		#print(props)
		var timer = Timer.new()

		timer.wait_time = props["frequency"]
		# summon_multiple.call(entity, props["count"], props["hp"])
		timer.connect("timeout", func(): summon_multiple(entity, props["hp"], props["count"]))
		timer.autostart = true
		%spawners.add_child(timer)
		
func _every_second():
	if difficulties.has(internal_timer):
		_set_difficulty(difficulties[internal_timer])
		
	internal_timer += 1

func _on_player_pass_variables(variable, type):
	if type == "funcs":
		func_upgrades = variable
	elif type == "callable":
		var callable = Callable(self, variable)
		callable.call()

func kill_everything():
	var visible = []
	$spawners.process_mode = Node.PROCESS_MODE_DISABLED
	for child in $Enemies.get_children():
		if child.global_position.distance_to(global_position) < get_viewport_rect().size.x/4:
			var Explosion = preload("res://scene/explosion.tscn").instantiate()
			Explosion.global_position = child.global_position
			child.add_sibling.call_deferred(Explosion)
			child.queue_free()
		else: child.queue_free()

