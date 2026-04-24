extends PanelContainer


@export_group("Spawn Settings")
@export var spawn_rate: float = 0.33

@export_group("Movement Settings")
@export var min_item_speed: float = 200.0
@export var max_item_speed: float = 1000.0

var MasterLootTable = preload("res://Loot/LT_Master.tres")
var falling_items: Array = []
var spawn_timer: float = 0.0

func _process(delta: float) -> void:
    spawn_timer += delta
    
    if spawn_timer >= spawn_rate:
        spawn_timer = 0.0
        _spawn_item()
    
    _update_falling_items(delta)

func _spawn_item() -> void:
    var item_data = MasterLootTable.items.pick_random()
    var tetris_scene = item_data.tetris.instantiate()
    add_child(tetris_scene)
    
    var spawner_width = size.x
    var random_x = randf_range(0, spawner_width)
    tetris_scene.position = Vector2(random_x, -300)
    
    var item_data_dict = {
        "node": tetris_scene,
        "speed": randf_range(min_item_speed, max_item_speed),
        "rotation": randf_range(0, 360)
    }
    falling_items.append(item_data_dict)

func _update_falling_items(delta: float) -> void:
    var spawner_height = size.y
    var items_to_remove = []
    
    for i in range(falling_items.size()):
        var item_data_dict = falling_items[i]
        var item_node = item_data_dict["node"]
        
        item_node.position.y += item_data_dict["speed"] * delta
        item_node.rotation_degrees = item_data_dict["rotation"]
        
        if item_node.position.y > spawner_height + 300:
            items_to_remove.append(i)
    
    for i in range(items_to_remove.size() - 1, -1, -1):
        var index = items_to_remove[i]
        var item_node = falling_items[index]["node"]
        item_node.queue_free()
        falling_items.remove_at(index)
