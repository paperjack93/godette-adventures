extends KinematicBody
export (NodePath) var target;
export (PackedScene) var attackScene;
export (NodePath) var attackSource;
export (float) var sightDistance = 25;
export (float) var sightCone = 45;
export (float) var speed = 10;
export (float) var attackDistance = 5;

export (int, LAYERS_3D_PHYSICS) var sightMask;
onready var nav = get_tree().current_scene.get_node("Navigation");
var Utils = preload("res://Utils.gd");
var path = [];
var pathId = 0;
var retargetTime = 0.25;
var gravity = -9.81;

var canSeeTarget : bool = false setget ,canSeeTargetGet;
var _canSeeTarget;
var _gravity = 0;
var _retargetTime = 0;
var isChasing = false;
var isAttacking = false;

func _ready():
	target = get_node(target);

func _physics_process (delta):
	if(!target): return;
	
	move_and_slide(Vector3.UP * _gravity, Vector3.UP);
	if(is_on_floor()):
		_gravity = gravity * delta;
	else:
		_gravity += gravity * delta;
	
	if(isAttacking): pass;
	elif(isChasing): chasingProcess(delta);
	else: idleProcess(delta);
	
func idleProcess(delta):
	if(_retargetTime < 0):
		var ds = PhysicsServer.space_get_direct_state(get_world().get_space());
		var col = ds.intersect_ray(global_transform.origin, target.global_transform.origin, [self], sightMask);
		if(!col.empty()):
			var dir = global_transform.origin - target.global_transform.origin;
			_canSeeTarget = col.collider == target \
				&& dir.length() <  sightDistance \
				&& Utils.Angle(global_transform.basis.z, dir);
		else:
			_canSeeTarget = false;
		if(_canSeeTarget): isChasing = true;
		_retargetTime = retargetTime;
	else: _retargetTime -= delta;
	
func chasingProcess(delta):
	if(_retargetTime < 0):
		moveTo(target.global_transform.origin);
		_canSeeTarget = path.size() == 2;
		_retargetTime = retargetTime;
	else: _retargetTime -= delta;
	
	if(!is_on_floor()): return;
	
	if(_canSeeTarget):
		var dir = target.global_transform.origin - global_transform.origin;
		look_at (global_transform.origin - Utils.ProjectVector(dir, Vector3.UP), Vector3.UP)
		move_and_slide(dir.normalized() * speed, Vector3.UP);
		if(dir.length() < attackDistance): attack();
	else:
		if(pathId < path.size()):
			var dir = path[pathId] - global_transform.origin;
			if(dir.length() < 1):
				pathId += 1;
			else:
				look_at (global_transform.origin - Utils.ProjectVector(dir, Vector3.UP), Vector3.UP)
				move_and_slide(dir.normalized() * speed, Vector3.UP);

func attack():
	isAttacking = true;
	yield(get_tree().create_timer(1.0), "timeout");
	isAttacking = false;

func spawnAttack():
	var a = attackScene.instance();
	get_tree().current_scene.add_child(a);
	a.global_transform = attackSource.global_transform;
	
func moveTo(pos : Vector3):
	path = nav.get_simple_path(global_transform.origin, pos, true);
	pathId = 0;
	
func canSeeTargetGet():
	return _canSeeTarget;

func death():
	queue_free();

