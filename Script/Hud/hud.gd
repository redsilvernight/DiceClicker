extends CanvasLayer

@onready var menuScene = preload("res://Scene/menu.tscn")

var dice_face_upgrade_price: int
var dice_upgrade_price: int

func _ready() -> void:
	var menu = menuScene.instantiate()
	add_child(menu)
	
	get_node("RollDice").connect("dice_rolled",updateScore)
	updateDiceFace()
	canBuyUpgrade()

func updateDiceFace():
	var current_index = Global.all_dice_face.find(Global.nbr_dice_face) + 1
	$addDiceFace/AnimatedSprite2D.frame = current_index

func updateScore(texture, score = 0):
	if Global.score > Global.hight_score:
		Global.hight_score = Global.score
	Global.score += score
	$Score.text = Global.displayNumber(Global.score, true)
	if score != 0:
		scorePopup(score, texture)
		canBuyUpgrade()

func scorePopup(score, texture):
	var popup = Label.new()
	
	var sprite = TextureRect.new()
	sprite.texture = texture
	sprite.position = Vector2(-40, 0)
	popup.add_child(sprite)
	
	var color: Color = Color(0.0, 0.553, 0.096, 1.0) if score > 0 else Color(0.719, 0.0, 0.0, 1.0)
	popup.text = ("+ " if score >= 0 else "") + Global.displayNumber(score)
	popup.set("theme_override_colors/font_color", color)
	
	popup.position = Vector2(randf_range(140, Global.screen_size.x - 140), 80)
	
	popup.add_theme_font_size_override("font_size", 24)
	add_child(popup)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "position", Vector2(popup.position.x, popup.position.y - 80 ), 3.0)
	tween.tween_property(popup, "modulate:a", 0.0, 2.0)
	
	tween.tween_callback(popup.queue_free).set_delay(1.0)

func _on_add_dice_pressed() -> void:
	Global.addDice()
	updateScore(load("res://Asset/Icon/dice_plus.png"), -dice_upgrade_price)

func _on_add_dice_face_pressed() -> void:
	Global.addDiceFace()
	updateScore(load("res://Asset/Icon/dice_plus.png"),-dice_face_upgrade_price)

func canBuyUpgrade():
	var all_dice_face = Global.all_dice_face
	var dice_upgrade = $addDice
	var dice_face_upgrade = $addDiceFace
	
	if all_dice_face.find(Global.nbr_dice_face) + 1 < all_dice_face.size():
		dice_face_upgrade_price = (all_dice_face[all_dice_face.find(Global.nbr_dice_face) + 1] - 5) * 600
		dice_face_upgrade.get_node("Label").text = str(dice_face_upgrade_price)
	else:
		dice_face_upgrade.get_node("Label").text = "Out of order"
	
	if Global.nbr_dice < Global.max_dice:
		dice_upgrade_price = Global.nbr_dice * 10000
	
	if Global.score >= dice_face_upgrade_price and Global.nbr_dice_face != 20:
		dice_face_upgrade.get_node("AnimatedSprite2D").material = null
		dice_face_upgrade.disabled = false
	else:
		dice_face_upgrade.get_node("AnimatedSprite2D").material = ShaderManager.bwShaderMaterial()
		dice_face_upgrade.disabled = true
		dice_face_upgrade.get_node("Label").text = "Out of order"
	
	if Global.score >= dice_upgrade_price and Global.nbr_dice != 5:
		dice_upgrade.material = null
		dice_upgrade.disabled = false
	else:
		dice_upgrade.material = ShaderManager.bwShaderMaterial()
		dice_upgrade.disabled = true
