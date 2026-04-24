extends Node

var McmHelpers = load("res://ModConfigurationMenu/Scripts/Doink Oink/MCM_Helpers.tres")
var gameData = preload("res://Resources/GameData.tres")

const MOD_ID = "ScreenSaver"
const FILE_PATH = "user://MCM/ScreenSaver"

@export var mod_enabled: bool = true
@export var ss_timeout_seconds: float = 180.0
@export var ss_check_interval: int = 5
@export var ss_ignore_mouse_motion: bool = false
@export var ss_mouse_motion_margin: float = 5.0
@export var ss_ignore_mouse_buttons: bool = false
@export var ss_ignore_keys: bool = false

var in_menu: bool = false
var ss_enabled: bool = false
var last_input_time: float = 0.0
var physics_frame_count: int = 0
var last_mouse_position: Vector2 = Vector2.ZERO

var ss_black = preload("res://mods/ScreenSaver/ScreenSaver/ss_black.tscn")
var ss_logo = preload("res://mods/ScreenSaver/ScreenSaver/ss_logo.tscn")
var ss_items = preload("res://mods/ScreenSaver/ScreenSaver/ss_items.tscn")
var ss_dvd = preload("res://mods/ScreenSaver/ScreenSaver/ss_dvd.tscn")
var ss_scene: Control = null
var desired_ss: int = 3

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	last_input_time = Time.get_unix_time_from_system()

	if McmHelpers == null:
		print("MCM NOT INSTALLED OR NOT LOADED!")
		return
	else:
		print("MCM LOADED!")

	var _config = ConfigFile.new()
	_config.set_value("Bool", "enabled", {
		"name" = "Mod Enabled",
		"tooltip" = "Toggle mod behavior ON/OFF.",
		"default" = true,
		"value" = true,
		"menu_pos" = 1
	})
	_config.set_value("Bool", "ignore_mouse_motion", {
		"name" = "Ignore Mouse Motion",
		"tooltip" = "Ignore mouse motion when checking for input.",
		"default" = false,
		"value" = false,
		"menu_pos" = 2
	})
	_config.set_value("Int", "mouse_motion_margin", {
		"name" = "Mouse Motion Margin",
		"tooltip" = "Mouse motion margin when checking for input.",
		"default" = 5,
		"value" = 5,
		"minRange" = 0,
		"maxRange" = 20,
		"menu_pos" = 3
	})
	_config.set_value("Bool", "ignore_mouse_buttons", {
		"name" = "Ignore Mouse Buttons",
		"tooltip" = "Ignore mouse button presses when checking for input.",
		"default" = false,
		"value" = false,
		"menu_pos" = 4
	})
	_config.set_value("Bool", "ignore_keys", {
		"name" = "Ignore Keys",
		"tooltip" = "Ignore key presses when checking for input.",
		"default" = false,
		"value" = false,
		"menu_pos" = 5
	})
	_config.set_value("Int", "timeout_seconds", {
		"name" = "Appear After (seconds)",
		"tooltip" = "Time in seconds before screen saver activates.",
		"default" = 180,
		"value" = 180,
		"minRange" = 10,
		"maxRange" = 600,
		"menu_pos" = 6
	})
	_config.set_value("Dropdown", "desired_ss", {
		"name" = "Desired Screen Saver",
		"tooltip" = "Desired screen saver to use.",
		"default" = 3,
		"value" = 3,
		"options" = ["Black Screen", "Logo", "Items", "DVD"],
		"menu_pos" = 7
	})
	if !FileAccess.file_exists(FILE_PATH + "/config.ini"):
		DirAccess.open("user://").make_dir(FILE_PATH)
		_config.save(FILE_PATH + "/config.ini")
	else:
		McmHelpers.CheckConfigurationHasUpdated(MOD_ID, _config, FILE_PATH + "/config.ini")
		_config.load(FILE_PATH + "/config.ini")
    
	McmHelpers.RegisterConfiguration(
		MOD_ID,
		"Screen Saver",
		FILE_PATH,
		"Screen Saver over menus to avoid burn-in.",
		{
			"config.ini" = UpdateConfigProperties
		}
	)
	UpdateConfigProperties(_config)

func UpdateConfigProperties(config: ConfigFile):
	mod_enabled = config.get_value("Bool", "enabled")["value"]
	ss_ignore_keys = config.get_value("Bool", "ignore_keys")["value"]
	ss_ignore_mouse_buttons = config.get_value("Bool", "ignore_mouse_buttons")["value"]
	ss_ignore_mouse_motion = config.get_value("Bool", "ignore_mouse_motion")["value"]
	ss_mouse_motion_margin = config.get_value("Int", "mouse_motion_margin")["value"]
	ss_timeout_seconds = config.get_value("Int", "timeout_seconds")["value"]
	desired_ss = config.get_value("Dropdown", "desired_ss")["value"]

func _process(_delta: float) -> void:
	if !mod_enabled:
		return
	in_menu = true if (gameData.isDead || gameData.isChecking || gameData.isTrading || gameData.menu || gameData.freeze) && !gameData.isSleeping else false
	if in_menu:
		last_input_time += _delta
		if last_input_time >= ss_timeout_seconds:
			if not ss_enabled:
				ss_enabled = true
				Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
				print("[ScreenSaver] Enabled")
				match desired_ss:
					0:
						ss_scene = ss_black.instantiate()
					1:
						ss_scene = ss_logo.instantiate()
					2:
						ss_scene = ss_items.instantiate()
					3:
						ss_scene = ss_dvd.instantiate()
				get_node("/root").add_child(ss_scene)
				ss_scene.process_mode = PROCESS_MODE_ALWAYS
		else:
			if ss_enabled:
				ss_enabled = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if in_menu else Input.MOUSE_MODE_CAPTURED
				print("[ScreenSaver] Disabled")
				if ss_scene:
					ss_scene.queue_free()
	else:
		if ss_enabled:
			ss_enabled = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if in_menu else Input.MOUSE_MODE_CAPTURED
			print("[ScreenSaver] Disabled")
			if ss_scene:
				ss_scene.queue_free()
		last_input_time = 0

func _input(_event: InputEvent) -> void:
	if _event is InputEventMouseMotion and !ss_ignore_mouse_motion:
		var mouse_pos = _event.position
		if last_mouse_position != Vector2.ZERO:
			var movement = mouse_pos.distance_to(last_mouse_position)
			if movement < ss_mouse_motion_margin:
				last_mouse_position = mouse_pos
				return
		last_mouse_position = mouse_pos
		last_input_time = 0
		return
	
	if _event is InputEventMouseButton and !ss_ignore_mouse_buttons:
		last_input_time = 0
		return
	if _event is InputEventKey and !ss_ignore_keys:
		last_input_time = 0
		return