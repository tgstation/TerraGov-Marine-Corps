// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	name = "Body Scanner"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scanner"
	density = TRUE
	anchored = TRUE
	coverage = 20
	use_power = IDLE_POWER_USE
	idle_power_usage = 60
	active_power_usage = 16000	//16 kW. It's a big all-body scanner - This is used on scan / examine
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	dir = EAST
	///mob inside
	var/mob/living/carbon/occupant
	///If its locked
	var/locked

/obj/machinery/bodyscanner/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/bodyscanner/update_icon()
	. = ..()
	if((machine_stat & (BROKEN|DISABLED|NOPOWER)) || !occupant)
		set_light(0)
	else
		set_light(initial(light_range))

/obj/machinery/bodyscanner/update_icon_state()
	. = ..()
	if(occupant)
		icon_state = "[initial(icon_state)]_occupied"
	else
		icon_state = initial(icon_state)

/obj/machinery/bodyscanner/update_overlays()
	. = ..()
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		return
	if(!occupant)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", src, alpha = src.alpha)
	. += mutable_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)

/obj/machinery/bodyscanner/relaymove(mob/user)
	if(user.incapacitated(TRUE))
		return
	go_out()


/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "IC.Object"
	set name = "Eject Body Scanner"

	if (usr.stat != CONSCIOUS)
		return
	go_out()

/obj/machinery/bodyscanner/proc/move_inside_wrapper(mob/living/target, mob/user)
	if(!ishuman(target) || !ishuman(user) || user.incapacitated(TRUE))
		return
	if(occupant)
		to_chat(user, span_boldnotice("The scanner is already occupied!"))
		return
	if(target.abiotic())
		to_chat(user, span_boldnotice("Subject cannot have abiotic items on."))
		return
	target.forceMove(src)
	occupant = target
	update_icon()
	for(var/obj/O in src)
		qdel(O)

/obj/machinery/bodyscanner/MouseDrop_T(mob/M, mob/user)
	. = ..()
	move_inside_wrapper(M, user)

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "IC.Object"
	set name = "Enter Body Scanner"

	move_inside_wrapper(usr, usr)

/obj/machinery/bodyscanner/Destroy()
	locked = FALSE
	go_out()
	return ..()

/obj/machinery/bodyscanner/proc/go_out()
	if (!occupant || locked)
		return
	occupant.forceMove(loc)
	occupant = null
	for(var/obj/O in src)
		O.forceMove(loc)
	update_icon()

/obj/machinery/bodyscanner/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	go_out()

/obj/machinery/bodyscanner/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out; this is here mainly for consistency's sake.
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)
		return

/obj/machinery/bodyscanner/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	. = ..()
	if(.)
		return
	if(occupant)
		to_chat(user, span_warning("The scanner is already occupied!"))
		return

	var/mob/grabbed_mob
	if(ismob(grab.grabbed_thing))
		grabbed_mob = grab.grabbed_thing
	else if(istype(grab.grabbed_thing, /obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/cryobag = grab.grabbed_thing
		if(!cryobag.bodybag_occupant)
			to_chat(user, span_warning("The stasis bag is empty!"))
			return
		grabbed_mob = cryobag.bodybag_occupant
		cryobag.open()
		user.start_pulling(grabbed_mob)

	if(!grabbed_mob)
		return

	if(grabbed_mob.abiotic())
		to_chat(user, span_warning("Subject cannot have abiotic items on."))
		return

	grabbed_mob.forceMove(src)
	occupant = grabbed_mob
	update_icon()
	for(var/obj/O in src)
		O.forceMove(loc)
	return TRUE

/obj/machinery/bodyscanner/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!occupant)
		to_chat(xeno_attacker, span_xenowarning("There is nothing of interest in there."))
		return
	if(xeno_attacker.status_flags & INCORPOREAL || xeno_attacker.do_actions)
		return
	visible_message(span_warning("[xeno_attacker] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(!do_after(xeno_attacker, 2 SECONDS))
		return
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	go_out()

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			for(var/atom/movable/A AS in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if (prob(50))
				for(var/atom/movable/A AS in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(EXPLODE_LIGHT)
			if(!prob(75))
				return
			for(var/atom/movable/A AS in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)

/obj/machinery/computer/body_scanconsole
	name = "Body Scanner Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scannerconsole"
	screen_overlay = "body_scannerconsole_emissive"
	density = FALSE
	idle_power_usage = 3
	light_color = LIGHT_COLOR_EMISSIVE_GREEN
	dir = EAST
	/// The connected body scanner pod
	var/obj/machinery/bodyscanner/connected
	/// The health scan functionality
	var/datum/health_scan/scanner

/obj/machinery/computer/body_scanconsole/Initialize(mapload)
	. = ..()
	set_connected(locate(/obj/machinery/bodyscanner, get_step(src, REVERSE_DIR(dir))))
	scanner = new(src, SKILL_MEDICAL_UNTRAINED, SKILL_MEDICAL_UNTRAINED, TRACK_DISTANCE_DISABLED)
	RegisterSignal(scanner, COMSIG_HEALTH_SCAN_DATA, PROC_REF(on_scanner_data))

/obj/machinery/computer/body_scanconsole/Destroy()
	QDEL_NULL(scanner)
	return ..()

/obj/machinery/computer/body_scanconsole/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)

/obj/machinery/computer/body_scanconsole/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!connected || !connected.is_operational())
		return FALSE

	if(!ishuman(connected.occupant))
		return FALSE

	return TRUE

/obj/machinery/computer/body_scanconsole/interact(mob/user)
	. = ..()
	if(.)
		return

	scanner.analyze_vitals(connected.occupant, user)

/obj/machinery/bodyscanner/examine(mob/living/user)
	. = ..()
	if(!occupant)
		return
	. += span_notice("It contains: [occupant].")
	. += span_notice("Scans performed will be archived and viewable when someone with a medical HUD examines a previous patient.")

/// Wrapper to guarantee connected bodyscanner references are properly nulled and avoid hard deletions
/obj/machinery/computer/body_scanconsole/proc/set_connected(obj/machinery/bodyscanner/new_connected)
	if(connected)
		UnregisterSignal(connected, COMSIG_QDELETING)
	connected = new_connected
	if(connected)
		RegisterSignal(connected, COMSIG_QDELETING, PROC_REF(on_bodyscanner_deletion))

/// Called by the deletion of the connected bodyscanner
/obj/machinery/computer/body_scanconsole/proc/on_bodyscanner_deletion(obj/machinery/bodyscanner/source, force)
	SIGNAL_HANDLER
	set_connected(null)

/// Called by the scan datum finishing `ui_data`, updates or creates
/// a historic scan for the connected pod's occupant
/obj/machinery/computer/body_scanconsole/proc/on_scanner_data(datum/health_scan/source, mob/living/carbon/human/patient, list/data)
	SIGNAL_HANDLER
	var/datum/data/record/medical_record = find_medical_record(patient, TRUE)
	var/datum/historic_scan/historic_scan = (medical_record.fields["historic_scan"] ||= new /datum/historic_scan(patient))
	historic_scan.data = data
	medical_record.fields["historic_scan_time"] = worldtime2text()
	medical_record.fields["autodoc_data"] = generate_autodoc_surgery_list(connected.occupant)
