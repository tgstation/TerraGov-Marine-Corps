/// Checks the owner's medical skill for autoupdate.
#define HEALTHSCAN_AUTOUPDATE_SKILLCHECK (1<<0)
/// Autoupdate will not stop if scanning oneself.
#define HEALTHSCAN_AUTOUPDATE_SELFSCAN (1<<1)
/// Checks the update_distance if autoupdate is on.
#define HEALTHSCAN_AUTOUPDATE_RANGECHECK (1<<2)

/** Healthscan component
 * If target and owner is set, allows it to open a tgui window with the target's vitals to the owner.
 * Able to autoupdate
 * Has optional flags to allow for skillchecks, selfscan checks and rangechecks
 */
/datum/component/healthscan
	/// Whether or not to actually allow the healthscan function.
	var/active = TRUE
	/// Mob to scan
	var/mob/living/carbon/target
	/// Mob to show the tgui to
	var/mob/owner
	var/healthscan_flags = HEALTHSCAN_AUTOUPDATE_SKILLCHECK | HEALTHSCAN_AUTOUPDATE_RANGECHECK
	/// If HEALTHSCAN_AUTOUPDATE_SKILLCHECK is set, medical skillcheck requirement for autoupdate to take effect.
	var/medical_skill_check = SKILL_MEDICAL_PRACTICED
	/// The maximum distance in tiles to the target the healthscan auto_updates
	var/update_distance = 3
	/// Blacklist of scannable targets
	var/list/healthscan_blacklist = list(/mob/living/carbon/xenomorph)


/datum/component/healthscan/Initialize(new_flags)
	. = ..()
	setup_blacklist()
	if(new_flags)
		healthscan_flags = new_flags

/datum/component/healthscan/Destroy()
	reset_target()
	reset_owner()
	stop_autoupdate()
	return ..()

/datum/component/healthscan/process()
	if(!active || !target || !owner || !check_skill() || !check_selfscan() || !check_distance())
		stop_autoupdate()
		return
	update_static_data(owner)

/// Creates the typecache of the mob blacklist.
/datum/component/healthscan/proc/setup_blacklist()
	healthscan_blacklist = typecacheof(healthscan_blacklist)

/**
 * Sets a new target to scan. If no target or invalid target is given, then the target is reset.
 * Returns TRUE if new_target is a valid non-blacklisted mob, FALSE otherwise.
 */
/datum/component/healthscan/proc/set_target(mob/living/carbon/new_target)
	if(!check_target_validity(new_target))
		return FALSE
	reset_target()
	target = new_target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, /datum/component/healthscan/.proc/on_target_qdel)
	return TRUE

/// Resets the healthscan target
/datum/component/healthscan/proc/reset_target()
	SIGNAL_HANDLER
	if(!target)
		return
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = null

/// Closes the tgui and resets the target
/datum/component/healthscan/proc/on_target_qdel()
	SIGNAL_HANDLER
	SStgui.close_uis(src)
	reset_target()

/// Sets the mob the healthscan tgui should be shown to
/datum/component/healthscan/proc/set_owner(mob/new_owner)
	reset_owner()
	if(!new_owner)
		return FALSE
	owner = new_owner
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, /datum/component/healthscan/.proc/on_owner_qdel)
	return TRUE

/// Resets the owner of the healthscan tgui and closes the tgui.
/datum/component/healthscan/proc/reset_owner(close_tgui = TRUE)
	if(close_tgui)
		SStgui.close_uis(src)
	if(!owner)
		return
	UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
	owner = null

/// Closes the tgui and resets the owner
/datum/component/healthscan/proc/on_owner_qdel()
	SIGNAL_HANDLER
	reset_owner()

/// Opens the tgui window to the owner and shows the healthdata of the target.
/datum/component/healthscan/proc/scan_target(mob/living/carbon/new_target)
	if(new_target)
		set_target(new_target)
	if(!active || !target || !owner || !owner.key)
		return
	ui_interact(owner)
	update_static_data(owner)
	if(!check_skill() || !check_selfscan() || !check_distance())
		return
	start_autoupdate()

/// Checks the medical skill requirement from var/medical_skill_check
/datum/component/healthscan/proc/check_skill()
	return (!(healthscan_flags & HEALTHSCAN_AUTOUPDATE_SKILLCHECK) || owner.skills.getRating("medical") >= medical_skill_check)

