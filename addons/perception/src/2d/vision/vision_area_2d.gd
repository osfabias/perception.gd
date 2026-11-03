## Tracks [VisibleObject2D] bodies and areas that enter its collision shape and
## are not occluded by other colliders.
@icon("../../../icons/VisionArea2D.svg")
class_name VisionArea2D
extends Area2D

# ---[ Public Variables ]---

## Objects, that are currently visible inside the vision area.
var visible_objects: Array[VisibleObject2D] = []

# ---[ Private Variables ]---

var _tracked_objects: Array[VisibleObject2D] = []

# ---[ Node Methods ]---


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _physics_process(_delta: float) -> void:
	_update_visibility()

# ---[ Private Methods ]---


func _on_body_entered(body: Node2D) -> void:
	_add_visible_object(body)


func _on_body_exited(body: Node2D) -> void:
	_remove_visible_object(body)


func _on_area_entered(area: Area2D) -> void:
	_add_visible_object(area)


func _on_area_exited(area: Area2D) -> void:
	_remove_visible_object(area)


func _add_visible_object(node: Node2D) -> void:
	if node is VisibleObject2D:
		var visible_object := node as VisibleObject2D

		if not _tracked_objects.has(visible_object):
			_tracked_objects.append(visible_object)
			_update_visibility()


func _remove_visible_object(node: Node2D) -> void:
	if node is VisibleObject2D:
		var visible_object := node as VisibleObject2D

		_tracked_objects.erase(visible_object)
		visible_objects.erase(visible_object)


func _update_visibility() -> void:
	visible_objects.clear()

	for visible_object in _tracked_objects:
		if is_instance_valid(visible_object) and _has_line_of_sight(visible_object):
			visible_objects.append(visible_object)


func _has_line_of_sight(visible_object: VisibleObject2D) -> bool:
	var from := global_position
	var to := visible_object.global_position

	if from.distance_squared_to(to) < 0.000001:
		return true

	var exclude := _get_ray_exclude_rids()
	var query := PhysicsRayQueryParameters2D.create(from, to, collision_mask, exclude)
	query.collide_with_areas = true

	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _get_ray_exclude_rids() -> Array[RID]:
	var exclude: Array[RID] = [get_rid()]

	for visible_object in _tracked_objects:
		if is_instance_valid(visible_object):
			exclude.append(visible_object.get_rid())

	return exclude
