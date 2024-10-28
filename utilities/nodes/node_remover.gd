class_name NodeRemover


static func is_node_valid(node: Node) -> bool:
	return node != null and is_instance_valid(node) and not node.is_queued_for_deletion()
	

static func remove(node: Node) -> void:
	if is_node_valid(node):
		if node.is_inside_tree():
			node.queue_free()
		else:
			node.call_deferred("free")

## Exceptions are passed as [Area3D.new().get_class)
static func remove_and_queue_free_children(node: Node, except: Array = []) -> void:
	if node.get_child_count() == 0:
		return
		
	var childrens = node.get_children().filter(func(child): return not child.get_class() in except)
	childrens.reverse()
	
	for child in childrens.filter(func(_node: Node): return is_node_valid(_node)):
		node.remove_child(child)
		remove(child)

## Exceptions are passed as [Area3D.new().get_class)
static func queue_free_children(node: Node, except: Array = []) -> void:
	if node.get_child_count() == 0:
		return

	var childrens = node.get_children().filter(func(child): return not child.get_class() in except)
	childrens.reverse()
	
	for child in childrens.filter(func(_node: Node): return is_node_valid(_node)):
		remove(child)
	
	except.clear()


## Exceptions are passed as [Area3D.new().get_class)
static func free_children(node: Node, except: Array = []) -> void:
	if node.get_child_count() == 0:
		return

	var childrens = node.get_children().filter(func(child): return not child.get_class() in except)
	childrens.reverse()
	
	for child in childrens.filter(func(_node: Node): return is_node_valid(_node)):
		child.free()
	
	except.clear()
