extends Node3D
@export var _speed: float = 1.0
func _physics_process(_delta: float) -> void : self.rotation_degrees.y += _speed
