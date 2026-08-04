@tool
extends Node
@export_tool_button("Prepare Demo") var _demo = _prepare_demo

@export_file("*.tscn") var _include_in_demo: Array[String]

func _prepare_demo():
 var _config = ConfigFile.new()
 _config.load("res://export_presets.cfg")

 var _exclude: PackedStringArray
 for _n in _include_in_demo:

  _exclude.append_array(ResourceLoader.get_dependencies(_n))
 print(_exclude)


 _config.save("res://export_presets.cfg")
 pass
