extends Node2D

var machinescene: PackedScene = load("res://scenes/machine.tscn")
var cupscene: PackedScene = load("res://scenes/cupchoice.tscn")
var cupimagescene: PackedScene = load("res://scenes/cupimage.tscn")
var cupresultscene: PackedScene = load("res://scenes/cupresult.tscn")

var obj
var emptycup
var choices = [5,6,7,8]
var targetnumber = 11

#index yg dipilih
var boxindex1 = null
var boxindex2 = null
#result yg dihasilkan
var result = null

var clicked = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#placing the machine
	obj = machinescene.instantiate()
	obj.position = Vector2(350,500) #nanti posisikan dynamic
	add_child(obj)
	obj.connect("reset", machinereset)	
	obj.connect("go", machineprocess)
	
	
	#taruh empty cup di kotak result
	emptycup = cupimagescene.instantiate()
	emptycup.position = Vector2(350,720)
	$cupresult.add_child(emptycup)
	
	#generate array choices angka nya dulu 
	#...
	#baru generate cups choice nya
	generatecups()
	

func generatecups():
	for child in $cupschoice.get_children():
		child.queue_free()
	
	generateonecup(0,choices[0])
	generateonecup(1,choices[1])
	generateonecup(2,choices[2])
	generateonecup(3,choices[3])			
	
func generateonecup(index, number):
	obj = cupscene.instantiate()
	
	if index == 0:
		obj.position = Vector2(150,950) 
		obj.index = 0 	
	elif index == 1:
		obj.position = Vector2(500,950) 
		obj.index = 1 			
	elif index == 2:
		obj.position = Vector2(150,1150) 
		obj.index = 2 				
	else :
		obj.position = Vector2(500,1150) 
		obj.index = 3 	
				
	$cupschoice.add_child(obj)	

	obj.set_label(number)
	
	var n = str(number)[-1]
	obj.get_node("AnimatedSprite2D").play(n)
	
	obj.connect("button_pressed", cuppressed)

func cuppressed(index,number):
	if clicked <2:
		#hapus yg di bawah dulu	
		deletecupwithindex(index)
		
		#taruh image ke atas
		obj = cupimagescene.instantiate()
		$cupsimage.add_child(obj)
	
		obj.set_label(number)
		
		var n = str(number)[-1]
		obj.get_node("AnimatedSprite2D").play(n)
	
		clicked = clicked + 1
		if clicked == 1:
			boxindex1 = index
			obj.position = Vector2(150,290)
		if clicked == 2:
			boxindex2 = index
			obj.position = Vector2(560,290)
		
func deletecupwithindex(index):
	for child in $cupschoice.get_children():
		if child.index == index:
			child.queue_free()
			break
			
func machinereset():
	if clicked > 0 :
		#delete semua di cupsimage
		for child in $cupsimage.get_children():
			child.queue_free()
		
		#generate ulang cupschoice
		generatecups()
		
		#delete resultcup - in case sudah ada isinya bukan emptycup
		for child in $cupresult.get_children():
			child.queue_free()		
		
		#taruh empty cup di kotak result
		emptycup = cupimagescene.instantiate()
		emptycup.position = Vector2(350,720)
		$cupresult.add_child(emptycup)				
		
		#reset clicker
		clicked = 0
		
		#reset index
		boxindex1 = null
		boxindex2 = null
		
		#reset result
		result = null
		
func machineprocess():
	if clicked == 2:
		
		#delete emptycup
		for child in $cupresult.get_children():
			child.queue_free()
			
		#hitung result	
		result = choices[boxindex1] + choices[boxindex2]
		
		#place result cup
		obj = cupresultscene.instantiate()
		$cupresult.add_child(obj)
		
		obj.set_label(result)
		obj.position = Vector2(350,720)
		
		var n = str(result)[-1]
		obj.get_node("AnimatedSprite2D").play(n)

