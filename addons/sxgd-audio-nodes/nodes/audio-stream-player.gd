extends AudioStreamPlayer
## An augmented [AudioStreamPlayer].

## Spawn a duplicate player to the node parent.
## Then play the sound and remove the node.
func spawn_duplicate() -> void:
	# Connect node to parents' parent
	var parent = get_parent()
	var parent_parent = parent.get_parent()

	var dup := duplicate()
	parent_parent.call_deferred("add_child", dup)
	dup.call_deferred("play_and_remove")

## Play the sound and remove the node.
func play_and_remove() -> void:
	if is_inside_tree():
		play()
		await finished
		queue_free()
