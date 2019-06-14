/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = TRUE //About time someone fixed this.
	density = 0
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"

	use_power = 1
	idle_power_usage = 40

/obj/machinery/sleep_console/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	updateUsrDialog()
	return

/obj/machinery/sleep_console/ex_act(severity)
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

/obj/machinery/sleep_console/Initialize()
	. = ..()
	if(orient == "RIGHT")
		icon_state = "sleeperconsole-r"
		connected = locate(/obj/machinery/sleeper, get_step(src, EAST))
		connected.connected = src
	else
		connected = locate(/obj/machinery/sleeper, get_step(src, WEST))
		connected.connected = src

/obj/machinery/sleep_console/attack_ai(mob/living/user)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_paw(mob/living/user)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/living/user)
	if(..())
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	var/dat = ""
	if (!connected || (connected.machine_stat & (NOPOWER|BROKEN)))
		dat += "This console is not connected to a sleeper or the sleeper is non-functional."
	else
		var/mob/living/occupant = connected.occupant
		dat += "<font color='#487553'><B>Occupant Statistics:</B></FONT><BR>"
		if (occupant)
			var/t1
			dat += text("<B>Name: [occupant.name]</B><BR>")
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "<font color='#487553'>Unconscious</font>"
				if(2)
					t1 = "<font color='#b54646'>*dead*</font>"
				else
			dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='#487553'>" : "<font color='#b54646'>"), occupant.health, t1)
			if(iscarbon(occupant))
				var/mob/living/carbon/C = occupant
				dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='#b54646'>" : "<font color='#487553'>"), C.get_pulse(GETPULSE_TOOL))
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"), occupant.getBruteLoss())
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"), occupant.getOxyLoss())
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"), occupant.getToxLoss())
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"), occupant.getFireLoss())
			dat += text("<HR>Knocked Out Summary %: [] ([] seconds left!)<BR>", occupant.knocked_out, round(occupant.knocked_out / 4))
			for(var/chemical in connected.available_chemicals)
				dat += "<label style='width:180px; display: inline-block'>[connected.available_chemicals[chemical]] ([round(occupant.reagents.get_reagent_amount(chemical), 0.01)] units)</label> Inject:"
				for(var/amount in connected.amounts)
					dat += " <a href ='?src=\ref[src];chemical=[chemical];amount=[amount]'>[amount] units</a>"
				dat += "<br>"
			dat += "<A href='?src=\ref[src];refresh=1'>Refresh Meter Readings</A><BR>"
			if(connected.beaker)
				dat += "<HR><A href='?src=\ref[src];removebeaker=1'>Remove Beaker</A><BR>"
				if(ishuman(occupant))
					if(connected.filtering)
						dat += "<A href='?src=\ref[src];togglefilter=1'>Stop Dialysis</A><BR>"
						dat += "Output Beaker has [connected.beaker.reagents.maximum_volume - connected.beaker.reagents.total_volume] units of free space remaining<BR><HR>"
					else
						dat += "<HR><A href='?src=\ref[src];togglefilter=1'>Start Dialysis</A><BR>"
						dat += "Output Beaker has [connected.beaker.reagents.maximum_volume - connected.beaker.reagents.total_volume] units of free space remaining<BR><HR>"
					if(connected.stasis)
						dat += "<HR><A href='?src=\ref[src];togglestasis=1'>Deactivate Cryostasis</A><BR><HR>"
					else
						dat += "<HR><A href='?src=\ref[src];togglestasis=1'>Activate Cryostasis</A><BR><HR>"
				else
					dat += "<HR>Dialysis Disabled - Non-human present.<BR><HR>"

			else
				dat += "<HR>No Dialysis Output Beaker is present.<BR><HR>"
			dat += "<HR><A href='?src=\ref[src];ejectify=1'>Eject Patient</A>"
		else
			dat += "The sleeper is empty."
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)

	var/datum/browser/popup = new(user, "sleeper", "<div align='center'>Sleeper Console</div>", 400, 670)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "sleeper")


/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return FALSE
	if(!usr)
		return FALSE
	if(usr.incapacitated() || !usr.IsAdvancedToolUser())
		return FALSE
	var/mob/living/carbon/human/user = usr
	if(get_dist(src, user) > 1)
		return FALSE
	user.set_interaction(src)
	if(href_list["chemical"] && connected && connected.occupant)
		if (connected.occupant.stat == DEAD)
			to_chat(usr, "<span class='warning'>This person has no life for to preserve anymore.</span>")
		else if(!(href_list["chemical"] in connected.available_chemicals))
			message_admins("[ADMIN_TPMONTY(usr)] has tried to inject an invalid chem with the sleeper. Looks like an exploit attempt, or a bug.")
		else
			var/amount = text2num(href_list["amount"])
			if(amount == 5 || amount == 10)
				connected.inject_chemical(user,href_list["chemical"],amount)
	if (href_list["removebeaker"])
		connected.remove_beaker()
	if (href_list["togglefilter"])
		connected.toggle_filter()
	if (href_list["togglestasis"])
		connected.toggle_stasis()
	if (href_list["ejectify"])
		connected.eject()
	attack_hand(user)
	return









