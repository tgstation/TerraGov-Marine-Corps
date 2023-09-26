/obj/effect/overlay/pod_warning //Used to indicate incoming POD
	name = "pod warning"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'modular_RUtgmc/icons/effects/lases.dmi'
	icon_state = "nothing"
	var/icon_state_on = "pod_warning"
	layer = ABOVE_FLY_LAYER
	hud_possible = list(SQUAD_HUD_TERRAGOV)

/obj/effect/overlay/pod_warning/Initialize(mapload)
	. = ..()
	prepare_huds()
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD_TERRAGOV]
	squad_hud.add_to_hud(src)
	set_visuals()

/obj/effect/overlay/pod_warning/proc/set_visuals()
	var/image/new_hud_list = hud_list[SQUAD_HUD_TERRAGOV]
	if(!new_hud_list)
		return
	new_hud_list.icon = 'modular_RUtgmc/icons/effects/lases.dmi'
	new_hud_list.icon_state = icon_state_on
	hud_list[SQUAD_HUD_TERRAGOV] = new_hud_list
