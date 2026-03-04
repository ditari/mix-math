extends Node2D

signal reset
signal go

func set_left(t):
	$AnimatedSprite2D/leftlabel.text = t

func set_right(t):
	$AnimatedSprite2D/rightlabel.text = t

func _on_gobutton_pressed():
	emit_signal("go")

func _on_resetbutton_pressed():
	emit_signal("reset")
