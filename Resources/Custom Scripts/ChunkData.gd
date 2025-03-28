class_name ChunkData
extends Resource

signal image_drawn(image: Image)

var width: int = 128
var noise: FastNoiseLite
var height_map: PackedFloat32Array = PackedFloat32Array()
var height_multiplier: int


func _ready() -> void:
	pass


func generate_height_map() -> void:
	height_map.resize(width * width)

	for z in range(width):
		for x in range(width):
			var index: int = x + z * width
			var height: float = noise.get_noise_2d(x, z)

			height = (height + 1.0) / 2.0
			height_map[index] = height
	_height_enhancement()


func _height_enhancement() -> void:
	for z in range(width):
		for x in range(width):
			var index: int = x + z * width
			height_map[index] = height_map[index] * height_multiplier


func _draw_noise_map() -> void:
	var image: Image = noise.get_image(width, width)
	emit_signal("image_drawn", image)
