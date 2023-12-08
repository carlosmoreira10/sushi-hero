extends Node3D

const _LERP_VELOCITY: float = 0.15

var is_upset: bool = false # saindo com raiva do restaurante
var is_eating: bool = false

@export_category("Objects")
@export var _client: CharacterBody3D = null
@export var _animation: AnimationPlayer = null

func apply_rotation(_velocity: Vector3) -> void:
	rotation.y = lerp_angle(#interpolacao linear
		rotation.y, 
		atan2(-_velocity.x, -_velocity.z),
		_LERP_VELOCITY
		)

func _ready() -> void:
	initialize()

func initialize() -> void:
	_animation.connect(
		"animation_finished",
		Callable(self, "_on_animation_finished")
	)
 
func animate(_velocity: Vector3) -> void:
	if _velocity:
		_animation.play("Walk")
		return
	
	_animation.play("Idle")

func animate_action(_action: String, _rotation: float = PI) -> void:
	rotation.y = _rotation
	_animation.play(_action)
	
	if _action == "Sitting_Eating":
		is_eating = true
		
func _on_animation_finished(_anim_name: String) -> void:
	match _anim_name:
		"Sitting_Start":
			if _client.on_table:
				recipes.order_random_food(_client)
			
			_animation.play("Sitting_Idle")
		
		"Sitting_End":
			if is_eating:
				_client.update_state("go_away", Vector3.ZERO, Vector3(0, 0, -52))
				_client.on_table = false
				is_eating = false
				return
			
			if not is_eating and is_upset:
				_client.update_state("go_away", Vector3.ZERO, Vector3(0, 0, -52))
				_client.getting_up = false
				return
			
			if _client.on_sofa:
				_client.on_sofa = false
				_client.update_state("seek_table")

func _on_eat_timer_timeout():
	_animation.play("Sitting_End")
	
