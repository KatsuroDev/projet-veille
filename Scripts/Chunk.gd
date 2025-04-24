@tool
class_name Chunk
extends MeshInstance3D

@export var level_of_detail: int:
	set(value):
		level_of_detail = clamp(value, 0, _get_number_factors_count(chunk_data.width))

var chunk_data: ChunkData = ChunkData.new()
var water_material: ShaderMaterial = preload("../Resources/Materials/water.material") as ShaderMaterial


func _init() -> void:
	material_override = preload("../Resources/Materials/default_chunk_material.tres") as ShaderMaterial


func _ready() -> void:
	chunk_data.connect("image_drawn", _on_image_drawn)


func generate_mesh() -> void:
	chunk_data.generate_height_map(Vector2(position.x, position.z))

	var new_mesh := ArrayMesh.new()
	var surface_array := _generate_surface()

	new_mesh.add_surface_from_arrays(ArrayMesh.PRIMITIVE_TRIANGLES, surface_array)
	self.mesh = new_mesh

	var material := material_override as ShaderMaterial
	material.set_shader_parameter("height_multiplier", chunk_data.height_multiplier)

	create_trimesh_collision()

	var water_mesh := MeshInstance3D.new()
	var water_plane := PlaneMesh.new()
	water_plane.center_offset = Vector3(chunk_data.width, 0, chunk_data.width)
	water_plane.size = Vector2(chunk_data.width, chunk_data.width)
	water_mesh.mesh = water_plane
	water_mesh.material_override = water_material
	water_mesh.position.y = 0.407 * chunk_data.height_multiplier
	add_child(water_mesh)


func _generate_surface() -> Array:
	var surface_array: Array = []
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var uvs := PackedVector2Array()
	var normals := PackedVector3Array()
	var triangle_index: int = 0
	var mesh_simplification_increment: int = 1 if level_of_detail == 0 else level_of_detail * 2
	var vertices_per_line: int = (chunk_data.size - 1) / mesh_simplification_increment + 1

	vertices.resize(vertices_per_line * vertices_per_line)
	indices.resize((vertices_per_line - 1) * (vertices_per_line - 1) * 6)
	uvs.resize(vertices_per_line * vertices_per_line)
	normals.resize(vertices_per_line * vertices_per_line)

	surface_array.resize(ArrayMesh.ARRAY_MAX)

	for z in range(0, chunk_data.size, mesh_simplification_increment):
		for x in range(0, chunk_data.size, mesh_simplification_increment):
			var index: int = (x / mesh_simplification_increment) + (z / mesh_simplification_increment) * vertices_per_line
			var height_index: int = x + z * chunk_data.size
			var height: float = chunk_data.height_map[height_index]
			var vertex_position := Vector3(x, height, z)

			vertices[index] = vertex_position
			uvs[index] = Vector2(x / float(chunk_data.size), z / float(chunk_data.size))
			normals[index] = Vector3.UP

			if x < chunk_data.size - 1 && z < chunk_data.size - 1:
				indices[triangle_index] = index
				indices[triangle_index + 1] = index + vertices_per_line + 1
				indices[triangle_index + 2] = index + vertices_per_line
				
				indices[triangle_index + 3] = index + vertices_per_line + 1
				indices[triangle_index + 4] = index
				indices[triangle_index + 5] = index + 1

				triangle_index += 6

	surface_array[ArrayMesh.ARRAY_VERTEX] = vertices
	surface_array[ArrayMesh.ARRAY_INDEX] = indices
	surface_array[ArrayMesh.ARRAY_TEX_UV] = uvs
	surface_array[ArrayMesh.ARRAY_NORMAL] = normals

	return surface_array


func _create_texture(image: Image) -> void:
	var texture := ImageTexture.create_from_image(image)
	var new_material := StandardMaterial3D.new()
	new_material.albedo_texture = texture
	new_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	new_material.texture_repeat = false
	
	material_override = new_material


func _on_image_drawn(image: Image) -> void:
	_create_texture(image)


func _get_number_factors_count(number: int) -> int:
	var factors: Array = []
	for i in range(1, number):
		if (number % i == 0):
			factors.append(i)
	return factors.size()