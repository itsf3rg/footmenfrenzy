extends Node
class_name BaseAbility

# Agent 2: Modular ability framework

@export var ability_id: String = "base_ability"
@export var cooldown_time: float = 5.0
@export var mana_cost: float = 20.0

var current_cooldown: float = 0.0

func _process(delta):
	if current_cooldown > 0:
		current_cooldown -= delta

func can_cast(caster: HeroUnit) -> bool:
	if current_cooldown > 0:
		return false
	if caster.current_mana < mana_cost:
		return false
	return true

func try_cast(caster: HeroUnit):
	if can_cast(caster):
		caster.current_mana -= mana_cost
		current_cooldown = cooldown_time
		execute(caster)

func execute(caster: HeroUnit):
	# Override in specialized ability scripts (e.g. FireballAbility, HealAbility)
	push_warning("BaseAbility execute called directly!")
	pass
