extends Button

@export var label_count_quests: Node3D
@export var QuestScene: String

func _ready() -> void:
	self.pressed.connect(switch_to_scene)

func switch_to_scene():
	var data = read_db()
	G.quest_list = data[0]
	get_tree().change_scene_to_file(QuestScene)

func read_db():
	var data = SQLite.new()
	data.path = "res://src/DataBase/db.db"
	data.open_db()
	var result = data.query("
	SELECT 
    tasks.*,
    
    s_back.id    AS back_id,
    s_back.sticker  AS back_path,
    
    s_front.id   AS front_id,
    s_front.sticker AS front_path,
    
    s_right.id   AS right_id,
    s_right.sticker AS right_path,
    
    s_left.id    AS left_id,
    s_left.sticker  AS left_path,
    
    t.id         AS truck_id,
    t.truck       AS truck_name,
    
    th.id        AS theme_id,
    th.theme      AS theme_name
	
	FROM tasks
	LEFT JOIN stickers AS s_back  ON s_back.id  = tasks.back
	LEFT JOIN stickers AS s_front ON s_front.id = tasks.front
	LEFT JOIN stickers AS s_right ON s_right.id = tasks.right
	LEFT JOIN stickers AS s_left  ON s_left.id  = tasks.left

	LEFT JOIN trucks   AS t  ON t.id  = tasks.truck
	LEFT JOIN themes   AS th ON th.id = tasks.theme;
	")
	
	var return_list = []
	
	if result:
		for row in data.query_result:
			return_list.append(row)
	else:
		push_error("Error: query was failed " + data.error_message)

	data.close_db()
	return return_list
