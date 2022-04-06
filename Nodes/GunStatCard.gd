extends TextureRect

var current


func _ready() -> void:
	self.visible = false

func _show(_gun: String):
	current = _gun
	
	self.visible = true
	$Equip.grab_focus()
	var gun = Global.guns[_gun]
	var firerate = gun[1]
	var damage = gun[4]
	var distance = gun[2]
	var icon = gun[5]
	
	$Stats/DamageV.text = str(damage)
	$Stats/FireRateV.text = str(int(1/firerate)) + "   times per second"
	$Stats/DistanceV.text = str(distance)
	$Icon.texture = load(icon)


func _on_Back_pressed() -> void:
	self.visible = false


func _on_Equip_pressed() -> void:
	Global.current_gun = Global.guns[str(current)]
	Global.current_gun_name = current
	self.visible = false
