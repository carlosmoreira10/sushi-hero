extends ColorRect

const  _RECIPE: PackedScene = preload("res://interface/scenes/slots/recipe_slot.tscn")

var _sign_ref = null

@export_category("Objects")
@export var _recipes: VBoxContainer = null

func _ready() -> void:
	for _recipe in recipes.recipes_dict.keys():
		var _recipe_slot = _RECIPE.instantiate()
		_populate_slot(_recipe, _recipe_slot)
		_recipes.add_child(_recipe_slot)
		
func _populate_slot(_recipe: String, _recipe_slot: VBoxContainer) -> void:
	var _v_container: VBoxContainer = _recipe_slot.get_node("VContainer")
	
	_v_container.get_node("HContainer/Container/ItemTexture").texture = load(
		recipes.recipes_dict[_recipe]["item_texture"]
	)
	
	_v_container.get_node("HContainer/Container/Label").text = _recipe.capitalize()
	
	var _ingredients_dict: Dictionary = recipes.recipes_dict[_recipe]["ingredients"]
	var _ingredient_keys: Array = _ingredients_dict.keys()
	
	var _ingredients: HBoxContainer = _v_container.get_node("VContainer/HContainer/Container")
	
	for _i in _ingredients_dict.size():
		var  _ingredient_slot: VBoxContainer = _ingredients.get_child(_i)
		
		var _ingredient_texture: TextureRect = _ingredient_slot.get_node("VContainer/HContainer/IngredientTexture")
		var _ingredient_name: Label = _ingredient_slot.get_node("VContainer/HContainer/VContainer/Ingredient")
		var _ingredient_amount: Label = _ingredient_slot.get_node("VContainer/HContainer/VContainer/Amount")
		
		_ingredient_slot.show()
		_ingredient_texture.texture = load(_ingredients_dict[_ingredient_keys[_i]]["item_texture"])
		_ingredient_name.text = _ingredient_keys[_i].capitalize()
		_ingredient_amount.text = str(_ingredients_dict[_ingredient_keys[_i]]["amount"]) + "x"
		
func _process(_delta: float) -> void:
	if get_tree().paused and not visible:
		return

	if Input.is_action_just_pressed("ui_cancel") and visible:
		visible = false
		get_tree().paused = false
		_sign_ref.change_state(true)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func display(_target, _visibility: bool) -> void:
	_sign_ref = _target
	visible = _visibility
