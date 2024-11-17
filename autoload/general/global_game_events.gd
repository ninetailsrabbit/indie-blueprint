extends Node


#region Interactables
@warning_ignore("unused_signal")
signal interactable_focused(interactable: Interactable3D)
@warning_ignore("unused_signal")
signal interactable_unfocused(interactable: Interactable3D)
@warning_ignore("unused_signal")
signal interactable_interacted(interactable: Interactable3D)
@warning_ignore("unused_signal")
signal interactable_canceled_interaction(interactable: Interactable3D)
@warning_ignore("unused_signal")
signal interactable_interaction_limit_reached(interactable: Interactable3D)
@warning_ignore("unused_signal")
signal canceled_interactable_scan(interactable: Interactable3D)


#endregion

#region Picking
@warning_ignore("unused_signal")
signal grabbable_focused(grabbable: Grabbable3D)
@warning_ignore("unused_signal")
signal grabbable_unfocused(grabbable: Grabbable3D)
#endregion



#region Narrative
#signal dialogues_requested(dialogue_blocks: Array[DialogueDisplayer.DialogueBlock])
#signal dialogue_display_started(dialogue: DialogueDisplayer.DialogueBlock)
#signal dialogue_display_finished(dialogue: DialogueDisplayer.DialogueBlock)
#signal dialogue_blocks_started_to_display(dialogue_blocks: Array[DialogueDisplayer.DialogueBlock])
#signal dialogue_blocks_finished_to_display()
#endregion
