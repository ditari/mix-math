extends Node2D

signal reset
signal go

func _on_gobutton_pressed():
	emit_signal("go")

func _on_cancelbutton_pressed():
	emit_signal("reset")
