/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/computer/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	screen_overlay = "sleeperconsole_emissive"
	dir = EAST
	density = FALSE
	idle_power_usage = 40
	///The connected sleeper
	var/obj/machinery/sleeper/connected = null

/obj/machinery/computer/sleep_console/Initialize(mapload)
	. = ..()
	set_connected(locate(/obj/machinery/sleeper, get_step(src, REVERSE_DIR(dir))))
	connected?.set_connected(src)

/obj/machinery/computer/sleep_console/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	updateUsrDialog()

/obj/machinery/computer/sleep_console/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)

///Set the connected var
/obj/machinery/computer/sleep_console/proc/set_connected(obj/future_connected)
	if(connected)
		UnregisterSignal(connected, COMSIG_QDELETING)
	connected = null
	if(future_connected)
		connected = future_connected
		RegisterSignal(connected, COMSIG_QDELETING, PROC_REF(clean_connected))

///Clean the connected var
/obj/machinery/computer/sleep_console/proc/clean_connected()
	SIGNAL_HANDLER
	set_connected(null)

/obj/machinery/computer/sleep_console/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat = ""
	if (!connected || (connected.machine_stat & (NOPOWER|BROKEN)))
		dat += "This console is not connected to a sleeper or the sleeper is non-functional."
	else
		var/mob/living/occupant = connected.occupant
		dat += "<font color='#487553'><B>Occupant Statistics:</B></FONT><BR>"
		if(occupant)
			var/t1
			dat += "<B>Name: [occupant.name]</B><BR>"
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "<font color='#487553'>Unconscious</font>"
				if(2)
					t1 = "<font color='#b54646'>*dead*</font>"
			var/health_ratio = occupant.health * 100 / occupant.maxHealth
			dat += "[health_ratio > 50 ? "<font color='#487553'>" : "<font color='#b54646'>"]\tHealth %: [health_ratio] ([t1])</FONT><BR>"
			if(ishuman(occupant))
				if(connected.filtering)
					dat += "<A href='?src=[text_ref(src)];togglefilter=1'>Stop Dialysis</A><BR>"
				else
					dat += "<HR><A href='?src=[text_ref(src)];togglefilter=1'>Start Dialysis</A><BR>"
				if(connected.stasis)
					dat += "<HR><A href='?src=[text_ref(src)];togglestasis=1'>Deactivate Cryostasis</A><BR><HR>"
				else
					dat += "<HR><A href='?src=[text_ref(src)];togglestasis=1'>Activate Cryostasis</A><BR><HR>"
			else
				dat += "<HR>Dialysis Disabled - Non-human present.<BR><HR>"
				var/mob/living/carbon/human/patient = occupant
				var/pulse = patient.handle_pulse()
				dat += "[pulse == PULSE_NONE || pulse == PULSE_THREADY ? "<font color='#b54646'>" : "<font color='#487553'>"]\t-Pulse, bpm: [patient.get_pulse(GETPULSE_TOOL)]</FONT><BR>"
			dat += "[occupant.getBruteLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Brute Damage %: [occupant.getBruteLoss()]</FONT><BR>"
			dat += "[occupant.getOxyLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Respiratory Damage %: [occupant.getOxyLoss()]</FONT><BR>"
			dat += "[occupant.getToxLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Toxin Content %: [occupant.getToxLoss()]</FONT><BR>"
			dat += "[occupant.getFireLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Burn Severity %: [occupant.getFireLoss()]</FONT><BR>"
			dat += "<HR>Knocked Out Summary %: [occupant.AmountUnconscious()] ([round(occupant.AmountUnconscious() * 0.1)] seconds left!)<BR>"
			for(var/chemical in connected.available_chemicals)
				dat += "<label style='width:180px; display: inline-block'>[connected.available_chemicals[chemical]] ([round(occupant.reagents.get_reagent_amount(chemical), 0.01)] units)</label> Inject:"
				for(var/amount in connected.amounts)
					dat += " <a href ='?src=[text_ref(src)];chemical=[chemical];amount=[amount]'>[amount] units</a>"
				dat += "<br>"
			dat += "<A href='?src=[text_ref(src)];refresh=1'>Refresh Meter Readings</A><BR>"
			dat += "<HR><A href='?src=[text_ref(src)];ejectify=1'>Eject Patient</A>"
		else
			dat += "The sleeper is empty."
	var/datum/browser/popup = new(user, "sleeper", "<div align='center'>Sleeper Console</div>", 400, 670)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/sleep_console/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["chemical"] && connected && connected.occupant)
		var/datum/reagent/R = text2path(href_list["chemical"])
		if(connected.occupant.stat == DEAD)
			to_chat(usr, span_warning("This person has no life for to preserve anymore."))
		else if(ismonkey(connected.occupant))
			to_chat(usr, span_scanner("Unknown biological subject detected, chemical injection not available. Please contact a licensed supplier for further assistance."))
		else if(!(R in connected.available_chemicals))
			message_admins("[ADMIN_TPMONTY(usr)] has tried to inject an invalid chem with the sleeper. Looks like an exploit attempt, or a bug.")
		else
			var/amount = text2num(href_list["amount"])
			if(amount == 5 || amount == 10)
				connected.inject_chemical(usr, R, amount)
	if (href_list["togglefilter"])
		connected.toggle_filter()
	if (href_list["togglestasis"])
		connected.toggle_stasis()
	if (href_list["ejectify"])
		connected.eject()

	updateUsrDialog()

