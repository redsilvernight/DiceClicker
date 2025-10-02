extends Control

var leaderboardControler: leaderboardManager

func _ready() -> void:
	leaderboardControler = Global.leaderboardControler
	leaderboardControler.leaderboardAuth.autoSignIn(self)
	await get_tree().create_timer(2).timeout
	updateMenu()
		
func _on_sign_up_menu_button_pressed() -> void:
	$ColorRect/ScrollContainer/Control/ConnexionMenu/SignInMenu.hide()
	$ColorRect/ScrollContainer/Control/ConnexionMenu/SignUpMenu.show()

func _on_sign_in_menu_button_pressed() -> void:
	$ColorRect/ScrollContainer/Control/ConnexionMenu/SignUpMenu.hide()
	$ColorRect/ScrollContainer/Control/ConnexionMenu/SignInMenu.show()
	
func _on_sign_up_button_pressed() -> void:
	leaderboardControler.leaderboardAuth.signUp(self)

func _on_sign_in_button_pressed() -> void:
	leaderboardControler.leaderboardAuth.signIn(self)

func updateMenu():
	if Global.player_name is String:
		$ColorRect/ScrollContainer/Control/ConnexionMenu.hide()
		setupLeaderboard()
	else:
		$ColorRect/ScrollContainer/Control/ConnexionMenu.show()

func returnError(label: Label, text: String):
	label.text = text
	label.show()
	
func setupLeaderboard():
	var learderboard = await leaderboardControler.getLeaderboard(Global.leaderboardId, Global.leaderboardNbrEntrieHightScore)
	print(learderboard)
	$ColorRect/ScrollContainer/Control/Leaderboard.show()
