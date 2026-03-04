extends Node
class_name FeedbackManager

# Agent 9: Audio & VFX Manager
# Manages spawning particle effects and playing sounds WITHOUT tying them to unit lifespans.
# If a unit dies, its sound/vfx should finish playing, not get destroyed with the unit.

@export var popup_vfx_scene: PackedScene
@export var death_sound: AudioStream

func play_death_feedback(global_pos: Vector3, faction_id: int):
	# 1. Play spatialized audio "pop"
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = death_sound
	audio_player.global_position = global_pos
	# Random pitch for variance in large crowds
	audio_player.pitch_scale = randf_range(0.8, 1.2) 
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()
	
	# Auto-destroy audio node when finished
	audio_player.finished.connect(func(): audio_player.queue_free())
	
	# 2. Spawn colored particle "pop" based on faction_id
	if popup_vfx_scene:
		var vfx = popup_vfx_scene.instantiate() as Node3D
		vfx.global_position = global_pos
		# Modify VFX color based on faction...
		get_tree().current_scene.add_child(vfx)
