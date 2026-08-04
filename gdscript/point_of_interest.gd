extends Area3D

func _on_body_entered(_body: Node3D) -> void : if _body is player: _body.change_poi(self)
func _on_body_exited(_body: Node3D) -> void : if _body is player: _body.change_poi()
