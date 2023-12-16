/atom/movable/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/atom/movable/screen/ghost/MouseEntered()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/follow_ghosts
	name = "Follow"
	icon_state = "follow_ghost"

/atom/movable/screen/ghost/follow_ghosts/Click()
	var/mob/dead/observer/G = usr
	G.follow()

// /atom/movable/screen/ghost/follow_xeno
// 	name = "Follow Xeno"
// 	icon_state = "follow_xeno"

// /atom/movable/screen/ghost/follow_xeno/Click()
// 	var/mob/dead/observer/G = usr
// 	G.follow_xeno()

// /atom/movable/screen/ghost/follow_human
// 	name = "Follow Humans"
// 	icon_state = "follow_human"

// /atom/movable/screen/ghost/follow_human/Click()
// 	var/mob/dead/observer/G = usr
// 	G.follow_human()

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/ghost = usr
	var/larva_position = SEND_SIGNAL(usr.client, COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION)
	if (larva_position) // If non-zero, we're in queue
		var/confirm = tgui_alert(usr, "Returning to your corpse will make you leave the larva queue. Position: [larva_position]", "Confirm.", list("Yes", "No"))
		if (confirm != "Yes")
			return
	ghost.reenter_corpse()


/datum/hud/ghost/New(mob/owner, ui_style='icons/mob/screen/white.dmi', ui_color, ui_alpha = 230)
	. = ..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/ghost/follow_ghosts()
	using.screen_loc = ui_ghost_slot2
	static_inventory += using

	using = new /atom/movable/screen/ghost/reenter_corpse()
	using.screen_loc = ui_ghost_slot3
	static_inventory += using


/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client.prefs.ghost_hud)
		screenmob.client.screen -= static_inventory
	else
		screenmob.client.screen += static_inventory

//We should only see observed mob alerts.
/datum/hud/ghost/reorganize_alerts(mob/viewmob)
	var/mob/dead/observer/obs = mymob
	if(istype(obs) && obs.observetarget)
		return
	return ..()
