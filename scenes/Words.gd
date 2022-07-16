extends Node2D

enum State { Playing, Success, Error }
onready var status = State.Playing

export(String, "easy", "medium", "hard" , "insane") var difficulty := "easy"
export var time := 10.0
export var wordcount = 1

var _start_time
var _current_word
var _word_list

onready var typing_text = $Panel/TypingText



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	_word_list = get_word_list(difficulty)
	_current_word = get_random_word(_word_list).to_upper()


# Function to get the words from a file in an array
func get_word_list(file_name: String)-> Array:

	var file = File.new()
	var file_path = "res://assets/words/{}.txt".format(file_name)
	file.open(file_path, File.READ)
	var lines = []
	while not file.eof_reached():
		lines.append(file.get_line())
	return lines


# Function to get and random word from a word_list
func get_random_word(word_list: Array)-> String:
	return word_list[randi() % word_list.size()]



func reset_game():
	# Asignamos una palabra al azar dependiendo de la dificultad

	_current_word = get_random_word(_word_list).to_upper()
	# Dependiendo de la dificultad se coloca un time determinado
	match difficulty:
		"easy":
			time = 10
		"medium":
			time = 5
		"hard":
			time = 3.5
		"insane":
			time = 3

	_start_time = time

	# Establecemos la palabra secleccionada en el texto del label a transcribir
	typing_text.text = _current_word



func _input(event):
	if (
		event is InputEventKey
		and !event.echo
		and event.pressed
		and status == State.Playing
	):
		# Si el evento es una Entrada de Teclad y si acaba de presionar y si olo justo presiona y el estado del desafio es Infecting

		if event.scancode >= 65 and event.scancode <= 90:
			# Aquí es si el codigo ASCII de las letras de la A-Z

			#var pressedChar = str(event.scancode)
			var pressedChar = OS.get_scancode_string(event.scancode)
			# Transformamos el codigo ASCII al caracter correspondiente

			if _current_word.begins_with(pressedChar):
				# Si la primera letra de la palabra es la tecla que presionamos
				_current_word.erase(0, 1)  # Borramos la primera letra
				typing_text.text = _current_word  # y cambiamos el label
				match difficulty:
					"hard":
						time += 0.1
					"insane":
						time += 0.05

				# la idea principal es que cada vez que el hacker introduzca bien una letra
				# esta desaparezca del label, quedando las letras siguientes a la palabra

				if _current_word == "":
					wordcount -= 1
					if wordcount == 0:
						# ya para cuando introduzca todas las letras correctas y el string esté vacio
						success()
					else:
						reset_game()

			else:
				# Si la primera letra de la palabra NO es la tecla que presionamos
				fail()
				#yield(get_tree().create_timer(1.0), "timeout") # Esperamos un segundo
				#queue_free() # Liberamos la instancia

				# Aquí está el desafio fallido


func success():
	status = State.Transmitted  # Cambiamos el estado del desafio
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()


func fail():
	status = State.Error  # Cambiamos al estado error
	typing_text.text = "Error!!!"  # Cambiamos el label a ERROR
	yield(get_tree().create_timer(0.5), "timeout")
	reset_game()


func _process(delta):
	if status == State.Playing:
		time -= delta


		if time <= 0.0:
			# Ahora si se acaba el tiempo estipulado para el desafio
			fail()
			yield(get_tree().create_timer(1.0), "timeout")
			queue_free()

			# Aquí está el desafio fallido
