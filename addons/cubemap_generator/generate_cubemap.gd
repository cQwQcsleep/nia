@tool
extends Node3D
class_name cubemap
@export var _bake_cubemap: bool = false:
 set(value): _generate_cubemap()
@export_dir var _path: String = "res://"
@export_range(0.0, 5.0) var _intensity: float = 1.0
@export_range(8, 1024) var _resolution: int = 256
@export var anti_aliasing: bool = true
func _generate_cubemap():
 var _views: Array
 var _view_texture: Array = []
 for _a in 6:
  var _temp_viewport = SubViewport.new()
  var _temp_camera = Camera3D.new()
  match _a:
   0: _temp_camera.rotation_degrees.y = -90
   1: _temp_camera.rotation_degrees.y = 90
   2:
    _temp_camera.rotation_degrees.x = 90
    _temp_camera.rotation_degrees.y = 180
   3:
    _temp_camera.rotation_degrees.x = -90
    _temp_camera.rotation_degrees.y = -180
   5: _temp_camera.rotation_degrees.y = 180
  _temp_camera.fov = 90.0
  _temp_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
  _temp_viewport.size = Vector2(_resolution, _resolution)
  if anti_aliasing: _temp_viewport.msaa_3d = Viewport.MSAA_8X
  _temp_viewport.scaling_3d_scale = 2.0
  _temp_viewport.add_child(_temp_camera)
  add_child(_temp_viewport)
  _temp_camera.global_position = global_position
  _views.append(_temp_viewport)
 await RenderingServer.frame_post_draw
 for _temp_view_texture in _views:
  await RenderingServer.frame_post_draw
  var _tex = _temp_view_texture.get_texture().get_image()
  _tex.generate_mipmaps()
  _tex.flip_y()
  _tex.adjust_bcs(_intensity, 1.0, 1.0)
  _view_texture.push_back(_tex)
 var _temp_path = "%s/%s.res" % [_path, self.name]
 var _cubemap = Texture2DArray.new()
 _cubemap.create_from_images(_view_texture)
 var _temp_array: Array
 for _d in _cubemap.get_layers(): _temp_array.append(_cubemap.get_layer_data(_d))
 var _cubemap_fix = Cubemap.new()
 _cubemap_fix.create_from_images(_temp_array)
 _cubemap_fix.take_over_path(_temp_path)
 ResourceSaver.save(_cubemap_fix, _temp_path, ResourceSaver.FLAG_COMPRESS)
 for _cleanup in get_children(): _cleanup.queue_free()
 print("Baked Cubemap. Saved to %s" % _temp_path)
 _view_texture.clear()
 _views.clear()
