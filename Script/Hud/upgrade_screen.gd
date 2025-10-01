extends Node

var sceneCardUpgrade = preload("res://Scene/item_card.tscn")
var scenePopUp = preload("res://Scene/popup_dice.tscn")
var node_menu
var bw_shader = preload("res://Shaders/blackwhite.gdshader")
	
func setupScreen(menu):
	node_menu = menu
	
	var rollers = Global.all_rollers
	
	for roller in rollers:
		if rollers[roller]:
			setupRollerCard(rollers[roller])
	
func setupRollerCard(roller):
	var roller_card = sceneCardUpgrade.instantiate()
	var card = roller_card.get_node("ColorRect")
	
	updateCard(card, roller)
	
	node_menu.get_node("ScrollContainer").get_node("upgradeMenu").get_node("rollerMenu").add_child(roller_card)
	
	if !card.get_node("BuyButton").is_connected("pressed",roller.rollerBuyed.bind(roller)):
		card.get_node("BuyButton").connect("pressed",roller.rollerBuyed.bind(roller))
	if !roller.is_connected("roller_buyed",self.rollerBuyed):
		roller.connect("roller_buyed",self.rollerBuyed)
	
func updateAllCard():
	if node_menu :
		var upgrade_menu = node_menu.get_node("ScrollContainer").get_node("upgradeMenu")
		var btnNextDice = upgrade_menu.get_node("HBoxContainer").get_node("ButtonNextDice").get_node("TextureRect")
		if Global.all_dice.find(Global.current_dice) + 1 < Global.all_dice.size():
			var nextDicePrice = Global.all_dice[Global.current_dice.id + 1].item_cost
			if nextDicePrice <= Global.score:
				btnNextDice.material = null
			else:
				var mat = ShaderMaterial.new()
				mat.shader = bw_shader
				mat.set_shader_parameter("intensity", 1.0)
				btnNextDice.material = mat
		
		var all_card = upgrade_menu.get_node("rollerMenu").get_children()
		var roller_values = Global.all_rollers.values()
		
		for card in range(all_card.size()):
			updateCard(all_card[card].get_node("ColorRect"), roller_values[card], 1)
		
func updateCard(card, item, upgrade = 0):
	card.get_node("Name").text = item.item_name
	if "buyed" in item:
		card.get_node("Buyed").text = str(item.buyed) if item.buyed != 0 else ""
	else:
		card.get_node("Buyed").text = ""
	card.get_node("Description").text = item.item_description
	if upgrade == 1:
		card.get_node("BuyButton").show()
		if item.item_type == Item.ItemType.ROLLER:
			card.get_node("BuyButton").get_node("Price").text = str(int(item.getCurrentPrice(item)))
		else:
			card.get_node("BuyButton").get_node("Price").text = str(int(item.item_cost))
		if item.item_type == Item.ItemType.DICE:
			if card.get_node("BuyButton").is_connected("pressed", self.diceBuyed):
				card.get_node("BuyButton").disconnect("pressed", self.diceBuyed)
				
			card.get_node("BuyButton").connect("pressed", self.diceBuyed.bind(item, card))
	else:
		card.get_node("BuyButton").hide()
	card.get_node("Texture").texture = item.item_texture
	
	var buy_button = card.get_node("BuyButton")
	var icon = card.get_node("Texture")
	var current_price = ""
	
	if item.item_type == Item.ItemType.ROLLER:
		current_price = item.getCurrentPrice(item)
	else:
		current_price = item.item_cost
		
	if item.item_cost != 0 and current_price <= Global.score:
		icon.material = null
		buy_button.material = null
		buy_button.disabled = false
	else:
		var mat = ShaderMaterial.new()
		mat.shader = bw_shader
		mat.set_shader_parameter("intensity", 1.0)
		icon.material = mat
		buy_button.material = mat
		buy_button.disabled = true

func rollerBuyed(roller, price):
	var all_card = node_menu.get_node("ScrollContainer").get_node("upgradeMenu").get_node("rollerMenu").get_children()
	var updated_card = null
	
	for card in all_card:
		if card.get_node("ColorRect").get_node("Name").text == roller.item_name:
			updated_card = card.get_node("ColorRect")
	
	updateCard(updated_card, roller, 1)
	node_menu.get_parent().get_parent().get_parent().get_node("Hud").updateScore(roller.item_texture, price)
	AudioManager.playBuySound()

func showDice(menu, type, upgrade = 0):
	var dice
	match type:
		"current":
			dice = Global.current_dice
		"next":
			if Global.all_dice.find(Global.current_dice) + 1 < Global.all_dice.size():
				dice = Global.all_dice[Global.all_dice.find(Global.current_dice) + 1]
	
	if dice:
		if menu.get_parent().has_node("PopupDice"):
			updateCard(menu.get_parent().get_node("PopupDice").get_node("ColorRect"), dice, upgrade)
			menu.get_parent().get_node("PopupDice").show()
		else:
			var dice_card = scenePopUp.instantiate()
			var card = dice_card.get_node("ColorRect")
		
			updateCard(card, dice, upgrade)
			menu.get_parent().add_child(dice_card)

func diceBuyed(dice, card):
	if Global.score >= dice.item_cost:
		Global.current_dice = dice
		card.get_parent().hide()
		updateAllCard()
		node_menu.get_parent().get_parent().get_parent().get_node("Hud").updateScore(dice.item_texture, -dice.item_cost)
		AudioManager.playBuySound()
		node_menu.get_parent().updateDice()
		
