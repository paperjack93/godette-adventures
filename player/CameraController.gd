extends Spatial

export (float) var SENSITIVITY_X = 0
export (float) var SENSITIVITY_Y = 0
export (float) var INVERSION_MULT = 1
export (float) var MAX_Y = 89
export (float) var SPEED = 15
export (float) var CONTAINERSPEED = 15
export (float) var ROTSPEED = 15
export (Vector3) var ORIGIN;
export (Vector3) var OFFSET;

var collision_exception = [];
var targetRot = Vector3.ZERO;
var offset;

var parent;
var container;

func _ready():
	set_as_toplevel(true);
	parent = get_parent();
	container = get_node("CameraContainer");
	collision_exception.append(parent.get_rid());
	offset = transform.origin/2;

func _input(event):
	if event is InputEventMouseMotion:			
		targetRot.x = clamp(targetRot.x + (SENSITIVITY_Y * event.relative.y), -MAX_Y, MAX_Y);
		targetRot.y += -SENSITIVITY_X * event.relative.x;
		targetRot.x = fmod(targetRot.x, 360);
		targetRot.y = fmod(targetRot.y, 360);

func _physics_process(delta):

	rotation_degrees.x = rad2deg(lerp_angle(deg2rad(rotation_degrees.x), deg2rad(targetRot.x), ROTSPEED * delta));
	rotation_degrees.y = rad2deg(lerp_angle(deg2rad(rotation_degrees.y), deg2rad(targetRot.y), ROTSPEED * delta));

	var pos = parent.to_global(ORIGIN);
	var target = to_global(OFFSET);
	
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space());
	var col = ds.intersect_ray(pos, target, collision_exception);
	if !col.empty():
		var dir = pos-target;
		target = col.position + dir.normalized() * 0.1;
	
	global_transform.origin = global_transform.origin.linear_interpolate(pos, SPEED*delta);
	container.global_transform.origin = container.global_transform.origin.linear_interpolate(target, CONTAINERSPEED*delta);
	
