extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func _on_player_direction_changed(is_horizontal: bool):
    if is_horizontal:
        $Horizontal.visible = true
        $Vertical.visible = false
    else:
        $Horizontal.visible = false
        $Vertical.visible = true
