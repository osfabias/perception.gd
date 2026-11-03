## Listens to noise bus and emits a signal whenever noise is hearable.
@icon("../../../icons/NoiseListener3D.svg")
class_name NoiseListener3D
extends Node3D

# ---[ Signals ]---

## Emitted when a noise event is within hearing range.
signal noise_detected(data: NoiseData3D)

# ---[ Node Methods ]---


func _ready() -> void:
	NoiseBus3D.noise_emitted.connect(_on_noise_emitted)

# ---[ Private Methods ]---


func _on_noise_emitted(data: NoiseData3D) -> void:
	var distance_to_noise_origin = global_position.distance_to(data.origin_position)

	if distance_to_noise_origin <= data.hearing_range:
		noise_detected.emit(data)
