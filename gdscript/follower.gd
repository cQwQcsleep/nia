extends MeshInstance3D
var _jittertimer: Timer
var _offset: Vector3
func _ready() -> void :
 _jittertimer = Timer.new()
 _jittertimer.one_shot = true
 _jittertimer.timeout.connect( func():
  _offset = Vector3(randf_range(-0.4, 0.4), randf_range(-0.4, 0.4), randf_range(-0.4, 0.4))
  _jittertimer.start(randf_range(1.0, 3.0))
  audio.play_snd_spatial([game.loadres("lens_00"), game.loadres("lens_01")], self.global_position, 7.0)
  )
 _jittertimer.autostart = true

 self.add_child(_jittertimer)
func _physics_process(_delta: float) -> void :
 if game.nia:
  var _dir: Vector3 = self.global_position.direction_to((game.nia.global_position + Vector3(0, 1.4, 0)) + _offset)
  var _target: Basis = Basis.looking_at(_dir)
  self.basis = self.basis.slerp(_target, 0.06)
  self.rotation_degrees.x = clamp(self.rotation_degrees.x, -45, 45)
  self.rotation_degrees.z = 0
