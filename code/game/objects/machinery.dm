/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	layer = BELOW_OBJ_LAYER
	verb_say = "beeps"
	verb_yell = "blares"
	anchored = TRUE
	destroy_sound = 'sound/effects/metal_crash.ogg'
	interaction_flags = INTERACT_MACHINE_DEFAULT

	var/machine_stat = NONE
	var/use_power = IDLE_POWER_USE
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/machine_current_charge = 0 //Does it have an integrated, unremovable capacitor? Normally 10k if so.
	var/machine_max_charge = 0
	var/power_channel = EQUIP
	var/list/component_parts //list of all the parts used to build it, if made from certain kinds of frames.

	var/wrenchable = FALSE
	var/obj/item/circuitboard/circuit // Circuit to be created and inserted when the machinery is created
	var/mob/living/carbon/human/operator

	///Whether bullets can bypass the object even though it's dense
	throwpass = TRUE

/obj/machinery/Initialize()
	. = ..()
	GLOB.machines += src
	component_parts = list()
	var/turf/current_turf = get_turf(src)
	if(anchored && current_turf && density)
		current_turf.flags_atom |= AI_BLOCKED


/obj/machinery/Destroy()
	GLOB.machines -= src
	STOP_PROCESSING(SSmachines, src)
	if(istype(circuit)) //There are some uninitialized legacy path circuits.
		QDEL_NULL(circuit)
	operator = null
	var/turf/current_turf = get_turf(src)
	if(anchored && current_turf && density)
		current_turf.flags_atom &= ~ AI_BLOCKED
	return ..()


/obj/machinery/proc/is_operational()
	return !(machine_stat & (NOPOWER|BROKEN|MAINT|DISABLED))


/obj/machinery/proc/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel = 0, custom_deconstruct = FALSE)
	. = !(flags_atom & NODECONSTRUCT) && crowbar.tool_behaviour == TOOL_CROWBAR
	if(!. || custom_deconstruct)
		return
	crowbar.play_tool_sound(src, 50)
	deconstruct(TRUE)

/obj/machinery/deconstruct(disassembled = TRUE)
	if(!(flags_atom & NODECONSTRUCT))
		on_deconstruction()
		if(length(component_parts))
			spawn_frame(disassembled)
			for(var/i in component_parts)
				var/obj/item/I = i
				I.forceMove(loc)
			component_parts.Cut()
	return ..()


/obj/machinery/proc/spawn_frame(disassembled)
	var/obj/machinery/constructable_frame/machine_frame/M = new(loc)
	. = M
	M.setAnchored(anchored)
	if(!disassembled)
		M.take_damage(M.max_integrity * 0.5) //the frame is already half broken
	M.state = 2
	M.icon_state = "box_1"


/obj/machinery/setAnchored(anchorvalue)
	. = ..()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MACHINERY_ANCHORED_CHANGE, src, anchorvalue)


//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/on_construction()
	return


//called on deconstruction before the final deletion
/obj/machinery/proc/on_deconstruction()
	return


/obj/machinery/proc/start_processing()
	START_PROCESSING(SSmachines, src)


/obj/machinery/proc/stop_processing()
	STOP_PROCESSING(SSmachines, src)


/obj/machinery/process() // If you dont use process or power why are you here
	return PROCESS_KILL


/obj/machinery/emp_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return FALSE
	if(use_power && !machine_stat)
		use_power(7500 / severity)
	new /atom/movable/effect/overlay/temp/emp_sparks (loc)
	return ..()


/obj/machinery/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return FALSE
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(!prob(50))
				return
			qdel(src)
		if(EXPLODE_LIGHT)
			if(!prob(25))
				return
			qdel(src)


/obj/machinery/proc/power_change()
	if(!powered(power_channel) && machine_current_charge <= 0)
		machine_stat |= NOPOWER
	else
		machine_stat &= ~NOPOWER
	update_icon()


