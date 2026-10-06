extends AnimatedSprite2D

@onready var player: Player = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.attack_anim:
		play("attack")
	elif player.running:
		play("slither")
	elif abs(player.velocity.x) > 0 or abs(player.velocity.z) > 0:
		play("walk")
	else:
		play("default")
