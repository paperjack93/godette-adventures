extends Spatial
var collision_exception = [];
export(float) var maxDistance = 100;
export(float) var meshHeight = 10;
export(float) var offset = 0.1;
var mesh;

func _ready():
	mesh = get_node("ShadowPoint");
	collision_exception.append(get_parent().get_rid());
	mesh.scale.z = meshHeight;

func _process(delta):
	var pos = global_transform.origin;
	var target = pos + Vector3.DOWN * maxDistance;
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space());
	var col = ds.intersect_ray(pos, target, collision_exception);
	if col.empty():
		self.visible = false;
	else:
		self.visible = true;
		mesh.global_transform.origin = col.position + Vector3.UP * offset;
		
