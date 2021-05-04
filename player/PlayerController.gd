extends KinematicBody
export (Vector3) var gravity;
export (float) var jumpForce;
export (float) var runForce;
export (float) var extraFallForce;
export (float) var accelleration;
export (float) var decelleration;
export (float) var shootTimer = 0.1;
export (PackedScene) var bulletScene;

var target_vel = Vector3.ZERO;
var linear_velocity = Vector3.ZERO;
var CameraTarget; 
var lastShootTime = 0;
var anim;
var shootSide : bool = false;

var dead = false;

func _ready():
	anim = get_node("AnimationTree");
	CameraTarget = get_node("CameraTarget");

func _physics_process(delta):
	linear_velocity += gravity * delta;
	
	var cam_basis = CameraTarget.get_global_transform().basis;
	var dir = Vector3()
	if(!dead):
		dir = (Input.get_action_strength("move_left") - Input.get_action_strength("move_right")) * cam_basis.x
		dir += (Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")) * cam_basis.z
		dir.y = 0;
		dir = dir.normalized()
		
		rotation_degrees.y = CameraTarget.rotation_degrees.y;
	
	if(dir != Vector3.ZERO):
		target_vel = lerp(target_vel, dir, accelleration*delta);
	else:
		target_vel = lerp(target_vel, dir, decelleration*delta);		

	var jump_attempt = Input.is_action_just_pressed("jump")
	var shoot_attempt = Input.is_action_pressed("shoot")
	
	move_and_slide(gravity*delta, -gravity.normalized());	
	if is_on_floor():
		linear_velocity = Vector3.ZERO;
		linear_velocity += target_vel * runForce;
		anim.set("parameters/Switch/blend_amount", 0.0);
		anim.set("parameters/Ground/blend_amount", linear_velocity.length());
		if(jump_attempt):
			linear_velocity.y += jumpForce;
	else:
		anim.set("parameters/Switch/blend_amount", 1.0);
		anim.set("parameters/Air/blend_amount", lerp(-1, 1, linear_velocity.y*0.1));
		if(!Input.is_action_pressed("jump") && linear_velocity.y > 0): 
			linear_velocity.y -= extraFallForce * delta;
			
	if(shoot_attempt):
		pass;
		
	linear_velocity = move_and_slide(linear_velocity, -gravity.normalized())

func death():
	dead = true;
