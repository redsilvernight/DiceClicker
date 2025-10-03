extends Node

var leaderboardId: String = "31916"
var leaderboardNbrEntrieHightScore: int = 10
var leaderboardControler: = preload("res://addons/SimpleLeaderboard/Script/leaderboardManager.gd").new()
var leaderboardAuthMethod = leaderboardControler.leaderboardAuth.AuthType.WHITELABEL
var player_name
var player_id

var current_dice : Dice
var menu_is_open: bool = false

var all_dice_face: Array = [4, 6, 8, 10, 12, 20]
var max_dice: int = 3

var nbr_dice_face: int = all_dice_face[0]
var nbr_dice: int = 1

var score: int
var hight_score: int

var screen_size: Vector2 = DisplayServer.window_get_size()

var suffixes: Array = [ "K", "M", "B", "T" ]

@onready var all_rollers: Dictionary = getRollers()
@onready var all_dice: Array = getDice()
@onready var icon_current_nbr_face: CompressedTexture2D = getIconCurrentNbrFace()
@onready var DiceScene = load("res://Scene/animatedDice.tscn")

func _ready() -> void:
	connect("tree_exiting", Callable(self, "_on_tree_exiting"))
	loadGame()

func getIconCurrentNbrFace() -> CompressedTexture2D:
	icon_current_nbr_face = load(str("res://Asset/Dice/d", nbr_dice_face, ".png"))
	return icon_current_nbr_face

func getRollers() -> Dictionary:
	var resource_dir = DirAccess.open("res://Resource/Roller")
	var rollers : Dictionary
	
	resource_dir.list_dir_begin()
	for resource in resource_dir.get_files():
		rollers[str(resource)] = load("res://Resource/Roller/%s" % str(resource))
		
	var sorted_keys = rollers.keys()
	sorted_keys.sort_custom(func(a, b): return rollers[a].item_cost < rollers[b].item_cost)
	
	var sorted_dict = {}
	for key in sorted_keys:
		sorted_dict[key] = rollers[key]
	return sorted_dict

func getDice() -> Array:
	var resource_dir = DirAccess.open("res://Resource/Dice")
	var dices : Array
	
	resource_dir.list_dir_begin()
	for resource in resource_dir.get_files():
		dices.append(load("res://Resource/Dice/%s" % str(resource)))
	
	dices.sort_custom(func(a, b): return a.item_cost < b.item_cost)

	return dices

func addDiceFace():
	if all_dice_face.find(nbr_dice_face) + 1 < all_dice_face.size() :
		nbr_dice_face = all_dice_face[all_dice_face.find(nbr_dice_face) + 1]
		var allDices = get_parent().get_node("Main").get_node("Hud").get_children()
		for dice in allDices:
			if dice.scene_file_path == "res://Scene/animatedDice.tscn":
				dice.get_node("AnimatedSprite2D").animation = "score_d" + str(Global.nbr_dice_face)
				dice.get_node("AnimatedSprite2D").frame = 1
		get_parent().get_node("Main").get_node("Hud").updateDiceFace()
		getIconCurrentNbrFace()

func addDice():
	if nbr_dice < max_dice:
		nbr_dice += 1
		var newDice = DiceScene.instantiate()
		newDice.connect("dice_rolled", get_parent().get_node("Main").get_node("Hud").updateScore)
		var newPosX = randf_range(screen_size.x * 0.1, screen_size.x * 0.9)
		var newPosY = randf_range(screen_size.y * 0.2, screen_size.y * 0.6)
		newDice.position = Vector2(newPosX, newPosY)
		get_parent().get_node("Main").get_node("Hud").add_child(newDice)

