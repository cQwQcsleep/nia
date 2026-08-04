extends WorldEnvironment

@export var _speed: float = 1.0
func _physics_process(_delta: float) -> void : self.environment.sky_rotation.y += (_speed / 10)
