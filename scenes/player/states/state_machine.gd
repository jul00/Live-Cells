extends Node
class_name StateMachine

var current_state
var previous_state_name 

func _ready() -> void:
	await get_tree().process_frame
	
	current_state = get_node("Idle")
	current_state.enter()
	#change_state(get_node("Idle"))
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
		
func change_state(new_state: Node):
	previous_state_name = current_state
	current_state = new_state
	current_state.enter()
		
	current_state = new_state
	current_state.enter()
