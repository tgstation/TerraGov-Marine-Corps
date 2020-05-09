// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/mob/living/carbon/occupant
	var/locked
	name = "Body Scanner"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner_0"
	density = TRUE
	anchored = TRUE

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
	if (M.stat != CONSCIOUS || !(ishuman(M) || ismonkey(M)))
		return
	if (occupant)
		to_chat(user, "<span class='boldnotice'>The scanner is already occupied!</span>")
		return
	if (M.abiotic())
		to_chat(user, "<span class='boldnotice'>Subject cannot have abiotic items on.</span>")
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
	return

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
		to_chat(user, "<span class='warning'>The scanner is already occupied!</span>")
		return

	var/obj/item/grab/G = I
	if(istype(G.grabbed_thing,/obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
		if(!C.bodybag_occupant)
			to_chat(user, "<span class='warning'>The stasis bag is empty!</span>")
			return
		M = C.bodybag_occupant
		C.open()
		user.start_pulling(M)
	else if(ismob(G.grabbed_thing))
		M = G.grabbed_thing

	if(!M)
		return

	if(M.abiotic())
		to_chat(user, "<span class='warning'>Subject cannot have abiotic items on.</span>")
		return

	M.forceMove(src)
	occupant = M
	icon_state = "body_scanner_1"
	for(var/obj/O in src)
		O.forceMove(loc)


/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				qdel(src)
				return
		if(EXPLODE_LIGHT)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				qdel(src)
				return
		else
	return

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
	var/known_implants = list(/obj/item/implant/neurostim)
	var/delete
	var/temphtml

/obj/machinery/body_scanconsole/Initialize()
	. = ..()
	connected = locate(/obj/machinery/bodyscanner, get_step(src, WEST))


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
		dat = med_scan(H, dat, known_implants)
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
		to_chat(user, "<span class='notice'>It contains: [occupant].</span>")
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical) //Again, for consistency with other medical machines/devices
		if (!R.fields["name"] == H.real_name)
			continue
		if(!(R.fields["last_scan_time"]))
			to_chat(user, "<span class = 'deptradio'>No scan report on record</span>\n")
		else
			to_chat(user, "<span class = 'deptradio'><a href='?src=\ref[src];scanreport=1'>It contains [occupant]: Scan from [R.fields["last_scan_time"]].</a></span>\n")
		break
