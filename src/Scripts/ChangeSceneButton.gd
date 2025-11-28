extends Button

@export var next_scene: String

func _ready() -> void:
	self.pressed.connect(_go_to_next_scene)

func _go_to_next_scene() -> void:
	get_tree().change_scene_to_file(next_scene)
