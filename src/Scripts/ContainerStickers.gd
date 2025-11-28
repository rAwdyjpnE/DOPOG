extends Node3D

var stickers: Array[Node3D] = []
func apply_sticker(texture_path: String, _pos: Vector3 = Vector3.ZERO) -> void:
	var texture = load(texture_path)
	if not texture:
		push_error("Failed to load texture: " + texture_path)
		return
	var decal = Decal.new()
	decal.texture_albedo = texture
	decal.size = Vector3(1, 1, 1)
	decal.cull_mask = 1
	add_child(decal)
	decal.position = Vector3(0, 0, 1.51)
	decal.rotation_degrees = Vector3(-90, 0, 0)
	stickers.append(decal)

func remove_all_stickers() -> void:
	for sticker in stickers:
		if is_instance_valid(sticker):
			sticker.queue_free()
	stickers.clear()