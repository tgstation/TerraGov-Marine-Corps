/atom/movable/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ghost/MouseEntered()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/toggle_health_scan
	name = "Toggle health scan"
	icon_state = "scan_health"
	base_icon_state = "scan_health"
	screen_loc = ui_ghost_slot1

/atom/movable/screen/ghost/toggle_health_scan/Click()
	var/mob/dead/observer/G = usr
	G.toggle_health_scan()
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/ghost/toggle_health_scan/update_icon_state()
	var/mob/dead/observer/G = usr
	icon_state = "[base_icon_state][G.health_scan ? "_active" : ""]"

/atom/movable/screen/ghost/follow_ghosts
	name = "Follow"
	icon_state = "follow_ghost"
	screen_loc = ui_ghost_slot2

/atom/movable/screen/ghost/follow_ghosts/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"
	screen_loc = ui_ghost_slot4

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.teleport()

/atom/movable/screen/ghost/zoom
	name = "Toggle Zoom"
	icon_state = "zoom_in"
	base_icon_state = "zoom"
	screen_loc = ui_ghost_slot5

/atom/movable/screen/ghost/zoom/Click()
	var/mob/dead/observer/G = usr
	G.toggle_zoom()
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/ghost/zoom/update_icon_state()
	if(hud.mymob?.client.view != CONFIG_GET(string/default_view))
		icon_state = "[base_icon_state]_out"
	else
		icon_state = "[base_icon_state]_in"

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
	screen_loc = ui_ghost_slot3

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

	using = new /atom/movable/screen/ghost/toggle_health_scan(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/follow_ghosts(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/reenter_corpse(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/teleport(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/zoom(null, src)
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
