/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = TRUE //About time someone fixed this.
	density = FALSE
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"

	use_power = IDLE_POWER_USE
	idle_power_usage = 40

/obj/machinery/sleep_console/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return

/obj/machinery/sleep_console/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)


/obj/machinery/sleep_console/Initialize()
	. = ..()
	if(orient == "RIGHT")
		icon_state = "sleeperconsole-r"
		set_connected(locate(/obj/machinery/sleeper, get_step(src, EAST)))
	else
		set_connected(locate(/obj/machinery/sleeper, get_step(src, WEST)))
	connected?.set_connected(src)

///Set the connected var
/obj/machinery/sleep_console/proc/set_connected(obj/future_connected)
	if(connected)
		UnregisterSignal(connected, COMSIG_PARENT_QDELETING)
	connected = null
	if(future_connected)
		connected = future_connected
		RegisterSignal(connected, COMSIG_PARENT_QDELETING, PROC_REF(clean_connected))

///Clean the connected var
/obj/machinery/sleep_console/proc/clean_connected()
	SIGNAL_HANDLER
	set_connected(null)

/obj/machinery/sleep_console/interact(mob/user)
	. = ..()
	if(.)
		return
	if (!connected || (connected.machine_stat & (NOPOWER|BROKEN)))
		to_chat(user, span_notice("This console is not connected to a sleeper or the sleeper is non-functional."))
	else
		ui_interact(user)

/obj/machinery/sleep_console/ui_data(mob/user)
	var/list/data = list()
	data["hasOccupant"] = connected.occupant ? TRUE : FALSE

	data["occupant"] = list()
	if(connected.occupant)
		var/mob/living/mob_occupant = connected.occupant
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(UNCONSCIOUS)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = round(mob_occupant.health, 1)
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = mob_occupant.health_threshold_dead
		data["occupant"]["bruteLoss"] = round(mob_occupant.getBruteLoss(), 1)
		data["occupant"]["oxyLoss"] = round(mob_occupant.getOxyLoss(), 1)
		data["occupant"]["toxLoss"] = round(mob_occupant.getToxLoss(), 1)
		data["occupant"]["fireLoss"] = round(mob_occupant.getFireLoss(), 1)
		data["occupant"]["bodyTemperature"] = round(mob_occupant.bodytemperature, 1)
		if(abs(mob_occupant.bodytemperature - 310) <= 20)
			data["occupant"]["temperaturestatus"] = "good"
		else if(abs(mob_occupant.bodytemperature - 310) <= 50)
			data["occupant"]["temperaturestatus"] = "average"
		else
			data["occupant"]["temperaturestatus"] = "bad"

		var/list/chemicals = list()
		for(var/chemical in connected.available_chemicals)
			var/datum/reagent/temp = GLOB.chemical_reagents_list[chemical]
			var/reagent_amount = 0

			if(mob_occupant.reagents)
				reagent_amount = round(mob_occupant.reagents.get_reagent_amount(chemical), 0.01)

			chemicals.Add(list(list("title" = connected.available_chemicals[chemical], "path" = chemical, "amount" = reagent_amount, "threshold" = temp.overdose_threshold)))

		data["chemicals"] = chemicals
		data["amounts"] = connected.amounts
		data["stasis"] = connected.stasis
		data["filter"] = connected.filtering

	return data

/obj/machinery/sleep_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Sleeper", name)
		ui.open()

/obj/machinery/sleep_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("inject")
			if(connected && connected.occupant)
				var/datum/reagent/R = text2path(params["chempath"])
				if(connected.occupant.stat == DEAD)
					to_chat(usr, span_warning("This person has no life for to preserve anymore."))
				else if(ismonkey(connected.occupant))
					to_chat(usr, span_scanner("Unknown biological subject detected, chemical injection not available. Please contact a licensed supplier for further assistance."))
				else if(!(R in connected.available_chemicals))
					message_admins("[ADMIN_TPMONTY(usr)] has tried to inject an invalid chem with the sleeper. Looks like an exploit attempt, or a bug.")
				else
					var/amount = text2num(params["amount"])
					if(amount == 5 || amount == 10)
						connected.inject_chemical(usr, R, amount)
		if("toggle_filter")
			connected.toggle_filter()
		if("toggle_stasis")
			connected.toggle_stasis()
		if("eject")
			connected.go_out()










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
	var/mob/living/carbon/human/occupant
	var/available_chemicals = list(/datum/reagent/medicine/inaprovaline = "Inaprovaline", /datum/reagent/toxin/sleeptoxin = "Soporific", /datum/reagent/medicine/paracetamol = "Paracetamol", /datum/reagent/medicine/bicaridine = "Bicaridine", /datum/reagent/medicine/kelotane = "Kelotane", /datum/reagent/medicine/dylovene = "Dylovene", /datum/reagent/medicine/dexalin = "Dexalin", /datum/reagent/medicine/tricordrazine = "Tricordrazine", /datum/reagent/medicine/spaceacillin = "Spaceacillin")
	var/amounts = list(5, 10)
	var/filtering = FALSE
	var/stasis = FALSE
	var/obj/machinery/sleep_console/connected

	use_power = IDLE_POWER_USE
	idle_power_usage = 15
	active_power_usage = 200 //builtin health analyzer, dialysis machine, injectors.


/obj/machinery/sleeper/Initialize()
	. = ..()
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(shuttle_crush))

/obj/machinery/sleeper/proc/shuttle_crush()
	SIGNAL_HANDLER
	if(occupant)
		var/mob/living/carbon/human/H = occupant
		go_out()
		H.gib()

///Set the connected var
/obj/machinery/sleeper/proc/set_connected(obj/future_connected)
	if(connected)
		UnregisterSignal(connected, COMSIG_PARENT_QDELETING)
	connected = null
	if(future_connected)
		connected = future_connected
		RegisterSignal(connected, COMSIG_PARENT_QDELETING, PROC_REF(clean_connected))

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
			. += span_deptradio("<a href='?src=\ref[src];scanreport=1'>It contains [occupant]: Scan from [R.fields["last_scan_time"]].[feedback]</a>")
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
	move_inside_wrapper(M, user)

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
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	else
		icon_state = "sleeper_0"


/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			occupant.reagents.add_reagent(chemical, amount)
			to_chat(user, span_notice("Occupant now has [occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream."))
			return
	to_chat(user, span_warning("There's no occupant in the sleeper or the subject has too many chemicals!"))

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

/obj/machinery/sleeper/proc/move_inside_wrapper(mob/living/M, mob/user)
	if(M.stat == DEAD || !ishuman(M))
		return

	if(occupant)
		to_chat(user, span_notice("The sleeper is already occupied!"))
		return

	if(ismob(M.pulledby))
		var/mob/grabmob = M.pulledby
		grabmob.stop_pulling()
	M.stop_pulling()

	if(!M.forceMove(src))
		return

	if(user != M)
		visible_message("[user] puts [M] into the sleeper.", 3)
	else
		visible_message("[M] climbs into the sleeper.", 3)

	occupant = M

	start_processing()
	connected.start_processing()

	icon_state = "sleeper_1"
	if(orient == "RIGHT")
		icon_state = "sleeper_1-r"

	for(var/obj/O in src)
		qdel(O)

/obj/machinery/sleeper/MouseDrop_T(mob/M, mob/user)
	if(!isliving(M) || !ishuman(user))
		return
	move_inside_wrapper(M, user)

/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)

	move_inside_wrapper(usr, usr)
