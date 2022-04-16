extends TextureButton

export (String) var label = "text"
export (DynamicFont) var font = load("res://Art/Font/arcadesmall.tres")
export var _pressed = false


func _ready() -> void:
	$Label.text = label
	$Label.add_font_override("font",font)
