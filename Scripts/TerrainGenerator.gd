@tool
class_name TerrainGenerator
extends Node

@export var noise: FastNoiseLite
@export_tool_button("Generate") var action: Callable = generate
@export_range(1, 1000) var height_multiplier: int = 1

var noiseTexture: NoiseTexture2D


func _ready() -> void:
	generate()


func _process(_delta: float) -> void:
	pass


func generate() -> void:
	for child in get_children():	
		if child is Chunk:
			var chunk: Chunk = child as Chunk
			chunk.chunk_data.noise = noise
			chunk.chunk_data.height_multiplier = height_multiplier
			chunk.generate_mesh()
