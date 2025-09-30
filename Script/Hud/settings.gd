extends Control

func _ready() -> void:
	if Global.sound_is_mute:
		$ColorRect/MuteSound.button_pressed = true

func _on_exit_game_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_reset_pressed() -> void:
	Global.resetGame()

func _on_mute_sound_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), toggled_on)
	Global.sound_is_mute = toggled_on