func saveGame():
	var buyed_roller: Dictionary
	for roller in all_rollers.values():
		buyed_roller[roller.item_name] = roller.buyed
	
	var save_data: Dictionary = {
		"player_name" : player_name,
		"score" : score,
		"hight_score": hight_score,
		"buyed_roller": buyed_roller,
		"current_dice": current_dice.id,
		"current_nbr_face": nbr_dice_face,
		"current_nbr_dice": nbr_dice,
		"sound_is_mute": AudioManager.sound_is_mute,
		"timestamp" : Time.get_unix_time_from_system()
	}
	
	var savefile = FileAccess.open("user://saveGame.json",FileAccess.WRITE)
	
	if savefile:
		savefile.store_string(JSON.stringify(save_data))
		savefile.close()
		
	if player_name:
			leaderboardControler.submitScore(leaderboardId, hight_score, player_name)
	
func loadGame():
	if FileAccess.file_exists("user://saveGame.json"):
		var savefile = FileAccess.open("user://saveGame.json",FileAccess.READ)
		
		if savefile:
			var data = JSON.parse_string(savefile.get_as_text())
			savefile.close()
			
			if typeof(data) == TYPE_DICTIONARY:
				player_name = data["player_name"]
				score = data["score"]
				hight_score = data["hight_score"]
				nbr_dice = data["current_nbr_dice"]
				nbr_dice_face = data["current_nbr_face"]
				icon_current_nbr_face = load(str("res://Asset/Dice/d", nbr_dice_face, ".png"))
				current_dice = all_dice[data["current_dice"]]
				AudioManager.toggleMuteSound(data["sound_is_mute"])
				
				var passed_time = Time.get_unix_time_from_system() - data['timestamp']
				
				for roller in all_rollers.values():
					var added_score: int
					roller.buyed = data["buyed_roller"][roller.item_name]
					if current_dice.has_effect:
						for effect in current_dice.effect_type:
							match effect:
								Dice.EffectType.QUANTUM:
									@warning_ignore("integer_division")
									added_score = passed_time / (roller.rolling_frequence + current_dice.roll_duration) * roller.buyed * (Global.nbr_dice_face * (Global.nbr_dice_face + 1) / 2)
								Dice.EffectType.COSMIC:
									@warning_ignore("integer_division")
									added_score = (passed_time / (roller.rolling_frequence + current_dice.roll_duration) * roller.buyed * (Global.nbr_dice_face * (Global.nbr_dice_face + 1) / 2)) * 2
					else:
						@warning_ignore("integer_division")
						added_score = passed_time / (roller.rolling_frequence + current_dice.roll_duration) * roller.buyed * (nbr_dice_face / 2)
				
					get_parent().get_node("Main").get_node("Hud").updateScore(roller.item_texture, added_score)
				
				await get_tree().create_timer(1).timeout
				get_parent().get_node("Main").get_node("Hud").get_node("menu").updateDice()
	else:
		current_dice = all_dice[0]
		score = 0

func resetGame():
	for roller in all_rollers.values():
		roller.buyed = 0
	current_dice = all_dice[0]
	nbr_dice_face = 4
	nbr_dice = 1
	score = 0
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		saveGame()
		await get_tree().create_timer(2).timeout
		get_tree().quit()
		
func _on_tree_exiting():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func displayNumber(number: int, withDecimals: bool = false) -> String:
	var strNumber = str(number)
	var numberWithComa = ""
	var count = 0
	
	for i in range(strNumber.length() - 1, -1, -1):
		numberWithComa = strNumber[i] + numberWithComa
		count += 1
		if count % 3 == 0 and i != 0:
			numberWithComa = "," + numberWithComa
	
	var numberSplit = numberWithComa.split(',')
	
	var currentSuffix = ""
	var decimals = ""
	for suffix in suffixes:
		if numberSplit.size() == 1:
			break
		
		currentSuffix = suffix
		if withDecimals:
			if decimals != "" and int(decimals) >= 500:
				numberSplit[-1] = str(int(numberSplit[-1]) + 1)
			decimals = numberSplit[-1]
		elif int(numberSplit[-1]) >= 500:
			numberSplit[-2] = str(int(numberSplit[-2]) + 1)
		numberSplit.resize(numberSplit.size() - 1)
	
	if decimals != "":
		decimals = "." + decimals
	
	return ','.join(numberSplit) + decimals + " " + currentSuffix