/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "Sleeper"
	desc = "A fancy bed with built-in injectors, a dialysis machine, and a limited health scanner."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeper_0"
	density = TRUE
	anchored = TRUE
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/carbon/human/occupant = null
	var/available_chemicals = list("inaprovaline" = "Inaprovaline", "sleeptoxin" = "Soporific", "paracetamol" = "Paracetamol", "bicaridine" = "Bicaridine", "kelotane" = "Kelotane", "dylovene" = "Dylovene", "dexalin" = "Dexalin", "tricordrazine" = "Tricordrazine", "spaceacillin" = "Spaceacillin")
	var/amounts = list(5, 10)
	var/obj/item/reagent_container/glass/beaker = null
	var/filtering = FALSE
	var/stasis = FALSE
	var/obj/machinery/sleep_console/connected

	use_power = 1
	idle_power_usage = 15
	active_power_usage = 200 //builtin health analyzer, dialysis machine, injectors.


/obj/machinery/sleeper/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_container/glass/beaker/large()
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
		
/obj/machinery/sleeper/Destroy()
	occupant?.in_stasis = FALSE //clean up; end stasis; remove from processing
	occupant = null
	STOP_PROCESSING(SSobj, src)
	stop_processing()
	return ..()

/obj/machinery/sleeper/examine(mob/living/user)
	. = ..()
	if(!occupant) //Allows us to reference medical files/scan reports for cryo via examination.
		return
	if(!ishuman(occupant))
		return
	var/feedback = ""
	if(stasis)
		feedback += " Cryostasis is active."
	if(filtering)
		feedback += " Dialysis is active."
	if(!hasHUD(user,"medical"))
		to_chat(user, "<span class='notice'>It contains: [occupant].[feedback]</span>")
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (!R.fields["name"] == H.real_name)
			continue
		if(!(R.fields["last_scan_time"]))
			to_chat(user, "<span class = 'deptradio'>No scan report on record</span>\n")
		else
			to_chat(user, "<span class = 'deptradio'><a href='?src=\ref[src];scanreport=1'>It contains [occupant]: Scan from [R.fields["last_scan_time"]].[feedback]</a></span>\n")
		break

/obj/machinery/sleeper/Topic(href, href_list)
	if (!href_list["scanreport"])
		return
	if(!hasHUD(usr,"medical"))
		return
	if(get_dist(usr, src) > 7)
		to_chat(usr, "<span class='warning'>[src] is too far away.</span>")
		return
	if(!ishuman(occupant))
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (!R.fields["name"] == H.real_name)
			continue
		if(R.fields["last_scan_time"] && R.fields["last_scan_result"])
			var/datum/browser/popup = new(usr, "scanresults", "<div align='center'>Last Scan Result</div>", 430, 600)
			popup.set_content(R.fields["last_scan_result"])
			popup.open(FALSE)
		break


/obj/machinery/sleeper/on_stored_atom_del(atom/movable/AM)
	if(AM == beaker)
		beaker = null

/obj/machinery/sleeper/process()
	if (machine_stat & (NOPOWER|BROKEN))
		if(occupant)
			occupant.in_stasis = null
		stasis = FALSE
		filtering = FALSE
		stop_processing() //Shut down; stasis off, filtering off, stop processing.
		return

	//Life support
	occupant?.adjustOxyLoss(-occupant.getOxyLoss()) // keep them breathing, pretend they get IV dexalinplus

	if(filtering)
		if(beaker)
			if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
				for(var/datum/reagent/x in occupant.reagents.reagent_list)
					occupant.reagents.trans_to(beaker, 10)


	updateUsrDialog()


/obj/machinery/sleeper/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_container/glass))
		if(beaker)
			to_chat(user, "<span class='warning'>The sleeper has a beaker already.</span>")
			return

		if(!user.transferItemToLoc(I, src))
			return

		beaker = I
		user.visible_message("[user] adds \a [I] to \the [src]!", "You add \a [I] to \the [src]!")
		updateUsrDialog()
		return

	if(istype(I, /obj/item/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)
		return

	if(isxeno(user))
		return

	if(occupant)
		to_chat(user, "<span class='notice'>The sleeper is already occupied!</span>")
		return


	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I
	if(!ismob(G.grabbed_thing))
		return

	var/mob/M = G.grabbed_thing
	if(!M.forceMove(src))
		return

	visible_message("[user] puts [M] into the sleeper.", 3)
	update_use_power(2)
	occupant = M
	start_processing()
	connected.start_processing()

	if(orient == "RIGHT")
		icon_state = "sleeper_1-r"
	else
		icon_state = "sleeper_1"


/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(25))
				qdel(src)


