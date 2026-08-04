extends Control


func _on_button_pressed() -> void :
 if game.is_steam(): game.steam_api.activateGameOverlayToWebPage("https://s.team/a/3979330", 1)
 OS.shell_open("https://s.team/a/3979330")
 await get_tree().create_timer(10).timeout
 game.change_stage("stage_title")

func _on_link_pressed() -> void :
 OS.shell_open("https://x.com/emiwau")
