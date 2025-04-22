@tool
class_name TerrainGenerator
extends Node

@export var noise: FastNoiseLite
@export_tool_button("Generate") var action: Callable = generate
@export_range(1, 1000) var height_multiplier: int = 1
@export var height_curve: Curve
@export_range(2, 240) var chunk_width: int = 240
@export_range(0, 12) var max_chunk_view_dist: int = 6

@onready var viewer: Node3D = $Viewer

var terrain_chunks: Dictionary[Vector2i, TerrainChunk] = {}
var visible_chunks_last_update: Array[TerrainChunk] = []
var noiseTexture: NoiseTexture2D


func _ready() -> void:
	generate()


func _process(_delta: float) -> void:
	_update_visible_chunks()


func generate() -> void:
	for child in get_children():	
		if child is Chunk:
			var chunk: Chunk = child as Chunk
			chunk.chunk_data.width = chunk_width
			chunk.chunk_data.noise = noise
			chunk.chunk_data.height_multiplier = height_multiplier
			chunk.chunk_data.height_curve = height_curve
			chunk.generate_mesh()

func _update_visible_chunks() -> void:

	for chunk: TerrainChunk in visible_chunks_last_update:
		chunk.set_visible(false)

	visible_chunks_last_update.clear()

	var current_chunk_coord := Vector2i()
	current_chunk_coord.x = roundi(viewer.position.x / chunk_width)
	current_chunk_coord.y = roundi(viewer.position.z / chunk_width)

	for z_offset in range(-max_chunk_view_dist, max_chunk_view_dist):
		for x_offset in range(-max_chunk_view_dist, max_chunk_view_dist):
			var viewed_chunk_coord := Vector2i(current_chunk_coord.x + x_offset, current_chunk_coord.y + z_offset)

			if terrain_chunks.has(viewed_chunk_coord):
				var existing_chunk: TerrainChunk = terrain_chunks[viewed_chunk_coord] 
				existing_chunk.update(Vector2(current_chunk_coord.x, current_chunk_coord.y))
				if existing_chunk.is_visible():
					visible_chunks_last_update.append(existing_chunk)
			else:
				terrain_chunks[viewed_chunk_coord] = TerrainChunk.new(viewed_chunk_coord, chunk_width, max_chunk_view_dist, self)
				visible_chunks_last_update.append(terrain_chunks[viewed_chunk_coord])


class TerrainChunk:
	var position: Vector2
	var size: int
	var max_chunk_view_dist: int
	var mesh_instance: MeshInstance3D
	var coord: Vector2i


	func _init(coord: Vector2i, size: int, max_chunk_view_dist: int, parent: Node) -> void:
		self.size = size
		self.max_chunk_view_dist = max_chunk_view_dist
		self.coord = coord
		position = coord * size 
		var position_3D := Vector3(position.x, 0, position.y)

		mesh_instance = MeshInstance3D.new()
		var plane_mesh := PlaneMesh.new()
		plane_mesh.size = Vector2(size, size)
		plane_mesh.center_offset = Vector3(size/2, 0, size/2)
		mesh_instance.mesh = plane_mesh
		mesh_instance.position = position_3D
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(coord.x / 10.0, 0, coord.y / 10.0)
		mesh_instance.material_override = material
		parent.add_child(mesh_instance)

	
	func update(viewer_chunk_coord: Vector2i) -> void:
		var distance: Vector2i = coord - viewer_chunk_coord
		var is_visible: bool = abs(distance.x) <= max_chunk_view_dist && abs(distance.y) <= max_chunk_view_dist
		set_visible(is_visible)
	
	
	func set_visible(visible: bool) -> void:
		mesh_instance.visible = visible
	
	func is_visible() -> bool:
		return mesh_instance.visible
