extends CharacterBody2D


const SPEED := 100.0
const ACCELERATION := 500.0
const ANGULAR_SPEED := 360
const ANGULAR_ACCELERATION := 1500
const PUSH_MODIFIER := .35
const LAUNCH_SPEED := 250.0

@export var holders: Array[Marker2D]
@export var held_elements: Array[GameElement]

var angular_velocity := 0.0


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	
	var impact_velocity = velocity
	move_and_slide()
	
	handle_collisions(impact_velocity)
	
	set_held_element_poses()
	
	handle_launch()


func handle_movement(delta: float):
	var direction := Input.get_vector("left", "right", "up", "down") # get desired movement vector
	velocity = velocity.move_toward(direction * SPEED, delta * ACCELERATION) # move toward desired movement vector
	
	var turn_direction = Input.get_axis("turn_left", "turn_right") # get desired turn direction
	angular_velocity = move_toward(angular_velocity, turn_direction * ANGULAR_SPEED, delta * ANGULAR_ACCELERATION) # move toward desired turn direction
	rotation_degrees += angular_velocity * delta # apply angular velocity to actual rotation
	
	if (direction.length() != 0 or turn_direction != 0):
		if !$AnimatedSprite2D.is_playing(): # if we are moving and animation wasnt playing yet start animation
			$AnimatedSprite2D.play()
	elif $AnimatedSprite2D.is_playing(): # if we arent moving and animation is playing stop animation
		$AnimatedSprite2D.stop()


func handle_collisions(impact_velocity: Vector2):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody2D:
			# Project the character's velocity onto the collision direction
			# This isolates the speed moving directly INTO the object
			var push_direction = -collision.get_normal()
			var approach_speed = impact_velocity.dot(push_direction)
			
			# Only push if moving toward the object, ignoring sideways scraping
			if approach_speed > 0.0:
				var dynamic_force = approach_speed * PUSH_MODIFIER
				collider.apply_central_impulse(push_direction * dynamic_force)


func set_held_element_poses():
	for i in range(len(held_elements)):
		held_elements[i].teleport_to(holders[i].global_position)


func handle_launch():
	if !Input.is_action_just_pressed("launch"): # dont do anything if we didnt hit the launch button
		return
	
	if held_elements.is_empty(): # cant launch if we arent holding anything
		return
		
	# The goals and raycast are set to layer 2 so that it can scan to see if its targeting them
	if $RayCast2D.is_colliding(): # if we see a goal, give the ball to that goal
		print("Passing element to goal")
		$RayCast2D.get_collider().held_elements.append(held_elements.pop_front()) # pop from robot held elements, append to goal held elements
	else: # if we dont see a goal, just eject element
		print("Dropping element")
		drop_element(held_elements.pop_front())


func drop_element(element: GameElement):
	element.teleport_to($DropPos.global_position)
	element.set_held(false)
	var launch_direction = global_position.direction_to($DropPos.global_position)
	element.linear_velocity = velocity + launch_direction * LAUNCH_SPEED


func _on_intake_collider_body_entered(body: Node2D) -> void:
	if body is GameElement:
		call_deferred("hold_element", body)


func hold_element(element: GameElement) -> void:
	if not is_instance_valid(element) or held_elements.has(element) or len(held_elements) >= len(holders):
		return

	element.set_held(true)
	element.teleport_to(holders[len(held_elements)].global_position)
	held_elements.append(element)
