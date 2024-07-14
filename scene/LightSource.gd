extends CanvasItem
@export var radius = 32
@export var color = Color("ffffff", 0.03)
@export var outline_color : Color

func _draw():
	if outline_color: draw_arc(Vector2.ZERO, radius, 0, TAU, 50, outline_color, 4)
	draw_circle(Vector2.ZERO, radius, color)

func set_radius(radius_):
	radius = radius_
