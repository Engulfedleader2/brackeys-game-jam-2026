class_name Toy
extends Resource

@export var id: StringName = &""
@export var display_name: String = "Toy"
@export_multiline var description: String = ""
@export var icon: Texture2D

func should_call(pile_state: Dictionary) -> bool:
	return false

# Whether to play card_value face-down. Only ever consulted for values other
# than 1 or 5 - those are always played face-down for every toy, no exceptions.
# context holds whatever this toy's rule needs: "pile_total", "turns_taken".
func should_bluff(_card_value: int, _context: Dictionary) -> bool:
	return false

# What to claim a face-down card is. Defaults to a random pick between the
# two legal declared values - override to always tell the truth instead.
func declare(_actual_value: int, context: Dictionary) -> int:
	var total: int = context.get("pile_total", 0)
	var threshold: int = context.get("bust_threshold", 20)
	
	if total < 5:
		return 5
	if total + 5 > threshold:
		return 1
	return [1, 5][randi() % 2]
