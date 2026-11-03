extends GutTest

const NOISE_BUS_PATH := "res://addons/perception/src/3d/noise/noise_bus_3d.gd"


func test_noise_bus_is_registered_and_loaded() -> void:
	var setting := "autoload/NoiseBus3D"

	assert_true(ProjectSettings.has_setting(setting))
	assert_eq(str(ProjectSettings.get_setting(setting)).trim_prefix("*"), NOISE_BUS_PATH)
	assert_not_null(get_node_or_null("/root/NoiseBus3D"))


func test_emitter_emits_noise_data_on_bus() -> void:
	var bus := get_node("/root/NoiseBus3D")
	var emitter := NoiseEmitter3D.new()
	emitter.hearing_range = 12.0
	add_child_autofree(emitter)
	emitter.global_position = Vector3(3.0, 0.0, 4.0)

	var received: Array[NoiseData3D] = []
	var handler := func(data: NoiseData3D) -> void:
		received.append(data)
	bus.noise_emitted.connect(handler)

	emitter.emit()

	assert_eq(received.size(), 1)
	assert_eq(received[0].origin_position, Vector3(3.0, 0.0, 4.0))
	assert_eq(received[0].hearing_range, 12.0)

	bus.noise_emitted.disconnect(handler)


func test_listener_detects_noise_in_range() -> void:
	var listener := NoiseListener3D.new()
	add_child_autofree(listener)
	listener.global_position = Vector3.ZERO
	watch_signals(listener)

	var emitter := NoiseEmitter3D.new()
	emitter.hearing_range = 10.0
	add_child_autofree(emitter)
	emitter.global_position = Vector3(3.0, 0.0, 4.0)

	emitter.emit()

	assert_signal_emitted(listener, "noise_detected")


func test_listener_ignores_noise_out_of_range() -> void:
	var listener := NoiseListener3D.new()
	add_child_autofree(listener)
	listener.global_position = Vector3.ZERO
	watch_signals(listener)

	var emitter := NoiseEmitter3D.new()
	emitter.hearing_range = 1.0
	add_child_autofree(emitter)
	emitter.global_position = Vector3(10.0, 0.0, 0.0)

	emitter.emit()

	assert_signal_not_emitted(listener, "noise_detected")
