/**
 * An evil, no-good component-like datum for health analyzer functionality.
 *
 * We have a couple things that want to use health analyzer functionality, from the health
 * analyzer object to ghosts and analyzer gloves so this is here to share it between all of them
 * in a slightly saner way than giving everything a health analyzer obj.
 *
 * This may not be parented to non-atoms. It needs to have something in-world parenting it.
 *
 * Example usage:
 * ```dm
 * /obj/item/abhorrent_item
 * 	...
 * 	var/datum/health_scan/scanner
 *
 * /obj/item/abhorrent_item/Initialize(mapload)
 * 	scanner = new(src)
 *
 * /obj/item/abhorrent_item/attack_self(mob/living/carbon/human/user)
 * 	scanner.analyze_vitals(user, user)
 * ```
 */
/datum/health_scan
	/// Var for if we should set autoupdating in [/datum/health_scan/ui_status] at all.
	/// Check the comment in that proc for more, but basically tgui's system for managing autoupdating
	/// is far too vague for what we're doing. We have to use a workaround to avoid dimming the UI and closing it.
	/// This var can't disable autoupdates in the first place—set `track_distance` to [TRACK_DISTANCE_DISABLED] for that.
	VAR_PRIVATE/allow_live_autoupdating = FALSE
	/// Current mob being tracked by the scanner.
	var/mob/living/carbon/human/patient
	/// The atom we will use for autoupdate tracking.
	/// This cannot be anything other than an atom. Even if this datum is being used
	/// in a component, you need to set this to the atom parenting that component.
	var/atom/owner
	/// Skill required to bypass the fumble time.
	var/skill_threshold
	/// Skill required to have the scanner auto refresh.
	var/upper_skill_threshold
	/// Distance the user can be away from the patient and still get autoupdates.
	/// Set to [TRACK_DISTANCE_DISABLED] to disable autoupdating entirely.
	var/track_distance
	/// Cooldown for showing a scan to somebody.
	COOLDOWN_DECLARE(show_scan_cooldown)

/**
 * New proc, with some args for controlling usage of this
 *
 * * `scan_owner`—The atom that *owns* this. Needed for balloon alerts and autoupdates.
 * * `skill_bypass_fumble`—The Medical skill needed to not fumble with this.
 * * `skill_auto_update`—The Medical skill needed to get autoupdates with this.
 * * `track_distance`—The distance (tiles) before autoupdating is locked until rescanning.
 */
