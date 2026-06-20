extends Control

signal player_accelerated(action_name: StringName, is_slowing: bool)
signal direction_changed(is_horizontal: bool)

func _ready():
    for child in $Keys/Horizontal.get_children():
        var indicator = child as KeyIndicator
        if indicator:
            player_accelerated.connect(indicator.on_player_accelerated)

func _on_player_accelerated(action_name: StringName, is_slowing: bool):
    player_accelerated.emit(action_name, is_slowing)


func _on_player_direction_changed(is_horizontal: bool):
    direction_changed.emit(is_horizontal)
