extends HBoxContainer

export (String) var button_name

signal change(direction)


func _ready() -> void:
	$Text.text = button_name


func _on_Left_pressed() -> void:
	emit_signal("change",-1)
	Global.save_game()


func _on_Right_pressed() -> void:
	emit_signal("change",1)
	Global.save_game()
