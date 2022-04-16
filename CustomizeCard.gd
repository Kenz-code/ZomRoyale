extends ColorRect

signal back

func _ready() -> void:
	yield(get_tree().create_timer(0.2),"timeout")
	$VBoxContainer/ColorRect.color = Global.curr_hair_color
	$VBoxContainer/SkinColor.color = Global.curr_skin

func _on_Hair_change(direction) -> void:
	if direction == 1:
		Global.curr_hair = (Global.curr_hair + direction) % Global.hair_spritesheet.size()
	else:
		if Global.curr_hair == 0:
			Global.curr_hair = Global.hair_spritesheet.size() -1
		else:
			Global.curr_hair = (Global.curr_hair - 1) % Global.hair_spritesheet.size()


func _on_Shirt_change(direction) -> void:
	if direction == 1:
		Global.curr_shirt = (Global.curr_shirt + direction) % Global.shirt_spritesheet.size()
	else:
		if Global.curr_shirt == 0:
			Global.curr_shirt = Global.shirt_spritesheet.size() -1
		else:
			Global.curr_shirt = (Global.curr_shirt - 1) % Global.shirt_spritesheet.size()


func _on_Pants_change(direction) -> void:
	if direction == 1:
		Global.curr_pants = (Global.curr_pants + direction) % Global.pants_spritesheet.size()
	else:
		if Global.curr_pants == 0:
			Global.curr_pants = Global.pants_spritesheet.size() -1
		else:
			Global.curr_pants = (Global.curr_pants - 1) % Global.pants_spritesheet.size()


func _on_Button_pressed() -> void:
	emit_signal("back")
	self.hide()


func _on_ColorPickerButton_pressed() -> void:
	$ColorSelector.show()
	get_parent().get_node("CompositeSprites").hide()


func _on_Grid_color_change() -> void:
	$VBoxContainer/ColorRect.color = Global.curr_hair_color
	get_parent().get_node("CompositeSprites").show()


func _on_SkinColorSelector_color_change_skin() -> void:
	$VBoxContainer/SkinColor.color = Global.curr_skin
	get_parent().get_node("CompositeSprites").show()


func _on_SkinPickerButton_pressed() -> void:
	$SkinColorSelector.show()
	get_parent().get_node("CompositeSprites").hide()
