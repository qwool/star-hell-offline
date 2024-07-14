#
# https://simple.wikipedia.org/wiki/Sunk_cost_fallacy
#

extends Line2D
var direction : Vector2
var SPEED = 600
var damage = 1
var pierce = 2

var funcs = []

var elemental = {
	"freeze": 0,
	"lightning": 0,
	"fire": 0
}

func set_buffs(_elemental, _funcs):
	elemental.merge(_elemental, true)
	funcs = _funcs
	print(elemental)

func _init():
	var Area = Area2D.new()
	Area.set_monitoring(true)
	Area.area_entered.connect(_on_area_entered)
	add_child(Area)
	
	add_point(Vector2(-(SPEED/60), 0))
	add_point(Vector2(10,0))
	
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		Area.add_child(new_shape)
		var rect = RectangleShape2D.new()
		new_shape.position = (points[i] + points[i + 1]) / 2
		new_shape.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, width / 2)
		new_shape.shape = rect
	width = 7
	direction = global_transform.basis_xform(Vector2.RIGHT)
	#var timer : Timer = Timer.new()
	#timer.wait_time = 3
	#timer.timeout.connect(func(): queue_free())
	#timer.autostart = true
	#add_child(timer)
	var onscreen = VisibleOnScreenNotifier2D.new()
	onscreen.screen_exited.connect(func(): queue_free())
	add_child(onscreen)
	
func _process(delta):
	global_position += direction * SPEED * delta

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		area.get_shot(damage, elemental, funcs)
		pierce -= 1
		if pierce <= 0:
			queue_free()
