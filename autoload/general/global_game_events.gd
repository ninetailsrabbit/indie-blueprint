## In this singleton will live all global events that you need to share across your game
extends Node

#region Interactables
@warning_ignore("unused_signal")
signal interactable_2d_focused(interactable: IndieBlueprintInteractable2D)
@warning_ignore("unused_signal")
signal interactable_2d_unfocused(interactable: IndieBlueprintInteractable2D)
@warning_ignore("unused_signal")
signal interactable_2d_interacted(interactable: IndieBlueprintInteractable2D)
@warning_ignore("unused_signal")
signal interactable_2d_canceled_interaction(interactable: IndieBlueprintInteractable2D)
@warning_ignore("unused_signal")
signal interactable_2d_interaction_limit_reached(interactable: IndieBlueprintInteractable2D)

#endregion


#region Weapons
@warning_ignore("unused_signal")
signal weapon_fired(weapon: FireArmWeapon, hitscan: RaycastResult)
#endregion
