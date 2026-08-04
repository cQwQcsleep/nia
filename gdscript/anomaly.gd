extends Node3D
@export var _id: int = 0
@export var _anim: AnimationPlayer
@export var _anim_name: StringName
@export var _sfx: AudioStream
@export var _sfx_pos: Vector3
var _value: float = 0
var _value_node: Node3D
@export var _value_shader: ShaderMaterial
@export var _value_particle: CPUParticles3D
var _timer: Timer
func _ready() -> void :
 set_physics_process(false)
 _timer = Timer.new()
 _timer.autostart = false
 _timer.one_shot = true
 _timer.timeout.connect(_event)
 get_parent().add_child.call_deferred(_timer)
 match _id:
  0:
   call_deferred("_finish_event")
  1:
   set_physics_process(true)

  2:
   _value_node = self.duplicate()
   _value_node.set_script(null)
   _value_node.material_override = _value_shader
   _value_node.hide()
   get_parent().add_child.call_deferred(_value_node)
   call_deferred("_finish_event")

  3:
   call_deferred("_finish_event")
func _input(event: InputEvent) -> void :
 if game.is_debug:
  if event is InputEventKey:
   match event.keycode:
    KEY_4:
     _finish_event()
     if _anim: _anim.stop()
     _event()
func _physics_process(_delta: float) -> void :
 match _id:
  1:
   self.position.y = pingpong(_value, 400.0) + 70.0
   _value += randf() * 0.1

func _event():
 match _id:
  0:
   audio.play_snd_spatial(_sfx, _sfx_pos, 128, 1.0)
   for _a in get_children(): _a.process_mode = Node.PROCESS_MODE_INHERIT
   self.show()
   if _anim_name:
    _anim.play(_anim_name)
    await _anim.animation_finished
   self.hide()
   _finish_event()
  2:
   _value_node.show()
   self.hide()
   audio.play_snd_spatial(_sfx, _sfx_pos, 32)
   await get_tree().create_timer(randf_range(0.1, 0.6)).timeout
   audio.play_snd_spatial(_sfx, _sfx_pos, 32)
   _value_node.hide()
   self.show()
   match randi_range(0, 2):
    1:
     _event()
     return
   _finish_event()
  3:
   if _value_particle:
    var _pv = game.nia.get_node("%view")
    self.rotation.y = _pv.global_rotation.y


    self.global_position = _pv.global_position
    _value_particle.amount = randi_range(1, 2)

    _value_particle.emitting = true
    await _value_particle.finished
    _finish_event()
func _finish_event():
 match _id:
  0:
   self.hide()
   for _a in get_children(): _a.process_mode = Node.PROCESS_MODE_DISABLED
   _timer.start(randi_range(20, 380))
  2: _timer.start(randi_range(5, 60))
  3: _timer.start(randi_range(2, 40))