/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		if(use_power && machine_current_charge > idle_power_usage) //Does it have an integrated battery/reserve power to tap into?
			machine_current_charge -= min(machine_current_charge, idle_power_usage) //Sterilize with min; no negatives allowed.
			update_icon()
			return TRUE
		else if(machine_current_charge > active_power_usage)
			machine_current_charge -= min(machine_current_charge, active_power_usage)
			update_icon()
			return TRUE
		else
			return FALSE

	switch(use_power)
		if(IDLE_POWER_USE)
			if(machine_current_charge < machine_max_charge && anchored) //here we handle recharging the internal battery of machines
				var/power_usage = clamp(machine_max_charge - machine_current_charge, 0, 500)
				machine_current_charge += power_usage //recharge internal cell at max rate of 500
				use_power(power_usage, power_channel)
				update_icon()
			else
				use_power(idle_power_usage, power_channel)

		if(ACTIVE_POWER_USE)
			use_power(active_power_usage, power_channel)
	return TRUE


/obj/machinery/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!is_operational())
		return FALSE

	if(iscarbon(user) && (!in_range(src, user) || !isturf(loc)))
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			visible_message(span_warning("[H] stares cluelessly at [src] and drools."))
			return FALSE
		if(prob(H.getBrainLoss()))
			to_chat(user, span_warning("You momentarily forget how to use [src]."))
			return FALSE

	return TRUE


/obj/machinery/attack_ai(mob/living/silicon/ai/user)
	if(!is_operational())
		return FALSE
	if(!(interaction_flags & INTERACT_SILICON_ALLOWED))
		return FALSE
	return interact(user)


/obj/machinery/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return //Already handled.

	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN) && wires && wires.interact(user))
		return TRUE

	return interact(user)


/obj/machinery/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!can_interact(user))
		return

	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN) && wires && wires.interact(user))
		return TRUE

	return interact(user)


/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return


/obj/machinery/proc/shock(mob/user, prb)
	if(!is_operational())
		return FALSE

	if(!prob(prb))
		return FALSE

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()

	if(electrocute_mob(user, get_area(src), src, 0.7))
		return TRUE
	else
		return FALSE


/obj/machinery/proc/med_scan(mob/living/carbon/human/H, dat, list/known_implants)
	var/datum/data/record/N = null
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (R.fields["name"] == H.real_name)
			N = R
	if(isnull(N))
		N = create_medical_record(H)
	var/list/od = get_occupant_data(H)
	dat = format_occupant_data(od, H, known_implants)
	N.fields["last_scan_time"] = od["stationtime"]
	N.fields["last_scan_result"] = dat
	N.fields["autodoc_data"] = generate_autodoc_surgery_list(H)
	visible_message(span_notice("\The [src] pings as it stores the scan report of [H.real_name]"))
	playsound(loc, 'sound/machines/ping.ogg', 25, 1)
	use_power(active_power_usage)
	return dat


/obj/machinery/proc/get_occupant_data(mob/living/carbon/human/H)
	if (!H)
		return
	var/list/occupant_data = list(
		"stationtime" = worldtime2text(),
		"stat" = H.stat,
		"health" = H.health,
		"bruteloss" = H.getBruteLoss(),
		"fireloss" = H.getFireLoss(),
		"oxyloss" = H.getOxyLoss(),
		"toxloss" = H.getToxLoss(),
		"cloneloss" = H.getCloneLoss(),
		"brainloss" = H.getBrainLoss(),
		"knocked_out" = H.AmountUnconscious(),
		"bodytemp" = H.bodytemperature,
		"inaprovaline_amount" = H.reagents.get_reagent_amount(/datum/reagent/medicine/inaprovaline),
		"dexalin_amount" = H.reagents.get_reagent_amount(/datum/reagent/medicine/dexalin),
		"sleeptoxin_amount" = H.reagents.get_reagent_amount(/datum/reagent/toxin/sleeptoxin),
		"bicaridine_amount" = H.reagents.get_reagent_amount(/datum/reagent/medicine/bicaridine),
		"dermaline_amount" = H.reagents.get_reagent_amount(/datum/reagent/medicine/dermaline),
		"blood_amount" = H.blood_volume,
		"disabilities" = H.disabilities,
		"lung_ruptured" = H.is_lung_ruptured(),
		"external_organs" = H.limbs.Copy(),
		"internal_organs" = H.internal_organs.Copy(),
		"species_organs" = H.species.has_organ //Just pass a reference for this, it shouldn't ever be modified outside of the datum.
		)
	return occupant_data


