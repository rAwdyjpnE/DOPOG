extends Resource
class_name ImageClass

@export var image_path: String
@export var image_name: String = ""

func _init(path: String = "", name: String = "") -> void:
	image_path = path
	image_name = name
