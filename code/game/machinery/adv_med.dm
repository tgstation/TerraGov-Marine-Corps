// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/mob/living/carbon/occupant
	var/locked
	name = "Body Scanner"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner_0"
	density = TRUE
	anchored = TRUE

	use_power = 1
	idle_power_usage = 60
	active_power_usage = 10000	//10 kW. It's a big all-body scanner.


/obj/machinery/bodyscanner/relaymove(mob/user)
	if(user.incapacitated(TRUE)) return
	go_out()


/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.stat != 0)
		return
	src.go_out()
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if (usr.stat || !(ishuman(usr) || ismonkey(usr)))
		return
	if (src.occupant)
		to_chat(usr, "<span class='boldnotice'>The scanner is already occupied!</span>")
		return
	if (usr.abiotic())
		to_chat(usr, "<span class='boldnotice'>Subject cannot have abiotic items on.</span>")
		return
	usr.forceMove(src)
	src.occupant = usr
	update_use_power(2)
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		//O = null
		qdel(O)
		//Foreach goto(124)
	return

/obj/machinery/bodyscanner/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(30)
	src.occupant.forceMove(loc)
	src.occupant = null
	update_use_power(1)
	src.icon_state = "body_scanner_0"
	return

/obj/machinery/bodyscanner/attack_hand(mob/living/user)
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
		if(!C.stasis_mob)
			to_chat(user, "<span class='warning'>The stasis bag is empty!</span>")
			return
		M = C.stasis_mob
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
	update_use_power(2)
	icon_state = "body_scanner_1"
	for(var/obj/O in src)
		O.forceMove(loc)


/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				qdel(src)
				return
		if(3.0)
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
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/body_scanconsole/power_change()
	..()
	if(machine_stat & BROKEN)
		icon_state = "body_scannerconsole-p"
	else
		if (machine_stat & NOPOWER)
			spawn(rand(0, 15))
				src.icon_state = "body_scannerconsole-p"
		else
			icon_state = initial(icon_state)

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/loyalty, /obj/item/implant/tracking, /obj/item/implant/neurostim)
	var/delete
	var/temphtml
	name = "Body Scanner Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scannerconsole"
	density = 0
	anchored = TRUE


/obj/machinery/body_scanconsole/Initialize()
	. = ..()
	connected = locate(/obj/machinery/bodyscanner, get_step(src, WEST))

/*

/obj/machinery/body_scanconsole/process() //not really used right now
	if(machine_stat & (NOPOWER|BROKEN))
		return
	//use_power(250) // power stuff

//	var/mob/M //occupant
//	if (!( src.limb_status )) //remove this
//		return
//	if ((src.connected && src.connected.occupant)) //connected & occupant ok
//		M = src.connected.occupant
//	else
//		if (istype(M, /mob))
//		//do stuff
//		else
///			src.temphtml = "Process terminated due to lack of occupant in scanning chamber."
//			src.limb_status = null
//	src.updateDialog()
//	return

*/


/obj/machinery/body_scanconsole/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_hand(var/mob/living/user)
	if(..())
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!connected || (connected.machine_stat & (NOPOWER|BROKEN)))
		to_chat(user, "<span class='warning'>This console is not connected to a functioning body scanner.</span>")
		return
	if(!ishuman(connected.occupant))
		to_chat(user, "<span class='warning'>This device can only scan compatible lifeforms.</span>")
		return

	var/dat
	if (delete && temphtml) //Window in buffer but its just simple message, so nothing
		delete = delete
	else if (!delete && temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", temphtml, src)
	else
		if (connected) //Is something connected?
			var/mob/living/carbon/human/H = connected.occupant
			dat = med_scan(H, dat, known_implants)
		else
			dat = "<font color='red'> Error: No Body Scanner connected.</font>"

	dat += text("<BR><A href='?src=\ref[];mach_close=scanconsole'>Close</A>", user)

	var/datum/browser/popup = new(user, "scanconsole", "<div align='center'>Body Scanner Console</div>", 430, 600)
	popup.set_content(dat)
	popup.open(FALSE)


/obj/machinery/body_scanconsole/Topic(href, href_list)
	if (..())
		return

	if (href_list["print"])
		if (!src.connected)
			to_chat(usr, "[icon2html(src, usr)]<span class='warning'>Error: No body scanner connected.</span>")
			return
		var/mob/living/carbon/human/occupant = src.connected.occupant
		if (!src.connected.occupant)
			to_chat(usr, "[icon2html(src, usr)]<span class='warning'>The body scanner is empty.</span>")
			return
		if (!istype(occupant,/mob/living/carbon/human))
			to_chat(usr, "[icon2html(src, usr)]<span class='warning'>The body scanner cannot scan that lifeform.</span>")
			return
		var/obj/item/paper/R = new(src.loc)
		R.name = "Body scan report -[src.connected.occupant.real_name]-"
		R.info = format_occupant_data(src.connected.get_occupant_data())

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
