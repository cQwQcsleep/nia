extends CPUParticles3D

func _ready() -> void :
 var _timer = Timer.new()
 _timer.autostart = true
 _timer.wait_time = randi_range(20, 90)
 _timer.one_shot = true
 _timer.timeout.connect( func():
  var _active: bool = false
  for _bird_check in game.findall("bird"):
   if _bird_check.emitting:
    _active = true
    break
  if !_active:
   self.lifetime = randf_range(2.0, 4.0)
   self.amount = randi_range(16, 90)
   self.emitting = true
   await self.finished
  _timer.start(randi_range(40, 520))
  )
 self.call_deferred("add_child", _timer)
