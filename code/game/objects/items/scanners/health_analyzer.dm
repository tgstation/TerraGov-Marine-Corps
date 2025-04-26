GLOBAL_LIST_INIT(known_implants, subtypesof(/obj/item/implant))

/obj/item/healthanalyzer
	name = "\improper HF2 health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/medical_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/medical_right.dmi',
	)
	worn_icon_state = "healthanalyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject. The front panel is able to provide the basic readout of the subject's status."
	atom_flags = CONDUCT
	equip_slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 5
	throw_range = 10
	/// Var for if we should set autoupdating in [/obj/item/healthanalyzer/ui_status] at all.
	/// Check the comment in that proc for more, but basically tgui's system for managing autoupdating
	/// is far too vague for what we're doing. We have to use a workaround to avoid dimming the UI and closing it.
	/// *This var is not for disabling autoupdates in the first place.*
	var/allow_live_autoupdating = TRUE
	/// Skill required to bypass the fumble time.
	var/skill_threshold = SKILL_MEDICAL_NOVICE
	/// Skill required to have the scanner auto refresh
	var/upper_skill_threshold = SKILL_MEDICAL_NOVICE
	/// Current mob being tracked by the scanner
	var/mob/living/carbon/human/patient
	/// Distance the user can be away from the patient and still get health data.
	var/track_distance = 3
	/// Cooldown for showing a scan to somebody
	COOLDOWN_DECLARE(show_scan_cooldown)

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	. += span_notice("You can set \the [src] to use a more accessible theme in your game preferences.")

/obj/item/healthanalyzer/attack(mob/living/carbon/patient_candidate, mob/living/user)
	. = ..()
	analyze_vitals(patient_candidate, user)

/obj/item/healthanalyzer/attack_alternate(mob/living/carbon/patient_candidate, mob/living/user)
	. = ..()
	analyze_vitals(patient_candidate, user, TRUE)

/**
 * If `user` is too unskilled, not on the same tile as src, `user` is out of tracking range,
 * or it's a self scan, we return `FALSE`.
 *
 * Otherwise, we return `TRUE`.
 */
/obj/item/healthanalyzer/proc/autoupdate_checks(mob/living/user, mob/living/patient)
	if(user.skills.getRating(SKILL_MEDICAL) < upper_skill_threshold)
		return FALSE
	if(get_turf(src) != get_turf(user))
		return FALSE
	if(get_dist(get_turf(user), get_turf(patient)) > track_distance)
		return FALSE
	if(patient == user)
		return FALSE
	return TRUE

/**
 * A wrapper proc, so integrated health analyzers can be used by signals/their parents/whatever.
 *
 * * `patient_candidate` - Only carbon humans are supported. This is who we will be scanning.
 * * `user` - Any mob is supported. This is who the scan is shown to, unless `show_patient` is active.
 * * `show_patient` - If this is TRUE, we'll show the scan to `patient_candidate` instead of `user`.
 */
/obj/item/healthanalyzer/proc/analyze_vitals(mob/living/carbon/patient_candidate, mob/living/user, show_patient)
	if(user.skills.getRating(SKILL_MEDICAL) < skill_threshold)
		to_chat(user, span_warning("You start fumbling around with [src]..."))
		if(!do_after(user, max(SKILL_TASK_AVERAGE - (1 SECONDS * user.skills.getRating(SKILL_MEDICAL)), 0), NONE, patient_candidate, BUSY_ICON_UNSKILLED))
			return
	if(!iscarbon(patient_candidate))
		balloon_alert(user, "Cannot scan")
		return
	if(isxeno(patient_candidate) || patient_candidate.species.species_flags & NO_SCAN)
		balloon_alert(user, "Unknown error")
		return
	patient = patient_candidate
	if(show_patient)
		if(!COOLDOWN_FINISHED(src, show_scan_cooldown))
			balloon_alert(user, "wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, show_scan_cooldown))]")
			return
		if(patient_candidate.faction != user.faction)
			balloon_alert(user, "incompatible factions")
			return
		if(!patient_candidate.client?.prefs?.allow_being_shown_health_scan)
			balloon_alert(user, "can't show healthscan")
			return
		balloon_alert_to_viewers("Showed healthscan", vision_distance = 4)
		ui_interact(patient_candidate)
		COOLDOWN_START(src, show_scan_cooldown, 3 SECONDS)
	else
		ui_interact(user)
	playsound(src.loc, 'sound/items/healthanalyzer.ogg', 45)

