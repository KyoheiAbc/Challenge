extends Node

var player: CharacterBody3D
var touchStartPosition = null
var dragDistance = Vector2.ZERO
var screenWidth


func _ready() -> void:
	player = $CharacterBody3D
	screenWidth = get_viewport().get_visible_rect().size.x
	print(screenWidth)

func _process(delta: float) -> void:
	if dragDistance != Vector2.ZERO:
		var direction = dragDistance.normalized()
		player.velocity = Vector3(direction.x * 5, player.velocity.y, direction.y * 5) # Adjust speed as needed
		var backward = Vector3(-direction.x, 0, -direction.y)
		player.look_at(player.position + backward, Vector3.UP)
	else:
		player.velocity.x = 0 # Reset horizontal velocity if no drag
		player.velocity.z = 0 # Reset forward velocity if no drag

	if not player.is_on_floor():
		# Apply gravity if the player is not on the floor
		player.velocity.y -= 100 * delta # Gravity


	player.move_and_slide()


	for index in range(player.get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = player.get_slide_collision(index)
		
		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("Mob"):
			var rigidBody: RigidBody3D = collision.get_collider()
			var playerLookDirection = player.global_transform.basis.z.normalized()
			rigidBody.apply_impulse(playerLookDirection * 0.5) # Adjust impulse strength as needed
			
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x > screenWidth * 3 / 4:
				jump()
				return
			touchStartPosition = event.position
		else:
			if touchStartPosition:
				touchStartPosition = null
			dragDistance = Vector2.ZERO
	elif event is InputEventScreenDrag:
		if touchStartPosition and event.position.x < screenWidth * 3 / 4:
			dragDistance = event.position - touchStartPosition
		else:
			dragDistance = Vector2.ZERO

func jump() -> void:
	player.velocity.y = 30 # Adjust jump strength as needed
	player.move_and_slide()
