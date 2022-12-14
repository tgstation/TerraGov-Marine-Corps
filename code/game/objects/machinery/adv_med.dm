// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/mob/living/carbon/occupant
	var/locked
	name = "Body Scanner"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner_0"
	density = TRUE
	anchored = TRUE
	coverage = 20

	use_power = IDLE_POWER_USE
	idle_power_usage = 60
	active_power_usage = 16000	//16 kW. It's a big all-body scanner - This is used on scan / examine


/obj/machinery/bodyscanner/relaymove(mob/user)
	if(user.incapacitated(TRUE))
		return
	go_out()


/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.stat != CONSCIOUS)
		return
	go_out()

/obj/machinery/bodyscanner/proc/move_inside_wrapper(mob/living/M, mob/user)
	if (M.stat != CONSCIOUS || !ishuman(M))
		return
	if (occupant)
		to_chat(user, span_boldnotice("The scanner is already occupied!"))
		return
	if (M.abiotic())
		to_chat(user, span_boldnotice("Subject cannot have abiotic items on."))
		return
	M.forceMove(src)
	occupant = M
	icon_state = "body_scanner_1"
	for(var/obj/O in src)
		qdel(O)

/obj/machinery/bodyscanner/MouseDrop_T(mob/M, mob/user)
	if(!isliving(M) || !ishuman(user))
		return
	move_inside_wrapper(M, user)

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	move_inside_wrapper(usr, usr)

/obj/machinery/bodyscanner/Destroy()
	locked = FALSE
	go_out()
	return ..()

/obj/machinery/bodyscanner/proc/go_out()
	if (!occupant || locked)
		return
	for(var/obj/O in src)
		O.loc = loc
	occupant.forceMove(loc)
	occupant = null
	icon_state = "body_scanner_0"

/obj/machinery/bodyscanner/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	go_out()


/obj/machinery/bodyscanner/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out; this is here mainly for consistency's sake.
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)
		return

	var/mob/M
	if(!istype(I, /obj/item/grab))
		return

	else if(occupant)
		to_chat(user, span_warning("The scanner is already occupied!"))
		return

	var/obj/item/grab/G = I
	if(istype(G.grabbed_thing,/obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
		if(!C.bodybag_occupant)
			to_chat(user, span_warning("The stasis bag is empty!"))
			return
		M = C.bodybag_occupant
		C.open()
		user.start_pulling(M)
	else if(ismob(G.grabbed_thing))
		M = G.grabbed_thing

	if(!M)
		return

	if(M.abiotic())
		to_chat(user, span_warning("Subject cannot have abiotic items on."))
		return

	M.forceMove(src)
	occupant = M
	icon_state = "body_scanner_1"
	for(var/obj/O in src)
		O.forceMove(loc)

/obj/machinery/bodyscanner/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!occupant)
		to_chat(X, span_xenowarning("There is nothing of interest in there."))
		return
	if(X.status_flags & INCORPOREAL || X.do_actions)
		return
	visible_message(span_warning("[X] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(!do_after(X, 2 SECONDS))
		return
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	go_out()

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(EXPLODE_LIGHT)
			if(!prob(75))
				return
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)

/obj/machinery/body_scanconsole/ex_act(severity)

	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)

/obj/machinery/body_scanconsole
	name = "Body Scanner Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scannerconsole"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 3
	var/obj/machinery/bodyscanner/connected
	var/delete
	var/temphtml

/obj/machinery/body_scanconsole/Initialize()
	. = ..()
	set_connected(locate(/obj/machinery/bodyscanner, get_step(src, WEST)))


/obj/machinery/body_scanconsole/update_icon()
	if(machine_stat & BROKEN)
		icon_state = "body_scannerconsole-p"
	else if(machine_stat & NOPOWER)
		icon_state = "body_scannerconsole-p"
	else
		icon_state = initial(icon_state)


/obj/machinery/body_scanconsole/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!connected || !connected.is_operational())
		return FALSE

	if(!ishuman(connected.occupant))
		return FALSE

	return TRUE


/obj/machinery/body_scanconsole/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	if(connected?.occupant) //Is something connected?
		var/mob/living/carbon/human/H = connected.occupant
		dat = med_scan(H, dat, GLOB.known_implants)
	else
		dat = "<font color='red'> Error: No Body Scanner connected.</font>"

	var/datum/browser/popup = new(user, "scanconsole", "<div align='center'>Body Scanner Console</div>", 430, 600)
	popup.set_content(dat)
	popup.open(FALSE)


/obj/machinery/bodyscanner/examine(mob/living/user)
	. = ..()
	if(!occupant)
		return
	if(!hasHUD(user,"medical"))
		. += span_notice("It contains: [occupant].")
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical) //Again, for consistency with other medical machines/devices
		if (!R.fields["name"] == H.real_name)
			continue
		if(!(R.fields["last_scan_time"]))
			. += span_deptradio("No scan report on record")
		else
			. += span_deptradio("<a href='?src=\ref[src];scanreport=1'>It contains [occupant]: Scan from [R.fields["last_scan_time"]].</a>")
		break


///Wrapper to guarantee connected bodyscanner references are properly nulled and avoid hard deletes.
/obj/machinery/body_scanconsole/proc/set_connected(obj/machinery/bodyscanner/new_connected)
	if(connected)
		UnregisterSignal(connected, COMSIG_PARENT_QDELETING)
	connected = new_connected
	if(connected)
		RegisterSignal(connected, COMSIG_PARENT_QDELETING, .proc/on_bodyscanner_deletion)


///Called by the deletion of the connected bodyscanner.
/obj/machinery/body_scanconsole/proc/on_bodyscanner_deletion(obj/machinery/bodyscanner/source, force)
	SIGNAL_HANDLER
	set_connected(null)
