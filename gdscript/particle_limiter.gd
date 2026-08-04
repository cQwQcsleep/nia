@tool
extends CPUParticles3D
@export var _update: bool = false:
 set(value):
  set_amount(_max_particle)
@export var _max_particle: int
func _ready() -> void :
 if OS.has_feature("web") or config.particle_limiter:
  set_amount(_max_particle / 2)
  preprocess = 12.0
  restart(true)
