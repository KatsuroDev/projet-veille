class_name ChunkData extends Resource

signal image_drawn(image: Image)

var width: int
var size: int:
	get:
		return width + 1
var terrain_noise: FastNoiseLite
var height_map: PackedFloat32Array = PackedFloat32Array()
var height_multiplier: int
var height_curve: Curve
var foliage_noise: FastNoiseLite
var foliages: Dictionary[Vector3, int]


func _ready() -> void:
	pass


func generate_height_map(offset: Vector2) -> void:
	height_map.resize(size * size)

	for z in range(size):
		for x in range(size):
			var index: int = x + z * size
			var height: float = terrain_noise.get_noise_2d(x + offset.x, z + offset.y)

			height = (height + 1.0) / 2.0
			
			height_map[index] = height_curve.sample(height) * height_multiplier
	_generate_foliage(offset)


func _generate_foliage(offset: Vector2) -> void:
	for z in range(size):
		for x in range(size):
			var index: int = x + z * size
			var sample: float = foliage_noise.get_noise_2d(x + offset.x, z + offset.y)
			var height: float = height_map[index]
			if sample > 0.6 && height >= 0.374 * height_multiplier && height < 0.448 * height_multiplier :
				foliages[Vector3(x, height_map[index], z)] = randi_range(1, 3)


func _draw_noise_map() -> void:
	var image: Image = terrain_noise.get_image(size, size)
	emit_signal("image_drawn", image)
