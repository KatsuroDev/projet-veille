@tool
class_name TerrainGenerator
extends Node

@export var noise: FastNoiseLite
@export_tool_button("Generate") var action: Callable = generate
@export_range(1, 1000) var height_multiplier: int = 1
@export var height_curve: Curve
@export_range(2, 240) var chunk_width: int = 16
@export_range(0, 12) var max_chunk_view_dist: int = 6

@onready var viewer: Node3D = $FreeLookCamera/Viewer

var chunks: Dictionary[Vector2i, Chunk] = {}
var visible_chunks_last_update: Array[Vector2i] = []
var noiseTexture: NoiseTexture2D

var last_chunk_coord: Vector2i


func _ready() -> void:
	generate()

	last_chunk_coord = _get_chunk_coord(viewer.position)
	_process_view_area()


func _process(_delta: float) -> void:
	if _get_chunk_coord(viewer.position) != last_chunk_coord:
		_process_view_area()
		last_chunk_coord = _get_chunk_coord(viewer.position)


func generate() -> void:
	for child in get_children():	
		if child is Chunk:
			var chunk: Chunk = child as Chunk
			chunk.chunk_data.width = chunk_width
			chunk.chunk_data.noise = noise
			chunk.chunk_data.height_multiplier = height_multiplier
			chunk.chunk_data.height_curve = height_curve
			chunk.generate_mesh()


func _get_chunk_coord(world_coord: Vector3) -> Vector2i:
	return Vector2i(roundi(world_coord.x / chunk_width), roundi(world_coord.z / chunk_width))


func _process_view_area() -> void:
	var current_chunk_coord: Vector2i = _get_chunk_coord(viewer.position)

	for z_offset in range(-max_chunk_view_dist, max_chunk_view_dist):
		for x_offset in range(-max_chunk_view_dist, max_chunk_view_dist):
			var viewed_chunk_coord := Vector2i(current_chunk_coord.x + x_offset, current_chunk_coord.y + z_offset)

			if not chunks.has(viewed_chunk_coord):
				var new_chunk := Chunk.new()
				chunks[viewed_chunk_coord] = new_chunk

				new_chunk.position = Vector3(viewed_chunk_coord.x * chunk_width, 0, viewed_chunk_coord.y * chunk_width)
				new_chunk.chunk_data.width = chunk_width
				new_chunk.chunk_data.noise = noise
				new_chunk.chunk_data.height_multiplier = height_multiplier
				new_chunk.chunk_data.height_curve = height_curve

				new_chunk.generate_mesh()
				$Chunks.add_child(new_chunk)

	_remove_unviewed_chunks()


func _remove_unviewed_chunks() -> void:
	var unviewed_chunks: Array[Chunk] = []
	for key: Vector2i in chunks.keys():
		var chunk: Chunk = chunks[key]
		var distance: Vector2i = key - _get_chunk_coord(viewer.position)
		var is_visible: bool = abs(distance.x) <= max_chunk_view_dist && abs(distance.y) <= max_chunk_view_dist
		if not is_visible:
			unviewed_chunks.append(chunk)
	for chunk in unviewed_chunks:
		chunks.erase(_get_chunk_coord(chunk.position))
		chunk.queue_free()
