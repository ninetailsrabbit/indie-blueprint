extends Node


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
@warning_ignore("unused_signal")
signal interactable_scanned(interactable: Interactable3D)

@warning_ignore("unused_signal")
signal grabbable_focused(grabbable: Grabbable3D)
@warning_ignore("unused_signal")
signal grabbable_unfocused(grabbable: Grabbable3D)
