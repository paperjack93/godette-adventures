extends Node
signal Empty;
signal Decreased;
export (float) var amount = 10;

func _ready():
	pass;

func decrease(n):
	if(amount == 0): return;
	if(n == 0): return;
	amount = max(amount-n, 0);
	emit_signal("Decreased");
	if(amount == 0): empty();

func empty():
	emit_signal("Empty");
