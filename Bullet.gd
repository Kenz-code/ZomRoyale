extends Area2D

export var speed = 400

func _on_Bullet_body_entered(body):
	if body.is_in_group("zoms"):
		body.queue_free()
	queue_free()

func _physics_process(delta):
	position += transform.x * speed * delta