/obj/item/healthanalyzer/ui_state(mob/user)
	if(!isobserver(user))
		return GLOB.not_incapacitated_state
	return GLOB.observer_state

/obj/item/healthanalyzer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MedScanner", "Medical Scanner")
		ui.open()
	allow_live_autoupdating = TRUE

/obj/item/healthanalyzer/ui_status(mob/user, datum/ui_state/state)
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

/obj/item/healthanalyzer/ui_data(mob/user)
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
			"is_robotic_species" = !!(patient.species?.species_flags & ROBOTIC_LIMBS ? TRUE : FALSE)
		),

		"accessible_theme" = user.client?.prefs?.accessible_tgui_themes
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

	var/list/limb_data_lists = list()
	if(!ishuman(patient)) // how did we get here?
		return

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

	// Advice: long list of if() checks incoming, there's really no better way to handle this
	var/list/advice = list()
	var/list/temp_advice = list()
	if(!HAS_TRAIT(patient, TRAIT_UNDEFIBBABLE)) // only show advice at all if the patient is coming back
		//random stuff that docs should be aware of. possible todo: make a system so we can put these in a collapsible tgui element if there's more added here.
		if(patient.maxHealth != LIVING_DEFAULT_MAX_HEALTH)
			advice += list(list(
				"advice" = "Patient has [patient.maxHealth / LIVING_DEFAULT_MAX_HEALTH * 100]% constitution.",
				"tooltip" = patient.maxHealth < LIVING_DEFAULT_MAX_HEALTH ? "Patient has less maximum health than most humans." : "Patient has more maximum health than most humans.",
				"icon" = patient.maxHealth < LIVING_DEFAULT_MAX_HEALTH ? FA_ICON_HEART_BROKEN : FA_ICON_HEARTBEAT,
				"color" = patient.maxHealth < LIVING_DEFAULT_MAX_HEALTH ? "grey" : "pink"
			))
		//species advice. possible todo: make a system so we can put these in a collapsible tgui element
		if(issynth(patient)) //specifically checking synth/robot here as these are specific to whichever species
			advice += list(list(
				"advice" = "Synthetic: Patient does not heal on defibrillation.",
				"tooltip" = "Synthetics do not heal when being shocked with a defibrillator, meaning they are only revivable over [patient.get_death_threshold() / patient.maxHealth * 100]% health.",
				"icon" = FA_ICON_ROBOT,
				"color" = "label"
			))
			advice += list(list(
				"advice" = "Synthetic: Patient overheats while lower than [SYNTHETIC_CRIT_THRESHOLD / patient.maxHealth * 100]% health.",
				"tooltip" = "Synthetics overheat rapidly while their health is lower than [SYNTHETIC_CRIT_THRESHOLD / patient.maxHealth * 100]%. When defibrillating, the patient should be repaired above this threshold to avoid unnecessary burning.",
				"icon" = FA_ICON_ROBOT,
				"color" = "label"
			))
			advice += list(list(
				"advice" = "Synthetic: Patient does not suffer from brain-death.",
				"tooltip" = "Synthetics don't expire after 5 minutes of death.",
				"icon" = FA_ICON_ROBOT,
				"color" = "label"
			))
		else if(isrobot(patient))
			advice += list(list(
				"advice" = "Combat Robot: Patient can be immediately defibrillated.",
				"tooltip" = "Combat Robots can be defibrillated regardless of health. It is highly advised to defibrillate them the moment their armor is removed instead of attempting repair.",
				"icon" = FA_ICON_ROBOT,
				"color" = "label"
			))
			advice += list(list(
				"advice" = "Combat Robot: Patient does not enter critical condition.",
				"tooltip" = "Combat Robots do not enter critical condition. They will continue operating until death at [patient.get_death_threshold() / patient.maxHealth * 100]% health.",
				"icon" = FA_ICON_ROBOT,
				"color" = "label"
			))
		if(patient.stat == DEAD) // death advice
			var/dead_color
			switch(patient.dead_ticks)
				if(0 to 0.4 * TIME_BEFORE_DNR)
					dead_color = "yellow"
				if(0.4 * TIME_BEFORE_DNR to 0.8 * TIME_BEFORE_DNR)
					dead_color = "orange"
				if(0.8 * TIME_BEFORE_DNR to INFINITY)
					dead_color = "red"
			if(!issynth(patient)) // specifically checking for synths here because synths don't expire but robots do
				advice += list(list(
					"advice" = "Time remaining to revive: [DisplayTimeText((TIME_BEFORE_DNR-(patient.dead_ticks))*20)].",
					"tooltip" = "This is how long until the patient is permanently unrevivable. Stasis bags pause this timer.",
					"icon" = FA_ICON_CLOCK,
					"color" = dead_color
					))
			if(patient.wear_suit && patient.wear_suit.atom_flags & CONDUCT)
				advice += list(list(
					"advice" = "Remove patient's suit or armor.",
					"tooltip" = "To defibrillate the patient, you need to remove anything conductive obscuring their chest.",
					"icon" = FA_ICON_SHIELD_ALT,
					"color" = "blue"
					))
			if(revivable_patient)
				advice += list(list(
					"advice" = "Administer shock via defibrillator!",
					"tooltip" = "The patient is ready to be revived, defibrillate them as soon as possible!",
					"icon" = FA_ICON_BOLT,
					"color" = "yellow"
					))
		if(patient.getBruteLoss() > 5)
			if(organic_patient)
				advice += list(list(
					"advice" = "Use trauma kits or sutures to repair the bruised areas.",
					"tooltip" = "Advanced trauma kits will heal brute damage, scaling with how proficient you are in the Medical field. Treated wounds slowly heal on their own.",
					"icon" = FA_ICON_BAND_AID,
					"color" = "green"
					))
			else
				advice += list(list(
					"advice" = "Use a blowtorch or nanopaste to repair the dented areas.",
					"tooltip" = "Only a blowtorch or nanopaste can repair dented robotic limbs.",
					"icon" = FA_ICON_TOOLS,
					"color" = "red"
				))
		if(patient.getFireLoss() > 5)
			if(organic_patient)
				advice += list(list(
					"advice" = "Use burn kits or sutures to repair the burned areas.",
					"tooltip" = "Advanced burn kits will heal burn damage, scaling with how proficient you are in the Medical field. Treated wounds slowly heal on their own.",
					"icon" = FA_ICON_BAND_AID,
					"color" = "orange"
					))
			else
				advice += list(list(
					"advice" = "Use cable coils or nanopaste to repair the scorched areas.",
					"tooltip" = "Only cable coils or nanopaste can repair scorched robotic limbs.",
					"icon" = FA_ICON_PLUG,
					"color" = "orange"
				))
		if(patient.getCloneLoss() > 5)
			advice += list(list(
				"advice" = organic_patient ? "Patient should sleep or seek cryo treatment - cellular damage." : "Patient should seek a robotic cradle - integrity damage.",
				"tooltip" = "[organic_patient ? "Cellular damage" : "Integrity damage"] is sustained from psychic draining, special chemicals and special weapons. It can only be healed through the aforementioned methods.",
				"icon" = organic_patient ? FA_ICON_DNA : FA_ICON_WRENCH,
				"color" = "teal"
				))
		if(total_unknown_implants)
			advice += list(list(
				"advice" = "Remove embedded objects with tweezers.",
				"tooltip" = "While moving with embedded objects inside, the patient will randomly sustain Brute damage. Make sure to take some time in between removing large amounts of implants to avoid internal damage.",
				"icon" = FA_ICON_WINDOW_CLOSE,
				"color" = "red"
				))
		if(organic_patient) // human advice, includes chems
			if(patient.status_flags & XENO_HOST)
				advice += list(list(
					"advice" = "Alien embryo detected. Immediate surgical intervention advised.", // friend detected :)
					"tooltip" = "The patient has been implanted with an alien embryo! Left untreated, it will burst out of their chest. Surgical intervention is strongly advised.",
					"icon" = FA_ICON_WORM,
					"color" = "orange"
					))
			if(internal_bleeding)
				advice += list(list(
					"advice" = "Internal bleeding detected. Cryo treatment advised.",
					"tooltip" = "Alongside cryogenic treatment, Quick Clot Plus can remove internal bleeding, or normal Quick Clot reduces its symptoms.",
					"icon" = FA_ICON_TINT,
					"color" = "crimson"
					))
			if(infection_message)
				temp_advice = list(list(
					"advice" = "Administer a single dose of spaceacillin. Infections detected.",
					"tooltip" = "There are one or more infections detected. If left untreated, they may worsen into Necrosis and require surgery.",
					"icon" = FA_ICON_BIOHAZARD,
					"color" = "olive"
					))
				if(chemicals_lists["Spaceacillin"])
					if(chemicals_lists["Spaceacillin"]["amount"] < 2)
						advice += temp_advice
				else
					advice += temp_advice
			var/datum/internal_organ/brain/brain = patient.get_organ_slot(ORGAN_SLOT_BRAIN)
			if(brain.organ_status != ORGAN_HEALTHY)
				temp_advice = list(list(
					"advice" = "Administer a single dose of alkysine.",
					"tooltip" = "Significant brain damage detected. Alkysine heals brain damage. If left untreated, patient may be unable to function well.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "blue"
					))
				if(chemicals_lists["Alkysine"])
					if(chemicals_lists["Alkysine"]["amount"] < 3)
						advice += temp_advice
				else
					advice += temp_advice
			var/datum/internal_organ/eyes/eyes = patient.get_organ_slot(ORGAN_SLOT_EYES)
			if(eyes.organ_status != ORGAN_HEALTHY)
				temp_advice = list(list(
					"advice" = "Administer a single dose of imidazoline.",
					"tooltip" = "Eye damage detected. Imidazoline heals eye damage. If left untreated, patient may be unable to see properly.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "yellow"
					))
				if(chemicals_lists["Imidazoline"])
					if(chemicals_lists["Imidazoline"]["amount"] < 3)
						advice += temp_advice
				else
					advice += temp_advice
			if(patient.getBruteLoss(organic_only = TRUE) > 30 && !chemicals_lists["Medical nanites"])
				temp_advice = list(list(
					"advice" = "Administer a single dose of bicaridine to reduce physical trauma.",
					"tooltip" = "Significant physical trauma detected. Bicaridine reduces brute damage.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "red"
					))
				if(chemicals_lists["Bicaridine"])
					if(chemicals_lists["Bicaridine"]["amount"] < 3)
						advice += temp_advice
				else
					advice += temp_advice
			if(patient.getFireLoss(organic_only = TRUE) > 30 && !chemicals_lists["Medical nanites"])
				temp_advice = list(list(
					"advice" = "Administer a single dose of kelotane to reduce burns.",
					"tooltip" = "Significant tissue burns detected. Kelotane reduces burn damage.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "yellow"
					))
				if(chemicals_lists["Kelotane"])
					if(chemicals_lists["Kelotane"]["amount"] < 3)
						advice += temp_advice
				else
					advice += temp_advice
			if(patient.getToxLoss() > 15)
				temp_advice = list(list(
					"advice" = "Administer a single dose of dylovene.",
					"tooltip" = "Significant blood toxins detected. Dylovene will reduce toxin damage, or their liver will filter it out on its own. Damaged livers will take even more damage while clearing blood toxins.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "green"
					))
				if(chemicals_lists["Dylovene"])
					if(chemicals_lists["Dylovene"]["amount"] < 5)
						advice += temp_advice
				else
					advice += temp_advice
			if(patient.getOxyLoss() > 30)
				temp_advice = list(list(
					"advice" = "Administer a single dose of dexalin plus to re-oxygenate patient's blood.",
					"tooltip" = "If you don't have Dexalin or Dexalin Plus, CPR or treating their other symptoms and waiting for their bloodstream to re-oxygenate will work.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "blue"
					))
				if(chemicals_lists["Dexalin Plus"])
					if(chemicals_lists["Dexalin Plus"]["amount"] < 3)
						advice += temp_advice
				else
					advice += temp_advice
			if(patient.blood_volume <= 500 && !chemicals_lists["Saline-Glucose"])
				advice += list(list(
					"advice" = "Administer a single dose of Isotonic solution.",
					"tooltip" = "The patient has lost a significant amount of blood. Isotonic solution speeds up blood regeneration significantly.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "cyan"
					))
			if(chemicals_lists["Medical nanites"])
				temp_advice = list(list(
					"advice" = "Nanites detected - only administer Peridaxon Plus, Quickclot and Dylovene.",
					"tooltip" = "Nanites purge all medicines except Peridaxon Plus, Quick Clot/Quick Clot Plus and Dylovene.",
					"icon" = FA_ICON_WINDOW_CLOSE,
					"color" = "blue"
					))
				advice += temp_advice
			if(patient.stat != DEAD && patient.health < patient.get_crit_threshold())
				temp_advice = list(list(
					"advice" = "Administer a single dose of inaprovaline.",
					"tooltip" = "When used in hard critical condition, Inaprovaline prevents suffocation and heals the patient, triggering a 5 minute cooldown.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "purple"
					))
				if(chemicals_lists["Inaprovaline"])
					if(chemicals_lists["Inaprovaline"]["amount"] < 5)
						advice += temp_advice
				else
					advice += temp_advice
			var/has_pain = FALSE
			if(patient.traumatic_shock > 50)
				has_pain = TRUE

			if(has_pain && !chemicals_lists["Paracetamol"] && !chemicals_lists["Medical nanites"])
				temp_advice = list(list(
					"advice" = "Administer a single dose of tramadol to reduce pain.",
					"tooltip" = "The patient is experiencing performance impeding pain and may suffer symptoms from sluggishness to collapsing. Tramadol reduces pain.",
					"icon" = FA_ICON_SYRINGE,
					"color" = "grey"
					))
				if(chemicals_lists["Tramadol"])
					if(chemicals_lists["Tramadol"]["amount"] < 3)
						advice += temp_advice
				else
					advice += temp_advice

			if(chemicals_lists["Paracetamol"])
				advice += list(list(
					"advice" = "Paracetamol detected - do NOT administer tramadol.",
					"tooltip" = "The patient has Paracetamol in their system. If Tramadol is administered, it will combine with Paracetamol to make Soporific, an anesthetic.",
					"icon" = FA_ICON_WINDOW_CLOSE,
					"color" = "red"
					))
	else
		advice += list(list(
			"advice" = "Patient is unrevivable.",
			"tooltip" = "The patient is permanently deceased. Can occur through being dead longer than 5 minutes, decapitation, DNR on record, or soullessness.",
			"icon" = "ribbon",
			"color" = "white"
			))
	if(advice.len)
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

	return data

