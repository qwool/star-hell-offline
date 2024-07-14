extends Node2D
var target = Vector2.ZERO

var last_shot = 1.0
@export var cooldown = 0.6
var BulletScript : Script = preload("res://scene/ability/bullet.gd")
func _process(_delta):
	look_at(target)
	
func trigger(buffs:Dictionary, funcs:Array):
	for ind in buffs["amount"]+1:
		await get_tree().create_timer(int(ind>0)*0.05).timeout
		var bullet = Line2D.new()
			
		cooldown = max(1-(buffs["cooldown"]/100), 0.2)
		bullet.global_position = global_position
		bullet.rotation = rotation
		bullet.set_script(BulletScript)
		
		var elemental = {
			"freeze": buffs["freeze"]
		}
		bullet.set_buffs(elemental, funcs)
		
		bullet.pierce = 1+buffs["pierce"]
		bullet.damage = 20 + buffs["damage"]
		bullet.SPEED = 600 * ((buffs["proj_speed"]+100)/100)
		
		get_tree().get_root().add_child(bullet)
		
