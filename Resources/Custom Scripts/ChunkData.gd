class_name ChunkData extends Resource

signal image_drawn(image: Image)

var width: int
var size: int:
	get:
		return width + 1
var noise: FastNoiseLite
var height_map: PackedFloat32Array = PackedFloat32Array()
var height_multiplier: int
var height_curve: Curve


func _ready() -> void:
	pass


func generate_height_map(offset: Vector2) -> void:
	height_map.resize(size * size)

	for z in range(size):
		for x in range(size):
			var index: int = x + z * size
			var height: float = noise.get_noise_2d(x + offset.x, z + offset.y)

			height = (height + 1.0) / 2.0
			
			height_map[index] = height_curve.sample(height) * height_multiplier


func _draw_noise_map() -> void:
	var image: Image = noise.get_image(size, size)
	emit_signal("image_drawn", image)
