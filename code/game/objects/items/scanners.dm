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
	///Skill required to bypass the fumble time.
	var/skill_threshold = SKILL_MEDICAL_PRACTICED
	///Skill required to have the scanner auto refresh
	var/upper_skill_threshold = SKILL_MEDICAL_PRACTICED
	///Current mob being tracked by the scanner
	var/mob/living/carbon/patient
	///Current user of the scanner
	var/mob/living/carbon/current_user
	///Distance the current_user can be away from the patient and still get health data.
	var/track_distance = 3

/obj/item/healthanalyzer/Destroy()
	. = ..()
	patient = null
	current_user = null

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
	current_user = user
	scan_target(M)
	if(user.skills.getRating("medical") < upper_skill_threshold)
		return
	START_PROCESSING(SSobj, src)

/obj/item/healthanalyzer/proc/scan_target(mob/living/carbon/target)
	if(!target || !iscarbon(target) || isxeno(target))
		return
	set_patient(target)
	ui_interact(current_user)
	update_static_data(current_user)

/obj/item/healthanalyzer/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/// Sets the target to scan. FALSE = patient is null, TRUE = patient exists
/obj/item/healthanalyzer/proc/set_patient(mob/living/carbon/target)

	reset_patient()
	patient = target
	RegisterSignal(patient, COMSIG_PARENT_QDELETING, .proc/on_patient_qdel) // Recursive call to clear patient ref

/// Resets the target for the health analyzer
/obj/item/healthanalyzer/proc/reset_patient(datum/source)

	if(!patient)
		return

	UnregisterSignal(patient, COMSIG_PARENT_QDELETING)
	patient = null

/obj/item/healthanalyzer/proc/on_patient_qdel()
	SIGNAL_HANDLER

	reset_patient()
	SStgui.close_uis(src)


/obj/item/healthanalyzer/process()
	if(!patient || get_turf(src) != get_turf(current_user) || get_dist(get_turf(current_user), get_turf(patient)) > track_distance || patient == current_user)
		STOP_PROCESSING(SSobj, src)
		reset_patient()
		current_user = null
		return
	update_static_data(current_user)

/obj/item/healthanalyzer/removed_from_inventory(mob/user)
	. = ..()
	if(get_turf(src) == get_turf(user)) //If you drop it or it enters a bag on the user.
		return
	STOP_PROCESSING(SSobj, src)
	reset_patient()
	current_user = null

/obj/item/healthanalyzer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MedScanner", "Medical Scanner")
		ui.open()

