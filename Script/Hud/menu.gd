extends Control

var upgradeScreen = preload("res://Script/Hud/upgrade_screen.gd").new()

func _process(_delta: float) -> void:
	if Global.menu_is_open:
		upgradeScreen.updateAllCard()
		
func _on_leaderboard_pressed() -> void:
	if Global.menu_is_open && $ColorRect/ScrollContainer/leaderboard.visible:
		closeMenu()
	else:
		clearScreen()
		$ColorRect/ScrollContainer/leaderboard.custom_minimum_size = Vector2(0, 300 + 70)
		$ColorRect/ScrollContainer/leaderboard.show()
		openMenu()

func _on_upgrade_pressed() -> void:
	if Global.menu_is_open && $ColorRect/ScrollContainer/upgradeMenu.visible:
		closeMenu()
	else:
		clearScreen()
		if $ColorRect/ScrollContainer/upgradeMenu/rollerMenu.get_children():
			upgradeScreen.updateAllCard()
		else:
			upgradeScreen.setupScreen($ColorRect)
			
		$ColorRect/ScrollContainer/upgradeMenu.custom_minimum_size = Vector2(0, 270 + 208 * Global.all_rollers.size())
		$ColorRect/ScrollContainer/upgradeMenu.show()
		openMenu()

func _on_settings_pressed() -> void:
	if Global.menu_is_open && $ColorRect/ScrollContainer/settingsMenu.visible:
		closeMenu()
	else:
		clearScreen()
		$ColorRect/ScrollContainer/settingsMenu.custom_minimum_size = Vector2(0, 811 + 70)
		$ColorRect/ScrollContainer/settingsMenu.show()
		openMenu()

func _on_close_pressed() -> void:
	closeMenu()

func clearScreen():
	for child in $ColorRect/ScrollContainer.get_children():
		child.hide()
		
func openMenu():
	if !Global.menu_is_open:
		$AnimationPlayer.play("openMenu")
		Global.menu_is_open = true

func closeMenu():
	if Global.menu_is_open:
		$AnimationPlayer.play("closeMenu")
		Global.menu_is_open = false
	
func _on_button_current_dice_pressed() -> void:
	upgradeScreen.showDice(self, "current")

func _on_button_next_dice_pressed() -> void:
	upgradeScreen.showDice(self, "next")

func _on_button_upgrade_pressed() -> void:
	upgradeScreen.showDice(self, "next", 1)

func updateDice():
	var current = $ColorRect/ScrollContainer/upgradeMenu/HBoxContainer/ButtonCurrentDice/TextureRect
	var next = $ColorRect/ScrollContainer/upgradeMenu/HBoxContainer/ButtonNextDice/TextureRect
	
	current.texture = Global.current_dice.item_texture
	
	if Global.all_dice.find(Global.current_dice) + 1 < Global.all_dice.size():
		next.texture = Global.all_dice[Global.all_dice.find(Global.current_dice) + 1].item_texture
	else:
		next.texture = TextureRect.new()