/datum/health_scan/New(
	atom/scan_owner,
	skill_bypass_fumble = SKILL_MEDICAL_NOVICE,
	skill_auto_update = SKILL_MEDICAL_NOVICE,
	autoupdate_distance = TRACK_DISTANCE_DEFAULT
)
	if(!isatom(scan_owner))
		stack_trace("[type] created on a non-atom: [scan_owner.type]")
		return qdel(src)
	owner = scan_owner
	skill_threshold = skill_bypass_fumble
	upper_skill_threshold = skill_auto_update
	track_distance = autoupdate_distance
	RegisterSignal(scan_owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/health_scan/Destroy(force, ...)
	patient = null
	owner = null
	return ..()

/// Examine note about accessible themes preference
/datum/health_scan/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(ismob(source))
		return
	examine_list += span_notice("\The [source] can be configured to use a more accessible theme in your game preferences.")

/**
 * Signal handler to clear the patient and close the UI in the very specific
 * (but not uncommon) case of tracking a patient who gets gibbed or otherwise deleted.
 *
 * We don't null patient when autoupdate disables because of our workarounds
 * with autoupdating—that causes runtimes every time autoupdating is disabled.
 * Instead, we keep the patient in mind (until another one is scanned) but listen
 * for their deletion and only then close the UI and null the patient var.
 *
 * This may not seem ideal and is a consequence of bending tgui in unforeseen ways, but better than incessant runtimes.
 */
/datum/health_scan/proc/clear_patient(force)
	SIGNAL_HANDLER
	SStgui.close_uis(src)
	patient = null

/**
 * If `user` is too unskilled, not on the same tile as `owner`, `user` is out of tracking range,
 * or it's a self scan, we return `FALSE`.
 *
 * Otherwise, we return `TRUE`.
 */
/datum/health_scan/proc/autoupdate_checks(mob/living/user, mob/living/patient)
	if(!track_distance) // checking being disabled should go first
		return FALSE
	if(user.skills.getRating(SKILL_MEDICAL) < upper_skill_threshold)
		return FALSE
	if(get_turf(owner) != get_turf(user))
		return FALSE
	if(get_dist(get_turf(user), get_turf(patient)) > track_distance)
		return FALSE
	if(patient == user)
		return FALSE
	return TRUE

/**
 * A wrapper proc, so this datum can be used by signals/its parent/whatever.
 *
 * * `patient_candidate`—Currently, only carbon humans are supported. This is who we will be scanning.
 * * `user`—Any mob is supported. This is who the scan is shown to, unless `show_patient` is active.
 * * `show_patient`—If this is TRUE, we'll show the scan to `patient_candidate` instead of `user`.
 */
/datum/health_scan/proc/analyze_vitals(mob/living/carbon/human/patient_candidate, mob/user, show_patient)
	if(user.skills.getRating(SKILL_MEDICAL) < skill_threshold)
		user.balloon_alert("fumbling...")
		if(!do_after(user, max(SKILL_TASK_AVERAGE - (1 SECONDS * user.skills.getRating(SKILL_MEDICAL)), 0), NONE, patient_candidate, BUSY_ICON_UNSKILLED))
			return
	if(!ishuman(patient_candidate))
		user.balloon_alert(user, "cannot scan!")
		return
	if(isxeno(patient_candidate) || patient_candidate.species.species_flags & NO_SCAN)
		user.balloon_alert(user, "unknown error!")
		return
	if(patient)
		UnregisterSignal(patient, COMSIG_QDELETING)
	patient = patient_candidate
	if(show_patient)
		if(!COOLDOWN_FINISHED(src, show_scan_cooldown))
			user.balloon_alert(user, "wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, show_scan_cooldown))]!")
			return
		if(patient_candidate.faction != user.faction)
			user.balloon_alert(user, "incompatible factions!")
			return
		if(!patient_candidate.client?.prefs?.allow_being_shown_health_scan)
			user.balloon_alert(user, "can't show healthscan!")
			return
		user.balloon_alert_to_viewers("showed healthscan", vision_distance = 4)
		ui_interact(patient_candidate)
		COOLDOWN_START(src, show_scan_cooldown, 3 SECONDS)
	else
		ui_interact(user)
	RegisterSignal(patient_candidate, COMSIG_QDELETING, PROC_REF(clear_patient))
	if(!ismob(owner))
		playsound(owner.loc, 'sound/items/healthanalyzer.ogg', 45)

/datum/health_scan/ui_state(mob/user)
	if(!isobserver(user))
		return GLOB.not_incapacitated_state
	return GLOB.observer_state

/datum/health_scan/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MedScanner", "Health Scan")
		ui.open()
	if(!autoupdate_checks(user, patient))
		// Stop native autoupdating at the gate to avoid double-dipping
		// updates when they really shouldn't happen in the first place
		ui.set_autoupdate(FALSE)
		return
	allow_live_autoupdating = TRUE

/datum/health_scan/ui_status(mob/user, datum/ui_state/state)
	// Returning UI_DISABLED will dim the window and prevent it from being opened in self-scans
	// so we have this override to avoid that behavior but still stop autoupdates from being sent.
	// allow_live_autoupdating also enforces not updating old scans, requiring you to scan again.
	// If tgui gets a better system for this shit in the future please feel free to replace this.
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(!allow_live_autoupdating)
		return UI_INTERACTIVE
	ui?.set_autoupdate(autoupdate_checks(user, patient))
	allow_live_autoupdating = !isnull(ui) ? ui.autoupdate : TRUE
	return UI_INTERACTIVE

/datum/health_scan/ui_data(mob/user)
	var/list/data = list(
		"patient" = patient.name,
		"dead" = (patient.stat == DEAD || HAS_TRAIT(patient, TRAIT_FAKEDEATH)),
		"health" = patient.health,
		"max_health" = patient.maxHealth,
		"crit_threshold" = patient.get_crit_threshold(),
		"dead_threshold" = patient.get_death_threshold(),
		"total_brute" = round(patient.getBruteLoss()),
		"total_burn" = round(patient.getFireLoss()),
		"toxin" = round(patient.getToxLoss()),
		"oxy" = round(patient.getOxyLoss()),
		"clone" = round(patient.getCloneLoss()),

		"blood_type" = patient.blood_type,
		"blood_amount" = patient.blood_volume,
		"regular_blood_amount" = initial(patient.blood_volume),

		"hugged" = !!(patient.status_flags & XENO_HOST),

		"species" = list(
			"name" = patient.species?.name || "Unknown Species",
			// species types
			"is_synthetic" = issynth(patient),
			"is_combat_robot" = isrobot(patient),
			// for the robot umbrella which shares a lot of traits
			"is_robotic_species" = !!(patient.species?.species_flags & ROBOTIC_LIMBS)
		),

		"accessible_theme" = user.client?.prefs?.accessible_tgui_themes,
	)

	var/temp_color = "white"
	if(patient.bodytemperature > patient.species?.heat_level_1)
		temp_color = "yellow"
	if(patient.bodytemperature > patient.species?.heat_level_2)
		temp_color = "orange"
	if(patient.bodytemperature > patient.species?.heat_level_3)
		temp_color = "red"
	data["body_temperature"] = list(
		"current" = "[round(patient.bodytemperature*1.8-459.67, 0.1)]°F ([round(patient.bodytemperature-T0C, 0.1)]°C)",
		"color" = temp_color,
		"warning" = temp_color != "white"
	)

	data["has_unknown_chemicals"] = FALSE
	var/list/chemicals_lists = list()
	for(var/datum/reagent/reagent AS in patient.reagents.reagent_list)
		if(!reagent.scannable)
			data["has_unknown_chemicals"] = TRUE
			continue
		chemicals_lists["[reagent.name]"] = list(
			"name" = reagent.name,
			"description" = reagent.description,
			"amount" = round(reagent.volume, 0.1),
			"od" = reagent.overdosed,
			"dangerous" = istype(reagent, /datum/reagent/toxin),
			"od_threshold" = reagent.overdose_threshold,
			"crit_od_threshold" = reagent.overdose_crit_threshold,
			"color" = reagent.color,
			"metabolism_factor" = reagent.custom_metabolism
		)
	data["has_chemicals"] = length(patient.reagents.reagent_list)
	data["chemicals_lists"] = chemicals_lists

	if(!ishuman(patient)) // Non humans are not supported, though they should be in the future
		return

	var/list/limb_data_lists = list()
	var/infection_message
	var/internal_bleeding

	var/total_unknown_implants = 0
	for(var/datum/limb/limb AS in patient.limbs)
		if((limb.parent?.limb_status & LIMB_DESTROYED) && !(istype(limb.parent, /datum/limb/groin) && istype(limb.parent, /datum/limb/chest) && istype(limb.parent, /datum/limb/head)))
			// avoid showing right arm and right hand as missing, for example
			continue
		var/infected = FALSE
		var/necrotized = FALSE

		if(!internal_bleeding)
			for(var/datum/wound/wound in limb.wounds)
				if(!istype(wound, /datum/wound/internal_bleeding))
					continue
				internal_bleeding = TRUE
				break
		if(limb.germ_level > INFECTION_LEVEL_ONE)
			infection_message = "Infection detected in subject's [limb.display_name]. Antibiotics recommended."
			infected = TRUE
		if(limb.limb_status & LIMB_NECROTIZED)
			infection_message = "Subject's [limb.display_name] has necrotized. Surgery required."
			necrotized = TRUE

		if(limb.hidden)
			total_unknown_implants++
		var/implants = 0
		if(length(limb.implants))
			for(var/obj/item/embedded AS in limb.implants)
				if(embedded.is_beneficial_implant())
					continue
				total_unknown_implants++
				implants++

		if(!limb.brute_dam && !limb.burn_dam && !CHECK_BITFIELD(limb.limb_status, LIMB_DESTROYED) && !CHECK_BITFIELD(limb.limb_status, LIMB_BROKEN) && !CHECK_BITFIELD(limb.limb_status, LIMB_BLEEDING) && !CHECK_BITFIELD(limb.limb_status, LIMB_NECROTIZED) && !implants && !infected )
			continue
		var/list/current_list = list(
			"name" = limb.display_name,
			"brute" = round(limb.brute_dam),
			"burn" = round(limb.burn_dam),
			"bandaged" = limb.is_bandaged(),
			"salved" = limb.is_salved(),
			"missing" = CHECK_BITFIELD(limb.limb_status, LIMB_DESTROYED),
			"limb_status" = null,
			"limb_type" = null,
			"bleeding" = CHECK_BITFIELD(limb.limb_status, LIMB_BLEEDING),
			"open_incision" = limb.surgery_open_stage,
			"necrotized" = necrotized,
			"infected" = infected,
			"implants" = implants,
			"max_damage" = limb.max_damage * LIMB_MAX_DAMAGE_SEVER_RATIO,
		)
		var/limb_type = ""
		if(CHECK_BITFIELD(limb.limb_status, LIMB_ROBOT))
			limb_type = "Robotic"
		else if(CHECK_BITFIELD(limb.limb_status, LIMB_BIOTIC))
			limb_type = "Biotic"

		var/limb_status = ""
		if(CHECK_BITFIELD(limb.limb_status, LIMB_BROKEN) && !CHECK_BITFIELD(limb.limb_status, LIMB_STABILIZED) && !CHECK_BITFIELD(limb.limb_status, LIMB_SPLINTED))
			limb_status = "Fracture"
		else if(CHECK_BITFIELD(limb.limb_status, LIMB_STABILIZED))
			limb_status = "Stable"
		else if(CHECK_BITFIELD(limb.limb_status, LIMB_SPLINTED))
			limb_status = "Splint"
		current_list["limb_type"] = limb_type
		current_list["limb_status"] = limb_status
		limb_data_lists["[limb.name]"] = current_list
	data["limb_data_lists"] = limb_data_lists
	data["limbs_damaged"] = length(limb_data_lists)
	data["internal_bleeding"] = internal_bleeding
	data["infection"] = infection_message
	data["pulse"] = "[patient.get_pulse(GETPULSE_TOOL)] bpm"
	data["total_unknown_implants"] = total_unknown_implants
	var/damaged_organs = list()
	for(var/datum/internal_organ/organ AS in patient.internal_organs)
		if(organ.damage <= organ.min_bruised_damage * 0.5)
			// allow organs to pop out when damaged but still 'functional'
			// only if their damage is close to being bruised
			continue
		var/current_organ = list(
			"name" = organ.name,
			"status" = organ.organ_status == ORGAN_BRUISED ? "Damaged" : organ.organ_status == ORGAN_BROKEN ? "Failing" : "Functional",
			"broken_damage" = organ.min_broken_damage,
			"bruised_damage" = organ.min_bruised_damage,
			"damage" = round(organ.damage, 0.1),
			"effects" = organ.damage_description,
		)
		damaged_organs += list(current_organ)
	data["damaged_organs"] = damaged_organs

	var/organic_patient = !(patient.species.species_flags & (IS_SYNTHETIC|ROBOTIC_LIMBS))
	var/revivable_patient = FALSE

	if(HAS_TRAIT(patient, TRAIT_IMMEDIATE_DEFIB))
		revivable_patient = TRUE
	else if(issynth(patient))
		if(patient.health >= patient.get_death_threshold())
			revivable_patient = TRUE
	else if(patient.health + patient.getOxyLoss() + (DEFIBRILLATOR_HEALING_TIMES_SKILL(user.skills.getRating(SKILL_MEDICAL), DEFIBRILLATOR_BASE_HEALING_VALUE)) >= patient.get_death_threshold())
		revivable_patient = TRUE

	if(HAS_TRAIT(patient, TRAIT_UNDEFIBBABLE))
		data["revivable_string"] = "Permanently deceased" // the actual information shown next to "revivable:" in tgui. "too much damage" etc.
		data["revivable_boolean"] = FALSE // the actual TRUE/FALSE entry used by tgui. if false, revivable text is red. if true, revivable text is yellow
	else if(organic_patient && !patient.has_working_organs())
		data["revivable_string"] = "Not ready to defibrillate - heart too damaged"
		data["revivable_boolean"] = FALSE
	else if(revivable_patient)
		data["revivable_string"] = "Ready to [organic_patient ? "defibrillate" : "reboot"]" // Ternary for defibrillate or reboot for some IC flavor
		data["revivable_boolean"] = TRUE
	else
		data["revivable_string"] = "Not ready to [organic_patient ? "defibrillate" : "reboot"] - repair damage above [patient.get_death_threshold() / patient.maxHealth * 100 - (organic_patient ? (DEFIBRILLATOR_HEALING_TIMES_SKILL(user.skills.getRating(SKILL_MEDICAL), DEFIBRILLATOR_BASE_HEALING_VALUE)) : 0)]%"
		data["revivable_boolean"] = FALSE

	var/list/advice = list()
	if(!HAS_TRAIT(patient, TRAIT_UNDEFIBBABLE))
		for(var/advice_type AS in GLOB.scanner_advice)
			var/datum/scanner_advice/advice_datum = GLOB.scanner_advice[advice_type]
			if(!advice_datum.can_show(patient, user))
				continue
			var/list/advice_data = advice_datum.get_data(patient, user)
			if(!length(advice_data))
				// in the case of advice that fires but returns an empty list because all its data is conditional
				continue
			if(islist(advice_data[1]))
				// if there are lists in the return value it's safe to assume it returns multiple advice entries
				for(var/list/data_iter in advice_data)
					advice += list(data_iter)
			else
				advice += list(advice_data)

	if(length(advice))
		data["advice"] = advice
	else
		data["advice"] = null

	var/ssd = null
	if(patient.has_brain() && patient.stat != DEAD)
		if(!patient.key)
			ssd = "No soul detected." // Catatonic- NPC, or ghosted
		else if(!patient.client)
			ssd = "Space Sleep Disorder detected." // SSD
	data["ssd"] = ssd

	SEND_SIGNAL(src, COMSIG_HEALTH_SCAN_DATA, patient, data.Copy())
	return data
