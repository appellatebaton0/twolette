extends Area2D
class_name StartTrigger

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.start_round.emit()
