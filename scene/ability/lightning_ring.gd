extends Area2D
@export var damage = 20

func init(target, player_pos):
	global_position = target
	$AnimationPlayer.play("default")
func trigger(x,y):
	pass

func _on_body_entered(body):
	if body.is_in_group("damageable"):
		body.damage(damage)
