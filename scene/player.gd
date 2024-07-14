extends CharacterBody2D

signal upgrade_called
signal pass_variables

var kills = 0
var data = preload("res://component/persistent.gd").new()
var colliding_orbs : Array = []
var level = 0
var experience = 0
var cursor_sprite = preload("res://assets/cursor.png")

var timers = {
	"elapsed_time": 0,
	"last_hit": 0,
	"cooldown_timer": 0.0
}

@export var SPEED = 200
#@onready var WaveAbility = preload("res://scene/ability/wave.tscn")

var func_upgrades  = []
var upgrades       = []
var upgrade_pathes = {}

@onready var WaveScene = preload("res://scene/ability/wave.tscn")
@onready var Functions = preload("res://component/functions.gd")
@onready var BuffList  = preload("res://component/buffs.gd")

@onready var bl = BuffList.new()
@onready var fn = Functions.new()

@onready var stats_flat   = bl.convert_for_player()
@onready var stats        = bl.convert_for_player()
@onready var stat_bonuses = bl.convert_for_bonuses()

var shooting = false
var is_aiming = true
var target_pos = Vector2.ZERO
var aa = false

func _ready():
	_fade(4)
	_merge_stat_bonuses()
	$Cursor.visible = false
	Input.set_custom_mouse_cursor(cursor_sprite)
	_refresh_weapons()
	


func _unhandled_input(_event):
	if Input.is_action_just_pressed("fuck_you"):
		get_tree().quit()
	if Input.is_action_pressed("pause"):
		_toggle_pause_menu()
	if Input.is_action_just_pressed("shoot"):
		shooting = true
	if Input.is_action_just_released("shoot"):
		shooting = false
	#if Input.is_action_just_pressed("exp_cheat"):
		#aa = !aa
		#if aa: Engine.time_scale = 10
		#else: Engine.time_scale = 1
	if Input.is_action_just_pressed("toggle_aim"):
		is_aiming = !is_aiming
		if !is_aiming:
			$Cursor.visible = true
			Input.set_custom_mouse_cursor(null)
		else:
			$Cursor.visible = false
			Input.set_custom_mouse_cursor(cursor_sprite)
var nearest_enemy = Vector2.ZERO
var abilities = {
	"Shoot" : {
		"node": "Pistol",
		"cooldown": 1.0,
		"last_shot": 0.0,
	}
}
var weapons = {
	"Pistol": {
		"scene": preload("res://scene/ability/pistol.tscn"),
		"equipped": true,
	},
}
var speed
func _physics_process(delta):
	speed = SPEED * (stats["speed"]/100+1)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		$Body.set_flip_h(direction.x > 0)
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	var collision = move_and_collide(velocity * delta)
	if collision:
		print("I collided with ", collision.get_collider().name)

func _process(delta):
	if is_aiming: target_pos = get_global_mouse_position()
	else:
		target_pos = _get_closest_in_group("enemy")[1]
		$Cursor.global_position = target_pos
	timers["cooldown_timer"] += delta
	
	if shooting or !is_aiming and target_pos!=Vector2(0,2000): _handle_abilities()
	_handle_weapons()
	if !colliding_orbs.is_empty(): _handle_orb_pull(delta)

var entities_in_sight = []

func _init_sight():
	%Sight/Timer.connect("timeout", func():
		for child in entities_in_sight:
			child.get_node("HP").receive_damage(stats["sight"]/8)
	)
	%Sight.connect("area_entered", func(area): 
		if area.is_in_group("enemy"):
			entities_in_sight.push_back(area)
	)
	%Sight.connect("area_exited", func(area): 
		if area.is_in_group("enemy"):
			entities_in_sight.pop_at(entities_in_sight.rfind(area))
	)
	
func _handle_weapons():
	for child in %Hand.get_children():
		child.target = target_pos

func _refresh_weapons():
	for child in %Hand.get_children():
		child.queue_free()
	for x in weapons:
		var weapon = weapons[x]
		if weapon["equipped"]:
			var cur_weapon  = weapon["scene"].instantiate()
			%Hand.add_child.call_deferred(cur_weapon)

func _fade(time : float):
	var node = %Effects/ColorRect
	node.visible = true
	node.color = Color.BLACK
	var tween = get_tree().create_tween().bind_node(node).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(node, "color", Color("00000000"), time)
	tween.tween_callback(func(): node.visible = false)
func _handle_abilities():
	for ability in %Hand.get_children():
		if timers["cooldown_timer"] - ability.cooldown > ability.last_shot:
			ability.trigger(stats, func_upgrades)
				
			ability.last_shot = timers["cooldown_timer"]
	
	
func _get_closest_in_group(group) -> Array:
	var positions : Array
	for node in get_tree().get_nodes_in_group(group):
		positions.push_front([global_position.distance_to(node.global_position), node.global_position])
	if positions.size() > 0:
		positions.sort()
	else:
		positions = [[0, Vector2(0,2000)]]
	return positions.front()
	

	
func _on_clock_timeout():
	timers["elapsed_time"] += 1
	%TimeLabel.text = fn.time_convert(timers["elapsed_time"])
	if func_upgrades.has("onhit_movesped") and timers["elapsed_time"] - timers["last_hit"] < 20:
		stat_bonuses["move_speed"]["onhit"] = 50
		_merge_stat_bonuses()

