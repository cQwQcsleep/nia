extends MeshInstance3D
@export var _video: VideoStreamPlayer

func _process(delta: float) -> void :
 self.get_active_material(0).albedo_texture = _video.get_video_texture()
