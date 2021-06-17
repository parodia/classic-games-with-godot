extends Node2D

var arr:=[1,2,3,4,5]
var b:=0

func _ready() -> void:
	b=((3 + randi() % 12) * 8)-4

func _process(delta: float) -> void:
	b=((3 + randi() % 12) * 8)
	if b < 24 || b > 100:
		printt("b:",b)

func rotates(l:Array,n:int) -> Array:
	return l.slice(n,l.size()) + l.slice(l.size(),n)

func _draw() -> void:
	draw_grid()

func draw_grid() -> void:
	var grid_size:= 8
	var grid_w:= int(128/grid_size)
	var grid_h:= int(128/grid_size)
	for y in range(0,grid_h):
		for x in range(0,grid_w):
			if (x+y) % 2 == 0:
				var r:Rect2 = Rect2(x*grid_size,y*grid_size,grid_size,grid_size)
				draw_rect(r,Color.green)
			else:
				var rr:Rect2 = Rect2(x*grid_size,y*grid_size,grid_size,grid_size)
				draw_rect(rr,Color.greenyellow)
