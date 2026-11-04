extends GutTest

const VISIBLE_OBJECT_PATH := "res://addons/perception/src/2d/vision/visible_object_2d.gd"
const TOLERANCE := Vector2(0.001, 0.001)


func test_visible_object_does_not_preset_collision_layer() -> void:
	var body := _make_visible_body(Vector2.ZERO)
	await wait_physics_frames(1)

	assert_eq(body.collision_layer, 1)

	var script := load(VISIBLE_OBJECT_PATH) as Script
	var constants := script.get_script_constant_map()
	assert_false(constants.has("COLLISION_LAYER"))
	assert_false(constants.has("COLLISION_LAYER_NUMBER"))


func test_visible_object_has_no_visibility_property() -> void:
	var body := _make_visible_body(Vector2.ZERO)
	var property_names := []

	for property in body.get_property_list():
		property_names.append(property.name)

	assert_false(property_names.has(&"visibility"))


func test_vision_cone_shape_has_default_points() -> void:
	var shape := VisionConeShape2D.new()
	var half_width := 16.0 * sin(deg_to_rad(100.0) * 0.5)
	var far_edge := 16.0 * cos(deg_to_rad(100.0) * 0.5)

	assert_eq(shape.sector_segments, 16)
	assert_eq(shape.points.size(), 18)
	assert_almost_eq(shape.points[0], Vector2.ZERO, TOLERANCE)
	assert_almost_eq(shape.points[1], Vector2(-half_width, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[17], Vector2(half_width, far_edge), TOLERANCE)


func test_vision_cone_shape_updates_points() -> void:
	var shape := VisionConeShape2D.new()
	shape.length = 10.0
	shape.fov = deg_to_rad(90.0)
	shape.sector_segments = 1

	var half_width := 10.0 * sin(deg_to_rad(45.0))
	var far_edge := 10.0 * cos(deg_to_rad(45.0))

	assert_eq(shape.points.size(), 3)
	assert_almost_eq(shape.points[1], Vector2(-half_width, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[2], Vector2(half_width, far_edge), TOLERANCE)


func test_vision_cone_shape_uses_sector_segments() -> void:
	var shape := VisionConeShape2D.new()
	shape.length = 10.0
	shape.fov = deg_to_rad(90.0)
	shape.sector_segments = 4

	var half_width := 10.0 * sin(deg_to_rad(45.0))
	var far_edge := 10.0 * cos(deg_to_rad(45.0))

	assert_eq(shape.points.size(), 6)
	assert_almost_eq(shape.points[0], Vector2.ZERO, TOLERANCE)
	assert_almost_eq(shape.points[1], Vector2(-half_width, far_edge), TOLERANCE)
	assert_almost_eq(shape.points[3], Vector2(0.0, 10.0), TOLERANCE)
	assert_almost_eq(shape.points[5], Vector2(half_width, far_edge), TOLERANCE)


func test_vision_cone_shape_clamps_sector_segments() -> void:
	var shape := VisionConeShape2D.new()

	shape.sector_segments = 0
	assert_eq(shape.sector_segments, 1)

	shape.sector_segments = 65
	assert_eq(shape.sector_segments, 64)


func test_vision_cone_shape_limits_fov_to_180_degrees() -> void:
	var shape := VisionConeShape2D.new()
	shape.length = 10.0
	shape.fov = deg_to_rad(270.0)
	shape.sector_segments = 8

	assert_almost_eq(shape.fov, PI, 0.001)
	assert_almost_eq(shape.points[0], Vector2.ZERO, TOLERANCE)

	for point in shape.points:
		assert_true(point.y >= -0.001)


func test_vision_cone_shape_hides_points_from_inspector() -> void:
	var shape := VisionConeShape2D.new()
	var points_property := { }

	for property in shape.get_property_list():
		if property.name == &"points":
			points_property = property
			break

	assert_false(points_property.is_empty())
	assert_eq(points_property.usage & PROPERTY_USAGE_EDITOR, 0)
	assert_ne(points_property.usage & PROPERTY_USAGE_STORAGE, 0)


func test_vision_area_does_not_create_vision_cone_shape() -> void:
	var area := VisionArea2D.new()
	add_child_autofree(area)

	assert_eq(area.get_child_count(), 0)


func test_vision_area_does_not_expose_vision_shape_properties() -> void:
	var area := VisionArea2D.new()
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
	var body := _make_visible_body(Vector2(0.0, 5.0))
	await wait_physics_frames(3)

	assert_has(area.visible_objects, body)


func test_vision_area_ignores_non_visible_objects() -> void:
	var area := _make_vision_area()
	_make_body(Vector2(0.0, 5.0))
	await wait_physics_frames(3)

	assert_eq(area.visible_objects.size(), 0)


func test_vision_area_ignores_occluded_visible_objects() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector2(0.0, 5.0))
	_make_body(Vector2(0.0, 2.5))
	await wait_physics_frames(3)

	assert_false(area.visible_objects.has(body))


func test_vision_area_detects_visible_objects_after_obstacle_is_removed() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector2(0.0, 5.0))
	var obstacle := _make_body(Vector2(0.0, 2.5))
	await wait_physics_frames(3)
	assert_false(area.visible_objects.has(body))

	obstacle.queue_free()
	await wait_physics_frames(3)

	assert_has(area.visible_objects, body)


