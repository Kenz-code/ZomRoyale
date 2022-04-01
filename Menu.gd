extends Node2D

export (NodePath) var option_path
onready var option = get_node(option_path)
onready var guns = $Control/Guns


func _ready() -> void:
	Global.load_game()
	if Global.save["first_time"] == true:
		$Control/name_enter.show()
	
	$Control/Button.text = "Wave " + str(Global.save["wave_reached"])
	#add guns items
	for n in Global.guns:
		var b = Button.new()
		b.text = n
		b.align = Button.ALIGN_CENTER
		var s = StyleBoxFlat.new()
		s.bg_color = Color("3e000000")
		b.add_stylebox_override("normal",s)
		b.add_stylebox_override("disabled",s)
		b.add_stylebox_override("focus",s)
		b.add_stylebox_override("pressed",s)
		b.add_stylebox_override("hover",s)
		b.connect("pressed",self,"_on_gun_pressed",[n])
		
		$Control/ColorRect/TextureRect/ScrollContainer/VBoxContainer.add_child(b)
		
		if Global.guns[n] == Global.current_gun:
			$Control/Guns.text = n
	
	$Control/Button.grab_focus()
	$Control/ColorRect.hide()
	$audio.play()
	
	$Name.text = Global.save["name"]
	



func _on_Button_pressed() -> void:
	$audio.stop()
	Global.marathon = false
	get_tree().change_scene("res://World.tscn")


func _on_Guns_pressed() -> void:
	$Control/ColorRect/TextureRect/ScrollContainer/VBoxContainer/Back.grab_focus()
	$Control/ColorRect.show()


func _on_Back_pressed() -> void:

	$Control/ColorRect.hide()
	$Control/Guns.grab_focus()

func _on_gun_pressed(key: String):
	Global.current_gun = Global.guns[key]
	$Control/Guns.text = key
	$Control/ColorRect.hide()
	$Control/Guns.grab_focus()


func _on_Button2_pressed() -> void:
	Global.marathon = true
	$audio.stop()
	get_tree().change_scene("res://World.tscn")


func _on_LineEdit_text_entered(new_text: String) -> void:
	$Name.text = new_text
	Global.save["name"] = new_text
	Global.save["first_time"] = false
	$Control/name_enter.hide()
	Global.save_game()



func _on_DelSave_pressed() -> void:
	var dir = Directory.new()
	dir.remove(Global.save_path)
	get_tree().reload_current_scene()
