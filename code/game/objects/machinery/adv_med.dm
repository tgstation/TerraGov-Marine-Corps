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

/obj/machinery/body_scanconsole/ui_data(mob/user)
	var/list/data = list()

	if(!connected.occupant)
		return data

	data["patient"] = connected.occupant.name
	data["dead"] = (connected.occupant.stat == DEAD || HAS_TRAIT(connected.occupant, TRAIT_FAKEDEATH))
	data["health"] = connected.occupant.health
	data["total_brute"] = round(connected.occupant.getBruteLoss())
	data["total_burn"] = round(connected.occupant.getFireLoss())
	data["toxin"] = round(connected.occupant.getToxLoss())
	data["oxy"] = round(connected.occupant.getOxyLoss())
	data["clone"] = round(connected.occupant.getCloneLoss())

	data["revivable"] = connected.occupant.getBruteLoss() + connected.occupant.getFireLoss() + connected.occupant.getToxLoss() + connected.occupant.getOxyLoss() + connected.occupant.getCloneLoss() <= 200

	data["blood_type"] = connected.occupant.blood_type
	data["blood_amount"] = connected.occupant.blood_volume

	data["hugged"] = locate(/obj/item/alien_embryo) in connected.occupant

	switch(connected.occupant.stat)
		if(CONSCIOUS)
			data["stat"] = "Conscious"
			data["statstate"] = "good"
		if(UNCONSCIOUS)
			data["stat"] = "Unconscious"
			data["statstate"] = "average"
		if(DEAD)
			data["stat"] = "Dead"
			data["statstate"] = "bad"

	var/list/chemicals_lists = list()
	for(var/datum/reagent/reagent AS in connected.occupant.reagents.reagent_list)
		chemicals_lists["[reagent.name]"] = list(
			"name" = reagent.name,
			"amount" = round(reagent.volume, 0.1),
			"od" = reagent.overdosed,
			"dangerous" = reagent.overdosed || istype(reagent, /datum/reagent/toxin) || istype(reagent, /datum/reagent/medicine/xenojelly)
		)
	data["has_chemicals"] = length_char(connected.occupant.reagents.reagent_list)
	data["chemicals_lists"] = chemicals_lists

	var/list/limb_data_lists = list()
	if(ishuman(connected.occupant))
		var/mob/living/carbon/human/human_patient = connected.occupant
		var/list/infection_list = list()
		var/list/necrotized_list = list()
		var/list/internal_bleeding_list = list()

		var/unknown_implants = 0
		for(var/datum/limb/limb AS in human_patient.limbs)
			var/infected = FALSE
			var/necrotized = FALSE
			var/internal_bleeding

			for(var/datum/wound/wound in limb.wounds)
				if(!istype(wound, /datum/wound/internal_bleeding))
					continue
				internal_bleeding_list.Add(limb.display_name)
				internal_bleeding = TRUE
				break
			if(limb.germ_level > INFECTION_LEVEL_ONE)
				infection_list.Add(limb.display_name)
				infected = TRUE
			if(limb.limb_status & LIMB_NECROTIZED)
				necrotized_list.Add(limb.display_name)
				necrotized = TRUE

			if(limb.hidden)
				unknown_implants++
			var/implant = 0
			if(length_char(limb.implants))
				for(var/I in limb.implants)
					if(is_type_in_list(I, GLOB.known_implants))
						continue
					unknown_implants++
					implant++

			if(!limb.brute_dam && !limb.burn_dam && !CHECK_BITFIELD(limb.limb_status, LIMB_DESTROYED) && !CHECK_BITFIELD(limb.limb_status, LIMB_BROKEN) && !CHECK_BITFIELD(limb.limb_status, LIMB_BLEEDING) && !CHECK_BITFIELD(limb.limb_status, LIMB_NECROTIZED) && !CHECK_BITFIELD(limb.limb_status, LIMB_ROBOT) && !implant && !infected )
				continue
			var/list/current_list = list(
				"name" = limb.display_name,
				"brute" = round(limb.brute_dam),
				"burn" = round(limb.burn_dam),
				"bandaged" = limb.is_bandaged(),
				"salved" = limb.is_salved(),
				"missing" = CHECK_BITFIELD(limb.limb_status, LIMB_DESTROYED),
				"limb_status" = null,
				"bleeding" = CHECK_BITFIELD(limb.limb_status, LIMB_BLEEDING),
				"internal_bleeding" = internal_bleeding,
				"open_incision" = limb.surgery_open_stage,
				"necrotized" = necrotized,
				"infected" = infected,
				"implant" = implant
			)
			var/limb_status = ""
			if(CHECK_BITFIELD(limb.limb_status, LIMB_ROBOT))
				limb_status = "Prosthetic"
			else if(CHECK_BITFIELD(limb.limb_status, LIMB_BROKEN) && !CHECK_BITFIELD(limb.limb_status, LIMB_STABILIZED) && !CHECK_BITFIELD(limb.limb_status, LIMB_SPLINTED))
				limb_status = "Fracture"
			else if(CHECK_BITFIELD(limb.limb_status, LIMB_STABILIZED))
				limb_status = "Stabilized"
			else if(CHECK_BITFIELD(limb.limb_status, LIMB_SPLINTED))
				limb_status = "Splinted"
			current_list["limb_status"] = limb_status
			limb_data_lists["[limb.name]"] = current_list

		data["limb_data_lists"] = limb_data_lists
		data["limbs_damaged"] = length_char(limb_data_lists)

		if(internal_bleeding_list.len > 0)
			var/internal_bleeding_message = jointext(internal_bleeding_list, ", ")
			data["internal_bleeding"] = "Internal Bleeding Detected in subject's [internal_bleeding_message]! Surgery required."

		if(infection_list.len > 0)
			var/infection_message = jointext(infection_list, ", ")
			data["infection"] = "Infection detected in subject's [infection_message]. Antibiotics recommended."

		if(necrotized_list.len > 0)
			var/necrotized_message = jointext(necrotized_list, ", ")
			data["necrotized"] = "Subject's [necrotized_message] has necrotized. Surgery required."

		data["body_temperature"] = "[round(human_patient.bodytemperature*1.8-459.67, 0.1)] degrees F ([round(human_patient.bodytemperature-T0C, 0.1)] degrees C)"
		data["pulse"] = "[human_patient.get_pulse(GETPULSE_TOOL)] bpm"
		data["knock"] = human_patient.AmountUnconscious()
		data["implants"] = unknown_implants
		var/damaged_organs = list()
		for(var/datum/internal_organ/organ AS in human_patient.internal_organs)
			if(organ.damage <= 0)
				continue
			var/current_organ = list(
				"name" = organ.name,
				"status" = organ.organ_status == ORGAN_HEALTHY ? "Healthy" : organ.organ_status == ORGAN_BRUISED ? "Bruised" : "Broken",
				"damage" = organ.damage
			)
			damaged_organs += list(current_organ)
		data["damaged_organs"] = damaged_organs

	if(connected.occupant.has_brain() && connected.occupant.stat != DEAD && ishuman(connected.occupant))
		if(!connected.occupant.key)
			data["ssd"] = "No soul detected." // they ghosted
		else if(!connected.occupant.client)
			data["ssd"] = "SSD detected." // SSD

	return data

/obj/machinery/body_scanconsole/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "BodyScanner")
		ui.open()

/obj/machinery/body_scanconsole/interact(mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)
	if(connected?.occupant) //Is something connected?
		var/dat
		var/mob/living/carbon/human/H = connected.occupant
		med_scan(H, dat, GLOB.known_implants)

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
		RegisterSignal(connected, COMSIG_PARENT_QDELETING, PROC_REF(on_bodyscanner_deletion))


///Called by the deletion of the connected bodyscanner.
/obj/machinery/body_scanconsole/proc/on_bodyscanner_deletion(obj/machinery/bodyscanner/source, force)
	SIGNAL_HANDLER
	set_connected(null)
