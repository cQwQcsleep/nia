extends MeshInstance3D

func _on_finished() -> void :

 pass
func remove():
 await create_tween().tween_property(self.get_active_material(0), "shader_parameter/modulate:a", 0.0, 12.0).set_trans(Tween.TRANS_SINE).finished
 self.queue_free()
 pass
