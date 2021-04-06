extends Camera

const MAX_HEIGHT = 2.0
const MIN_HEIGHT = 0
export (bool) var movEnabled = true
export (float) var mouseSensitivity = 0.1

export var min_distance = 0.5
export var max_distance = 3.5
export var angle_v_adjust = 0.0
export var autoturn_ray_aperture = 25
export var autoturn_speed = 50

var collision_exception = []

var yaw : float = 0.0
var pitch : float = 0.0
var yawDelta : float = 0.0
var pitchDelta : float = 0.0
var origin : Vector3;

func _ready():
	# Find collision exceptions for ray.
	var node = self
	while node:
		if node is RigidBody:
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()
	set_physics_process(true)
	# This detaches the camera transform from the parent spatial node.
	set_as_toplevel(true)
	origin = get_global_transform().origin - get_parent().get_global_transform().origin;
	yaw = 0.0
	pitch = 0.0
	
func _input(event):
	if event is InputEventMouseMotion and movEnabled:
		var mouseVec : Vector2 = event.get_relative()
		yaw = fmod(yaw  - mouseVec.x * mouseSensitivity , 360.0)
		pitch = max(min(pitch - mouseVec.y * mouseSensitivity , 90.0), -90.0)
		get_parent().set_rotation(Vector3(deg2rad(pitch), deg2rad(yaw), 0.0))

func _physics_process(dt):
	var target = get_parent().get_global_transform().origin
	var pos = get_global_transform().origin

	var delta = pos - target; 
	# Regular delta follow.

	# Check ranges.
	if delta.length() < min_distance:
		delta = delta.normalized() * min_distance
	elif  delta.length() > max_distance:
		delta = delta.normalized() * max_distance

	# Check upper and lower height.
	delta.y = clamp(delta.y, MIN_HEIGHT, MAX_HEIGHT)

	# Apply lookat.
	if delta == Vector3():
		delta = (pos - target).normalized() * 0.0001

	look_at_from_position(pos, target, Vector3.UP)

	# Turn a little up or down.
	var t = get_transform()
	t.basis = Basis(t.basis[0], deg2rad(angle_v_adjust)) * t.basis
	set_transform(t)
	
	var targetPos = get_parent().to_global(origin);
	global_transform.origin = global_transform.origin.linear_interpolate(targetPos, 15*dt);
