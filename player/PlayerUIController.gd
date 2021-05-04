extends CanvasLayer

export (NodePath) var healthLabel;
export (NodePath) var health;

var Utils = preload("res://Utils.gd");

func _ready():
	healthLabel = get_node(healthLabel);
	health = get_node(health);

func _process(delta):
	healthLabel.text = str(health.amount);
