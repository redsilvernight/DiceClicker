class_name Item
extends Resource

enum ItemType { DICE, ROLLER }

@export var item_type: ItemType
@export var item_name: String
@export var item_description: String
@export var item_texture: Texture2D
@export var item_cost: int
