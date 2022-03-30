extends Node2D

export (NodePath) var option_path
onready var option = get_node(option_path)
onready var guns = $Control/Guns


func _ready() -> void:
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
	$Control/ColorRect.hide()
	$audio.play()
	


func _on_Button_pressed() -> void:
	$audio.stop()
	get_tree().change_scene("res://World.tscn")


func _on_Guns_pressed() -> void:
	$Control/ColorRect.show()


func _on_Back_pressed() -> void:
	$Control/ColorRect.hide()

func _on_gun_pressed(key: String):
	Global.current_gun = Global.guns[key]
	$Control/Guns.text = key
	$Control/ColorRect.hide()