/obj/item/healthanalyzer/ui_static_data(mob/user)
	var/list/data = list(
		"patient" = patient.name,
		"dead" = (patient.stat == DEAD || HAS_TRAIT(patient, TRAIT_FAKEDEATH)),
		"health" = patient.health,
		"total_brute" = round(patient.getBruteLoss()),
		"total_burn" = round(patient.getFireLoss()),
		"toxin" = round(patient.getToxLoss()),
		"oxy" = round(patient.getOxyLoss()),
		"clone" = round(patient.getCloneLoss()),

		"revivable" = patient.getBruteLoss() + patient.getFireLoss() + patient.getToxLoss() + patient.getOxyLoss() + patient.getCloneLoss() <= 200,

		"blood_type" = patient.blood_type,
		"blood_amount" = patient.blood_volume,

		"hugged" = (locate(/obj/item/alien_embryo) in patient)
	)
	data["has_unknown_chemicals"] = FALSE
	var/list/chemicals_lists = list()
	for(var/datum/reagent/reagent AS in patient.reagents.reagent_list)
		if(!reagent.scannable)
			data["has_unknown_chemicals"] = TRUE
			continue
		chemicals_lists["[reagent.name]"] = list(
			"name" = reagent.name,
			"amount" = round(reagent.volume, 0.1),
			"od" = reagent.overdosed,
			"dangerous" = reagent.overdosed || istype(reagent, /datum/reagent/toxin)
		)
	data["has_chemicals"] = length(patient.reagents.reagent_list)
	data["chemicals_lists"] = chemicals_lists

	var/list/limb_data_lists = list()
	if(ishuman(patient))
		var/mob/living/carbon/human/human_patient = patient
		var/infection_message
		var/infected = 0
		var/internal_bleeding

		var/unknown_implants = 0
		for(var/datum/limb/limb AS in human_patient.limbs)
			if(!internal_bleeding)
				for(var/datum/wound/wound in limb.wounds)
					if(!istype(wound, /datum/wound/internal_bleeding))
						continue
					internal_bleeding = TRUE
					break
			if(infected < 2 && limb.limb_status & LIMB_NECROTIZED)
				infection_message = "Subject's [limb.display_name] has necrotized. Surgery required."
				infected = 2
			if(infected < 1 && limb.germ_level > INFECTION_LEVEL_ONE)
				infection_message = "Infection detected in subject's [limb.display_name]. Antibiotics recommended."
				infected = 1

			if(limb.hidden)
				unknown_implants++
			var/implant = FALSE
			if(length(limb.implants))
				for(var/I in limb.implants)
					if(is_type_in_list(I, GLOB.known_implants))
						continue
					unknown_implants++
					implant = TRUE

			if(!limb.brute_dam && !limb.burn_dam && !CHECK_BITFIELD(limb.limb_status, LIMB_DESTROYED) && !CHECK_BITFIELD(limb.limb_status, LIMB_BROKEN) && !CHECK_BITFIELD(limb.limb_status, LIMB_BLEEDING) && !implant)
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
				"open_incision" = limb.surgery_open_stage,
				"infected" = infected,
				"implant" = implant
			)
			var/limb_status = ""
			if(CHECK_BITFIELD(limb.limb_status, LIMB_BROKEN) && !CHECK_BITFIELD(limb.limb_status, LIMB_STABILIZED) && !CHECK_BITFIELD(limb.limb_status, LIMB_SPLINTED))
				limb_status = "Fracture"
			else if(CHECK_BITFIELD(limb.limb_status, LIMB_STABILIZED))
				limb_status = "Stabilized"
			else if(CHECK_BITFIELD(limb.limb_status, LIMB_SPLINTED))
				limb_status = "Splinted"
			current_list["limb_status"] = limb_status
			limb_data_lists["[limb.name]"] = current_list
		data["limb_data_lists"] = limb_data_lists
		data["limbs_damaged"] = length(limb_data_lists)
		data["internal_bleeding"] = internal_bleeding
		data["infection"] = infection_message
		data["body_temperature"] = "[round(human_patient.bodytemperature*1.8-459.67, 0.1)] degrees F ([round(human_patient.bodytemperature-T0C, 0.1)] degrees C)"
		data["pulse"] = "[human_patient.get_pulse(GETPULSE_TOOL)] bpm"
		data["implants"] = unknown_implants
		var/damaged_organs = list()
		for(var/datum/internal_organ/organ AS in human_patient.internal_organs)
			if(organ.organ_status == ORGAN_HEALTHY)
				continue
			var/current_organ = list(
				"name" = organ.name,
				"status" = organ.organ_status == ORGAN_BRUISED ? "Bruised" : "Broken",
				"damage" = organ.damage
			)
			damaged_organs += list(current_organ)
		data["damaged_organs"] = damaged_organs

	if(patient.has_brain() && patient.stat != DEAD && ishuman(patient))
		if(!patient.key)
			data["ssd"] = "No soul detected." // they ghosted
		else if(!patient.client)
			data["ssd"] = "SSD detected." // SSD

	return data

/obj/item/healthanalyzer/integrated
	name = "\improper HF2 integrated health analyzer"
	desc = "A body scanner able to distinguish vital signs of the subject. This model has been integrated into another object, and is simpler to use."
	skill_threshold = SKILL_MEDICAL_UNTRAINED

/obj/item/healthanalyzer/ghost
	name = "\improper Ghost health analyzer"
	skill_threshold = SKILL_MEDICAL_UNTRAINED

/obj/item/healthanalyzer/ghost/process()
	update_static_data(current_user)

/obj/item/healthanalyzer/ghost/ui_state(mob/user)
	return GLOB.observer_state

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
