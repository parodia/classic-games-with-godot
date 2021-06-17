"""
--todo
+(done) fix snake direction for multiple inputs
+(done) make score/health system
+(done) fix after health 0 score text position
+(done) game-states:title,play,game_over

-(in process) fix new_tail for first time position issue
-(in process) sfx

--assets
font : [QuinqueFive] *by GGBot
"""

extends Node2D

signal dead_zone
enum States {TITLE,IDLE,PLAY,GAMEOVER}
const tail = preload("res://game/src/Snake.tscn")
export(int) var score: int = 0 setget set_score
export(int) var health: int = 3 setget set_health
export(float,0.1,0.8) var w_time:= 0.25
var _state:int= States.TITLE
var i_rot:=false
var g_step:= 8
var g_size:= 14
var dir:= Vector2.ZERO
var vel:= Vector2.ZERO
var new_tail:=Vector2.ZERO

onready var snake:= $Snake
onready var fruit:= $Fruit
onready var timer:= $Timer
onready var game_hud:= $Gui/Interface

func _ready() -> void:
	change_state(States.TITLE)

# check player input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") && i_rot:
		if !dir == Vector2.RIGHT:
			i_rot=false
			dir = Vector2.LEFT
	elif event.is_action_pressed("ui_right") && i_rot:
		if !dir == Vector2.LEFT:
			i_rot=false
			dir = Vector2.RIGHT
	elif event.is_action_pressed("ui_up") && i_rot:
		if !dir == Vector2.DOWN:
			i_rot=false
			dir = Vector2.UP
	elif event.is_action_pressed("ui_down") && i_rot:
		if !dir == Vector2.UP:
			i_rot=false
			dir = Vector2.DOWN
	if event.is_action_pressed("ui_accept") && !_state == 1:
		change_state(States.PLAY)

func _draw() -> void:
	var r_corner:=Rect2(8,8,112,112)
	var r_bg:=Rect2(0,0,128,128)
	draw_rect(r_bg,Color("#ffffff"))
	draw_rect(r_corner,Color("#0000ff"))
	draw_line(Vector2(8,12),Vector2(120,12),Color("#ffffff"),8.0)


# state control @GDQuest
func change_state(new_state: int) -> void:
	_state = new_state
	match _state:
		States.TITLE:
			# snake
			snake.position = snake_restart()
			# fruit
			fruit.position = fruit_spawn()
			dir = Vector2.ZERO
			game_hud.emit_signal("title_screen","SHOW")
		States.IDLE:
			pass
		States.PLAY:
			set_score(0,"SET")
			set_health(3,"SET")
			game_hud.emit_signal("title_screen","HIDE")
			game_hud.emit_signal("game_over_screen",score,"HIDE")
			timer.wait_time = w_time
			timer.start()
		States.GAMEOVER:
			timer.stop()
			dir = Vector2.ZERO
			game_hud.emit_signal("game_over_screen",score,"SHOW")

# snake default position, start/restart
func snake_restart() -> Vector2:
	return Vector2.ONE * ((128/2)-4)

# most harder part
# we moving snake and when snake grows up tail follows snake's head
func move_snake(_dir:Vector2) -> void:
	var b:=get_tree().get_nodes_in_group("body")
	vel = _dir * g_step
	for i in range(b.size()-1,0,-1):
		b[i].position = b[i-1].position
	new_tail = b[0].position
	b[0].position += vel

# do something when time is out
func _on_Timer_timeout() -> void:
	i_rot=true
	move_snake(dir)
	# check if snake hits the wall
	if snake.position.x > 116 || snake.position.x < 12:
		emit_signal("dead_zone")
	elif snake.position.y > 116 || snake.position.y < 20:
		emit_signal("dead_zone")

# check if snake hits itself
func _on_Snake_area_entered(area: Area2D) -> void:
	if !area.name == "Fruit":
		emit_signal("dead_zone")

func check_game_over() -> bool:
	if health < 0:
		return true
	return false

# restart
func _on_Main_dead_zone() -> void:
	var body:=get_tree().get_nodes_in_group("body")
	for b in body.slice(1,body.size()):
		b.queue_free()
	dir = Vector2.ZERO
	snake.position = snake_restart()
	set_health(1,"DOWN")
	if check_game_over():
		change_state(States.GAMEOVER)

# when the snake eats fruit add a tail
func snake_add_tail() -> void:
	var body = tail.instance()
	body.add_to_group("body")
	body.position = new_tail
	call_deferred("add_child",body)

# simple logic for spawn fruit on grid
func fruit_spawn() -> Vector2:
	randomize()
	var b:=get_tree().get_nodes_in_group("body")
	var x:= ((2 + randi() % g_size) * g_step)-4
	var y:= ((3 + randi() % 12) * g_step)-4
	var spawn_pos:= Vector2(x,y)
	for i in b:
		if spawn_pos == i.position:
			x = ((2 + randi() % g_size) * g_step)-4
			y = ((3 + randi() % 12) * g_step)-4
	return Vector2(x,y)

# fruit signal
func _on_Fruit_area_entered(_area: Area2D) -> void:
	set_score(10,"UP")
	snake_add_tail()
	fruit.position = fruit_spawn()

# Set health
func set_health(value: int, type: String = "SET") -> void:
	match type:
		"SET":health = value
		"DOWN":health -= value
	# update health textture
	game_hud.emit_signal("up_health",health)

# Set score
func set_score(value: int, type: String = "SET") -> void:
	match type:
		"SET":score = value
		"UP":score += value
	# update score text
	game_hud.emit_signal("up_score",score)
