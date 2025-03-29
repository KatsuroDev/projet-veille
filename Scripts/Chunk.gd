@tool
class_name Chunk
extends MeshInstance3D

var chunk_data: ChunkData = ChunkData.new()
@export_range(0, 6) var level_of_detail: int


func _ready() -> void:
	chunk_data.connect("image_drawn", _on_image_drawn)


func generate_mesh() -> void:
	chunk_data.generate_height_map()

	var new_mesh := ArrayMesh.new()
	var surface_array := _generate_surface()

	new_mesh.add_surface_from_arrays(ArrayMesh.PRIMITIVE_TRIANGLES, surface_array)
	self.mesh = new_mesh

	var material := material_override as ShaderMaterial
	material.set_shader_parameter("height_multiplier", chunk_data.height_multiplier)


func _generate_surface() -> Array:
	var surface_array: Array = []
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var uvs := PackedVector2Array()
	var triangle_index: int = 0
	var mesh_simplification_increment: int = 1 if level_of_detail == 0 else level_of_detail * 2
	var vertices_per_line: int = (chunk_data.size - 1) / mesh_simplification_increment + 1

	vertices.resize(vertices_per_line * vertices_per_line)
	indices.resize((vertices_per_line - 1) * (vertices_per_line - 1) * 6)
	uvs.resize(vertices_per_line * vertices_per_line)

	surface_array.resize(ArrayMesh.ARRAY_MAX)

	for z in range(0, chunk_data.size, mesh_simplification_increment):
		for x in range(0, chunk_data.size, mesh_simplification_increment):
			var index: int = (x / mesh_simplification_increment) + (z / mesh_simplification_increment) * vertices_per_line
			var height: float = chunk_data.height_map[index]
			var vertex_position := Vector3(x, height, z)

			vertices[index] = vertex_position
			uvs[index] = Vector2(x / float(chunk_data.size), z / float(chunk_data.size))

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
