extends MarginContainer

signal title_screen(type)
signal game_over_screen(value,type)
signal up_score(value)
signal up_health(value)

onready var i_score:=$Play/Score
onready var h:=$Play/HBar
onready var t:=$Title
onready var g:=$GameOver


func _ready() -> void:
	g.visible = false

# 16*12*10*3
# 5040 max score?
func _on_Interface_up_score(value:int) -> void:
	i_score.text = "SCORE:" + str(value).pad_zeros(4)

# nice logic from @KidsCanCode
func _on_Interface_up_health(value:int) -> void:
	for i in h.get_child_count():
		h.get_child(i).visible = value > i


func _on_Interface_title_screen(type:String) -> void:
	match type:
		"SHOW":
			t.visible = true
		"HIDE":
			t.visible = false


func _on_Interface_game_over_screen(value:int,type:String) -> void:
	var last_score:=$GameOver/ScoreApple/LastScore
	var apple:=$GameOver/ScoreApple/Apple
	last_score.text = "(S):" + str(value).pad_zeros(4)
	apple.text = "(A):" + str(int(value/10))
	match type:
		"SHOW":
			g.visible = true
		"HIDE":
			g.visible = false
