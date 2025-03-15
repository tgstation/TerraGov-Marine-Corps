/atom/movable/vis_obj
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/atom/movable/vis_obj/action
	appearance_flags = NO_CLIENT_COLOR
	plane = HUD_PLANE
	icon = 'icons/mob/actions.dmi'

/atom/movable/vis_obj/effect/muzzle_flash
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "muzzle_flash"
	layer = MOB_BELOW_PIGGYBACK_LAYER
	plane = GAME_PLANE // todo we can make these emissive
	appearance_flags = KEEP_APART|TILE_BOUND|KEEP_TOGETHER
	var/applied = FALSE

/atom/movable/vis_obj/effect/muzzle_flash/Initialize(mapload, new_icon_state)
	. = ..()
	if(new_icon_state)
		icon_state = new_icon_state
	update_appearance(UPDATE_OVERLAYS)

/atom/movable/vis_obj/effect/muzzle_flash/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, layer, reset_transform = FALSE)

/atom/movable/vis_obj/fulton_balloon
	appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	icon = 'icons/obj/items/fulton_balloon.dmi'
	icon_state = "fulton_noballoon"
	pixel_y = 10
