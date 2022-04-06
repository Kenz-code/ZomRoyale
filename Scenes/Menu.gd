extends Node2D

onready var guns = $Control/Guns

var pressdown_position = Vector2()
var press_threshold = 20

var gun_key


func _ready() -> void:
	get_tree().paused = false
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
		b.connect("button_down",self,"set_key",[n])
		b.connect("gui_input",self,"_on_gun_gui_input")
		b.icon = load(Global.guns[n][5])
		b.mouse_filter = 1
		
		$Control/ColorRect/TextureRect/ScrollContainer/VBoxContainer.add_child(b)
		
		if Global.guns[n] == Global.current_gun:
			guns.text = n
	
	$Control/Button.grab_focus()
	$Control/ColorRect.hide()
	$audio.play()
	
	$Name.text = Global.save["name"]
	
	$"Zom smasher".playing = true
	$AnimationPlayer.play("name bob")

func _process(_delta: float) -> void:
	guns.text = Global.current_gun_name

func set_key(key: String):
	gun_key = key


func _on_Button_pressed() -> void:
	$audio.stop()
	Global.marathon = false
	SceneManager.change_scene("res://Scenes/World.tscn")


func _on_Guns_pressed() -> void:
	$Control/ColorRect/TextureRect/ScrollContainer/VBoxContainer/Back.grab_focus()
	$Control/ColorRect.show()


func _on_Back_pressed() -> void:
	$Control/ColorRect.hide()
	guns.grab_focus()

func _on_gun_pressed():
	$Control/GunStatCard._show(gun_key)


func _on_Button2_pressed() -> void:
	Global.marathon = true
	$audio.stop()
	SceneManager.change_scene("res://Scenes/World.tscn")


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


func _on_gun_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			pressdown_position = event.position
		elif event.position.distance_to(pressdown_position) <= press_threshold:
			_on_gun_pressed()
