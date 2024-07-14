extends Area2D

var damage = 1

func _ready(): $AnimatedSprite2D.play("default")
func _on_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_node("HP").receive_damage(20)

func _on_animated_sprite_2d_animation_finished():
	queue_free()
