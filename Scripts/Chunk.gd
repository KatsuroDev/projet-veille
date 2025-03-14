@tool
class_name Chunk
extends MeshInstance3D


var chunk_data: ChunkData = ChunkData.new()


func _ready() -> void:
	pass


func generate_mesh() -> void:
	chunk_data.generate_height_map()

	var new_mesh := ArrayMesh.new()
	var surface_array := _generate_surface()

	new_mesh.add_surface_from_arrays(ArrayMesh.PRIMITIVE_TRIANGLES, surface_array)
	self.mesh = new_mesh


func _generate_surface() -> Array:
	var surface_array: Array = []
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var uvs := PackedVector2Array()
	var triangle_index: int = 0

	vertices.resize(chunk_data.width * chunk_data.width)
	indices.resize((chunk_data.width - 1) * (chunk_data.width - 1) * 6)
	uvs.resize(chunk_data.width * chunk_data.width)

	surface_array.resize(ArrayMesh.ARRAY_MAX)

	for z in range(chunk_data.width):
		for x in range(chunk_data.width):
			var index: int = z + x * chunk_data.width
			var height: float = chunk_data.height_map[index]
			var vertex_position := Vector3(x, height, z)

			vertices[index] = vertex_position
			uvs[index] = Vector2(x / float(chunk_data.width), z / float(chunk_data.width))

			if x < chunk_data.width - 1 && z < chunk_data.width - 1:
				indices[triangle_index] = index + chunk_data.width
				indices[triangle_index + 1] = index + chunk_data.width + 1
				indices[triangle_index + 2] = index
				
				indices[triangle_index + 3] = index + 1
				indices[triangle_index + 4] = index
				indices[triangle_index + 5] = index + chunk_data.width + 1

				triangle_index += 6

	surface_array[ArrayMesh.ARRAY_VERTEX] = vertices
	surface_array[ArrayMesh.ARRAY_INDEX] = indices
	surface_array[ArrayMesh.ARRAY_TEX_UV] = uvs

	return surface_array
