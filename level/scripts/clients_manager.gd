extends Node3D

const _CLIENTS : Array = [
	preload("res://characters/scenes/clients/rabbit_bald_client.tscn"),
	preload("res://characters/scenes/clients/rabbit_cyan_client.tscn")
]

@export var _spawn_timer: Timer = null

func _ready() -> void:
	_spawn_client()
	_spawn_timer.start()
	
func _spawn_client() -> void:
	var _client = _CLIENTS[randi() % _CLIENTS.size()].instantiate()
	add_child(_client)

func _on_spawn_timer_timeout():
	_spawn_client()
	_spawn_timer.start()
