@tool
extends MeshInstance3D

@export_range(0.0001, 10) var noiseScale: float = 1:
	set(value):
		noiseScale = value
		noise_has_changed()

@export var width: int = 100 :
	set(value):
		width = value
		noise_has_changed()

@export var height: int = 100 :
	set(value):
		height = value
		noise_has_changed()


var noiseTexture: NoiseTexture2D

func _ready() -> void:
	noiseTexture = NoiseTexture2D.new()
	noiseTexture.height = floor(height / noiseScale)
	noiseTexture.width = floor(width / noiseScale)

	noiseTexture.noise = FastNoiseLite.new()
	await noiseTexture.changed

	var material: StandardMaterial3D = mesh.surface_get_material(0)
	material.albedo_texture = noiseTexture


func _process(_delta: float) -> void:
	pass

func noise_has_changed() -> void:
	noiseTexture.height = floor(height / noiseScale)
	noiseTexture.width = floor(width / noiseScale)
	await noiseTexture.changed
	var material: StandardMaterial3D = mesh.surface_get_material(0)
	material.albedo_texture = noiseTexture
