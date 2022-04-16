tool
extends TextureRect

var color:= Color.white

signal color_change_skin


func _ready() -> void:
	$Grid/ColorSwatch51.grab_focus()
	for swatch in $Grid.get_children():
		swatch.connect("pressed",self,"_on_ColorSwatch_pressed", [swatch.color])


func _on_ColorSwatch_pressed(color_string: Color):
	color = color_string
	Global.curr_skin = color_string
	Global.save_game()
	emit_signal("color_change_skin")
	hide()