/// Checks for the distance between target and owner
/datum/component/healthscan/proc/check_distance()
	return (!(healthscan_flags & HEALTHSCAN_AUTOUPDATE_RANGECHECK) || get_dist(get_turf(owner), get_turf(target)) <= update_distance)

/// Checks if you can self-scan with autoupdate
/datum/component/healthscan/proc/check_selfscan()
	return (healthscan_flags & HEALTHSCAN_AUTOUPDATE_SELFSCAN || target != owner )

/datum/component/healthscan/proc/check_target_validity(mob/living/carbon/new_target)
	return (new_target && iscarbon(new_target) && !(new_target in healthscan_blacklist))

/// Starts the autoupdate
/datum/component/healthscan/proc/start_autoupdate()
	START_PROCESSING(SSobj, src)
	SEND_SIGNAL(parent, COMSIG_HEALTHSCAN_AUTOSCAN_STARTED)
	if(owner)
		SEND_SIGNAL(owner, COMSIG_HEALTHSCAN_AUTOSCAN_STARTED)

/// Stops the autoupdate from continuing
/datum/component/healthscan/proc/stop_autoupdate()
	STOP_PROCESSING(SSobj, src)
	SEND_SIGNAL(parent, COMSIG_HEALTHSCAN_AUTOSCAN_STOPPED)
	if(owner)
		SEND_SIGNAL(owner, COMSIG_HEALTHSCAN_AUTOSCAN_STOPPED)

/datum/component/healthscan/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MedScanner", "Medical Scanner")
		ui.open()

/datum/component/healthscan/ui_static_data(mob/user)
	var/list/data = list(
		"patient" = target.name,
		"dead" = (target.stat == DEAD || HAS_TRAIT(target, TRAIT_FAKEDEATH)),
		"health" = target.health,
		"total_brute" = round(target.getBruteLoss()),
		"total_burn" = round(target.getFireLoss()),
		"toxin" = round(target.getToxLoss()),
		"oxy" = round(target.getOxyLoss()),
		"clone" = round(target.getCloneLoss()),

		"revivable" = target.getBruteLoss() + target.getFireLoss() + target.getToxLoss() + target.getOxyLoss() + target.getCloneLoss() <= 200,

		"blood_type" = target.blood_type,
		"blood_amount" = target.blood_volume,

		"hugged" = (locate(/obj/item/alien_embryo) in target)
	)
	data["has_unknown_chemicals"] = FALSE
	var/list/chemicals_lists = list()
	for(var/datum/reagent/reagent AS in target.reagents.reagent_list)
		if(!reagent.scannable)
			data["has_unknown_chemicals"] = TRUE
			continue
		chemicals_lists["[reagent.name]"] = list(
			"name" = reagent.name,
			"amount" = round(reagent.volume, 0.1),
			"od" = reagent.overdosed,
			"dangerous" = reagent.overdosed || istype(reagent, /datum/reagent/toxin)
		)
	data["has_chemicals"] = length(target.reagents.reagent_list)
	data["chemicals_lists"] = chemicals_lists

	var/list/limb_data_lists = list()
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/infection_message
		var/infected = 0
		var/internal_bleeding

		var/unknown_implants = 0
		for(var/datum/limb/limb AS in human_target.limbs)
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
		data["body_temperature"] = "[round(human_target.bodytemperature*1.8-459.67, 0.1)] degrees F ([round(human_target.bodytemperature-T0C, 0.1)] degrees C)"
		data["pulse"] = "[human_target.get_pulse(GETPULSE_TOOL)] bpm"
		data["implants"] = unknown_implants
		var/damaged_organs = list()
		for(var/datum/internal_organ/organ AS in human_target.internal_organs)
			if(organ.organ_status == ORGAN_HEALTHY)
				continue
			var/current_organ = list(
				"name" = organ.name,
				"status" = organ.organ_status == ORGAN_BRUISED ? "Bruised" : "Broken",
				"damage" = organ.damage
			)
			damaged_organs += list(current_organ)
		data["damaged_organs"] = damaged_organs

	if(target.has_brain() && target.stat != DEAD && ishuman(target))
		if(!target.key)
			data["ssd"] = "No soul detected." // they ghosted
		else if(!target.client)
			data["ssd"] = "SSD detected." // SSD

	return data
