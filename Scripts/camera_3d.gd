class_name PlayerCamera
extends Camera3D

@export var TWEEN_TIME: float = 0.8
@export var BOB_AMOUNT: float = 5
@export var BOB_TIME: float = 1

var mean_y: float = 0
var bobbing: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if bobbing:
		position.y = mean_y + BOB_AMOUNT * sin(TAU * Time.get_ticks_msec() / 1000 / BOB_TIME)
	else:
		position.y = mean_y
		
func tween_y(target_y: float):
	var tween = create_tween()

	# Tweens this node's Y position to 200 over 1.5 seconds
	tween.tween_property(self, "mean_y", target_y, TWEEN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
