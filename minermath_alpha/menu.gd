extends Control




func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://character_body_2d.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()
