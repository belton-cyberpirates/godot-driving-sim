extends RigidBody2D
class_name GameElement

enum TeamColor {
	NEUTRAL,
	RED,
	BLUE
}

@export var color: TeamColor

func get_weight() -> float:
	return 1./7. if color == TeamColor.NEUTRAL else 1./5.


func teleport_to(world_position: Vector2) -> void:
	global_position = world_position
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, global_transform)
	reset_physics_interpolation()


func set_held(held: bool):
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	if held:
		z_index = 99
		freeze = true
		collision_layer = 0
	else:
		z_index = 3
		freeze = false
		collision_layer = 1
		sleeping = false
