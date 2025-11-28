extends Node3D

@export var object: Node3D
@export var camera: Camera3D
@export var task_label: Label

var is_rotating = false
const ROTATE_TIME = 0.5
const RAY_LENGTH = 1_000

const ZOOM_SPEED = 0.5
const MIN_ZOOM = 3.0
const MAX_ZOOM = 10.0
var target_zoom: float = 6.5

var stickers : Array[Dictionary] = []
var stickers_lenght : int = 0

var link_sticker : String
var preview_sticker: Decal = null

var sq = load("res://src/Nodes/Cube.tscn")
var ci = load("res://src/Nodes/circle.tscn")
var cy = load("res://src/Nodes/cylinder.tscn")
var figures = []
var index_fig = 0

var trigger_list : Array
var quest: Dictionary = G.quest_list

const BACK_TR = Vector3(1, 1, 1)
const FRONT_TR = Vector3(0, 0.795, 1.489)
const RIGHT_TR = Vector3(1, 1, 1)
const LEFT_TR= Vector3(1, 1, 1)

func _ready() -> void:
	figures = [sq, ci, cy]
	if object == null:
		_spawn_initial_object()
	if camera:
		target_zoom = camera.position.z
		
	_init_triggers()
	_update_task_ui()

func _init_triggers() -> void:
	if quest.get("front") != null and quest.get("front_path") != null:
		trigger_list.append(Trigger.new(FRONT_TR, quest.get("front_path")))
	if quest.get("back") != null and quest.get("back_path") != null:
		trigger_list.append(Trigger.new(BACK_TR, quest.get("back_path")))
	if quest.get("right") != null and quest.get("right_path") != null:
		trigger_list.append(Trigger.new(RIGHT_TR, quest.get("right_path")))
	if quest.get("left") != null and quest.get("left_path") != null:
		trigger_list.append(Trigger.new(LEFT_TR, quest.get("left_path")))

func _update_task_ui() -> void:
	if not task_label: return
	var text = "ЗАДАНИЕ:\n"
	if quest.is_empty():
		text += "Тестовый режим"
	else:
		if quest.get("theme_name"):
			text += str(quest.get("theme_name")) + "\n"
		if quest.get("truck_name"):
			text += "Транспорт: " + str(quest.get("truck_name"))
	task_label.text = text

func _spawn_initial_object() -> void:
	if figures.size() > 0:
		var new_obj = figures[0].instantiate()
		add_child(new_obj)
		object = new_obj
		object.position = Vector3.ZERO

func _input(event) -> void:
	if event is InputEventMouseMotion:
		_update_preview()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(-ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(ZOOM_SPEED)

	if Input.is_action_just_pressed("right_rot"):
		_rotate_object(Vector3.UP, -90)
	if Input.is_action_just_pressed("left_rot"):
		_rotate_object(Vector3.UP, 90)
	if Input.is_action_just_pressed("up_rot"):
		_rotate_object(Vector3.RIGHT, -90)
	if Input.is_action_just_pressed("down_rot"):
		_rotate_object(Vector3.RIGHT, 90)
	if Input.is_action_just_pressed("placed_sticker"):
		_place_sticker()
	if Input.is_action_just_pressed("delete"):
		_delete_last_sticker()
	if Input.is_action_just_pressed("change_figure"):
		_change_figure() 

func _zoom_camera(amount: float) -> void:
	if not camera: return
	
	target_zoom = clamp(target_zoom + amount, MIN_ZOOM, MAX_ZOOM)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "position:z", target_zoom, 0.2)

func set_active_sticker(texture_path: String) -> void:
	link_sticker = texture_path
	_create_preview_sticker()

func remove_all_stickers() -> void:
	for data in stickers:
		if is_instance_valid(data.get("link")):
			data.get("link").queue_free()
	stickers.clear()
	stickers_lenght = 0

func _safe_look_at(node: Node3D, pos: Vector3, normal: Vector3) -> void:
	var up = Vector3.UP
	if abs(normal.dot(up)) > 0.95:
		up = Vector3.RIGHT
	node.look_at(pos + normal, up)

