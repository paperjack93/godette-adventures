extends Camera

const MAX_HEIGHT = 2.0
const MIN_HEIGHT = 0
export (bool) var movEnabled = true
export (Vector2) var mouseSensitivity;

export var min_distance = 0.5
export var max_distance = 3.5
export var angle_v_adjust = 0.0
export var autoturn_ray_aperture = 25
export var autoturn_speed = 50
export (Vector2) var pitchClamp;

var collision_exception = []

var yaw : float = 0.0;
var pitch : float = 0.0;
var targetPitch : float = 0.0;
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
		yaw = fmod(yaw  - mouseVec.x * mouseSensitivity.x, 360.0)
		pitch = pitch - mouseVec.y * mouseSensitivity.y;
		get_parent().set_rotation(Vector3(0, deg2rad(yaw), 0.0))

func _physics_process(dt):
	var target = get_parent().get_global_transform().origin
	var pos = get_global_transform().origin
	var targetPos = get_parent().to_global(origin);
	
	var delta = target - targetPos; 
	
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space());

	var col = ds.intersect_ray(target, targetPos, collision_exception);

	if !col.empty():
		targetPos = col.position + delta.normalized() * 0.1;

	pitch = lerp(pitch, clamp(pitch, pitchClamp.x, pitchClamp.y), 10 * dt);
	targetPitch = lerp(targetPitch, pitch, 10 * dt);
	
	var rot = global_transform.looking_at(target, Vector3.UP).basis.get_euler();
	rot.x = deg2rad(targetPitch);
	self.rotation = rot;
	
	global_transform.origin = global_transform.origin.linear_interpolate(targetPos, 15*dt);
