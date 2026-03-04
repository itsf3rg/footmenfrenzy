extends Control
class_name HUDManager

# Agent 8: UI & UX Implementation
# This script manages the high-level layout of the in-game HUD.

@onready var hero_portrait = $BottomPanel/HeroCenter/Portrait
@onready var hp_bar = $BottomPanel/HeroCenter/HPBar
@onready var mana_bar = $BottomPanel/HeroCenter/ManaBar
@onready var ability_container = $BottomPanel/HeroCenter/Abilities
@onready var gold_label = $BottomPanel/RTSPanel/GoldAmount
@onready var base_upgrade_btn = $BottomPanel/RTSPanel/UpgradeButton

var active_hero: HeroUnit
var current_gold: int = 0

func _ready():
	# In a real game, this would be connected to a global signal
	# EventBus.connect("hero_selected", _on_hero_selected)
	pass

func _process(delta):
	if active_hero and is_instance_valid(active_hero):
		_update_hero_stats()

func _update_hero_stats():
	hp_bar.max_value = active_hero.max_health
	hp_bar.value = active_hero.current_health
	
	mana_bar.max_value = active_hero.max_mana
	mana_bar.value = active_hero.current_mana
	
	# Update ability cooldown overlays...

func add_gold(amount: int):
	current_gold += amount
	gold_label.text = str(current_gold)

func _on_upgrade_button_pressed():
	# Signal the server that this player wants to upgrade their base
	print("Requested base upgrade!")
	pass
