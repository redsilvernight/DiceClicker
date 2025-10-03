extends Control

var leaderboardControler
var is_ready: bool = false

func _ready() -> void:
	leaderboardControler = Global.leaderboardControler
	leaderboardControler.leaderboardAuth.autoSignIn(self)
	
		
func _on_sign_up_menu_button_pressed() -> void:
	$ColorRect/ScrollContainer/ConnexionMenu/SignInMenu.hide()
	$ColorRect/ScrollContainer/ConnexionMenu/SignUpMenu.show()

func _on_sign_in_menu_button_pressed() -> void:
	$ColorRect/ScrollContainer/ConnexionMenu/SignUpMenu.hide()
	$ColorRect/ScrollContainer/ConnexionMenu/SignInMenu.show()
	
func _on_sign_up_button_pressed() -> void:
	leaderboardControler.leaderboardAuth.signUp(self)

func _on_sign_in_button_pressed() -> void:
	leaderboardControler.leaderboardAuth.signIn(self)

func updateMenu():
	if Global.player_name:
		$ColorRect/ScrollContainer/ConnexionMenu.hide()
		setupLeaderboard()
	else:
		$ColorRect/ScrollContainer/ConnexionMenu.show()

func returnError(label: Label, text: String):
	label.text = text
	label.show()
	
func setupLeaderboard():
	if is_ready:
		for child in $ColorRect/ScrollContainer/Leaderboard.get_children():
			if child.name != "YourRank":
				$ColorRect/ScrollContainer/Leaderboard.remove_child(child)
				child.queue_free()
			
		var leaderboard = await leaderboardControler.getLeaderboard(Global.leaderboardId, Global.leaderboardNbrEntrieHightScore)
		if !leaderboard.has(Global.player_name):
			var player_rank = await leaderboardControler.getPlayerRank(Global.leaderboardId, Global.player_id)
			var player_card = leaderboardControler.leaderboardCard.instantiate()
			player_card.setup(player_rank[Global.player_name]["rank"], player_rank.keys()[0], player_rank[Global.player_name]["score"])
			player_card.get_node("Panel").get_theme_stylebox("panel").bg_color = Color(0.142, 0.349, 0.409, 1.0)
			$ColorRect/ScrollContainer/Leaderboard/YourRank.add_child(player_card)
			$ColorRect/ScrollContainer/Leaderboard/YourRank.show()
		else:
			$ColorRect/ScrollContainer/Leaderboard/YourRank.hide()
			
		for player in leaderboard:
			var new_card = leaderboardControler.leaderboardCard.instantiate()
			var color: Color
			var styleBox = StyleBoxFlat.new()
			
			new_card.setup(leaderboard[player]["rank"], player, leaderboard[player]["score"])
			
			if player == Global.player_name:
				color = Color(0.142, 0.349, 0.409, 1.0)
			else:
				color = Color(0.377, 0.31, 0.134, 1.0)
				
			styleBox.bg_color = color
			new_card.get_node("Panel").set("theme_override_styles/panel", styleBox)
			$ColorRect/ScrollContainer/Leaderboard.add_child(new_card)
		
		var nbr_card = get_node("ColorRect/ScrollContainer/Leaderboard").get_children().size()
		$ColorRect/ScrollContainer/Leaderboard.custom_minimum_size = Vector2(0,(57 + 20) * nbr_card)
		$ColorRect/ScrollContainer/Leaderboard.show()
