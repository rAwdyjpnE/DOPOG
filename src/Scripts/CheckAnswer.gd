extends Button

@export var quest_scene: Node3D
@export var result_scene: String

const MAX_DISTANCE: float = 1

func _ready() -> void:
	self.pressed.connect(_check_result)
	quest_scene = get_parent().get_parent()

func _check_result() -> void:
	if not quest_scene:
		push_error("Error: quest_scene wasn't found")
		return
	
	var correct: Array = []
	var wrong: Array = []
	
	for sticker in quest_scene.stickers:
		var decal_pos = sticker.get("link").position
		var decal_texture = sticker.get("name")
		
		var trig = null
		
		for trigger in quest_scene.trigger_list:
			if trigger.__texture_sticker == decal_texture:
				trig = trigger
				break
		
		if trig != null and trig.__pos.distance_to(decal_pos) <= MAX_DISTANCE:
			correct.append(sticker)
		else:
			if trig != null:
				print(trig.__pos.distance_to(decal_pos))
			wrong.append(sticker)
	
	G.correct = correct.size()
	G.wrong = wrong.size()
	get_tree().change_scene_to_file(result_scene)
