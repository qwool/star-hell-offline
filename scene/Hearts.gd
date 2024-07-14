extends Control

@onready var init_region = Rect2(32,64,16,16)
@onready var hollow_region = Rect2(64,64,16,16)

var atlas_texture = preload("res://assets/tileset.png")


func set_health(health : int, max_health : int = -1):
	if max_health>0 : for child in $HBoxContainer.get_children():
		child.queue_free()
	for x in max_health:
		var heart = _construct_heart(x)
		if x >= health: heart.texture.region = hollow_region
		$HBoxContainer.add_child(heart)
		
		
func _construct_heart(i: int) -> TextureRect:
	var index = str(i)
	var node = TextureRect.new()
	node.texture = AtlasTexture.new()
	node.texture.atlas = atlas_texture
	node.texture.region = init_region
	node.name = index
	return node