/obj/machinery/proc/format_occupant_data(list/occ, mob/living/carbon/human/H, list/known_implants)
	var/dat = "<font color='#487553'><b>Scan performed at [occ["stationtime"]]</b></font><br>"
	dat += "<font color='#487553'><b>Occupant Statistics:</b></font><br>"
	var/aux
	switch (occ["stat"])
		if(0)
			aux = "Conscious"
		if(1)
			aux = "Unconscious"
		else
			aux = "Dead"
	dat += text("[]\tHealth %: [] ([])</font><br>", (occ["health"] > 50 ? "<font color=#487553>" : "<font color=#b54646>"), occ["health"], aux)
	if (occ["virus_present"])
		dat += "<font color=#b54646>Viral pathogen detected in blood stream.</font><br>"
	dat += text("[]\t-Brute Damage %: []</font><br>", (occ["bruteloss"] < 60 ? "<font color='#487553'>" : "<font color=#b54646>"), occ["bruteloss"])
	dat += text("[]\t-Respiratory Damage %: []</font><br>", (occ["oxyloss"] < 60 ? "<font color='#487553'>" : "<font color=#b54646>"), occ["oxyloss"])
	dat += text("[]\t-Toxin Content %: []</font><br>", (occ["toxloss"] < 60 ? "<font color='#487553'>" : "<font color=#b54646>"), occ["toxloss"])
	dat += text("[]\t-Burn Severity %: []</font><br><br>", (occ["fireloss"] < 60 ? "<font color='#487553'>" : "<font color=#b54646>"), occ["fireloss"])

	dat += text("[]\tRadiation Level %: []</font><br>", (occ["rads"] < 10 ?"<font color='#487553'>" : "<font color=#b54646>"), occ["rads"])
	dat += text("[]\tGenetic Tissue Damage %: []</font><br>", (occ["cloneloss"] < 1 ?"<font color=#487553>" : "<font color=#b54646>"), occ["cloneloss"])
	dat += text("[]\tApprox. Brain Damage %: []</font><br>", (occ["brainloss"] < 1 ?"<font color=#487553>" : "<font color=#b54646>"), occ["brainloss"])
	dat += text("Knocked Out Summary %: [] ([] seconds left!)<br>", occ["knocked_out"], round(occ["knocked_out"] * 0.1))
	dat += text("Body Temperature: [occ["bodytemp"]-T0C]&deg;C ([occ["bodytemp"]*1.8-459.67]&deg;F)<br><HR>")

	dat += text("[]\tBlood Level %: [] ([] units)</FONT><BR>", (occ["blood_amount"] > 448 ?"<font color=#487553>" : "<font color=#b54646>"), occ["blood_amount"]*100 / 560, occ["blood_amount"])

	dat += text("Inaprovaline: [] units<BR>", occ["inaprovaline_amount"])
	dat += text("Soporific: [] units<BR>", occ["sleeptoxin_amount"])
	dat += text("[]\tDermaline: [] units</FONT><BR>", (occ["dermaline_amount"] < 30 ? "<font color='white'>" : "<font color=#b54646>"), occ["dermaline_amount"])
	dat += text("[]\tBicaridine: [] units<BR>", (occ["bicaridine_amount"] < 30 ? "<font color='white'>" : "<font color=#b54646>"), occ["bicaridine_amount"])
	dat += text("[]\tDexalin: [] units<BR>", (occ["dexalin_amount"] < 30 ? "<font color='white'>" : "<font color=#b54646>"), occ["dexalin_amount"])

	dat += "<HR><table border='1'>"
	dat += "<tr>"
	dat += "<th>Organ</th>"
	dat += "<th>Burn Damage</th>"
	dat += "<th>Brute Damage</th>"
	dat += "<th>Other Wounds</th>"
	dat += "</tr>"

	for(var/datum/limb/e in occ["external_organs"])
		var/AN = ""
		var/open = ""
		var/infected = ""
		var/necrosis = ""
		var/imp = ""
		var/bled = ""
		var/robot = ""
		var/splint = ""
		var/internal_bleeding = ""
		var/lung_ruptured = ""
		var/stabilized = ""

		dat += "<tr>"

		for(var/datum/wound/internal_bleeding/IB in e.wounds)
			internal_bleeding = "Internal bleeding<br>"
			break
		if(istype(e, /datum/limb/chest) && occ["lung_ruptured"])
			lung_ruptured = "Lung ruptured:<br>"
		if(e.limb_status & LIMB_SPLINTED)
			splint = "Splinted:<br>"
		if(e.limb_status & LIMB_STABILIZED)
			stabilized = "Stabilized:<br>"
		if(e.limb_status & LIMB_BLEEDING)
			bled = "Bleeding:<br>"
		if(e.limb_status & LIMB_BROKEN)
			AN = "[e.broken_description]:<br>"
		if(e.limb_status & LIMB_NECROTIZED)
			necrosis = "Necrotizing:<br>"
		if(e.limb_status & LIMB_ROBOT)
			robot = "Prosthetic:<br>"
		if(e.surgery_open_stage)
			open = "Open:<br>"

		switch (e.germ_level)
			if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
				infected = "Mild Infection:<br>"
			if (INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infected = "Mild Infection+:<br>"
			if (INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infected = "Mild Infection++:<br>"
			if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 100)
				infected = "Acute Infection:<br>"
			if (INFECTION_LEVEL_TWO + 100 to INFECTION_LEVEL_TWO + 200)
				infected = "Acute Infection+:<br>"
			if (INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infected = "Acute Infection++:<br>"
			if (INFECTION_LEVEL_THREE to INFECTION_LEVEL_THREE + 300)
				infected = "Septic:<br>"
			if (INFECTION_LEVEL_THREE to INFECTION_LEVEL_THREE + 600)
				infected = "Septic+:<br>"
			if (INFECTION_LEVEL_THREE to INFINITY)
				infected = "Septic++:<br>"

		var/unknown_body = 0
		if (e.implants.len)
			for(var/I in e.implants)
				if(is_type_in_list(I,known_implants))
					imp += "[I] implanted:<br>"
				else
					unknown_body++
		if(e.hidden)
			unknown_body++
		if(e.body_part == CHEST) //embryo in chest?
			if(locate(/obj/item/alien_embryo) in H)
				imp += "Larva present; extract immediately:<br>"
		if(unknown_body)
			if(unknown_body > 1)
				imp += "Unknown bodies present:<br>"
			else
				imp += "Unknown body present:<br>"

		if(!AN && !open && !infected && !imp && !necrosis && !bled && !internal_bleeding && !lung_ruptured)
			AN = "None:"
		if(!(e.limb_status & LIMB_DESTROYED))
			dat += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][stabilized][open][infected][necrosis][imp][internal_bleeding][lung_ruptured]</td>"
		else
			dat += "<td>[e.display_name]</td><td>-</td><td>-</td><td>Not Found</td>"
		dat += "</tr>"

	for(var/datum/internal_organ/i in occ["internal_organs"])

		var/mech = ""
		if(i.robotic == ORGAN_ASSISTED)
			mech = "Assisted:<br>"
		if(i.robotic == ORGAN_ROBOT)
			mech = "Mechanical:<br>"

		dat += "<tr>"
		dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>None:[mech]</td><td></td>"
		dat += "</tr>"
	dat += "</table>"

	var/list/species_organs = occ["species_organs"]
	for(var/organ_name in species_organs)
		if(!locate(species_organs[organ_name]) in occ["internal_organs"])
			dat += text("<font color=#b54646>No [organ_name] detected.</font><BR>")

	if(occ["disabilities"] & BLIND)
		dat += text("<font color=#b54646>Cataracts detected.</font><BR>")
	if(occ["disabilities"] & NEARSIGHTED)
		dat += text("<font color=#b54646>Retinal misalignment detected.</font><BR>")
	return dat


/obj/machinery/proc/remove_eye_control(mob/living/user)
	return

/obj/machinery/proc/adjust_item_drop_location(atom/movable/AM)	// Adjust item drop location to a 3x3 grid inside the tile, returns slot id from 0 to 8
	var/md5 = md5(AM.name)										// Oh, and it's deterministic too. A specific item will always drop from the same slot.
	for (var/i in 1 to 32)
		. += hex2num(md5[i])
	. = . % 9
	AM.pixel_x = -8 + ((.%3)*8)
	AM.pixel_y = -8 + (round( . / 3)*8)

///Currently used for computers only; it can be repaired with a welder after a 5 second wind up
/obj/machinery/proc/set_disabled()

	if(machine_stat & (BROKEN|DISABLED)) //If we're already broken or disabled, don't bother
		return

	machine_stat |= DISABLED
	density = FALSE
	update_icon()
