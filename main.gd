extends Node

func _ready():
    pass

func _process(_delta):
    if Input.is_action_just_pressed("quit") and OS.has_feature("pc"):
        print("exit requested")
        get_tree().quit()
