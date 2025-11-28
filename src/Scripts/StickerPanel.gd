extends Panel

@export var main_script: Node3D

var selected_btn: TextureButton = null

const STICKER_FILES = [
	"1.png", "1.4.png", "1.5.png", "1.6.png",
	"2.png", "2.1.png", "2.2.png", "2.3.png", "2.4.png",
	"3.png", "3.1.png",
	"4.png", "4.1.png", "4.2.png", "4.3.png",
	"5.1.png", "5.2.png", "5.2.1.png",
	"6.png",
	"7.1.png", "7.2.png", "7.3.png", "7.4.png",
	"8.png",
	"9.png", "9.1.png"
]

@onready var container_box = $ScrollContainer/HBoxContainer

func _ready() -> void:
	visible = false
	_populate_stickers()
	call_deferred("_init_position")

func _init_position() -> void:
	var screen_h = get_viewport_rect().size.y
	position.y = screen_h + 10

func show_panel() -> void:
	if visible: return
	visible = true
	
	var screen_h = get_viewport_rect().size.y
	var target_y = screen_h - size.y - 10
	
	if position.y < target_y:
		position.y = screen_h + 10
		
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", target_y, 0.3)

func hide_panel() -> void:
	if not visible: return
	var screen_h = get_viewport_rect().size.y
	var target_y = screen_h + 10
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", target_y, 0.25)
	tween.tween_callback(func(): visible = false)

func _populate_stickers() -> void:
	for child in container_box.get_children():
		child.queue_free()
		
	for filename in STICKER_FILES:
		var ui_path = "res://src/Images/" + filename
		var logic_path = "res://src/Textures/" + filename
		
		if not ResourceLoader.exists(ui_path):
			continue
			
		var btn = TextureButton.new()
		btn.custom_minimum_size = Vector2(110, 110)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.texture_normal = load(ui_path)
		var border = Panel.new()
		border.name = "SelectionBorder"
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		border.set_anchors_preset(Control.PRESET_FULL_RECT)
		border.visible = false
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0)
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_color = Color(0.2, 0.8, 0.2, 1)
		style.set_corner_radius_all(8)
		border.add_theme_stylebox_override("panel", style)
		btn.add_child(border)
		btn.pressed.connect(_on_sticker_clicked.bind(btn, logic_path))
		var label_text = filename.replace(".png", "")
		var lbl = Label.new()
		lbl.text = label_text
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_constant_override("outline_size", 4)
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		btn.add_child(lbl)
		container_box.add_child(btn)

func _on_sticker_clicked(btn: TextureButton, path: String) -> void:
	if selected_btn != null and is_instance_valid(selected_btn):
		var old_border = selected_btn.get_node_or_null("SelectionBorder")
		if old_border:
			old_border.visible = false

	selected_btn = btn

	var new_border = selected_btn.get_node_or_null("SelectionBorder")
	if new_border:
		new_border.visible = true

	if main_script and main_script.has_method("set_active_sticker"):
		main_script.set_active_sticker(path)