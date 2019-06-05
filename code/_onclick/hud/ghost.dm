/obj/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/obj/screen/ghost/MouseEntered()
	flick(icon_state + "_anim", src)

/obj/screen/ghost/follow_ghosts
	name = "Follow Ghosts"
	icon_state = "follow_ghost"

/obj/screen/ghost/follow_ghosts/Click()
	var/mob/dead/observer/G = usr
	G.follow_ghost()

/obj/screen/ghost/follow_xeno
	name = "Follow Xeno"
	icon_state = "follow_xeno"

/obj/screen/ghost/follow_xeno/Click()
	var/mob/dead/observer/G = usr
	G.follow_xeno()

/obj/screen/ghost/follow_human
	name = "Follow Humans"
	icon_state = "follow_human"

/obj/screen/ghost/follow_human/Click()
	var/mob/dead/observer/G = usr
	G.follow_human()

/obj/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"

/obj/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()


/datum/hud/ghost/New(mob/owner, ui_style='icons/mob/screen/white.dmi', ui_color, ui_alpha = 230)
	. = ..()
	var/obj/screen/using

	using = new /obj/screen/ghost/follow_ghosts()
	using.screen_loc = ui_ghost_slot1
	static_inventory += using

	using = new /obj/screen/ghost/follow_xeno()
	using.screen_loc = ui_ghost_slot2
	static_inventory += using

	using = new /obj/screen/ghost/follow_human()
	using.screen_loc = ui_ghost_slot3
	static_inventory += using

	using = new /obj/screen/ghost/reenter_corpse()
	using.screen_loc = ui_ghost_slot4
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