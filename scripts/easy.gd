extends Node2D

var machine_scene: PackedScene = load("res://scenes/machine.tscn")
var b_empty_scene: PackedScene = load("res://scenes/bottle-empty.tscn")
var b_choice_scene: PackedScene = load("res://scenes/bottle-choice.tscn")

var b_pour_left_scene: PackedScene = load("res://scenes/bottle-pour-left.tscn")
var b_pour_right_scene: PackedScene = load("res://scenes/bottle-pour-right.tscn")
var b_pour_result_scene: PackedScene = load("res://scenes/bottle-pour-result.tscn")

var b_result_scene: PackedScene = load("res://scenes/bottle-result.tscn")

var machine
var b_empty
var b_pour_result
var b_result

var question_number = 0
var choices
var target_number 

#index yg dipilih
var b_index1 = null
var b_index2 = null
#result yg dihasilkan
var result = null

var clicked = 0
var processed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#placing the machine
	machine = machine_scene.instantiate()
	machine.position = Vector2(360,500) #nanti posisikan dynamic
	add_child(machine)
	machine.connect("reset", machine_reset)	
	machine.connect("go", machine_process)
	
	#generate new questions
	generate_new_questions()
	
func _process(delta):
	pass
	
func generate_new_questions():
	#clean up
	processed = false
	clicked = 0		
	
	#question increased
	question_number = question_number+1
	
	#place empty bottle
	b_empty = b_empty_scene.instantiate()
	b_empty.position = Vector2(360,775) 
	add_child(b_empty)
	
	#generate array choices angka nya dulu 
	generate_choices_array()
	#baru generate choice bottle nya
	generate_choices_bottle()		
	
func generate_choices_array():
	#emptying the choices first
	choices = []
	
	#randomize number from 1 to 10
	var numbers = range(1,11)   # 1–10
	numbers.shuffle()
	
	#get choicesarray
	for i in range(4):
		choices.append(numbers[i])
			
	#randomize index 0 to 3		
	var nums = [0, 1, 2, 3]
	nums.shuffle()

	#get two index
	var index1 = nums[0]
	var index2 = nums[1]
	
	target_number = choices[index1] + choices[index2]
	$question_label.text = "Make a " + str(target_number) + "!"
	
func generate_choices_bottle():
	for child in $bottle_choice.get_children():
		child.queue_free()
	
	generate_one_bottle(0,choices[0])
	generate_one_bottle(1,choices[1])
	generate_one_bottle(2,choices[2])
	generate_one_bottle(3,choices[3])	

func generate_one_bottle(index, number):
	var obj = b_choice_scene.instantiate()
	
	if index == 0:
		obj.position = Vector2(200,950) 
		obj.index = 0 	
	elif index == 1:
		obj.position = Vector2(500,950) 
		obj.index = 1 			
	elif index == 2:
		obj.position = Vector2(200,1150) 
		obj.index = 2 				
	else :
		obj.position = Vector2(500,1150) 
		obj.index = 3 	
				
	$bottle_choice.add_child(obj)	

	obj.set_label(number)
	
	var n = str(number)[-1]
	obj.get_node("AnimatedSprite2D").play(n)
	
	obj.connect("button_pressed", choice_pressed)

func choice_pressed(index,number):
	var pour_bottle
	var textlabel = str(number)
	
	if clicked <2 and processed == false:
		
		#hapus yg di bawah dulu	
		delete_bottle_choice(index)
		
		#image pour bottle harusnya nanti animasi
		clicked = clicked + 1
		if clicked == 1:
			b_index1 = index
			machine.set_left(textlabel)
			
			pour_bottle = b_pour_left_scene.instantiate()
			add_child(pour_bottle)
		
			pour_bottle.position = Vector2(140,240)
			
			
		if clicked == 2:
			b_index2 = index
			machine.set_right(textlabel)
			
			pour_bottle = b_pour_right_scene.instantiate()
			#$bottle_pour.add_child(pour_bottle)			
			add_child(pour_bottle)
			pour_bottle.position = Vector2(570,240)
			
			
		#sound harusnya di sini	
		var n = str(number)[-1]
		pour_bottle.get_node("AnimatedSprite2D").play(n)
		await get_tree().create_timer(0.7).timeout
		pour_bottle.queue_free()
		
		
func delete_bottle_choice(index):
	for child in $bottle_choice.get_children():
		if child.index == index:
			child.queue_free()
			break

func machine_reset():
	if processed:
		return
		
	clicked = 0
	processed = false
	b_index1 = null
	b_index2 = null
	result = null
	
	for child in $bottle_choice.get_children():
		child.queue_free()

	generate_choices_bottle()
	
	machine.set_left("")
	machine.set_right("")
		

		
func machine_process():
	if clicked == 2:
		#status = sudah di proses
		processed = true
		#hitung result	
		result = choices[b_index1] + choices[b_index2]
		var correct = result == target_number
		#tambah score di sini
		
		#delete emptycup
		if is_instance_valid(b_empty):
			b_empty.queue_free()
		
		#animasi bottle pour result, sebentar lalu dihapus
		b_pour_result = b_pour_result_scene.instantiate()
		b_pour_result.position = Vector2(360,757)
		add_child(b_pour_result)
		
		#sound harusnya di sini	
		var n = str(result)[-1]
		b_pour_result.get_node("AnimatedSprite2D").play(n)
		await get_tree().create_timer(0.7).timeout
		b_pour_result.queue_free()	
		
		
		#delete label dari machine
		machine.set_left("")
		machine.set_right("")
		
		
		#taruh bottle result
		b_result = b_result_scene.instantiate()
		b_result.position = Vector2(360,775) 
		add_child(b_result)
		
		#animasi bottle result sebentar
		b_result.get_node("AnimatedSprite2D").play(n)
		b_result.set_label(result)
		
		#animasi correct or wrong here
		#sound juga
		if correct :
			$output_label.text = "CORRECT!"
		else :
			$output_label.text = "WRONG!"
			
		await get_tree().create_timer(1).timeout
		b_result.queue_free()
		
		#clean up
		$output_label.text = ""
		b_index1 = null
		b_index2 = null
		result = null
		
		#generate new questions
		generate_new_questions()
