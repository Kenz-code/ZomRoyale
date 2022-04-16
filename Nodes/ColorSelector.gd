tool
extends GridContainer

var Swatch: PackedScene = preload("res://Nodes/ColorSwatch.tscn")

var color:= Color.white

signal color_change


func _ready() -> void:
	$ColorSwatch51.grab_focus()
	for swatch in get_children():
		swatch.connect("pressed",self,"_on_ColorSwatch_pressed", [swatch.color])


func _on_ColorSwatch_pressed(color_string: Color):
	color = color_string
	Global.curr_hair_color = color_string
	Global.save_game()
	emit_signal("color_change")
	get_parent().hide()
