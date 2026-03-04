extends Node3D
class_name BaseSpawner

@export var spawn_interval: float = 5.0
@export var units_per_wave: int = 4
@export var faction_id: int = 0
@export var spawn_radius: float = 3.0

var footman_scene: PackedScene
var spawn_timer: float = 0.0

func _ready():
	# In a real build, we load this from a data table to allow for upgrades
	# footman_scene = load("res://scenes/units/tier1_footman.tscn")
	pass

func _process(delta):
	if footman_scene == null:
		return
		
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_wave()

func spawn_wave():
	for i in range(units_per_wave):
		var unit = footman_scene.instantiate() as FootmanUnit
		
		# Add a slight random offset so they don't immediately stack on each other
		var offset = Vector3(randf_range(-spawn_radius, spawn_radius), 0, randf_range(-spawn_radius, spawn_radius))
		unit.global_position = global_position + offset
		
		unit.faction_id = faction_id
		
		# Spawn them into the world
		get_tree().current_scene.add_child(unit)
