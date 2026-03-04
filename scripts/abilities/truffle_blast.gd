extends BaseAbility
class_name TruffleBlastAbility

@export var projectile_speed: float = 15.0
@export var damage: float = 75.0

func execute(caster: HeroUnit):
	print(caster.name, " casted Truffle Blast!")
	
	# Future implementation: Instantiate projectile scene, set velocity towards target/mouse
	# When projectile hits, call target.take_damage(damage)
	pass