/obj/item/healthanalyzer/integrated
	name = "\improper HF2 integrated health analyzer"
	desc = "A body scanner able to distinguish vital signs of the subject. This model has been integrated into another object, and is simpler to use."
	skill_threshold = SKILL_MEDICAL_UNTRAINED

/obj/item/healthanalyzer/gloves
	name = "\improper HF2 Medical Gloves"
	desc = "Advanced medical gloves, these include a built-in analyzer to quickly scan patients."
	icon_state = "medscan_gloves"
	worn_icon_state = "medscan_gloves"
	equip_slot_flags = ITEM_SLOT_GLOVES
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	item_state_worn = TRUE
	siemens_coefficient = 0.50
	blood_sprite_state = "bloodyhands"
	armor_protection_flags = HANDS
	equip_slot_flags = ITEM_SLOT_GLOVES
	attack_verb = "scans"
	soft_armor = list(MELEE = 25, BULLET = 15, LASER = 10, ENERGY = 15, BOMB = 15, BIO = 5, FIRE = 15, ACID = 15)
	cold_protection_flags = HANDS
	heat_protection_flags = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/healthanalyzer/gloves/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(user.gloves == src)
		RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
		RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK_ALTERNATE, PROC_REF(on_unarmed_attack_alternate))

	else
		UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)

/obj/item/healthanalyzer/gloves/unequipped(mob/living/carbon/human/user, slot)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK) //Unregisters in the case of getting delimbed
	UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK_ALTERNATE) //Unregisters in the case of getting delimbed


//when you are wearing these gloves, this will call the normal attack code to health scan the target
/obj/item/healthanalyzer/gloves/proc/on_unarmed_attack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.a_intent != INTENT_HELP)
		return
	if(istype(user) && istype(target))
		analyze_vitals(target, user)

///Used for right click and showing the patient their scan
/obj/item/healthanalyzer/gloves/proc/on_unarmed_attack_alternate(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.a_intent != INTENT_HELP)
		return
	if(istype(user) && istype(target))
		analyze_vitals(target, user, TRUE)

/obj/item/healthanalyzer/gloves/attack(mob/living/carbon/patient_candidate, mob/living/user)
	. = ..()
	if(user.a_intent != INTENT_HELP)
		return
	analyze_vitals(patient_candidate, user)

/obj/item/healthanalyzer/gloves/attack_alternate(mob/living/carbon/patient_candidate, mob/living/user)
	. = ..()
	if(user.a_intent != INTENT_HELP)
		return
	analyze_vitals(patient_candidate, user, TRUE)
