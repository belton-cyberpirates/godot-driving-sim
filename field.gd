extends Node2D


const BLUE_NECTAR_SCENE: PackedScene = preload("res://blue_nectar.tscn")
const RED_NECTAR_SCENE: PackedScene = preload("res://red_nectar.tscn")
const MAX_NECTAR_SPAWNS := 5

var goal_switch_counts: Dictionary = {&"blue": 0, &"red": 0}


func _physics_process(_delta: float) -> void:
	_update_goal_pair($BlueRightGoal, $BlueLeftGoal, &"blue", BLUE_NECTAR_SCENE, $BlueHumanPlayerZone)
	_update_goal_pair($RedRightGoal, $RedLeftGoal, &"red", RED_NECTAR_SCENE, $RedHumanPlayerZone)
	$Sprite2D/BlueGoal.flip_h = $BlueRightGoal.up
	$Sprite2D/BlueGoal/Marker.flip_h = $BlueRightGoal.up
	$Sprite2D/RedGoal.flip_h = $RedLeftGoal.up
	$Sprite2D/RedGoal/Marker.flip_h = $RedLeftGoal.up


func _update_goal_pair(right_goal: Goal, left_goal: Goal, team: StringName, nectar_scene: PackedScene, spawn_marker: Marker2D) -> void:
	if right_goal.up and right_goal.full:
		_switch_active_goal(right_goal, left_goal)
		_spawn_nectar_for_switch(team, nectar_scene, spawn_marker)
	elif left_goal.up and left_goal.full:
		_switch_active_goal(left_goal, right_goal)
		_spawn_nectar_for_switch(team, nectar_scene, spawn_marker)


func _switch_active_goal(active_goal: Goal, next_goal: Goal) -> void:
	active_goal.up = false
	active_goal.full = false
	next_goal.up = true
	next_goal.full = false


func _spawn_nectar_for_switch(team: StringName, nectar_scene: PackedScene, spawn_marker: Marker2D) -> void:
	var switch_count: int = goal_switch_counts[team]
	if switch_count >= MAX_NECTAR_SPAWNS:
		return

	var nectar := nectar_scene.instantiate() as GameElement
	add_child(nectar)
	nectar.teleport_to(spawn_marker.global_position)
	goal_switch_counts[team] = switch_count + 1
