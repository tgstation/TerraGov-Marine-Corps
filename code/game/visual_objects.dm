/atom/movable/vis_obj
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/atom/movable/vis_obj/action
	appearance_flags = NO_CLIENT_COLOR
	layer = HUD_LAYER
	plane = HUD_PLANE
	icon = 'icons/mob/actions.dmi'


/atom/movable/vis_obj/action/selected_frame
	icon_state = "selected_frame"

/atom/movable/vis_obj/action/empowered_frame
	icon_state = "borders_center"

/atom/movable/vis_obj/action/fmode_single
	icon_state = "fmode_single"

/atom/movable/vis_obj/action/fmode_burst
	icon_state = "fmode_burst"

/atom/movable/vis_obj/action/fmode_single_auto
	icon_state = "fmode_single_auto"

/atom/movable/vis_obj/action/fmode_burst_auto
	icon_state = "fmode_burst_auto"


/atom/movable/vis_obj/action/bump_attack_active
	icon_state = "bumpattack_on"

/atom/movable/vis_obj/action/bump_attack_inactive
	icon_state = "bumpattack_off"


/atom/movable/vis_obj/effect/muzzle_flash
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "muzzle_flash"
	layer = ABOVE_LYING_MOB_LAYER
	plane = GAME_PLANE
	var/applied = FALSE

/atom/movable/vis_obj/effect/muzzle_flash/Initialize(mapload, new_icon_state)
	. = ..()
	if(new_icon_state)
		icon_state = new_icon_state

/atom/movable/vis_obj/fulton_baloon
	appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	icon = 'icons/obj/items/fulton_balloon.dmi'
	icon_state = "fulton_noballoon"
	pixel_y = 10
