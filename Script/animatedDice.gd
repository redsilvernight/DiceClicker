extends Node2D

signal dice_rolled

var dice_rolling = false
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.animation = "score_d" + str(Global.nbr_dice_face)
	$AnimatedSprite2D.frame = 1
	set_roll_path()

func _process(_delta: float) -> void:
	if Input.is_action_just_released("roll_dice") and dice_rolling == false and Global.menu_is_open == false:
		start_rolling()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and dice_rolling == false and Global.menu_is_open == false:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			start_rolling()

func start_rolling() -> void:
	AudioManager.playRollingSound()
	dice_rolling = true
	$AnimatedSprite2D.play("roll_d" + str(Global.nbr_dice_face))
	$RollingTimer.start()
	update_roll_path()
	$AnimationPlayer.play("default/roll")

func finish_rolling() -> void:
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.animation = "score_d" + str(Global.nbr_dice_face)
	var score = 1 + randi() % Global.nbr_dice_face
	$AnimatedSprite2D.frame = score
	dice_rolling = false
	
	dice_rolled.emit(Global.icon_current_nbr_face, score)

func set_roll_path() -> void:
	var animation = Animation.new()
	animation.length = $RollingTimer.wait_time
	
	var track = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath(str(self.get_path()) + ":position"))
	
	animation.track_insert_key(track, 0.0, Vector2())
	animation.track_insert_key(track, 0.5, Vector2())
	animation.track_insert_key(track, 1.0, Vector2())
	
	$AnimationPlayer.add_animation_library("default", AnimationLibrary.new())
	$AnimationPlayer.get_animation_library("default").add_animation("roll", animation)

func update_roll_path() -> void:
	var animation = $AnimationPlayer.get_animation_library("default").get_animation("roll")
	var track = 0
	
	var pos_x = self.position.x
	var pos_y = self.position.y
	animation.track_set_key_value(track, 0, Vector2(pos_x, pos_y))
	
	var dir_x = [-1, 1].pick_random()
	if (pos_x < screen_size.x * 0.25):
		dir_x = 1
	elif (pos_x > screen_size.x * 0.75):
		dir_x = -1
		
	var dir_y = [-1, 1].pick_random()
	if (pos_y < screen_size.x * 0.35):
		dir_y = 1
	elif (pos_y > screen_size.x * 0.65):
		dir_y = -1
	
	pos_x = clampi(pos_x + (50 + randi() % 100) * dir_x, screen_size.x * 0.1, screen_size.x * 0.9)
	pos_y = clampi(pos_y + (100 + randi() % 150) * dir_y, screen_size.y * 0.2, screen_size.y * 0.6)
	animation.track_set_key_value(track, 1, Vector2(pos_x, pos_y))
	
	dir_x -= dir_x
	if (pos_x < screen_size.x * 0.25):
		dir_x = 1
	elif (pos_x > screen_size.x * 0.75):
		dir_x = -1
	
	pos_x = clampi(pos_x + 50 * dir_x, screen_size.x * 0.1, screen_size.x * 0.9)
	pos_y = clampi(pos_y + 100 * dir_y, screen_size.y * 0.2, screen_size.y * 0.6)
	animation.track_set_key_value(track, 2, Vector2(pos_x, pos_y))
