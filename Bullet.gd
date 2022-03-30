extends Area2D

export var speed = 400
export (int) var decay
export (int) var direction
export (int) var damage

onready var start_position = position

func _ready():
	set_as_toplevel(true)

func _on_Bullet_body_entered(body):
	if body.is_in_group("zoms"):
		body.die(damage)
	queue_free()

func _physics_process(delta):
	position += transform.x * speed * delta
	
	if (position.x > start_position.x + 300):
		queue_free()
	elif (position.x < start_position.x - 300):
		queue_free()
