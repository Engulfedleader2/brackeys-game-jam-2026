class_name ItemResource
extends Resource

#What does the item target
enum TargetKind {
	NONE,
	CARD,
	PLAYER,
	PILE,
}

@export var id: StringName = &""
@export var display_name: String = "Item"
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var cost: int = 5
@export var target: TargetKind = TargetKind.NONE
