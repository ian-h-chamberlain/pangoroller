class_name KeyIndicator
extends Control

@export_custom(PROPERTY_HINT_INPUT_NAME, "") var action: StringName

@export var speed_color: Color
@export var slow_color: Color
@export var update_label: bool = true

@onready var animation: AnimationPlayer = $AnimationPlayer


func _ready():
    if update_label:
        $Label.text = InputMap.action_get_events(action)[0].as_text().split()[0]


func on_player_accelerated(action_name: StringName, is_slowing: bool):
    if action != action_name:
        return

    if is_slowing:
        $ColorRect.color = slow_color
    else:
        $ColorRect.color = speed_color

    animation.stop()
    animation.play("fade_out")


func _on_direction_changed(_direction: Player.Direction):
    $ColorRect.color = speed_color
    animation.stop()
    animation.play("fade_out")
