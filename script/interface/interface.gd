extends Node

## INTERFACES

class Interactible:
	func highlight():
		pass
	func stopHighlighting():
		pass
	func interact():
		pass
	func stopInteracting():
		pass
	func interactSecondary():
		pass

## USAGE
## To implement one of the interfaces in a script:
## var implements = Interface.ExampleInterface
## var implements = [Interface.ExampleInterface, Interface.AnotherExampleInterface]

## To check if a node implements an interface:
## if Interface.implements(myNode, Interface.ExampleInterface):



func implements(node_to_check:Node, interface) -> bool:
	if "implements" in node_to_check:
		var node_implements = node_to_check.implements

		if node_implements is Array:
			for implemented_interface in node_implements:
				if implemented_interface == interface:
					return true
		else: 
			if node_implements == interface:
				return true


	return false


func _get_all_descendants(node:Node) -> Array:
	var all_descendants = [node]

	var children = node.get_children()
	for child in children:
		all_descendants.append_array(_get_all_descendants(child))

	return all_descendants


func _ready():
	var nodes = _get_all_descendants(get_tree().current_scene)

	for node in nodes:
		_check_node(node)

	get_tree().node_added.connect(_check_node)


func _check_node(node:Node) -> void:
	if "implements" in node:
		var node_implements = node.implements

		var check = func (node_to_check:Node, interface_instance):
			var error_message : String = "Interface error: " + node.name + " does not implement the "

			for method in interface_instance.get_script().get_script_method_list():
				assert(method.name in node_to_check, error_message + method.name + " method.")
				var interface_method_args = method.arguments
				var node_method_args = node_to_check.get_method(method.name).arguments
				assert(interface_method_args == node_method_args, error_message + method.name + " method with the correct arguments.")

			for this_signal in interface_instance.get_script().get_script_signal_list():
				assert(this_signal.name in node_to_check, error_message + this_signal.name + " signal.")
			
			var prop_list : Array = interface_instance.get_script().get_script_property_list()
			for i in range(1, prop_list.size()):
				var property = prop_list[i]
				assert(property.name in node_to_check, error_message + property.name + " property.")

				var interface_property_type = typeof(property)
				var node_property_type = typeof(node_to_check.get(property.name))
				assert(interface_property_type == node_property_type, error_message + property.name + " property with the correct type.")

		if node_implements is Array:
			for implemented_interface in node_implements:
				var instance = implemented_interface.new()
				check.call(node, instance)
		else:
			var instance = node.implements.new()
			check.call(node, instance)
