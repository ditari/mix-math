extends Node2D

var machine_scene: PackedScene = load("res://scenes/machine.tscn")
var b_empty_scene: PackedScene = load("res://scenes/bottle-empty.tscn")
var b_choice_scene: PackedScene = load("res://scenes/bottle-choice.tscn")

var b_pour_left_scene: PackedScene = load("res://scenes/bottle-pour-left.tscn")
var b_pour_right_scene: PackedScene = load("res://scenes/bottle-pour-right.tscn")
var b_pour_result_scene: PackedScene = load("res://scenes/bottle-pour-result.tscn")

var b_result_scene: PackedScene = load("res://scenes/bottle-result.tscn")

var mark_scene: PackedScene = load("res://scenes/mark.tscn")
var stars_scene: PackedScene = load("res://scenes/stars.tscn")



@onready var question_label = $CanvasLayer/Control/PanelContainer/question_label
@onready var timer_label = $CanvasLayer/Control/timer_label
@onready var score_label = $CanvasLayer/Control/score_label

var machine
var b_empty
var b_pour_result
var b_result
var mark

var max_question = 10
var question_number = 0

var total_correct_times = 0 
var total_correct_question = 0

var choices
var target_number 
var score = 0

#index yg dipilih
var b_index1 = null
var b_index2 = null
#result yg dihasilkan
var result = null

var interaction_locked = false
var clicked = 0
var processed = false

#timer
var time_elapsed = 0.0 #total time played shown on screen
var timer_running = false #timer when activity happened (no animation)

#timer untuk tiap question
var timer_question_start
var timer_question_end

func _ready():
	#placing the machine
	machine = machine_scene.instantiate()
	machine.position = Vector2(360,500) #nanti posisikan dynamic
	add_child(machine)
	machine.connect("reset", machine_reset)	
	machine.connect("go", machine_process)
	
	#mark instantiate but not visible
	mark = mark_scene.instantiate()
	mark.position = Vector2(360,800) 
	mark.visible = false
	add_child(mark)
	
	#timer
	timer_running = true
	
	#generate new questions
	generate_new_questions()

func _process(delta):
	
	if timer_running:
		time_elapsed += delta

		var total_seconds = int(time_elapsed)
		var minutes = total_seconds / 60
		var seconds = total_seconds % 60

		timer_label.text = "%02d:%02d" % [minutes, seconds]
		
	if question_number > max_question:
		timer_running = false
		end_level(time_elapsed)
		
func generate_new_questions():
	#additional code
	if is_instance_valid(b_empty):
		b_empty.queue_free()	
	
	#clean up
	processed = false
	clicked = 0		
	
	#question increased
	question_number = question_number+1
	timer_question_start = time_elapsed
	
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
	
	#mencegah target_number sudah ada di choices
	if choices.has(target_number):
		target_number = choices.max() + choices.min()
	
	question_label.text = "Mix a " + str(target_number) + "!"
	
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
	
	if interaction_locked:
		return	
	
	var pour_bottle
	var textlabel = str(number)
	
	if clicked <2 and processed == false:
		interaction_locked = true
		
		#pause timer
		timer_running = false		
		
		#hapus yg di bawah dulu	
		delete_bottle_choice(index)
		
		#image pour bottle
		clicked = clicked + 1
		if clicked == 1:
			b_index1 = index
			machine.set_left(textlabel)
			
			pour_bottle = b_pour_left_scene.instantiate()
			add_child(pour_bottle)
		
			pour_bottle.position = Vector2(140,250)
			
			
		if clicked == 2:
			b_index2 = index
			machine.set_right(textlabel)
			
			pour_bottle = b_pour_right_scene.instantiate()
			#$bottle_pour.add_child(pour_bottle)			
			add_child(pour_bottle)
			pour_bottle.position = Vector2(570,250)
			
			
		#sound harusnya di sini	
		var n = str(number)[-1]
		pour_bottle.get_node("AnimatedSprite2D").play(n)
		
		await get_tree().create_timer(0.3).timeout	
		
		#delete pour bottle
		if is_instance_valid(pour_bottle):
			pour_bottle.queue_free()	

		#restart timer
		timer_running = true
		interaction_locked = false
		
func delete_bottle_choice(index):
	for child in $bottle_choice.get_children():
		if child.index == index:
			child.queue_free()
			break

func machine_reset():
	
	if interaction_locked:
		return	
	
	if processed:
		return
		
	interaction_locked = true	
		
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
	
	interaction_locked = false	
		
func machine_process():
	
	if interaction_locked:
		return	
	
	if clicked == 2 and processed == false:
		interaction_locked = true

		#timer pause
		timer_running = false
		
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
		await get_tree().create_timer(0.4).timeout
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
		await get_tree().create_timer(0.6).timeout
				
		mark.visible = true
		#sound juga
		if correct :
			mark.get_node("AnimatedSprite2D").play("correct")
			timer_question_end = time_elapsed
			var solve_time = timer_question_end - timer_question_start
			
			total_correct_question = total_correct_question+1
			total_correct_times = total_correct_times+solve_time
			
			#untuk easy
			if solve_time < 6 :
				score = score + 100
			elif solve_time < 9 :
				score = score + 80
			elif solve_time < 12 :
				score = score + 60	
			else :
				score = score + 40	
			
		else :
			mark.get_node("AnimatedSprite2D").play("wrong")			
			
		score_label.text = "Score: " + str (score)
			
		await get_tree().create_timer(0.6).timeout
		mark.visible = false
		b_result.queue_free()
		
		#clean up
		b_index1 = null
		b_index2 = null
		result = null
		
		#restart timer
		timer_running = true
				
		#generate new questions
		generate_new_questions()

		interaction_locked = false

func end_level(time_elapsed):
	$CanvasLayer/end_level.visible = true
	
	var avg_time = 0
	
	if total_correct_question > 0:			
		avg_time = snapped(total_correct_times/total_correct_question, 0.1 )
	#var avg_time = snapped(time_elapsed/max_question, 0.1)
	
	$CanvasLayer/end_level/avg_time_label.text = "AVG. TIME: "+ str(avg_time) + "s"
	
	$CanvasLayer/end_level/total_score_label.text = "SCORE: " + str(score)

	var stars = stars_scene.instantiate()
	$CanvasLayer/end_level.add_child(stars)
	stars.position = Vector2(360,500)
	
	if (total_correct_question>=9) and (avg_time <= 8):
		stars.set_stars(3)	
	elif (total_correct_question>=8) and (avg_time <= 12):
		stars.set_stars(2)
	elif (total_correct_question>=6):
		stars.set_stars(1)
	else :
		stars.visible = false

	if total_correct_question == 0:
		$CanvasLayer/end_level/completed_label.text = "TRY AGAIN!"
