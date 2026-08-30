extends Node

# some UI stuff ofr characerwds fsifdsjfhsf
var chosen_toy_class: Script = null


func select(toy_class: Script) -> void:
	chosen_toy_class = toy_class
	print("[CharacterSelection] Chose ", toy_class)


func clear() -> void:
	chosen_toy_class = null
