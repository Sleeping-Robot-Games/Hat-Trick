extends CharacterBody2D

const SPEED = 200.0

var hats = []

func _ready():
	for i in range(self.get_child_count()):
		var child = self.get_child(i)
		if child.name.begins_with("Hat"):
			hats.append(child)

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var hat_shift = 0.0
	for hat in hats:
		hat_shift += 4.0
		var target_x = -direction * hat_shift
		hat.position.x = lerp(hat.position.x, target_x, 0.1)

	move_and_slide()
