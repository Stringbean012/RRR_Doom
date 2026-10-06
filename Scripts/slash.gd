class_name Slash
extends Area3D

@export var SPEED: float = 1000
@export var OFFSET: float = 60
@export var RANDOM_OFFSET: float = 10
@onready var sprite: Sprite3D = $Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await  get_tree().create_timer(5).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	global_position += -transform.basis.z * SPEED
	
func apply_offset(direction: float):
	var offset := direction * (OFFSET + randf_range(-RANDOM_OFFSET, RANDOM_OFFSET))
	global_position += offset * global_basis.x
	sprite.flip_h = offset > 0
