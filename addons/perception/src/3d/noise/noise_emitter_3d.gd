## Emits noise events through [NoiseBus3D].
@icon("../../../icons/NoiseEmitter3D.svg")
class_name NoiseEmitter3D
extends Node3D

# ---[ Inspector Properties ]---

## Maximum distance at which the noise can be heard.
@export_range(0.0, 999.0, 1.0, "suffix:m") var hearing_range: float

# ---[ Public Methods ]---


## Emits a noise event at the emitter's global position.
func emit() -> void:
	var data: NoiseData3D = NoiseData3D.new()
	data.origin_position = global_position
	data.hearing_range = hearing_range

	NoiseBus3D.noise_emitted.emit(data)
