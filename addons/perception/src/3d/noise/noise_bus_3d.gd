## Global signal bus used to broadcast noise events.
## Registered as an autoload by the perception plugin.
extends Node

# ---[ Signal ]---

## Emitted by [NoiseEmitter3D] when a noise is made.
signal noise_emitted(data: NoiseData3D)
