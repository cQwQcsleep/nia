extends Node

var cam_zoom: float = 5.0
var cam_sens: float = 0.4
var cam_invert_x: bool = false
var cam_invert_y: bool = false
var cam_vel_mul: int = 4
var cam_hide_ui: bool = false
var auto_run: bool = false
var particle_limiter: bool = false
var widescreen: bool = false
var fullscreen: bool = false
var screen_filter: bool = true
var antialiasing: bool = false
var vsync: bool = true
var max_framerate: int = 60
var phone_screen_brightness: float = 0.4
var active_wallpaper: int = 0
var unlocked_wallpaper: Array[int] = [0, 1]
var disable_all_light: bool = false
var audio_master_volume: float = 0.8
var audio_snd_volume: float = 0.9
var audio_step_volume: float = 0.8
var audio_mus_volume: float = 0.8
var audio_amb_volume: float = 0.7
var gamepad_use_rumble: bool = true
var use_multiplayer: bool = false
var multiplayer_port: int = 0
var current_screen: int = DisplayServer.get_primary_screen()
var language: int = 0
var visited: Array[String]
var last_visited: String
var has_ended: bool = false
var is_demo: bool = false
var outlived: int = 0
var has_killed_her: bool = false
var has_gutted_her: bool = false
var bleed_out: bool = true
