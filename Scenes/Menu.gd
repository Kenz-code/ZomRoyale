extends Node2D

onready var guns = $Control/Guns

var pressdown_position = Vector2()
var press_threshold = 20

var gun_key

onready var fpsv = $Control/SettingsCard/Options/FpsV
onready var soundv = $Control/SettingsCard/Options/SoundV
onready var vsyncv = $Control/SettingsCard/Options/VSyncV

var level
var xp


func _ready() -> void:
	get_tree().paused = true
	Global.load_game()
	
	#set variables
	level = Global.save["level"]
	xp = Global.save["xp"]
	
	#load settings
	_on_settingV_pressed("load")
	
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
	
	#set settings
	fpsv.text = Global.save["settings"]["fps"]
	soundv.text = Global.save["settings"]["sound"]
	
	#set xp
	$Control/Xp.text = str(level)
	$Control/Xp/Xp_bar._on_health_updated(xp)
	$Control/Xp/Xp_bar._on_max_health_updated(level * level)
	
	#reload abilities
	Global.load_abilities()
	$Control/Abilities/AbilTex/ReloadTime.text = str(Global.save["ability"]["reload"])
	$Control/Abilities/AbilTex/Speed.text = str(Global.save["ability"]["speed"])
	
	get_tree().paused = false

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
	$Control/SettingsCard.hide()
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


func _on_gun_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			pressdown_position = event.position
		elif event.position.distance_to(pressdown_position) <= press_threshold:
			_on_gun_pressed()


func _on_Back_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			pressdown_position = event.position
		elif event.position.distance_to(pressdown_position) <= press_threshold:
			_on_Back_pressed()


func _on_settingV_pressed(extra_arg_0: String) -> void:
	match extra_arg_0:
		"fps":
			if fpsv.text == "Off":
				Global.save["settings"]["fps"] = "On"
				fpsv.text = "On"
			else:
				Global.save["settings"]["fps"] = "Off"
				fpsv.text = "Off"
		"sound":
			if soundv.text == "Off":
				Global.save["settings"]["sound"] = "On"
				soundv.text = "On"
				AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
			else:
				Global.save["settings"]["sound"] = "Off"
				soundv.text = "Off"
				AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		"vsync":
			if vsyncv.text == "Off":
				Global.save["settings"]["vsync"] = "On"
				vsyncv.text = "On"
				OS.set_deferred("vsync_enabled", true)
			else:
				Global.save["settings"]["vsync"] = "Off"
				vsyncv.text = "Off"
				OS.set_deferred("vsync_enabled", false)
		"load":
			#fps
			if Global.save["settings"]["fps"] == "On":
				fpsv.text = "On"
			else:
				fpsv.text = "Off"
			#sound
			if Global.save["settings"]["sound"] == "On":
				soundv.text = "On"
			else:
				soundv.text = "Off"
				AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
			#vsync
			if Global.save["settings"]["vsync"] == "On":
				vsyncv.text  = "On"
			else:
				vsyncv.text = "Off"
				OS.set_deferred("vsync_enabled", false)
	
	Global.save_game()


func _on_Settings_pressed() -> void:
	$Control/SettingsCard.show()
	$Control/SettingsCard/Back.grab_focus()


func _on_Customize_pressed() -> void:
	$Control/CustomizeCard.show()
	$Name.hide()
	$Control/CompositeSprites.position = Vector2(230,157)


func _on_CustomizeCard_back() -> void:
	#$Control/CustomizeCard.show()
	$Name.show()
	$Control/CompositeSprites.position = Vector2(534,74)
