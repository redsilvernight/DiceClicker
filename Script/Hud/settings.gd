extends Control

func _ready() -> void:
	if AudioManager.sound_is_mute:
		$ColorRect/MuteSound.button_pressed = true

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_reset_pressed() -> void:
	Global.resetGame()

func _on_mute_sound_toggled(toggled_on: bool) -> void:
	AudioManager.toggleMuteSound(toggled_on)
