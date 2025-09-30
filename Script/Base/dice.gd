class_name Dice
extends Item

enum EffectType { QUANTUM, COSMIC }

@export var id : int
@export var roll_duration: float
@export var has_effect: bool
@export var effect_type: Array[EffectType]


func _init() -> void:
	item_type = ItemType.DICE
	