func _rotate_object(axis, degrees) -> void:
	if object == null || is_rotating:
		return
	is_rotating = true
	var from = object.global_transform
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
	tween.tween_method(func(val): 
		object.global_transform = from.rotated(axis, deg_to_rad(degrees) * val), 
		0.0, 1.0, ROTATE_TIME)
		
	tween.tween_callback(func(): is_rotating = false)

func _place_sticker() -> void:
	if camera == null or link_sticker == "":
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var start = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var end = start + dir * RAY_LENGTH
	var ray = PhysicsRayQueryParameters3D.create(start, end)
	ray.collide_with_bodies = true
	ray.collide_with_areas = true
	var space = get_world_3d().direct_space_state
	var result = space.intersect_ray(ray)

	if result:
		var pos = result.position
		var normal = result.normal
		var collider = result.collider
	
		if abs(normal.dot(Vector3.UP)) > 0.95:
			return 
			
		var sticker: Decal = create_sticker()

		if sticker:
			if collider is Node3D:
				collider.add_child(sticker)
			else:
				add_child(sticker)
			
			sticker.global_transform.origin = pos
			_safe_look_at(sticker, pos, normal)
			sticker.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(90))
			sticker.scale = Vector3(0.01, 0.01, 0.01)
			sticker.albedo_mix = 0.0
			
			var tween = create_tween()
			tween.set_parallel(true)
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			tween.tween_property(sticker, "scale", Vector3(1, 1, 1), 0.5)
			
			tween.set_trans(Tween.TRANS_LINEAR) 
			tween.tween_property(sticker, "albedo_mix", 1.0, 0.3)

func create_sticker() -> Decal:
	var decal : Decal = Decal.new()
	if link_sticker:
		var texture : Texture2D = load(link_sticker)
		decal.texture_albedo = texture
		decal.size = Vector3(0.3, 0.3, 0.3)
		decal.upper_fade = 0.01
		decal.lower_fade = 0.01
		decal.albedo_mix = 1.0 
		
		var data = {"name": link_sticker, "link": decal}
		stickers.append(data)
		stickers_lenght += 1
		return decal
	return null
	 
func _delete_last_sticker() -> void:
	if stickers_lenght > 0:
		var sticker : Dictionary = stickers.pop_at(stickers_lenght - 1)
		if is_instance_valid(sticker.get("link")):
			sticker.get("link").queue_free()
		stickers_lenght -= 1

func _create_preview_sticker() -> void:
	if preview_sticker != null:
		preview_sticker.queue_free()
	preview_sticker = Decal.new()	
	if link_sticker == "": return
	var texture : Texture2D = load(link_sticker)
	if not texture: return
	preview_sticker.texture_albedo = texture
	preview_sticker.size = Vector3(0.3, 0.3, 0.3)
	preview_sticker.upper_fade = 0.01
	preview_sticker.lower_fade = 0.01
	preview_sticker.modulate = Color(1, 1, 1, 0.3)
	preview_sticker.visible = false
	add_child(preview_sticker)

func _update_preview() -> void:
	if camera == null or preview_sticker == null: return
	var mouse_pos = get_viewport().get_mouse_position()
	var start = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	var end = start + dir * RAY_LENGTH
	var ray = PhysicsRayQueryParameters3D.create(start, end)
	ray.collide_with_bodies = true
	ray.collide_with_areas = true
	var space = get_world_3d().direct_space_state
	var result = space.intersect_ray(ray)
	if result:
		var pos = result.position
		var normal = result.normal
		if abs(normal.dot(Vector3.UP)) > 0.95: return 
		if not preview_sticker.visible: preview_sticker.visible = true
		preview_sticker.global_transform.origin = pos
		_safe_look_at(preview_sticker, pos, normal)
		preview_sticker.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(90))
	else:
		if preview_sticker.visible: preview_sticker.visible = false

func _change_figure() -> void:
	if object: object.queue_free()
	stickers.clear()
	stickers_lenght = 0
	index_fig += 1
	var new_obj = figures[index_fig % figures.size()]
	object = new_obj.instantiate()
	object.scale = Vector3(1, 1, 1)
	add_child(object)
	object.position = Vector3.ZERO