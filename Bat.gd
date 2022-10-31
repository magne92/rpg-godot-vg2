extends KinematicBody2D

var knockback = Vector2.ZERO
var FRICTION = 200 

onready var stats = $Stats

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

func _on_HurtBox_area_entered(area):
	knockback = area.knockback_vector * 150
