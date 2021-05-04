static func ProjectVector(vector, up):
	return Plane(up, 0).project(vector);

static func Angle(from, to):	
	return abs(1 - to.normalized().dot(from.normalized())) * 90;
		
static func SignedAngle(from, to, up):	
	if(to.cross(from).dot(up) > 0):
		return Angle(from, to);
	else:
		return -Angle(from, to);	

static func FindNodeInParent(node, name):
	if(node == null): return null;
	var n = node.get_node(name);
	if(n == null):
		if("parent" in node): FindNodeInParent(node.parent, name);
		else: return null;
	else: 
		return n; 

static func get_random_pos_in_sphere (radius : float) -> Vector3:
	var sphere = random_pos_on_unit_sphere(1);

	return sphere * rand_range (0, radius);
	
static func random_pos_on_unit_sphere (radius: float) -> Vector3:
	var x1 = rand_range (-1, 1)
	var x2 = rand_range (-1, 1)

	while x1*x1 + x2*x2 >= 1:
		x1 = rand_range (-1, 1)
		x2 = rand_range (-1, 1)
		
	return Vector3 (
		2 * x1 * sqrt (1 - x1*x1 - x2*x2),
		2 * x2 * sqrt (1 - x1*x1 - x2*x2),
		1 - 2 * (x1*x1 + x2*x2)) * radius;
