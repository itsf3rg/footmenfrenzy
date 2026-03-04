extends Node3D
class_name ArtAssetManager

# Agent 6: Art Director
# Central hub for dynamically loading 3D meshes based on Faction ID and Unit Tier

@export var faction_materials: Array[Material]
@export var default_footman_mesh: Mesh
@export var default_hero_mesh: Mesh

func apply_faction_colors(target_mesh_instance: MeshInstance3D, faction_id: int):
	if faction_id >= 0 and faction_id < faction_materials.size():
		target_mesh_instance.material_override = faction_materials[faction_id]
	else:
		push_warning("Invalid faction ID for material application")

func get_footman_mesh(tier: int) -> Mesh:
	# Later we will load specific .glb files based on the tier
	return default_footman_mesh

func get_hero_mesh(hero_id: String) -> Mesh:
	# Later we will dynamically load unique Hero models
	return default_hero_mesh