/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "Sleeper"
	desc = "A fancy bed with built-in injectors, a dialysis machine, and a limited health scanner."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeper"
	density = TRUE
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	dir = EAST
	var/mob/living/carbon/human/occupant = null
	var/available_chemicals = list(/datum/reagent/medicine/inaprovaline = "Inaprovaline", /datum/reagent/toxin/sleeptoxin = "Soporific", /datum/reagent/medicine/paracetamol = "Paracetamol", /datum/reagent/medicine/bicaridine = "Bicaridine", /datum/reagent/medicine/kelotane = "Kelotane", /datum/reagent/medicine/dylovene = "Dylovene", /datum/reagent/medicine/dexalin = "Dexalin", /datum/reagent/medicine/tricordrazine = "Tricordrazine", /datum/reagent/medicine/spaceacillin = "Spaceacillin")
	var/amounts = list(5, 10)
	var/filtering = FALSE
	var/stasis = FALSE
	var/obj/machinery/computer/sleep_console/connected

	use_power = IDLE_POWER_USE
	idle_power_usage = 15
	active_power_usage = 200 //builtin health analyzer, dialysis machine, injectors.


/obj/machinery/sleeper/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(shuttle_crush))
	update_icon()

/obj/machinery/sleeper/proc/shuttle_crush()
	SIGNAL_HANDLER
	if(occupant)
		var/mob/living/carbon/human/H = occupant
		go_out()
		H.gib()

///Set the connected var
/obj/machinery/sleeper/proc/set_connected(obj/future_connected)
	if(connected)
		UnregisterSignal(connected, COMSIG_QDELETING)
	connected = null
	if(future_connected)
		connected = future_connected
		RegisterSignal(connected, COMSIG_QDELETING, PROC_REF(clean_connected))

///Clean the connected var
/obj/machinery/sleeper/proc/clean_connected()
	SIGNAL_HANDLER
	set_connected(null)

/obj/machinery/sleeper/Destroy()
	//clean up; end stasis; remove from processing
	if(occupant)
		REMOVE_TRAIT(occupant, TRAIT_STASIS, SLEEPER_TRAIT)
		go_out()
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
		. += span_notice("It contains: [occupant].[feedback]")
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (!R.fields["name"] == H.real_name)
			continue
		if(!(R.fields["last_scan_time"]))
			. += span_deptradio("No scan report on record")
		else
			. += span_deptradio("<a href='?src=[text_ref(src)];scanreport=1'>It contains [occupant]: Scan from [R.fields["last_scan_time"]].[feedback]</a>")
		break

/obj/machinery/sleeper/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (!href_list["scanreport"])
		return
	if(!hasHUD(usr,"medical"))
		return
	if(get_dist(usr, src) > 7)
		to_chat(usr, span_warning("[src] is too far away."))
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

/obj/machinery/sleeper/process()
	if (machine_stat & (NOPOWER|BROKEN))
		if(occupant)
			REMOVE_TRAIT(occupant, TRAIT_STASIS, SLEEPER_TRAIT)
		stasis = FALSE
		filtering = FALSE
		stop_processing() //Shut down; stasis off, filtering off, stop processing.
		return

	//Life support
	occupant?.adjustOxyLoss(-occupant.getOxyLoss()) // keep them breathing, pretend they get IV dexalinplus

	if(filtering)
		for(var/datum/reagent/x in occupant.reagents.reagent_list)
			occupant.reagents.remove_reagent(x.type, 10)


	updateUsrDialog()

/obj/machinery/sleeper/update_icon()
	. = ..()
	if((machine_stat & (BROKEN|DISABLED|NOPOWER)) || !occupant)
		set_light(0)
	else
		set_light(initial(light_range))

