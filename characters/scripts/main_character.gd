extends CharacterBody3D
class_name Character

const _NORMAL_SPEED = 5.0
const _SPRINT_SPEED = 9.0

var _current_speed: float
var current_entity = null
var gold: int = 25

var is_freezed: bool = false
var can_interact: bool = true

var _last_food: String = " "
var _last_prepared_ingredient: String = " "
var _last_prepared_ingredient_amount: int 

@export_category("Objects")
@export var _body: Node3D = null
@export var _spring_arm_offset: Node3D = null
@export var _item_feedback: MeshInstance3D = null
@export var _inventory: Node = null
#get node() - obter uma referência para um nó específico na árvore de cena (scene tree)
#to pascal case ficaria como "ToPascalCase"
#capitalize() - exemplo de texto - Exemplo de texto

func _ready() -> void:#chamada automaticamente quando um nó é inserido na árvore de cena 
	globals.character = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)#retirar a captura do mouse
	get_tree().call_group("environment", "update_gold", gold)
	#get_tree() é uma função que retorna uma referência para o objeto SceneTree

func _physics_process(_delta: float) -> void:#funcao executada a cada frame do projeto
	if is_freezed:
		return
	
	_move()
	move_and_slide()
	_body.animate(velocity)

func _move() -> void:
	var _input_direction: Vector2 = Input.get_vector(
		"move_left", "move_right",
		"move_forward", "move_backward"
	)
	
	#conversao do vetor de 2 p/ 3 dimensoes
	var _direction: Vector3 = transform.basis * Vector3(
		_input_direction.x,
		0,
		_input_direction.y
	).normalized()#aplicada a vetores para torná-los "unitarios" ou "normais".
	#normalizado tem comprimento 1, o que significa que ele mantém a mesma direcao
	
	is_running()
	_direction = _direction.rotated(Vector3.UP, _spring_arm_offset.rotation.y)
	
	if _direction: #se tiver direcao movimenta normal
		velocity.x = _direction.x * _current_speed
		velocity.z = _direction.z * _current_speed
		_body.apply_rotation(velocity)
		return
	
	velocity.x = move_toward(velocity.x, 0, _current_speed)#se nao esta parado
	velocity.z = move_toward(velocity.z, 0, _current_speed)
	
func is_running() -> bool:
	if Input.is_action_pressed("shift"):
		_current_speed = _SPRINT_SPEED
		return true
	else:
		_current_speed = _NORMAL_SPEED
		return false

func freeze(_state: bool) -> void:#funcao freezar na interacao com objetos
	_body.animation.play("Idle")
	
	if _state:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if not _state:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	_spring_arm_offset.can_rotate = not _state
	is_freezed = _state

func change_position(_position: Vector3, _rotation: float) -> void:
	global_position = _position
	_body.rotation.y = _rotation

func chop(_prepared_ingredient: String, _amount: int) -> void:
	can_interact = false
	_last_prepared_ingredient_amount = _amount
	_last_prepared_ingredient = _prepared_ingredient

	_item_feedback.get_node("FrontTexture").texture = load(
		ingredients.ingredients_dict[_prepared_ingredient]["item_texture"]
	)
	_item_feedback.get_node("BackTexture").texture = load(
		ingredients.ingredients_dict[_prepared_ingredient]["item_texture"]
	)
	
	_body.is_chopping = true
	_body.animate(velocity)
	set_physics_process(false)
	_spring_arm_offset.can_rotate = true
	_body.get_node("Body/Skeleton3D/Knife").show()

func on_chop_finished() -> void:
	freeze(false)
	_body.is_chopping = false
	set_physics_process(true)
	_body.get_node("Body/Skeleton3D/Knife").hide()
	_item_feedback.get_node("Animation").play("show_ingredient")

func cook(_food: String) -> void:
	_last_food = _food
	can_interact = false
	
	_item_feedback.get_node("FrontTexture").texture = load(
		recipes.recipes_dict[_food]["item_texture"]
	)
	_item_feedback.get_node("BackTexture").texture = load(
		recipes.recipes_dict[_food]["item_texture"]
	)
	
	_body.is_cooking = true
	_body.animate(velocity)
	set_physics_process(false)
	_spring_arm_offset.can_rotate = true
	_body.get_node("Body/Skeleton3D/Pan").show()

func on_cook_finished() -> void:
	freeze(false)
	_body.is_cooking = false
	set_physics_process(true)#pode movimentar
	_body.get_node("Body/Skeleton3D/Pan").hide()
	_item_feedback.get_node("Animation").play("show")

func _on_item_feedback_animation_finished(_anim_name: String) -> void:
	match _anim_name:
		"show":
			var _item: Dictionary = {}
			_item[_last_food] = {
				"item_amount": 1,
				"item_name": _last_food,
				"item_texture": recipes.recipes_dict[_last_food]["item_texture"],
				"price": recipes.recipes_dict[_last_food]["price"]
			}
			
			_inventory.add_item(_item[_last_food])
		
		"show_ingredient":
			for i in _last_prepared_ingredient_amount:
				var _item: Dictionary = {}
				_item[_last_prepared_ingredient] = {
					"item_amount": 1,
					"item_name": _last_prepared_ingredient,
					"item_texture": ingredients.ingredients_dict[_last_prepared_ingredient]["item_texture"]
				}
				
				_inventory.add_item(_item[_last_prepared_ingredient])
			
	can_interact = true
	if current_entity != null:
		current_entity.can_interact(true, self)

func update_gold(_value: int, _type: String) -> void:
	match _type:
		"increase":
			gold += _value
			
		"decrease":
			gold -= _value
			
	globals.spawn_sfx("res://musics/sfx/assets/money.mp3", self)
	get_tree().call_group("environment", "update_gold", gold)

func spawn_chop_sfx() -> void:
	globals.spawn_sfx("res://musics/sfx/assets/chop.mp3", self)
