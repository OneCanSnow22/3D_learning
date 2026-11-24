class_name BaseLevel
extends Node3D
@onready var player_spawn: Node3D = %PlayerSpawn
const PLAYER_PREFAB=preload("res://scenes/characters/player/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player:Player=PLAYER_PREFAB.instantiate()
	player.global_transform=player_spawn.global_transform
	add_child(player)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
