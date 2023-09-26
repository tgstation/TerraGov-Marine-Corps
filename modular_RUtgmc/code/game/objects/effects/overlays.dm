/obj/effect/overlay/blinking_laser/marine/pod_warning //Used to indicate incoming POD
	name = "pod warning"
	icon = 'modular_RUtgmc/icons/effects/lases.dmi'
	icon_state_on = "pod_laser"

/obj/effect/overlay/blinking_laser/marine/pod_warning/set_visuals()
	var/image/new_hud_list = hud_list[SQUAD_HUD_TERRAGOV]
	if(!new_hud_list)
		return
	new_hud_list.icon = 'modular_RUtgmc/icons/effects/lases.dmi'
	new_hud_list.icon_state = icon_state_on
	hud_list[SQUAD_HUD_TERRAGOV] = new_hud_list
