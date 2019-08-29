/atom/movable/vis_obj
	appearance_flags = NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/atom/movable/vis_obj/action
	layer = HUD_LAYER
	plane = HUD_PLANE
	icon = 'icons/mob/actions.dmi'


/atom/movable/vis_obj/action/selected_frame
	icon_state = "selected_frame"


/atom/movable/vis_obj/action/fmode_single
	icon_state = "fmode_single"

/atom/movable/vis_obj/action/fmode_burst
	icon_state = "fmode_burst"

/atom/movable/vis_obj/action/fmode_single_auto
	icon_state = "fmode_single_auto"

/atom/movable/vis_obj/action/fmode_burst_auto
	icon_state = "fmode_burst_auto"


/atom/movable/vis_obj/effect/muzzle_flash
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "muzzle_flash"
	layer = ABOVE_LYING_MOB_LAYER
	plane = GAME_PLANE
	var/applied = FALSE