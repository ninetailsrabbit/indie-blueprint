extends Node


#region Narrative
#signal dialogues_requested(dialogue_blocks: Array[DialogueDisplayer.DialogueBlock])
#signal dialogue_display_started(dialogue: DialogueDisplayer.DialogueBlock)
#signal dialogue_display_finished(dialogue: DialogueDisplayer.DialogueBlock)
#signal dialogue_blocks_started_to_display(dialogue_blocks: Array[DialogueDisplayer.DialogueBlock])
#signal dialogue_blocks_finished_to_display()
#endregion
