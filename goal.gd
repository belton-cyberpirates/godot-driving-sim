extends Area2D
class_name Goal


const DROP_ROLL_FORCE := 75

enum dir {LEFT=-1, RIGHT=1}

@export var direction: dir = dir.LEFT

@export var up := true
@export var full := false

@export var held_elements: Array[GameElement]


func _ready() -> void:
	for i in range(len(held_elements)):
		held_elements[i].set_held(true)
		held_elements[i].teleport_to(_held_element_position(i, len(held_elements)))


func _physics_process(_delta: float) -> void:
	for i in range(len(held_elements)):
		held_elements[i].teleport_to(_held_element_position(i, len(held_elements)))
	
	if !up:
		drop_elements()
	elif held_elements.reduce(func(x,y): return x + y.get_weight(), 0) >= .99:
		full = true


func _held_element_position(index: int, count: int) -> Vector2:
	return $Marker2D.global_position + Vector2(0, index - (count - 1) / 2.0) * 8


func drop_elements():
	if held_elements.is_empty():
		return
	
	for _i in range(len(held_elements)):
		call_deferred("drop_element", held_elements.pop_back())


func drop_element(element):
	element.teleport_to(element.global_position + Vector2(20 * direction, 0))
	element.set_held(false)
	element.apply_impulse( Vector2(direction, 0).rotated(deg_to_rad(randf_range(-45, 45))) * DROP_ROLL_FORCE )