/obj/machinery/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()
	if(stasis)
		toggle_stasis()
	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..()

/obj/machinery/sleeper/proc/toggle_filter()
	if(!occupant)
		filtering = 0
		return
	if(filtering)
		filtering = FALSE
	else
		filtering = TRUE

/obj/machinery/sleeper/proc/toggle_stasis()
	if(!occupant)
		stasis = FALSE
		return
	if(stasis)
		occupant.in_stasis = null
		stasis = FALSE
	else
		occupant.in_stasis = STASIS_IN_BAG
		stasis = TRUE

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!occupant)
		return
	if(occupant in contents)
		occupant.forceMove(loc)
	occupant.in_stasis = null //disable stasis
	stasis = FALSE
	occupant = null
	stop_processing()
	connected.stop_processing()
	update_use_power(1)
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	return


/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			occupant.reagents.add_reagent(chemical, amount)
			to_chat(user, "<span class='notice'>Occupant now has [occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream.</span>")
			return
	to_chat(user, "<span class='warning'>There's no occupant in the sleeper or the subject has too many chemicals!</span>")
	return


/obj/machinery/sleeper/proc/check(mob/living/user)
	if(occupant)
		to_chat(user, text("<span class='boldnotice'>Occupant ([]) Statistics:</span>", occupant))
		var/t1
		switch(occupant.stat)
			if(0)
				t1 = "Conscious"
			if(1)
				t1 = "Unconscious"
			if(2)
				t1 = "*dead*"
			else
		to_chat(user, text("[]\t Health %: [] ([])</font>", (occupant.health > 50 ? "<font color='#487553'> " : "<font color='#b54646'> "), occupant.health, t1))
		to_chat(user, text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (occupant.bodytemperature > 50 ? "<font color='#487553'>" : "<font color='#b54646'>"), occupant.bodytemperature-T0C, occupant.bodytemperature*1.8-459.67))
		to_chat(user, text("[]\t -Brute Damage %: []</font>", (occupant.getBruteLoss() < 60 ? "<font color='#487553'> " : "<font class='#b54646'> "), occupant.getBruteLoss()))
		to_chat(user, text("[]\t -Respiratory Damage %: []</font>", (occupant.getOxyLoss() < 60 ? "<span color='#487553'> " : "<font color='#b54646'> "), occupant.getOxyLoss()))
		to_chat(user, text("[]\t -Toxin Content %: []</font>", (occupant.getToxLoss() < 60 ? "<font color='#487553'> " : "<font color='#b54646'> "), occupant.getToxLoss()))
		to_chat(user, text("[]\t -Burn Severity %: []</font>", (occupant.getFireLoss() < 60 ? "<font color='#487553'> " : "<font color='#b54646'> "), occupant.getFireLoss()))
		to_chat(user, "<span class='notice'>Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)</span>")
		to_chat(user, "<span class='notice'>\t [occupant.knocked_out / 5] second\s (if around 1 or 2 the sleeper is keeping them asleep.)</span>")
		if(beaker)
			to_chat(user, "<span class='notice'>\t Dialysis Output Beaker has [beaker.reagents.maximum_volume - beaker.reagents.total_volume] of free space remaining.</span>")
		else
			to_chat(user, "<span class='notice'>No Dialysis Output Beaker loaded.</span>")
	else
		to_chat(user, "<span class='notice'>There is no one inside!</span>")
	return


/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	icon_state = "sleeper_0"
	go_out()


/obj/machinery/sleeper/verb/remove_beaker()
	set name = "Remove Beaker"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(beaker)
		filtering = FALSE
		beaker.loc = usr.loc
		beaker = null


/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr

	if(occupant)
		to_chat(user, "<span class='notice'>The sleeper is already occupied!</span>")
		return

	if(ismob(user.pulledby))
		var/mob/grabmob = user.pulledby
		grabmob.stop_pulling()
	user.stop_pulling()
	if(!user.forceMove(src))
		return
	visible_message("[user] climbs into the sleeper.", 3)
	update_use_power(2)
	occupant = usr
	start_processing()
	connected.start_processing()
	icon_state = "sleeper_1"
	if(orient == "RIGHT")
		icon_state = "sleeper_1-r"

	for(var/obj/O in src)
		qdel(O)
