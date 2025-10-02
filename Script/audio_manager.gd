extends Node

var sound_is_mute: bool = false

func playBuySound() -> void:
	$BuySound.pitch_scale = _randomPitch()
	$BuySound.play()

func playRollingSound() -> void:
	$RollingSound.pitch_scale = _randomPitch()
	$RollingSound.play()

func toggleMuteSound(mute: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), mute)
	sound_is_mute = mute

func _randomPitch() -> float:
	return [0.9, 1.0, 1.1].pick_random()
