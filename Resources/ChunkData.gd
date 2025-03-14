class_name ChunkData
extends Resource

@export var width: int = 16
var noise: FastNoiseLite
var height_map: PackedFloat32Array = PackedFloat32Array()


func _ready() -> void:
	pass


func generate_height_map() -> void:
	height_map.resize(width * width)
	var max_height: float = 0
	var min_height: float = INF

	for x in range(width):
		for z in range(width):
			var index: int = x + z * width
			var height: float = noise.get_noise_2d(x, z)

			if height > max_height:
				max_height = height

			if height < min_height:
				min_height = height
			
			height_map[index] = height
	_normalize_height_map(min_height, max_height)


func _normalize_height_map(min_height: float, max_height: float) -> void:
	for x in range(width):
		for z in range(width):
			var _index: int = x + z * width
			height_map[_index] = inverse_lerp(min_height, max_height, height_map[_index])
