extends GutTest

const VISIBLE_OBJECT_PATH := "res://addons/perception/src/3d/vision/visible_object_3d.gd"
const TOLERANCE := Vector3(0.001, 0.001, 0.001)


func test_visible_object_does_not_preset_collision_layer() -> void:
	var body := _make_visible_body(Vector3.ZERO)
	await wait_physics_frames(1)

	assert_eq(body.collision_layer, 1)

	var script := load(VISIBLE_OBJECT_PATH) as Script
	var constants := script.get_script_constant_map()
	assert_false(constants.has("COLLISION_LAYER"))
	assert_false(constants.has("COLLISION_LAYER_NUMBER"))


func test_visible_object_has_no_visibility_property() -> void:
	var body := _make_visible_body(Vector3.ZERO)
	var property_names := []

	for property in body.get_property_list():
		property_names.append(property.name)

	assert_false(property_names.has(&"visibility"))


func test_vision_cone_shape_has_default_points() -> void:
	var shape := VisionConeShape3D.new()
	var half_width := 16.0 * sin(deg_to_rad(100.0) * 0.5)
	var far_edge := 16.0 * cos(deg_to_rad(100.0) * 0.5)

	assert_eq(shape.sector_segments, 16)
	assert_eq(shape.points.size(), 36)
	assert_almost_eq(shape.points[0], Vector3(0.0, -2.0, 0.0), TOLERANCE)
	assert_almost_eq(shape.points[1], Vector3(-half_width, -2.0, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[17], Vector3(half_width, -2.0, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[18], Vector3(-half_width, 2.0, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[34], Vector3(half_width, 2.0, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[35], Vector3(0.0, 2.0, 0.0), TOLERANCE)


func test_vision_cone_shape_updates_points() -> void:
	var shape := VisionConeShape3D.new()
	shape.length = 10.0
	shape.fov = deg_to_rad(90.0)
	shape.height = 2.0
	shape.sector_segments = 1

	var half_w := 10.0 * sin(deg_to_rad(45.0))
	var far_edge := 10.0 * cos(deg_to_rad(45.0))

	assert_eq(shape.points.size(), 6)
	assert_almost_eq(shape.points[1], Vector3(-half_w, -1.0, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[4], Vector3(half_w, 1.0, far_edge), TOLERANCE)


func test_vision_cone_shape_uses_sector_segments() -> void:
	var shape := VisionConeShape3D.new()
	shape.length = 10.0
	shape.fov = deg_to_rad(90.0)
	shape.height = 2.0
	shape.sector_segments = 4

	var half_w := 10.0 * sin(deg_to_rad(45.0))
	var far_edge := 10.0 * cos(deg_to_rad(45.0))

	assert_eq(shape.points.size(), 12)
	assert_almost_eq(shape.points[0], Vector3(0.0, -1.0, 0.0), TOLERANCE)
	assert_almost_eq(shape.points[1], Vector3(-half_w, -1.0, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[3], Vector3(0.0, -1.0, 10.0), TOLERANCE)
	assert_almost_eq(shape.points[5], Vector3(half_w, -1.0, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[-2], Vector3(half_w, 1.0, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[-1], Vector3(0.0, 1.0, 0.0), TOLERANCE)


func test_vision_cone_shape_clamps_sector_segments() -> void:
	var shape := VisionConeShape3D.new()

	shape.sector_segments = 0
	assert_eq(shape.sector_segments, 1)

	shape.sector_segments = 65
	assert_eq(shape.sector_segments, 64)


func test_vision_cone_shape_limits_fov_to_180_degrees() -> void:
	var shape := VisionConeShape3D.new()
	shape.length = 10.0
	shape.height = 2.0
	shape.fov = deg_to_rad(270.0)
	shape.sector_segments = 8

	assert_almost_eq(shape.fov, PI, 0.001)
	assert_almost_eq(shape.points[0], Vector3(0.0, -1.0, 0.0), TOLERANCE)

	for point in shape.points:
		assert_true(point.z >= -0.001)


func test_vision_cone_shape_hides_points_from_inspector() -> void:
	var shape := VisionConeShape3D.new()
	var points_property := { }

	for property in shape.get_property_list():
		if property.name == &"points":
			points_property = property
			break

	assert_false(points_property.is_empty())
	assert_eq(points_property.usage & PROPERTY_USAGE_EDITOR, 0)
	assert_ne(points_property.usage & PROPERTY_USAGE_STORAGE, 0)


func test_vision_area_does_not_create_vision_cone_shape() -> void:
	var area := VisionArea3D.new()
	add_child_autofree(area)

	assert_eq(area.get_child_count(), 0)


func test_vision_area_does_not_expose_vision_shape_properties() -> void:
	var area := VisionArea3D.new()
	var property_names := []

	for property in area.get_property_list():
		property_names.append(property.name)

	area.free()

	assert_false(property_names.has(&"length"))
	assert_false(property_names.has(&"fov"))
	assert_false(property_names.has(&"height"))
	assert_false(property_names.has(&"sector_segments"))
	assert_false(property_names.has(&"vision_ray_collision_mask"))


func test_vision_area_detects_visible_objects() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector3(0.0, 0.0, 5.0))
	await wait_physics_frames(3)

	assert_has(area.visible_objects, body)


func test_vision_area_ignores_non_visible_objects() -> void:
	var area := _make_vision_area()
	_make_body(Vector3(0.0, 0.0, 5.0))
	await wait_physics_frames(3)

	assert_eq(area.visible_objects.size(), 0)


func test_vision_area_ignores_occluded_visible_objects() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector3(0.0, 0.0, 5.0))
	_make_body(Vector3(0.0, 0.0, 2.5))
	await wait_physics_frames(3)

	assert_false(area.visible_objects.has(body))


func test_vision_area_detects_visible_objects_after_obstacle_is_removed() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector3(0.0, 0.0, 5.0))
	var obstacle := _make_body(Vector3(0.0, 0.0, 2.5))
	await wait_physics_frames(3)
	assert_false(area.visible_objects.has(body))

	obstacle.queue_free()
	await wait_physics_frames(3)

	assert_has(area.visible_objects, body)


func test_vision_area_detects_visible_areas() -> void:
	var area := _make_vision_area()
	var visible_area := _make_visible_area(Vector3(0.0, 0.0, 5.0))
	await wait_physics_frames(3)

	assert_has(area.visible_objects, visible_area)


func test_vision_area_forgets_exited_visible_objects() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector3(0.0, 0.0, 5.0))
	await wait_physics_frames(3)
	assert_has(area.visible_objects, body)

	body.queue_free()
	await wait_physics_frames(3)

	assert_eq(area.visible_objects.size(), 0)


func _make_vision_area() -> VisionArea3D:
	var area := VisionArea3D.new()

	var shape := VisionConeShape3D.new()
	shape.length = 10.0
	shape.fov = deg_to_rad(90.0)

	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "VisionShape"
	collision_shape.shape = shape
	area.add_child(collision_shape)

	add_child_autofree(area)
	return area


func _make_visible_body(position: Vector3) -> StaticBody3D:
	var body := _make_body(position)
	body.set_script(load(VISIBLE_OBJECT_PATH))
	return body


func _make_visible_area(position: Vector3) -> Area3D:
	var area := Area3D.new()
	area.position = position
	area.set_script(load(VISIBLE_OBJECT_PATH))

	var collision_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3.ONE
	collision_shape.shape = box
	area.add_child(collision_shape)

	add_child_autofree(area)
	return area


func _make_body(position: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = position

	var collision_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3.ONE
	collision_shape.shape = box
	body.add_child(collision_shape)

	add_child_autofree(body)
	return body
