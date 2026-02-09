extends Node2D

var index
var number

signal button_pressed

func set_label(t):
	$label.text = str(t)
	number = t

func _on_button_pressed():
#	print("here")
	emit_signal("button_pressed", index,number)
	#queue_free()
	
#func _on_button_pressed():
#	emit_signal("button_pressed")
#	#queue_free()
