extends Control

func set_stars(count):
	if count == 1:
		$star1.visible = true
	elif count == 2:
		$star2.visible = true
	else:
		$star3.visible = true
