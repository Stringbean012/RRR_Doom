extends ColorRect

@export var MELT_TIME = 0.8
@export var INITIAL_OFFSET_MIN: int = 20
@export var INITIAL_OFFSET_MAX: int = 50
var melting: bool
var offsets_float: Array[float]
var res: Vector2

func _ready() -> void:
	res = material.get_shader_parameter("res")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		melt()
	
	if melting:
		for i in range(offsets_float.size()):
			offsets_float[i] += (res.y / MELT_TIME) * delta
		var offsets: PackedInt32Array = []
		for i in range(offsets_float.size()):
			offsets.append(int(offsets_float[i]))
		material.set_shader_parameter("offsets", offsets)

func melt():
	
	var mat = material as ShaderMaterial
	var screen_image = get_viewport().get_texture().get_image()
	var snapshot_texture = ImageTexture.create_from_image(screen_image)
	mat.set_shader_parameter("melt_texture", snapshot_texture)
	mat.set_shader_parameter("melting", true)
	melting = true
	
	offsets_float = []
	offsets_float.append(randi_range(-INITIAL_OFFSET_MAX, -INITIAL_OFFSET_MIN))
	for i in range(1, res.x / 2):
		offsets_float.append(offsets_float[-1] + randi_range(-4, 4) * 2)
	get_tree().reload_current_scene()
