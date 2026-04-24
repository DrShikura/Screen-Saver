extends Control

@export_group("Movement Settings")
@export var move_speed: float = 200.0

@onready var logo: Sprite2D = $"../Logo"
@onready var hitbox: ColorRect = $"../Logo/Hitbox"
@onready var hit_top: Control = $"../Logo/Hit_T"
@onready var hit_bottom: Control = $"../Logo/Hit_B"
@onready var hit_left: Control = $"../Logo/Hit_L"
@onready var hit_right: Control = $"../Logo/Hit_R"

var bump_x: bool = false #false=right, true=left
var bump_y: bool = false #false=down, true=up

func _ready() -> void:
    var random_x = randf_range(0.0+(hitbox.size.x/2), size.x-(hitbox.size.x/2))
    var random_y = randf_range(0.0+(hitbox.size.y/2), size.y-(hitbox.size.y/2))
    logo.position = Vector2(random_x, random_y)


func _process(_delta: float) -> void:
    if hit_right.global_position.x >= get_viewport_rect().size.x:
        bump_x = true
    elif hit_left.global_position.x <= 0:
        bump_x = false
    if hit_top.global_position.y <= 0:
        bump_y = false
    elif hit_bottom.global_position.y >= get_viewport_rect().size.y:
        bump_y = true
    
    if bump_x:
        logo.position.x -= move_speed * _delta
    else:
        logo.position.x += move_speed * _delta
    
    if bump_y:
        logo.position.y -= move_speed * _delta
    else:
        logo.position.y += move_speed * _delta