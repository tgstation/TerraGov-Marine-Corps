GLOBAL_LIST_INIT(known_implants, subtypesof(/obj/item/implant))

/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
GAS ANALYZER
PLANT ANALYZER
MASS SPECTROMETER
REAGENT SCANNER
*/
/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"


/obj/item/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "t-ray[on]"

	if(on)
		START_PROCESSING(SSobj, src)


/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null

	for(var/turf/T in range(1, src.loc) )

		if(!T.intact_tile)
			continue

		for(var/obj/O in T.contents)

			if(!HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
				continue

			if(O.invisibility == INVISIBILITY_MAXIMUM)
				O.invisibility = 0
				O.alpha = 128
				spawn(10)
					if(O && !O.gc_destroyed)
						var/turf/U = O.loc
						if(U.intact_tile)
							O.invisibility = INVISIBILITY_MAXIMUM
							O.alpha = 255


/obj/item/healthanalyzer
	name = "\improper HF2 health analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject. The front panel is able to provide the basic readout of the subject's status."
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 5
	throw_range = 10
	var/datum/component/healthscan/healthscan
	///Skill required to bypass the fumble time.
	var/skill_threshold = SKILL_MEDICAL_PRACTICED

/obj/item/healthanalyzer/Initialize()
	. = ..()
	setup_healthscan_component()
	 // We always want a healthscan component otherwise things get fucky.

/obj/item/healthanalyzer/Destroy()
	. = ..()
	qdel(healthscan)
	healthscan = null

/obj/item/healthanalyzer/process()
	if(get_turf(src) != get_turf(healthscan.owner))
		healthscan.stop_autoupdate()
		healthscan.reset_owner()
		return

/obj/item/healthanalyzer/pickup(mob/user)
	. = ..()
	if(user != healthscan.owner)
		healthscan.stop_autoupdate()
		healthscan.set_owner(user)

/obj/item/healthanalyzer/attack(mob/living/carbon/M, mob/living/user)
	. = ..()
	if(user.skills.getRating("medical") < skill_threshold)
		to_chat(user, span_warning("You start fumbling around with [src]..."))
		if(!do_mob(user, M, max(SKILL_TASK_AVERAGE - (1 SECONDS * user.skills.getRating("medical")), 0), BUSY_ICON_UNSKILLED))
			return
	playsound(src.loc, 'sound/items/healthanalyzer.ogg', 50)
	if(CHECK_BITFIELD(M.species.species_flags, NO_SCAN))
		to_chat(user, span_warning("Error: Cannot read vitals!"))
		return
	if(isxeno(M))
		to_chat(user, span_warning("[src] can't make sense of this creature!"))
		return
	to_chat(user, span_notice("[user] has analyzed [M]'s vitals."))
	healthscan.scan_target(M)

/// Setup for the healthscan component
/obj/item/healthanalyzer/proc/setup_healthscan_component()
	SIGNAL_HANDLER
	if(healthscan)
		UnregisterSignal(healthscan, COMSIG_HEALTHSCAN_AUTOSCAN_STARTED)
		UnregisterSignal(healthscan, COMSIG_HEALTHSCAN_AUTOSCAN_STOPPED)
		UnregisterSignal(healthscan, COMSIG_COMPONENT_REMOVING)
		qdel(healthscan)
		healthscan = null
	healthscan = AddComponent(/datum/component/healthscan)
	RegisterSignal(healthscan, COMSIG_HEALTHSCAN_AUTOSCAN_STARTED, .proc/start_autoupdate)
	RegisterSignal(healthscan, COMSIG_HEALTHSCAN_AUTOSCAN_STOPPED, .proc/stop_autoupdate)
	RegisterSignal(healthscan, COMSIG_COMPONENT_REMOVING, .proc/setup_healthscan_component)

/obj/item/healthanalyzer/proc/start_autoupdate()
	SIGNAL_HANDLER
	START_PROCESSING(SSobj, src)

/obj/item/healthanalyzer/proc/stop_autoupdate()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)

/obj/item/healthanalyzer/integrated
	name = "\improper HF2 integrated health analyzer"
	desc = "A body scanner able to distinguish vital signs of the subject. This model has been integrated into another object, and is simpler to use."
	skill_threshold = SKILL_MEDICAL_UNTRAINED

/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20


/obj/item/analyzer/attack_self(mob/user as mob)
	..()
	var/turf/T = get_turf(user)
	if(!T)
		return

	playsound(src, 'sound/effects/pop.ogg', 100)
	var/area/user_area = T.loc
	var/datum/weather/ongoing_weather = null

	if(!user_area.outside)
		to_chat(user, span_warning("[src]'s barometer function won't work indoors!"))
		return

	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
			ongoing_weather = W
			break

	if(ongoing_weather)
		if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
			to_chat(user, span_warning("[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]"))
			return

		to_chat(user, span_notice("The next [ongoing_weather] will hit in [(ongoing_weather.next_hit_time - world.time)/10] Seconds."))
		if(ongoing_weather.aesthetic)
			to_chat(user, span_warning("[src]'s barometer function says that the next storm will breeze on by."))
	else
		var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
		var/fixed = next_hit ? timeleft(next_hit) : -1
		if(fixed < 0)
			to_chat(user, span_warning("[src]'s barometer function was unable to trace any weather patterns."))
		else
			to_chat(user, span_warning("[src]'s barometer function says a storm will land in approximately [fixed/10] Seconds]."))

/obj/item/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	var/details = 0
	var/recent_fail = 0

/obj/item/mass_spectrometer/Initialize(mapload)
	. = ..()
	create_reagents(5, OPENCONTAINER)

/obj/item/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/mass_spectrometer/attack_self(mob/user as mob)
	if (user.stat)
		return
	if (crit_fail)
		to_chat(user, span_warning("This device has critically failed and is no longer functional!"))
		return
	if(reagents.total_volume)
		var/list/blood_traces = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.type != /datum/reagent/blood)
				reagents.clear_reagents()
				to_chat(user, span_warning("The sample was contaminated! Please insert another sample"))
				return
			else
				blood_traces = params2list(R.data["trace_chem"])
				break
		var/dat = "Trace Chemicals Found: "
		for(var/R in blood_traces)
			if(prob(reliability))
				if(details)
					dat += "[R] ([blood_traces[R]] units) "
				else
					dat += "[R] "
				recent_fail = 0
			else
				if(recent_fail)
					crit_fail = 1
					reagents.clear_reagents()
					return
				else
					recent_fail = 1
		to_chat(user, "[dat]")
		reagents.clear_reagents()


/obj/item/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = 1


/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	var/details = FALSE
	var/recent_fail = 0

/obj/item/reagent_scanner/afterattack(obj/O, mob/user as mob, proximity)
	if(!proximity)
		return
	if (user.stat)
		return
	if(!istype(O))
		return
	if (crit_fail)
		to_chat(user, span_warning("This device has critically failed and is no longer functional!"))
		return

	if(!isnull(O.reagents))
		var/dat = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for (var/datum/reagent/R in O.reagents.reagent_list)
				if(prob(reliability))
					dat += "\n \t [span_notice(" [R][details ? ": [R.volume / one_percent]%" : ""]")]"
					recent_fail = 0
				else if(recent_fail)
					crit_fail = 1
					dat = null
					break
				else
					recent_fail = 1
		if(dat)
			to_chat(user, span_notice("Chemicals found: [dat]"))
		else
			to_chat(user, span_notice("No active chemical agents found in [O]."))
	else
		to_chat(user, span_notice("No significant chemical agents found in [O]."))

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = TRUE
