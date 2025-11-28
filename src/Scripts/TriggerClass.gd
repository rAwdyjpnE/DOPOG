extends Resource

class_name Trigger
@export var __pos: Vector3
@export var __texture_sticker: String

func _init(pos: Vector3, link_sticker: String) -> void:
	self.__pos = pos
	self.__texture_sticker = link_sticker
