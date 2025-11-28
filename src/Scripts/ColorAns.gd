extends RichTextLabel

func _ready() -> void:
	var correct = G.correct
	var wrong = G.wrong
	var correct_text = "Правильно решено: %d" % correct
	var wrong_text = "Неправильно решено: %d" % wrong
	var result_text = ""
	if correct > 0:
		result_text += "[color=green]" + correct_text + "[/color]\n"
	else:
		result_text += correct_text + "\n"
	if wrong > 0:
		result_text += "[color=red]" + wrong_text + "[/color]"
	else:
		result_text += wrong_text
	self.bbcode_enabled = true
	self.text = result_text