/obj/machinery/sleeper/update_icon_state()
	if(occupant)
		icon_state = "[initial(icon_state)]_occupied"
	else
		icon_state = initial(icon_state)

/obj/machinery/sleeper/update_overlays()
	. = ..()
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		return
	if(!occupant)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)
	. += mutable_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)

/obj/machinery/sleeper/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)
		return

	if(isxeno(user))
		return

	if(occupant)
		to_chat(user, span_notice("The sleeper is already occupied!"))
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
	occupant = M
	start_processing()
	connected.start_processing()
	update_icon()

/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
		if(EXPLODE_LIGHT)
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
	if(ismonkey(occupant))
		to_chat(usr, span_scanner("Unknown biological subject detected, dialysis not available. Please contact a licensed supplier for further assistance."))
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
		REMOVE_TRAIT(occupant, TRAIT_STASIS, SLEEPER_TRAIT)
		stasis = FALSE
	else
		ADD_TRAIT(occupant, TRAIT_STASIS, SLEEPER_TRAIT)
		stasis = TRUE

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!occupant)
		return
	if(occupant in contents)
		occupant.forceMove(loc)
	REMOVE_TRAIT(occupant, TRAIT_STASIS, SLEEPER_TRAIT)
	stasis = FALSE
	occupant = null
	stop_processing()
	connected.stop_processing()
	update_icon()


/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(occupant?.reagents)
		if(occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			occupant.reagents.add_reagent(chemical, amount)
			to_chat(user, span_notice("Occupant now has [occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream."))
			return
	to_chat(user, span_warning("There's no occupant in the sleeper or the subject has too many chemicals!"))


/obj/machinery/sleeper/proc/check(mob/living/user)
	if(occupant)
		to_chat(user, span_boldnotice("Occupant ([occupant]) Statistics:"))
		var/t1
		switch(occupant.stat)
			if(0)
				t1 = "Conscious"
			if(1)
				t1 = "Unconscious"
			if(2)
				t1 = "*dead*"
			else
		var/health_ratio = occupant.health * 100 / occupant.maxHealth
		to_chat(user, "[health_ratio > 50 ? "<font color='#487553'> " : "<font color='#b54646'> "]\t Health %: [health_ratio] ([t1])</font>")
		to_chat(user, "[occupant.bodytemperature > 50 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t -Core Temperature: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)</FONT><BR>")
		to_chat(user, "[occupant.getBruteLoss() < 60 ? "<font color='#487553'> " : "<font class='#b54646'> "]\t -Brute Damage %: [occupant.getBruteLoss()]</font>")
		to_chat(user, "[occupant.getOxyLoss() < 60 ? "<span color='#487553'> " : "<font color='#b54646'> "]\t -Respiratory Damage %: [occupant.getOxyLoss()]</font>")
		to_chat(user, "[occupant.getToxLoss() < 60 ? "<font color='#487553'> " : "<font color='#b54646'> "]\t -Toxin Content %: [occupant.getToxLoss()]</font>")
		to_chat(user, "[occupant.getFireLoss() < 60 ? "<font color='#487553'> " : "<font color='#b54646'> "]\t -Burn Severity %: [occupant.getFireLoss()]</font>")
		to_chat(user, span_notice("Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)"))
		to_chat(user, span_notice("\t [occupant.AmountUnconscious() * 0.1] second\s (if around 1 or 2 the sleeper is keeping them asleep.)"))
	else
		to_chat(user, span_notice("There is no one inside!"))

/obj/machinery/sleeper/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
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

/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != CONSCIOUS)
		return

	go_out()

/obj/machinery/sleeper/relaymove(mob/user)
	if(user.incapacitated(TRUE))
		return
	go_out()

/obj/machinery/sleeper/proc/move_inside_wrapper(mob/living/target, mob/user)
	if(!ishuman(target) || !ishuman(user) || user.incapacitated(TRUE))
		return

	if(occupant)
		to_chat(user, span_notice("The sleeper is already occupied!"))
		return

	if(ismob(target.pulledby))
		var/mob/grabmob = target.pulledby
		grabmob.stop_pulling()
	target.stop_pulling()

	if(!target.forceMove(src))
		return

	visible_message("[target] climbs into the sleeper.", null, null, 3)
	occupant = target

	start_processing()
	connected.start_processing()
	update_icon()

	for(var/obj/O in src)
		qdel(O)

/obj/machinery/sleeper/MouseDrop_T(mob/M, mob/user)
	. = ..()
	move_inside_wrapper(M, user)

/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)

	move_inside_wrapper(usr, usr)
