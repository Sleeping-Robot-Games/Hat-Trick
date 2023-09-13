extends Control

func change_hat(hatname):
	$Border/Hat.texture = load("res://assets/sprites/hat/"+hatname+".png")
