extends BaseAbility
class_name GummySlamAbility

@export var slam_radius: float = 3.0
@export var damage: float = 50.0

func execute(caster: HeroUnit):
	print(caster.name, " casted Gummy Slam!")
	
	# Future implementation: Play animation, spawn VFX, then deal damage to all units in area
	
	var enemies_in_range = _get_enemies_in_radius(caster.global_position, slam_radius)
	for enemy in enemies_in_range:
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

func _get_enemies_in_radius(pos: Vector3, radius: float) -> Array:
	# Placeholder for spatial query
	return []
