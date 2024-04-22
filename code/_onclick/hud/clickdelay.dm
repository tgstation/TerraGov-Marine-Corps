/obj/screen/action_bar

/obj/screen/action_bar/Destroy()
	STOP_PROCESSING(SShuds, src)
	return ..()

/obj/screen/action_bar/proc/mark_dirty()
	var/mob/living/L = hud?.mymob
	if(L?.client && update_to_mob(L))
		START_PROCESSING(SShuds, src)

/obj/screen/action_bar/process()
	var/mob/living/L = hud?.mymob
	if(!L?.client || !update_to_mob(L))
		return PROCESS_KILL

/obj/screen/action_bar/proc/update_to_mob(mob/living/L)
	return FALSE

/datum/hud/var/obj/screen/action_bar/clickdelay/left/cdleft
/datum/hud/var/obj/screen/action_bar/clickdelay/right/cdright
/datum/hud/var/obj/screen/action_bar/clickdelay/cdmid

/obj/screen/action_bar/clickdelay
	name = "click delay"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = ""
	mouse_opacity = 0
	layer = 22.1
	plane = 22
	alpha = 230

/obj/screen/action_bar/clickdelay/update_to_mob(mob/living/L)
	if(world.time >= L.next_move)
		icon_state = ""
		return FALSE
	icon_state = "resiswait"
	return TRUE

/obj/screen/action_bar/clickdelay/left/update_to_mob(mob/living/L)
	if(world.time >= L.next_lmove)
		icon_state = ""
		return FALSE
	icon_state = "resiswait"
	return TRUE

/obj/screen/action_bar/clickdelay/right/update_to_mob(mob/living/L)
	if(world.time >= L.next_rmove)
		icon_state = ""
		return FALSE
	icon_state = "resiswait"
	return TRUE

/datum/hud/var/obj/screen/action_bar/resistdelay/resistdelay

/obj/screen/action_bar/resistdelay
	name = "resist delay"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = ""

/obj/screen/action_bar/resistdelay/update_to_mob(mob/living/L)
	if(world.time >= L.last_special)
		icon_state = ""
		return FALSE
	icon_state = "resiswait"
	return TRUE

