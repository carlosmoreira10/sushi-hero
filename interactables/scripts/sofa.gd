extends MeshInstance3D

var _offset: Vector3 =  Vector3(0, 0.25, 0.02)#posicao onde vai ficar sentado o cliente
var _is_available: bool = true

func is_available(_entity) -> void:#has_available_slot
	if _is_available:
		_entity.update_state("walking", _offset, global_position)
		change_available_state(false)
		return
		
	_entity.update_state("seek_sofa")
	
func change_available_state(_state: bool) -> void:
	_is_available = _state
