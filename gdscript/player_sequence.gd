extends Node3D
@export var _skeleton: Skeleton3D
var _tween: Tween
func _ready() -> void :
 _tween = game.tween(_tween)
 _tween.set_loops()
 var _temp_scale = Vector3(1.03, 1.04, 1.0)
 _tween.tween_method(_set_bone, Vector3.ONE, _temp_scale, 0.9).set_delay(0.2).set_trans(Tween.TRANS_CIRC)
 _tween.tween_method(_set_bone, _temp_scale, Vector3.ONE, 0.9).set_delay(0.1).set_trans(Tween.TRANS_CIRC)
func _set_bone(_value):
 _skeleton.set_bone_pose_scale(_skeleton.find_bone("Chest"), _value)
 pass
