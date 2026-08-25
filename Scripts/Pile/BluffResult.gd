class_name BluffResult
extends RefCounted

var entry: PileEntry
var caller_id: int
var was_lie: bool
var loser_id: int

func describe() -> String:
	if was_lie:
		return "Player %d called Player %d - it was a %d. Caught. Player %d takes the pile" % [ caller_id, entry.owner_id, entry.actual_value(), loser_id ]
	return "Player %d called Player %d - it really was a %d. Bad Call. Player %d takes the pile" % [ caller_id, entry.owner_id, entry.actual_value(), loser_id]
