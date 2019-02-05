//// Research Stuff ////
/obj/machinery/alien_container
	name = "Speciemen Analyze Chamber"
	desc = "Standart pressure chamber for all your biology needs"
	icon = 'icons/Marine/Research/Research_Machinery.dmi'
	icon_state = "analyzer_chamber"
	var/mob/living/carbon/Xenomorph/occupant = null
	var/obj/machinery/computer/analyze_console/linked_console = null

	use_power = TRUE
	idle_power_usage = 20
	active_power_usage = 200

/obj/machinery/alien_container/update_icon()
	if(occupant)
		icon_state = "analyzer_chamber_full"
		return
	icon_state = "analyzer_chamber"

/obj/machinery/alien_container/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(!ismob(G.grabbed_thing))
			return
		var/mob/M = G.grabbed_thing
		if(isXeno(M))
			put_mob(M)
	return

/obj/machinery/alien_container/proc/put_mob(mob/living/carbon/M as mob)
	if (stat & (NOPOWER|BROKEN))
		to_chat(usr, "<span class='notice'>The chamber is not functioning.</span>")
		return
	if (!istype(M))
		to_chat(usr, "<span class='warning'><B>The chamber cannot handle such a lifeform!</B></span>")
		return
	if (!isXeno(M))
		to_chat(usr, "<span class='warning'><B>You feel stupid...</B></span>")
		return
	if (occupant)
		to_chat(usr, "<span class='warning'>The chamber is already occupied!</B></span>")
		return
	if (M.abiotic())
		to_chat(usr, "<span class='warning'> Subject may not have abiotic items on.</span>")
		return
	M.forceMove(src)
	occupant = M
	update_use_power(2)
//	M.metabslow = 1
	add_fingerprint(usr)
	update_icon()
	return TRUE

/obj/machinery/alien_container/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set waitfor = FALSE
	set src in oview(1)

	if(usr == occupant)//If the user is inside the tube...
		to_chat(usr, "<span class='notice'> Release sequence activated. This will take two minutes.</span>")
		sleep(1200)
		if(!src || !usr || !occupant || (occupant != usr)) //Check if someone's released/replaced/bombed him already
			return
		go_out()//and release him from the eternal prison.
	else
		go_out()
	add_fingerprint(usr)
	update_icon()
	return

/obj/machinery/alien_container/proc/go_out()
	occupant.forceMove(loc)
	occupant = null



/*
///// Speciemen Analyze Console /////

If chamber connected to the console, you can start research aliens. Just don't butcher them before.
*/

/obj/machinery/computer/analyze_console
	name = "Speciemen Analyze Console"
	icon = 'icons/Marine/Research/Research_Machinery.dmi'
	icon_state = "sensor_comp"
	circuit = /obj/item/circuitboard/machine/analyze_console

	var/obj/machinery/alien_container/linked_chamber = null
	var/screen = 1.0
	var/errored = FALSE
	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/machinery/computer/analyze_console/update_icon()
	if(stat & NOPOWER)
		icon_state = "sensor_comp_off"
		return
	if(stat & BROKEN)
		icon_state = "sensor_comp_b"
		return
	icon_state = "sensor_comp"

/obj/machinery/computer/analyze_console/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any). Derived from rdconsole.dm
	if(linked_chamber != null)
		return
	for(var/obj/machinery/alien_container/D in oview(3,src))
		if(D.linked_console != null)
			continue
		linked_chamber = D
		D.linked_console = src
		screen = 1.3
		updateUsrDialog()
		return
	screen = 1.3
	updateUsrDialog()
	return

