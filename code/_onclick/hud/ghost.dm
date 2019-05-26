/datum/hud/ghost/New(mob/owner)
	. = ..()


/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if(istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	return ..()


/mob/dead/observer/create_hud()
	if(!client || hud_used)
		return

	hud_used = new /datum/hud/ghost(src)