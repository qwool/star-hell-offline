extends Area2D
var SPEED = 3.5
@export var damage = 10
var direction = Vector2.ZERO

func init(target, player_pos):
	global_position = player_pos
	look_at(target)
	$AnimationPlayer.set_speed_scale(0.5)
	$AnimationPlayer.play("default")
	direction = global_transform.basis_xform(Vector2.RIGHT)

func _process(_delta):
	global_position += direction * SPEED

func _on_area_entered(area):
	if area.is_in_group("damageable"):
		area.damage(damage)