/obj/machinery/computer/analyze_console/proc/harvest()
	screen = 1.0
	if(isXenoCrusher(linked_chamber.occupant))
		new /obj/item/marineResearch/xenomorph/chitin/crusher(linked_chamber.loc)
	else
		new /obj/item/marineResearch/xenomorph/chitin(linked_chamber.loc)

	new /obj/item/marineResearch/xenomorph/muscle(linked_chamber.loc)

	switch(linked_chamber.occupant.caste_base_type)

		if(/mob/living/carbon/Xenomorph/Warrior)
			new /obj/item/marineResearch/xenomorph/muscle(linked_chamber.loc)

		if(/mob/living/carbon/Xenomorph/Ravager)
			new /obj/item/marineResearch/xenomorph/muscle(linked_chamber.loc)

		if(/mob/living/carbon/Xenomorph/Drone)
			new /obj/item/marineResearch/xenomorph/secretor(linked_chamber.loc)

		if(/mob/living/carbon/Xenomorph/Sentinel)
			new /obj/item/marineResearch/xenomorph/acid_gland(linked_chamber.loc)

		if(/mob/living/carbon/Xenomorph/Spitter)
			new /obj/item/marineResearch/xenomorph/acid_gland/spitter(linked_chamber.loc)

		if(/mob/living/carbon/Xenomorph/Hivelord)
			new /obj/item/marineResearch/xenomorph/secretor(linked_chamber.loc)
			new /obj/item/marineResearch/xenomorph/secretor/hivelord(linked_chamber.loc)
			new /obj/item/marineResearch/xenomorph/secretor/hivelord(linked_chamber.loc)

		if(/mob/living/carbon/Xenomorph/Queen)
			new /obj/item/marineResearch/xenomorph/acid_gland/spitter(linked_chamber.loc)
			new /obj/item/marineResearch/xenomorph/secretor(linked_chamber.loc)
			new /obj/item/marineResearch/xenomorph/secretor/hivelord(linked_chamber.loc)
			new /obj/item/marineResearch/xenomorph/core(linked_chamber.loc)

	updateUsrDialog()

/obj/machinery/computer/analyze_console/Topic(href, href_list)				//Brutally teared from rdconsole.dm
	if(..())
		return

	add_fingerprint(usr)

	usr.set_interaction(src)
	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		if(temp_screen <= 1.0 || src.allowed(usr) || emagged) //Unless you are making something, you need access.
			screen = temp_screen
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		screen = 0.0
		addtimer(CALLBACK(src, .proc/SyncRDevices), 20)

	else if(href_list["harvest"])
		if(!linked_chamber)
			updateUsrDialog()
		else
			if(!linked_chamber.occupant)
				return
			if(linked_chamber.occupant.autopsied == TRUE)
				return
			linked_chamber.occupant.autopsied = TRUE
			screen = 0.3
			addtimer(CALLBACK(src, .proc/harvest), 300)

	updateUsrDialog()

/obj/machinery/computer/analyze_console/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	user.set_interaction(src)
	var/dat = ""
	switch(screen) //A quick check to make sure you get the right screen when a device is disconnected.
		if(2 to 2.9)
			if(linked_chamber == null)
				screen = 2.0
			else if(linked_chamber.occupant == null)
				screen = 2.1
			else if(linked_chamber.occupant.autopsied == TRUE)
				screen = 2.3
			else
				screen = 2.2

	switch(screen)

		if(0.0)
			dat += "Establishing linkage with nearby chamber"

		if(0.1)
			dat += "Scanning in progress."

		if(0.2)
			dat += "SYSTEM LOCKED<BR><BR>"
			dat += "<A href='?src=\ref[src];lock=1.2'>Unlock</A>"

		if(0.3)
			dat += "Harvesting...<BR><BR>"

		if(1.0)
			dat += "Main Menu:<BR><BR>"
			if(linked_chamber != null) dat += "<A href='?src=\ref[src];menu=2.2'>Analyze Chamber Menu</A><BR>"
			else dat += "NO CHAMBER LINKED<BR>"
			dat += "<HR><A href='?src=\ref[src];menu=1.2'>Settings</A>"

		if(1.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "R&D Console Setting:<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.3'>Device Linkage Menu</A><BR>"
			dat += "<A href='?src=\ref[src];lock=0.2'>Lock Console</A><BR>"

		if(1.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || <A href='?src=\ref[src];menu=1.2'>Settings</A><HR>"
			dat += "<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Chamber</A><BR>"
			dat += "Chamber status: "
			if(linked_chamber)
				if(linked_chamber.occupant)
					dat += " OCCUPIED<BR>"
				else
					dat += " LINKED <A href='?src=\ref[src];disconnect=chamber'>(Disconnect)</A><BR>"
			else
				dat += " NOT FOUND<BR>"

		if(2.0)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "CHAMBER NOT LINKED<HR>"

		if(2.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "CHAMBER IS EMPTY"

		if(2.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "[linked_chamber.occupant.name]: <A href='?src=\ref[src];harvest=1'>Harvest Organs</A><BR>"
		if(2.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "ERROR! Speciemen internal injures is too severe. Suspected organ removal."

	user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
	onclose(user, "rdconsole")