func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy"):
		$Hitbox.receive_damage(area.dmg)
		timers["last_hit"] = timers["elapsed_time"]
	elif area.is_in_group("exp"):
		_pickup_orb(area)
		
func _on_hitbox_dead():
	for child in $Hand.get_children(): child.queue_free()
	SPEED = 0
	emit_signal("pass_variables", "kill_everything","callable")
	$Body.play("death")
	await $Body.animation_finished
	
	%DeathMenu.visible = true
	finalize_stats()

func finalize_stats():
	var survived = timers["elapsed_time"]
	
	var points = level*10+kills+survived
	
	var text = ""
	text += "* level ["+str(level)+"] // "+str(level*10)+"\n"
	text += "* ["+str(kills)+"] kills // "+str(kills)+"\n"
	text += "* survived ["+fn.time_convert(survived)+"] // "+str(survived)+"\n"
	%DeathMenu/Panel/RichTextLabel.text = fn.style_text(text)
	data.set_key("points", points, true)

func _on_pickup_range_area_entered(area): # honestly dont know another way to do this
	if area.is_in_group("exp"):
		colliding_orbs.push_front(area)

func _on_pickup_range_area_exited(area):
	if area.is_in_group("exp"):
		for x in len(colliding_orbs): # shut up i know
			if colliding_orbs[x-1] == area: colliding_orbs.pop_at(x-1)

func _handle_orb_pull(delta):
	for orb in colliding_orbs:
		orb.global_position = orb.global_position.move_toward(global_position, speed * delta * 1.5)


func _pickup_orb(area : Area2D):
	randomize()
	kills += 1
	experience += area.get_meta("value")
	if func_upgrades.has("xp_chance_to_heal") and randi_range(1,100)==2:
		%Hitbox.receive_damage(1, true)
	if fn.exp_until_level(level+1) - experience < 0:
		level+=1
		experience = 0
		%ExpBar.max_value = fn.exp_until_level(level+1)
		%LevelLabel.text = str(level)
		emit_signal("upgrade_called", upgrade_pathes)
	%ExpBar.value = experience

	area.queue_free()
	
func _on_hitbox_damaged(_damage, healed):
	if !healed: $AnimationPlayer.play("flash")
	

func _on_upgrade_menu_request_upgrade(x):
	if x[0]["name"] == "heal":
		%Hitbox.receive_damage(-1, true)
	else:
		if !upgrade_pathes.has(x[1][0]):
			upgrade_pathes[x[1][0]] = []
		upgrade_pathes[x[1][0]].push_back(x[1][1])
		upgrades.push_front(x[0])
		
	stats_flat.merge(bl.stats_from_upgrades(upgrades), true)
	#print(x[0]["name"], stats_flat)
	if x[0].has("id"): # this is to prevent something i forgor
		func_upgrades.push_front(x[0]["id"])
	if not len(%Sight.get_signal_connection_list("area_entered")) > 0:
		_init_sight()
	_add_stats()

func _add_stats():
	emit_signal("pass_variables", func_upgrades, "funcs")
	if func_upgrades.has("damage_affected_by_move_speed"):
		stat_bonuses["damage"]["move_speed"] = stats["speed"]/5
	if func_upgrades.has("cooldown_affected_by_move_speed"):
		stat_bonuses["cooldown"]["move_speed"] = stats["speed"]/2
	if func_upgrades.has("amount_affected_by_move_speed"):
		stat_bonuses["amount"]["move_speed"] = floor(stats["speed"]/50)
	if func_upgrades.has("level_affects_health"):
		stat_bonuses["health"]["level"] = floor(level/5)
	if func_upgrades.has("level_affects_amount_pierce") and level%10==0:
		stat_bonuses["amount"]["level"] = floor(level/10)
		stat_bonuses["pierce"]["level"] = floor(level/10)
	if func_upgrades.has("level_affects_damage"):
		stat_bonuses["damage"]["level"] = level*2
	if func_upgrades.has("cooldown_affects_sight"):
		%Sight/Timer.wait_time = 1.0*(1-(stats["cooldown"]/100))
		
	var pickup_range = 64+stats["speed"]/2
	if func_upgrades.has("sight_affects_pickup"):
		pickup_range += stats["sight"]
	_merge_stat_bonuses()
	%Hitbox.set_max_hp(stats["health"])
	
	
	$PickupRange/CollisionShape2D.shape.radius = pickup_range
	$PickupRange/CollisionShape2D.radius = pickup_range
	
	%Sight/CollisionShape2D.shape.radius = stats["sight"]
	%Sight/CollisionShape2D.radius = stats["sight"]
	%Sight/CollisionShape2D.outline_color = Color("ffffff", 0.02)

func _merge_stat_bonuses(): #TODO
	var temp_stats = stats_flat
	for stat in stat_bonuses:
		for x in stat_bonuses[stat]:
			temp_stats[stat]+=stat_bonuses[stat][x]
	stats = temp_stats


func _on_unpause_button_pressed():
	_toggle_pause_menu()

func _toggle_pause_menu():
	get_tree().paused = !get_tree().paused
	%PauseMenu.visible = !%PauseMenu.visible
	set_process_input(true)


func _on_lobby_button_pressed():
	get_tree().change_scene_to_file("res://scene/upgrades_screen.tscn")
