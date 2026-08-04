extends Sprite3D

@export var _flicker: bool = false

func _ready() -> void :
 if _flicker:
  var _timer = Timer.new()
  _timer.wait_time = 2.0
  _timer.autostart = true
  _timer.timeout.connect( func():
   if self.visible: self.hide()
   else: self.show()
   )
  self.call_deferred("add_child", _timer)
