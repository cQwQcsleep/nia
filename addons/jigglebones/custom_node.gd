@tool
extends EditorPlugin

func _enter_tree():


 add_custom_type("Jigglebone", "Node3D", preload("jigglebone.gd"), preload("icon.svg"))

func _exit_tree():


 remove_custom_type("Jigglebone")
