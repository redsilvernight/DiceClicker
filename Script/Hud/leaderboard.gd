extends Control

func _ready() -> void:
	if Global.player_name:
		loadLeaderboard()
	else:
		$ColorRect/ScrollContainer/Control/Leaderboard.hide()
		$ColorRect/ScrollContainer/Control/SignUpMenu.show()
		
func loadLeaderboard():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	for score in sw_result.scores:
		var entrie = Label.new()
		entrie.text = str(score.player_name, str(int(score.score)))
		$ColorRect/ScrollContainer/Control/Leaderboard.add_child(entrie)

func _on_valid_username_pressed() -> void:
	var username_input = $ColorRect/ScrollContainer/Control/NameInput/TextEdit.text
	if !username_input.is_empty() and username_input.length() < 24 :
		Global.player_name = username_input
		$ColorRect/ScrollContainer/Control/NameInput.hide()
		loadLeaderboard()