func test_vision_area_detects_visible_areas() -> void:
	var area := _make_vision_area()
	var visible_area := _make_visible_area(Vector2(0.0, 5.0))
	await wait_physics_frames(3)

	assert_has(area.visible_objects, visible_area)


func test_vision_area_forgets_exited_visible_objects() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector2(0.0, 5.0))
	await wait_physics_frames(3)
	assert_has(area.visible_objects, body)

	body.queue_free()
	await wait_physics_frames(3)

	assert_eq(area.visible_objects.size(), 0)


func test_vision_area_emits_entered_signal_for_visible_object() -> void:
	var area := _make_vision_area()
	watch_signals(area)
	var body := _make_visible_body(Vector2(0.0, 5.0))
	await wait_physics_frames(3)

	assert_signal_emitted_with_parameters(area, "visible_object_entered", [body])
	assert_signal_not_emitted(area, "visible_object_exited")


func test_vision_area_emits_exited_signal_when_object_leaves() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector2(0.0, 5.0))
	await wait_physics_frames(3)

	watch_signals(area)
	body.queue_free()
	await wait_physics_frames(3)

	assert_signal_emitted_with_parameters(area, "visible_object_exited", [body])


func test_vision_area_emits_exited_signal_when_object_is_occluded() -> void:
	var area := _make_vision_area()
	var body := _make_visible_body(Vector2(0.0, 5.0))
	await wait_physics_frames(3)

	watch_signals(area)
	_make_body(Vector2(0.0, 2.5))
	await wait_physics_frames(3)

	assert_signal_emitted_with_parameters(area, "visible_object_exited", [body])
	assert_signal_not_emitted(area, "visible_object_entered")


func _make_vision_area() -> VisionArea2D:
	var area := VisionArea2D.new()

	var shape := VisionConeShape2D.new()
	shape.length = 10.0
	shape.fov = deg_to_rad(90.0)

	var collision_shape := CollisionShape2D.new()
	collision_shape.name = "VisionShape"
	collision_shape.shape = shape
	area.add_child(collision_shape)

	add_child_autofree(area)
	return area


func _make_visible_body(position: Vector2) -> StaticBody2D:
	var body := _make_body(position)
	body.set_script(load(VISIBLE_OBJECT_PATH))
	return body


func _make_visible_area(position: Vector2) -> Area2D:
	var area := Area2D.new()
	area.position = position
	area.set_script(load(VISIBLE_OBJECT_PATH))

	var collision_shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2.ONE
	collision_shape.shape = box
	area.add_child(collision_shape)

	add_child_autofree(area)
	return area


func _make_body(position: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = position

	var collision_shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2.ONE
	collision_shape.shape = box
	body.add_child(collision_shape)

	add_child_autofree(body)
	return body
