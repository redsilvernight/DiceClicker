class_name Roller
extends Item

signal roller_buyed

@export var rolling_frequence: float
@export var buyed: int

func _init() -> void:
	item_type = ItemType.ROLLER

func rollerBuyed(roller):
	if Global.score >= roller.getCurrentPrice(roller):
		roller_buyed.emit(roller, -roller.getCurrentPrice(roller))
		roller.buyed += 1
		
func getCurrentPrice(roller):
	return ceil(roller.item_cost * 1.15 ** roller.buyed)
