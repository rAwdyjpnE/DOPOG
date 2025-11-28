extends Label

func _ready() -> void:
	var correct = G.correct
	var wrong = G.wrong
	self.text = "Правильно решено: %d\nНеправильно решено: %d" % [correct, wrong]	
