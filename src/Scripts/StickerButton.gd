extends Button

@export var image_path: String = ""
@export var main_script_link: Node3D

func _ready() -> void:
	self.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	var path_to_use: String = ""
	
	if image_path:
		path_to_use = image_path
	
	if not path_to_use:
		push_error("StickerButton: image path is not set.")
		return
	
	if not main_script_link:
		push_error("StickerButton: main_script_link is not set")
		return
	
	#Устанавливаем путь картинки в основной скрипт для формирования decal
	main_script_link.link_sticker = path_to_use
	main_script_link._create_preview_sticker()
	print("StickerButton: Changed image path to: ", path_to_use)
