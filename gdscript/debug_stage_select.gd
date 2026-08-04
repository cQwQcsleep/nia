extends Control

func _process(delta: float) -> void :
 $label.text = "please enter the name of the stage you want to enter or ur computer an d files will self destruct in %s seconds" % int($timer.time_left)

func _on_button_pressed() -> void :
 game.change_stage($text_edit.text)
