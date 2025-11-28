extends VBoxContainer

@export var sticker_panel: Control
@export var main_script: Node3D

func _on_toggle_stickers_pressed() -> void:
	if sticker_panel:
		if sticker_panel.visible:
			sticker_panel.hide_panel()
		else:
			sticker_panel.show_panel()

func _on_eraser_pressed() -> void:
	var btn = get_child(1)
	if btn:
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.15)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15)

	if main_script and main_script.has_method("remove_all_stickers"):
		main_script.remove_all_stickers()