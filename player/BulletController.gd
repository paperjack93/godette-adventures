extends Spatial
export (float) var damage = 1;
export (float) var speed = 5;
export (PackedScene) var explosionScene;

var ignore = [];

func _physics_process(delta):
	var target = global_transform.origin + global_transform.basis.z * delta * speed;
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space());
	var col = ds.intersect_ray(global_transform.origin, target, ignore);
	if col.empty():
		global_transform.origin = target;
	else:
		if(explosionScene): 
			var e = explosionScene.instance();
			get_tree().current_scene.add_child(e);
			e.global_transform.origin = col.position;
			
		if(col.collider.get_node("Health")):
			col.collider.get_node("Health").decrease(damage);
			
		queue_free();
