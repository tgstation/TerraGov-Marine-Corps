#define AUTODOC_NOTICE_SUCCESS 1
#define AUTODOC_NOTICE_DEATH 2
#define AUTODOC_NOTICE_NO_RECORD 3
#define AUTODOC_NOTICE_NO_POWER 4
#define AUTODOC_NOTICE_XENO_FUCKERY 5
#define AUTODOC_NOTICE_IDIOT_EJECT 6
#define AUTODOC_NOTICE_FORCE_EJECT 7

#define SURGERY_CATEGORY_UNKNOWN 0
#define SURGERY_CATEGORY_LIMB 1
#define SURGERY_CATEGORY_ORGAN 2
#define SURGERY_CATEGORY_EXTERNAL 3

#define SURGERY_PROCEDURE_UNKNOWN 0
#define SURGERY_PROCEDURE_LIMB_INTERNAL 1
#define SURGERY_PROCEDURE_LIMB_FACIAL 2
#define SURGERY_PROCEDURE_LIMB_BROKEN 3
#define SURGERY_PROCEDURE_LIMB_MISSING 4
#define SURGERY_PROCEDURE_LIMB_NECROTIZED 5
#define SURGERY_PROCEDURE_LIMB_IMPLANTS 6 // Shrapnel and alien embryos.
#define SURGERY_PROCEDURE_LIMB_GERMS 7
#define SURGERY_PROCEDURE_LIMB_OPEN 8
#define SURGERY_PROCEDURE_ORGAN_DAMAGE 9
#define SURGERY_PROCEDURE_ORGAN_EYES 10
#define SURGERY_PROCEDURE_ORGAN_GERMS 11
#define SURGERY_PROCEDURE_EXTERNAL_BRUTE 12
#define SURGERY_PROCEDURE_EXTERNAL_BURN 13
#define SURGERY_PROCEDURE_EXTERNAL_TOXIN 14
#define SURGERY_PROCEDURE_EXTERNAL_DIALYSIS 15
#define SURGERY_PROCEDURE_EXTERNAL_BLOOD 16

#define UNNEEDED_DELAY 10 SECONDS // How long to waste if someone queues an unneeded surgery.

//Autodoc
/obj/machinery/autodoc
	name = "\improper autodoc medical system"
	desc = "A fancy machine developed to be capable of operating on people with minimal human intervention. However, the interface is rather complex and most of it would only be useful to trained medical personnel."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "autodoc_open"
	density = TRUE
	anchored = TRUE
	coverage = 20
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP)
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	dir = EAST
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 15
	active_power_usage = 120000 // It rebuilds you from nothing...
	/// The connected autodoc console.
	var/obj/machinery/computer/autodoc_console/connected
	/// The human that is currently inside of the machine.
	var/mob/living/carbon/human/occupant = null
	/// Do users need access to interact with this?
	var/locked = FALSE
	/// A list of surgeries that should be done in order.
	var/list/datum/autodoc_surgery/surgery_list = list()
	// Is there active surgery going on? If so, what surgery is it?
	var/datum/autodoc_surgery/active_surgery
	/// The amount to multiply surgery times by.
	var/surgery_time_multiplier = 1
	/// Every process, how many units of each chemical in the occupant's reagents should be removed? Default: 10.
	var/filtering = 0
	/// Every process, how many units of blood should the occupant gain? Default: 8.
	var/blood_transfer = 0
	/// Every process, how many brute damage should be healed? Default: 3.
	var/heal_brute = 0
	/// Every process, how many burn damage should be healed? Default: 3.
	var/heal_burn = 0
	/// Every process, how many toxin damage should be healed? Default: 3.
	var/heal_toxin = 0
	/// Should the surgery list be automatically generated and automatically start?
	var/automatic_mode = 0
	/// What surgery skill level does the user need to not fumble?
	var/required_skill_level = SKILL_SURGERY_TRAINED
	/// Is the occupant going to be forcibly ejected? Used for async.
	var/forcibly_ejected = FALSE
	/// How much metal is currently stored? Used for limb replacements.
	var/stored_metal = LIMB_METAL_AMOUNT * 8
	/// The maximum amount of metal that can be stored.
	var/stored_metal_max = LIMB_METAL_AMOUNT * 16
	/// The timer ID to callback the surgery operation loop.
	var/surgery_timer_id
	/// The timer ID to callback the autostart.
	var/autostart_timer_id

/obj/machinery/autodoc/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(shuttle_crush))
	update_icon()

/obj/machinery/autodoc/Destroy()
	forcibly_ejected = TRUE
	INVOKE_ASYNC(src, PROC_REF(try_ejecting))
	if(connected)
		connected.connected = null
		connected = null
	return ..()

/obj/machinery/autodoc/power_change()
	. = ..()
	if(is_operational() || !occupant)
		return
	visible_message("[src] engages the safety override, ejecting the occupant.")
	do_eject(AUTODOC_NOTICE_NO_POWER)

/obj/machinery/autodoc/update_icon()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
		return
	if(occupant || is_active())
		set_light(initial(light_range) + 1)
		return
	set_light(initial(light_range))

/obj/machinery/autodoc/update_icon_state()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "autodoc_off"
		return
	if(is_active())
		icon_state = "autodoc_operate"
		return
	if(occupant)
		icon_state = "autodoc_closed"
		return
	icon_state = "autodoc_open"

/obj/machinery/autodoc/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", src, alpha = src.alpha)

/obj/machinery/autodoc/process()
	if(!occupant)
		return
	if(occupant.stat == DEAD)
		say("Patient has expired.")
		do_eject(AUTODOC_NOTICE_DEATH)
		return
	if(!length(surgery_list) && !is_active()) // Everything, including external surgeries, are done.
		visible_message("\The [src] clicks and opens up having finished the requested operations.")
		do_eject(AUTODOC_NOTICE_SUCCESS)
		return

	if(prob(5))
		visible_message("[src] beeps as it continues working.")

	occupant.adjustToxLoss(-0.5) // Pretend that they're getting dylovene. We don't want to add reagents only for it to be filtered away.
	occupant.adjustOxyLoss(-occupant.getOxyLoss()) // Pretend that they're getting Dexalin+. Ditto above.
	if(filtering)
		var/something_filtered = FALSE
		for(var/datum/reagent/held_reagent in occupant.reagents.reagent_list)
			if(occupant.reagents.remove_reagent(held_reagent.type, filtering))
				something_filtered = TRUE
		if(!something_filtered)
			filtering = 0
			say("Blood filtering complete.")
		else if(prob(10))
			visible_message("[src] whirrs and gurgles as the dialysis module operates.")
			to_chat(occupant, span_info("You feel slightly better."))
	if(blood_transfer)
		if(connected && occupant.blood_volume < BLOOD_VOLUME_NORMAL)
			if(connected.blood_pack.reagents.get_reagent_amount(/datum/reagent/blood) < 4)
				connected.blood_pack.reagents.add_reagent(/datum/reagent/blood, 195, list("donor" = null,"blood_DNA" = null,"blood_type" = "O-"))
				say("Blood reserves depleted, switching to fresh bag.")
			occupant.inject_blood(connected.blood_pack, blood_transfer)
			if(prob(10))
				visible_message("[src] whirrs and gurgles as it tranfuses blood.")
				to_chat(occupant, span_info("You feel slightly less faint."))
		else
			blood_transfer = 0
			say("Blood transfer complete.")

	var/should_update_health = FALSE
	if(heal_brute)
		if(occupant.getBruteLoss() > 0)
			occupant.heal_limb_damage(heal_brute, 0)
			should_update_health = TRUE
			if(prob(10))
				visible_message("[src] whirrs and clicks as it stitches flesh together.")
				to_chat(occupant, span_info("You feel your wounds being stitched and sealed shut."))
		else
			heal_brute = 0
			say("Trauma repair surgery complete.")
	if(heal_burn)
		if(occupant.getFireLoss() > 0)
			occupant.heal_limb_damage(0, heal_burn)
			should_update_health = TRUE
			if(prob(10))
				visible_message("[src] whirrs and clicks as it grafts synthetic skin.")
				to_chat(occupant, span_info("You feel your burned flesh being sliced away and replaced."))
		else
			heal_burn = 0
			say("Skin grafts complete.")
	if(heal_toxin)
		if(occupant.getToxLoss() > 0)
			occupant.adjustToxLoss(-heal_toxin)
			should_update_health = TRUE
			if(prob(10))
				visible_message("[src] whirrs and gurgles as it kelates the occupant.")
				to_chat(occupant, span_info("You feel slighly less ill."))
		else
			heal_toxin = 0
			say("Chelation complete.")
	if(should_update_health)
		occupant.updatehealth()

/obj/machinery/autodoc/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(. || !ishuman(user))
		return
	if(istype(I, /obj/item/healthanalyzer) && occupant) // Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/healthanalyzer/health_analyzer = I
		health_analyzer.attack(occupant, user)
		return
	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/metal_stack = I
		if(stored_metal >= stored_metal_max)
			to_chat(user, span_warning("[src]'s metal reservoir is full; it can't hold any more material!"))
			return
		var/amount_to_use = min(metal_stack.amount, CEILING((stored_metal_max - stored_metal) / 100, 1)) // Only insert as much metal as required to completely fill it up.
		stored_metal = min(stored_metal_max, stored_metal + (amount_to_use * 100))
		to_chat(user, span_notice("[src] processes \the [metal_stack]. Its metal reservoir now contains [stored_metal] of [stored_metal_max] units."))
		metal_stack.use(amount_to_use) // Will qdel if there is no metal remaining.
		return

/obj/machinery/autodoc/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
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
	try_ejecting(xeno_attacker)

/obj/machinery/autodoc/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	. = ..()
	if(. || !ishuman(user))
		return
	var/mob/grabbed_mob
	if(ismob(grab.grabbed_thing))
		grabbed_mob = grab.grabbed_thing
	else if(istype(grab.grabbed_thing,/obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/cryobag = grab.grabbed_thing
		if(!cryobag.bodybag_occupant)
			to_chat(user, span_warning("The stasis bag is empty!"))
			return
		grabbed_mob = cryobag.bodybag_occupant
		cryobag.open()
		user.start_pulling(grabbed_mob)
	if(!ishuman(grabbed_mob))
		to_chat(user, span_notice("[src] is compatible with humanoid anatomies only!"))
		return
	try_entering(user, grabbed_mob)
	return TRUE

/obj/machinery/autodoc/MouseDrop_T(atom/dropping, mob/user)
	. = ..()
	if(!ishuman(dropping) || !ishuman(user))
		return
	try_entering(user, dropping)

/// Handles a mob trying to eject the occupant.
/obj/machinery/autodoc/proc/try_ejecting(mob/ejector)
	if(!occupant)
		return
	if(forcibly_ejected)
		if(!active_surgery)
			visible_message("\The [src] is destroyed, ejecting [occupant] and showering them in debris.")
			occupant.take_limb_damage(rand(10, 20), rand(10, 20))
		else
			visible_message("\The [src] malfunctions as it is destroyed mid-surgery, ejecting [occupant] with surgical wounds and showering them in debris.")
			occupant.take_limb_damage(rand(30, 50), rand(30, 50))
		do_eject(AUTODOC_NOTICE_FORCE_EJECT)
		return
	if(isxeno(ejector)) // Let xenos eject people hiding inside.
		do_eject(AUTODOC_NOTICE_XENO_FUCKERY)
		return
	if(!ishuman(ejector))
		return
	if(ejector == occupant)
		if(active_surgery)
			to_chat(ejector, span_warning("There's no way you're getting out while this thing is operating on you!"))
			return
		visible_message("[ejector] engages the internal release mechanism, and climbs out of \the [src].")
		do_eject()
		return
	var/skilled_enough = ejector.skills.getRating(SKILL_SURGERY) >= required_skill_level
	if(skilled_enough)
		do_eject()
		return
	ejector.visible_message(span_notice("[ejector] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
	var/fumbling_time = max(0 , SKILL_TASK_TOUGH - (SKILL_TASK_EASY * ejector.skills.getRating(SKILL_SURGERY))) // 8 seconds. Each skill level decreases it by 3 seconds.
	if(!do_after(ejector, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED) || !occupant)
		return
	if(!active_surgery)
		do_eject()
		return
	// Untrained people will fail to terminate the surgery properly.
	visible_message("\The [src] malfunctions as [ejector] aborts the surgery in progress.")
	occupant.take_limb_damage(rand(30, 50), rand(30, 50))
	log_game("[key_name(ejector)] ejected [key_name(occupant)] from the autodoc during surgery causing damage.")
	message_admins("[ADMIN_TPMONTY(ejector)] ejected [ADMIN_TPMONTY(occupant)] from the autodoc during surgery causing damage.")
	do_eject(AUTODOC_NOTICE_IDIOT_EJECT)

/// Ejects the occupant and ends all surgery if applicable.
/obj/machinery/autodoc/proc/do_eject(notice_code)
	for(var/atom/movable/movable_thing AS in contents)
		movable_thing.forceMove(loc)
	if(connected?.release_notice && occupant) // If auto-release notices are on as they should be, let the doctors know what's up.
		var/reason = "Reason for discharge: Procedural completion."
		switch(notice_code)
			if(AUTODOC_NOTICE_SUCCESS)
				playsound(loc, 'sound/machines/ping.ogg', 50, FALSE) // All steps finished properly; this is the 'normal' notification.
			if(AUTODOC_NOTICE_DEATH)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Patient death."
			if(AUTODOC_NOTICE_NO_RECORD)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Medical records not detected. Alerting security advised."
			if(AUTODOC_NOTICE_NO_POWER)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Power failure."
			if(AUTODOC_NOTICE_XENO_FUCKERY)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Unauthorized manual release. Alerting security advised."
			if(AUTODOC_NOTICE_IDIOT_EJECT)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Unauthorized manual release during surgery. Alerting security advised."
			if(AUTODOC_NOTICE_FORCE_EJECT)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Destruction of linked Autodoc Medical System. Alerting security advised."
		connected.radio.talk_into(src, "<b>Patient: [occupant] has been released from [src] at: [get_area(src)]. [reason]</b>", RADIO_CHANNEL_MEDICAL)
	occupant = null
	surgery_list = list()
	active_surgery = null
	filtering = 0
	blood_transfer = 0
	heal_brute = 0
	heal_burn = 0
	heal_toxin = 0
	if(surgery_timer_id)
		deltimer(surgery_timer_id)
		surgery_timer_id = null
	if(autostart_timer_id)
		deltimer(autostart_timer_id)
		autostart_timer_id = null
	if(datum_flags & DF_ISPROCESSING)
		stop_processing()
	update_icon()

/// Checks if a human can enter the machine.
/obj/machinery/autodoc/proc/can_enter(mob/living/carbon/human/mover_of_occupant, mob/living/carbon/human/future_occupant, silent = FALSE)
	if(occupant)
		if(!silent)
			to_chat(mover_of_occupant, span_notice("[src] is already occupied!"))
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN))
		if(!silent)
			to_chat(mover_of_occupant, span_notice("[src] is non-functional!"))
		return FALSE
	if(mover_of_occupant.incapacitated(TRUE))
		if(!silent)
			to_chat(mover_of_occupant, span_notice("You need to be standing for this!"))
		return FALSE
	var/subject_name = mover_of_occupant == future_occupant ? "You" : "Subject"
	if(future_occupant.stat == DEAD)
		if(!silent)
			to_chat(mover_of_occupant, span_notice("[subject_name] need to be alive to enter!"))
		return FALSE
	if(future_occupant.abiotic())
		to_chat(mover_of_occupant, span_warning("[subject_name] cannot have abiotic items on."))
		return
	return TRUE

/// Tries to move a human into the machine.
/obj/machinery/autodoc/proc/try_entering(mob/living/carbon/human/mover_of_occupant, mob/living/carbon/human/future_occupant)
	if(!can_enter(mover_of_occupant, future_occupant))
		return
	if(mover_of_occupant.skills.getRating(SKILL_SURGERY) < required_skill_level)
		mover_of_occupant.visible_message(span_notice("[mover_of_occupant] fumbles around figuring out how to use [src]."),
			span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = max(0 , SKILL_TASK_TOUGH - (SKILL_TASK_EASY * mover_of_occupant.skills.getRating(SKILL_SURGERY))) // 8 seconds. Each skill level decreases it by 3 seconds.
		if(!do_after(mover_of_occupant, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return
	mover_of_occupant.visible_message(span_notice("[mover_of_occupant] starts [mover_of_occupant == future_occupant ? "climbing" : "moving [future_occupant]"] into \the [src]."),
		span_notice("You start [mover_of_occupant == future_occupant ? "climbing" : "moving [future_occupant]"] into \the [src]."))
	if(!do_after(mover_of_occupant, 1 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_GENERIC) || !can_enter(mover_of_occupant, future_occupant))
		return
	future_occupant.stop_pulling()
	future_occupant.forceMove(src)
	occupant = future_occupant
	update_icon()
	autodoc_scan(occupant)
	if(automatic_mode)
		say("Automatic mode engaged, initialising procedures.")
		autostart_timer_id = addtimer(CALLBACK(src, PROC_REF(auto_start)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/// Callback to start the surgery operation for automatic mode.
/obj/machinery/autodoc/proc/auto_start()
	if(autostart_timer_id)
		deltimer(autostart_timer_id)
		autostart_timer_id = null
	if(active_surgery)
		return
	if(!occupant)
		say("Occupant missing, procedures canceled.")
		return
	if(!automatic_mode)
		say("Automatic mode disengaged, awaiting manual inputs.")
		return
	begin_surgery_operation()

/// Returns if the surgery is active.
/obj/machinery/autodoc/proc/is_active()
	if(active_surgery || surgery_timer_id || filtering || blood_transfer || heal_brute || heal_burn || heal_toxin)
		return TRUE
	return FALSE

/// Kicks out and gibs the occupant.
/obj/machinery/autodoc/proc/shuttle_crush()
	SIGNAL_HANDLER
	if(!occupant)
		return
	var/mob/living/carbon/human/occupant_to_gib = occupant
	do_eject() // This sets occupant to null and thus the reason why we need to get the occupant beforehand.
	occupant_to_gib.gib()

/// Populates `patient`'s medical record `autodoc_data` field with applicable surgeries.
/obj/machinery/autodoc/proc/autodoc_scan(mob/living/carbon/human/patient)
	var/datum/data/record/final_record = find_medical_record(patient, TRUE)
	final_record.fields["autodoc_data"] = generate_autodoc_surgery_list(patient)
	use_power(active_power_usage)
	visible_message(span_notice("\The [src] pings as it stores the scan report of [patient.real_name]."))
	playsound(loc, 'sound/machines/ping.ogg', 25, 1)

/// Verb to move yourself into the autodoc.
/obj/machinery/autodoc/verb/move_inside()
	set name = "Enter Autodoc Pod"
	set category = "IC.Object"
	set src in oview(1)

	if(ishuman(usr))
		try_entering(usr, usr)

/// Verb to eject whoever is in the autodoc.
/obj/machinery/autodoc/verb/eject()
	set name = "Eject Autodoc"
	set category = "IC.Object"
	set src in oview(1)

	if(usr.incapacitated())
		return
	if(locked && !allowed(usr)) // Check access if locked.
		to_chat(usr, span_warning("Access denied."))
		playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)
		return
	do_eject()

/datum/autodoc_surgery
	/// The limb that is referenced in the surgery.
	var/datum/limb/limb_reference = null
	/// The organ that is referenced in the surgery.
	var/datum/internal_organ/organ_reference = null
	/// The surgery category.
	var/surgery_category = SURGERY_CATEGORY_UNKNOWN
	/// The procedure within the surgery category.
	var/surgery_procedure = SURGERY_PROCEDURE_UNKNOWN
	/// Has this procedure been checked if it was needed?
	var/checked_for_necessity = FALSE

/datum/autodoc_surgery/New(new_limb_reference, new_organ_reference, new_surgery_category, new_surgery_procedure)
	limb_reference = new_limb_reference
	organ_reference = new_organ_reference
	surgery_category = new_surgery_category
	surgery_procedure = new_surgery_procedure

/// Generates a full list of surgeries that should be completed based on a human.
/proc/generate_autodoc_surgery_list(mob/living/carbon/human/operated_human)
	var/list/datum/autodoc_surgery/surgery_list = list()
	for(var/datum/limb/operated_limb in operated_human.limbs)
		if(length(operated_limb.wounds))
			surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_INTERNAL)
		for(var/datum/internal_organ/operated_organ in operated_limb.internal_organs)
			if(operated_organ.robotic == ORGAN_ASSISTED || operated_organ.robotic == ORGAN_ROBOT)
				continue // We can't handle robotic organs.
			if(operated_organ.organ_id == ORGAN_EYES)
				continue // Eye surgery is a seperate surgery.
			if(!operated_organ.damage)
				continue
			surgery_list += new /datum/autodoc_surgery(operated_limb, operated_organ, SURGERY_CATEGORY_ORGAN, SURGERY_PROCEDURE_ORGAN_DAMAGE)
		if(istype(operated_limb, /datum/limb/head))
			var/datum/limb/head/operated_head = operated_limb
			if(operated_head.disfigured || operated_head.face_surgery_stage > 0)
				surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_FACIAL)
		switch(operated_limb.limb_status)
			if(LIMB_BROKEN)
				surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_BROKEN)
			if(LIMB_DESTROYED)
				if(operated_limb.body_part != HEAD && !(operated_limb.parent.limb_status & LIMB_DESTROYED)) // We want to pick the missing limb that is most accurate: missing foot = foot, missing foot + leg = leg.
					surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_MISSING)
			if(LIMB_NECROTIZED)
				surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_NECROTIZED)
		var/already_added_surgery = FALSE
		if(length(operated_limb.implants))
			for(var/obj/item/implant_in_question AS in operated_limb.implants)
				if(implant_in_question.is_beneficial_implant())
					continue
				surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_IMPLANTS)
				already_added_surgery = TRUE
		if(!already_added_surgery && operated_limb.body_part == CHEST && locate(/obj/item/alien_embryo) in operated_human)
			// Larvas aren't implants. We offer the surgery if it hasn't been offered yet.
			surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_IMPLANTS)
		if(operated_limb.germ_level > INFECTION_LEVEL_ONE)
			surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_GERMS)
		if(operated_limb.surgery_open_stage)
			surgery_list += new /datum/autodoc_surgery(operated_limb, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_OPEN)

	var/datum/internal_organ/operated_organ = operated_human.get_organ_slot(ORGAN_SLOT_EYES)
	if(operated_organ && (operated_human.disabilities & NEARSIGHTED || operated_human.disabilities & BLIND || operated_organ.damage > 0))
		surgery_list += new /datum/autodoc_surgery(null, operated_organ, SURGERY_CATEGORY_ORGAN, SURGERY_PROCEDURE_ORGAN_EYES)

	if(operated_human.getBruteLoss() > 0)
		surgery_list += new /datum/autodoc_surgery(null, operated_organ, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_BRUTE)
	if(operated_human.getFireLoss() > 0)
		surgery_list += new /datum/autodoc_surgery(null, operated_organ, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_BURN)
	if(operated_human.getToxLoss() > 0)
		surgery_list += new /datum/autodoc_surgery(null, operated_organ, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_TOXIN)
	var/overdosing = FALSE
	for(var/datum/reagent/held_reagent in operated_human.reagents.reagent_list)
		if(istype(held_reagent, /datum/reagent/toxin) || operated_human.reagents.get_reagent_amount(held_reagent.type) > held_reagent.overdose_threshold)
			overdosing = TRUE
			break
	if(overdosing)
		surgery_list += new /datum/autodoc_surgery(null, operated_organ, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_DIALYSIS)
	if(operated_human.blood_volume < BLOOD_VOLUME_NORMAL)
		surgery_list += new /datum/autodoc_surgery(null, operated_organ, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_BLOOD)
	return surgery_list

/// Begins the surgery operation.
/obj/machinery/autodoc/proc/begin_surgery_operation()
	if(is_active())
		return
	if(QDELETED(occupant) || occupant.stat == DEAD)
		if(!ishuman(occupant))
			stack_trace("Non-human occupant made its way into the autodoc: [occupant] | [occupant?.type].")
		visible_message("[src] buzzes.")
		do_eject(AUTODOC_NOTICE_DEATH) // Kick them out too.
		return

	var/datum/data/record/N = null
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (R.fields["name"] == occupant.real_name)
			N = R
	if(isnull(N))
		visible_message("[src] buzzes: No records found for occupant.")
		do_eject(AUTODOC_NOTICE_NO_RECORD) // Kick them out too.
		return
	surgery_list = automatic_mode ?	N.fields["autodoc_data"] : N.fields["autodoc_manual"]
	if(!length(surgery_list))
		visible_message("[src] buzzes, no surgical procedures were queued.")
		return

	start_processing()
	for(var/datum/autodoc_surgery/surgery_in_list in surgery_list)
		if(surgery_in_list.surgery_category != SURGERY_CATEGORY_EXTERNAL)
			continue
		switch(surgery_in_list.surgery_procedure)
			if(SURGERY_PROCEDURE_EXTERNAL_BRUTE)
				heal_brute = 3
			if(SURGERY_PROCEDURE_EXTERNAL_BURN)
				heal_burn = 3
			if(SURGERY_PROCEDURE_EXTERNAL_TOXIN)
				heal_toxin = 3
			if(SURGERY_PROCEDURE_EXTERNAL_DIALYSIS)
				filtering = 10 // Same amount as sleeper.
			if(SURGERY_PROCEDURE_EXTERNAL_BLOOD)
				blood_transfer = 8 // Double IV stand rate.
		surgery_list -= surgery_in_list
	visible_message("[src] begins to operate, the pod locking shut with a loud click.")
	loop_surgery_operation()
	update_icon()

/// Continues a surgery operation based on available information at the time.
/obj/machinery/autodoc/proc/loop_surgery_operation()
	if(surgery_timer_id)
		deltimer(surgery_timer_id)
		surgery_timer_id = null
	if(!length(surgery_list)) // Process determines if everything is completed / to eject the occupant.
		return
	if(!active_surgery)
		active_surgery = surgery_list[1]

	var/datum/limb/limb_ref = active_surgery.limb_reference
	var/datum/internal_organ/organ_ref = active_surgery.organ_reference
	switch(active_surgery.surgery_category)
		if(SURGERY_CATEGORY_ORGAN)
			switch(active_surgery.surgery_procedure)
				if(SURGERY_PROCEDURE_ORGAN_DAMAGE)
					if(!active_surgery.checked_for_necessity)
						say("Beginning organ restoration.")
						active_surgery.checked_for_necessity = TRUE
						if(!organ_ref)
							handle_unnecessary_surgery()
							return
					if(!organ_ref.damage)
						if(!limb_ref.surgery_open_stage)
							handle_completed_surgery()
							return
						if(limb_ref.encased && limb_ref.surgery_open_stage >= 2.5)
							loop_in_time(close_encased(limb_ref))
							return
						loop_in_time(close_incision(occupant, limb_ref))
						return
					if(!limb_ref.surgery_open_stage)
						loop_in_time(open_incision(occupant, limb_ref))
						return
					if(limb_ref.encased && limb_ref.surgery_open_stage < 3)
						loop_in_time(open_encased(limb_ref))
						return
					if(istype(organ_ref, /datum/internal_organ/brain))
						if(organ_ref.damage > BONECHIPS_MAX_DAMAGE)
							loop_in_time(HEMOTOMA_MAX_DURATION)
							organ_ref.heal_organ_damage(organ_ref.damage - BONECHIPS_MAX_DAMAGE)
							return
						loop_in_time(BONECHIPS_REMOVAL_MAX_DURATION)
						organ_ref.heal_organ_damage(organ_ref.damage)
						return
					loop_in_time(FIX_ORGAN_MAX_DURATION)
					organ_ref.heal_organ_damage(organ_ref.damage)
					return
				if(SURGERY_PROCEDURE_ORGAN_EYES)
					if(!active_surgery.checked_for_necessity)
						say("Beginning corrective eye surgery.")
						active_surgery.checked_for_necessity = TRUE
						if(!organ_ref || !istype(organ_ref, /datum/internal_organ/eyes))
							handle_unnecessary_surgery()
							return
					var/datum/internal_organ/eyes/eye_ref = organ_ref
					if(eye_ref.eye_surgery_stage == 0)
						loop_in_time(EYE_CUT_MAX_DURATION)
						eye_ref.eye_surgery_stage = 1
						occupant.disabilities |= NEARSIGHTED
						return
					if(eye_ref.eye_surgery_stage == 1)
						loop_in_time(EYE_LIFT_MAX_DURATION)
						eye_ref.eye_surgery_stage = 2
						return
					if(eye_ref.eye_surgery_stage == 2)
						loop_in_time(EYE_MEND_MAX_DURATION)
						eye_ref.eye_surgery_stage = 3
						return
					if(eye_ref.eye_surgery_stage == 3)
						occupant.disabilities &= ~NEARSIGHTED
						occupant.disabilities &= ~BLIND
						eye_ref.heal_organ_damage(eye_ref.damage)
						eye_ref.eye_surgery_stage = 0
						handle_completed_surgery(EYE_MEND_MAX_DURATION)
						return
				if(SURGERY_PROCEDURE_ORGAN_GERMS)
					if(!active_surgery.checked_for_necessity)
						say("Beginning organ disinfection.")
						to_chat(occupant, span_info("You feel a soft prick from a needle."))
						active_surgery.checked_for_necessity = TRUE
					var/datum/reagent/spaceacillin_reagent = GLOB.chemical_reagents_list[/datum/reagent/medicine/spaceacillin]
					var/injection_amount = min(3, spaceacillin_reagent.overdose_threshold - occupant.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin))
					if(injection_amount > 0)
						occupant.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, injection_amount)
						loop_in_time(1 SECONDS)
						return
					handle_completed_surgery()
		if(SURGERY_CATEGORY_LIMB)
			switch(active_surgery.surgery_procedure)
				if(SURGERY_PROCEDURE_LIMB_INTERNAL)
					if(!active_surgery.checked_for_necessity)
						say("Beginning internal bleeding procedure.")
						active_surgery.checked_for_necessity = TRUE
						if(!limb_ref)
							handle_unnecessary_surgery()
							return
					if(!length(limb_ref.wounds))
						if(!limb_ref.surgery_open_stage)
							handle_completed_surgery()
							return
						loop_in_time(close_incision(active_surgery.limb_reference))
						occupant.updatehealth()
						return
					if(limb_ref.surgery_open_stage)
						loop_in_time(open_incision(active_surgery.limb_reference))
						occupant.updatehealth()
						return
					loop_in_time(FIXVEIN_MAX_DURATION)
					QDEL_LIST(limb_ref.wounds)
					return
				if(SURGERY_PROCEDURE_LIMB_BROKEN)
					if(!active_surgery.checked_for_necessity)
						say("Beginning broken bone procedure.")
						active_surgery.checked_for_necessity = TRUE
						if(!limb_ref)
							handle_unnecessary_surgery()
							return
					if(!(limb_ref.limb_status & LIMB_BROKEN))
						if(limb_ref.bone_repair_stage)
							loop_in_time(BONESETTER_MAX_DURATION)
							limb_ref.bone_repair_stage = 0
							return
						if(limb_ref.surgery_open_stage)
							loop_in_time(close_incision(occupant, limb_ref))
							return
						handle_completed_surgery()
						return
					if(!limb_ref.surgery_open_stage)
						loop_in_time(open_incision(occupant, limb_ref))
						return
					if(!limb_ref.bone_repair_stage)
						loop_in_time(BONEGEL_REPAIR_MAX_DURATION)
						limb_ref.bone_repair_stage = 1
						return
					if(limb_ref.brute_dam > 20) // Healing to prevent it from breaking again.
						loop_in_time((limb_ref.brute_dam - 20) / 2)
						limb_ref.heal_limb_damage(limb_ref.brute_dam - 20, updating_health = TRUE)
						return
					limb_ref.remove_limb_flags(LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED)
					limb_ref.add_limb_flags(LIMB_REPAIRED)
					loop_in_time(1)
					return
				if(SURGERY_PROCEDURE_LIMB_MISSING)
					if(!active_surgery.checked_for_necessity)
						say("Beginning limb replacement.")
						active_surgery.checked_for_necessity = TRUE
						if(!limb_ref)
							handle_unnecessary_surgery()
							return
					if(stored_metal < LIMB_METAL_AMOUNT)
						say("Metal reserves depleted.")
						playsound(loc, 'sound/machines/buzz-two.ogg', 15, TRUE)
						surgery_list -= active_surgery
						active_surgery = null
						loop_in_time(1)
						return
					if(limb_ref.parent.limb_status & LIMB_DESTROYED)
						say("Limb attachment failed.")
						playsound(loc, 'sound/machines/buzz-two.ogg', 15, TRUE)
						surgery_list -= active_surgery
						active_surgery = null
						loop_in_time(1)
						return
					if(!(limb_ref.limb_status & LIMB_AMPUTATED))
						switch(limb_ref.limb_replacement_stage)
							if(0)
								loop_in_time(ROBOLIMB_CUT_MAX_DURATION)
								limb_ref.limb_replacement_stage = 1
								return
							if(1)
								loop_in_time(ROBOLIMB_MEND_MAX_DURATION)
								limb_ref.limb_replacement_stage = 2
								return
							if(2)
								loop_in_time(ROBOLIMB_PREPARE_MAX_DURATION)
								limb_ref.add_limb_flags(LIMB_AMPUTATED)
								limb_ref.setAmputatedTree()
								limb_ref.limb_replacement_stage = 0
								return
					limb_ref.robotize()
					occupant.update_body()
					occupant.updatehealth()
					occupant.UpdateDamageIcon()
					handle_completed_surgery(LIMB_PRINTING_TIME + ROBOLIMB_ATTACH_MAX_DURATION)
					return
				if(SURGERY_PROCEDURE_LIMB_NECROTIZED)
					if(!active_surgery.checked_for_necessity)
						say("Beginning necrotic tissue removal.")
						active_surgery.checked_for_necessity = TRUE
						if(!limb_ref)
							handle_unnecessary_surgery()
							return
					if(!(limb_ref.limb_status & LIMB_NECROTIZED))
						if(limb_ref.surgery_open_stage)
							loop_in_time(close_incision(occupant, limb_ref))
							return
						handle_completed_surgery()
						return
					if(!limb_ref.surgery_open_stage)
						loop_in_time(open_incision(occupant, limb_ref))
						return
					if(!limb_ref.necro_surgery_stage)
						loop_in_time(NECRO_REMOVE_MAX_DURATION)
						limb_ref.necro_surgery_stage = 1
						return
					loop_in_time(NECRO_TREAT_MAX_DURATION)
					limb_ref.necro_surgery_stage = 0
					limb_ref.remove_limb_flags(LIMB_NECROTIZED)
					occupant.update_body()
				if(SURGERY_PROCEDURE_LIMB_IMPLANTS)
					if(!active_surgery.checked_for_necessity)
						say("Beginning foreign body removal.")
						active_surgery.checked_for_necessity = TRUE
						if(!limb_ref)
							handle_unnecessary_surgery()
							return
					var/should_surgery = (limb_ref.body_part == CHEST && locate(/obj/item/alien_embryo) in occupant)
					for(var/obj/item/implant AS in limb_ref.implants)
						if(implant.is_beneficial_implant())
							continue
						should_surgery = TRUE
						break
					if(!should_surgery)
						if(!limb_ref.surgery_open_stage)
							handle_completed_surgery()
							return
						if(limb_ref.encased && limb_ref.surgery_open_stage >= 2.5)
							loop_in_time(close_encased(limb_ref))
							return
						loop_in_time(close_incision(occupant, limb_ref))
						return
					if(!limb_ref.surgery_open_stage)
						loop_in_time(open_incision(occupant, limb_ref))
						return
					if(limb_ref.encased && limb_ref.surgery_open_stage < 3)
						loop_in_time(open_encased(limb_ref))
						return
					if(!limb_ref.surgery_open_stage)
						loop_in_time(open_incision(occupant, limb_ref))
						return
					if(limb_ref.encased && limb_ref.surgery_open_stage < 3)
						loop_in_time(open_encased(limb_ref))
						return
					if(limb_ref.body_part == CHEST) // We got to do this first because it seems more important.
						var/obj/item/alien_embryo/embyro = locate() in occupant
						if(embyro)
							for(embyro in occupant)
								loop_in_time(HEMOSTAT_REMOVE_MAX_DURATION)
								occupant.visible_message(span_warning("[src] defty extracts a wriggling parasite from [occupant]'s ribcage!"))
								var/mob/living/carbon/xenomorph/larva/live_larva = locate() in occupant // The larva was fully grown, ready to burst.
								if(live_larva)
									live_larva.forceMove(get_turf(src))
								else
									embyro.forceMove(occupant.loc)
									occupant.status_flags &= ~XENO_HOST
								qdel(embyro)
					if(length(limb_ref.implants))
						for(var/obj/item/implant AS in limb_ref.implants)
							if(implant.is_beneficial_implant())
								continue
							loop_in_time(HEMOSTAT_REMOVE_MAX_DURATION)
							implant.unembed_ourself(TRUE)
							return
				if(SURGERY_PROCEDURE_LIMB_GERMS)
					if(!active_surgery.checked_for_necessity)
						say("Beginning limb disinfection.")
						to_chat(occupant, span_info("You feel a soft prick from a needle."))
						active_surgery.checked_for_necessity = TRUE
					var/datum/reagent/spaceacillin_reagent = GLOB.chemical_reagents_list[/datum/reagent/medicine/spaceacillin]
					var/injection_amount = min(3, spaceacillin_reagent.overdose_threshold - occupant.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin))
					if(injection_amount > 0)
						occupant.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, injection_amount)
						loop_in_time(1 SECONDS)
						return
					handle_completed_surgery()
				if(SURGERY_PROCEDURE_LIMB_FACIAL)
					if(!active_surgery.checked_for_necessity)
						say("Beginning facial reconstruction surgery.")
						active_surgery.checked_for_necessity = TRUE
						if(!limb_ref)
							handle_unnecessary_surgery()
							return
					var/datum/limb/head/head_limb = limb_ref
					if(!head_limb.disfigured)
						handle_completed_surgery()
						return
					switch(head_limb.face_surgery_stage)
						if(0)
							loop_in_time(FACIAL_CUT_MAX_DURATION)
							head_limb.face_surgery_stage = 1
							return
						if(1)
							loop_in_time(FACIAL_MEND_MAX_DURATION)
							head_limb.face_surgery_stage = 2
							return
						if(2)
							loop_in_time(FACIAL_FIX_MAX_DURATION)
							head_limb.face_surgery_stage = 3
							return
						if(3)
							loop_in_time(FACIAL_CAUTERISE_MAX_DURATION)
							head_limb.remove_limb_flags(LIMB_BLEEDING)
							head_limb.disfigured = 0
							head_limb.owner.name = head_limb.owner.get_visible_name()
							head_limb.face_surgery_stage = 0
				if(SURGERY_PROCEDURE_LIMB_OPEN)
					if(!active_surgery.checked_for_necessity)
						say("Beginning facial reconstruction surgery.")
						active_surgery.checked_for_necessity = TRUE
						if(!limb_ref || !limb_ref.surgery_open_stage)
							handle_unnecessary_surgery()
							return
					if(!limb_ref.surgery_open_stage)
						handle_completed_surgery()
						return
					if(limb_ref.encased && limb_ref.surgery_open_stage >= 2.5)
						loop_in_time(close_encased(limb_ref))
						return
					loop_in_time(close_incision(occupant, limb_ref))
					return

/// Reports and ends the active surgery as an unnecessary surgery.
/obj/machinery/autodoc/proc/handle_unnecessary_surgery()
	say("Procedure has been deemed unnecessary.")
	surgery_list -= active_surgery
	active_surgery = null
	loop_in_time(UNNEEDED_DELAY)

/// Reports and ends the active surgery as a completed surgery.
/obj/machinery/autodoc/proc/handle_completed_surgery(time_to_loop = 1)
	say("Procedure complete.")
	surgery_list -= active_surgery
	active_surgery = null
	loop_in_time(time_to_loop)

/// Callback to loop surgery operation in a certain amount of time plus any multipliers.
/obj/machinery/autodoc/proc/loop_in_time(time_to_loop)
	if(!time_to_loop)
		CRASH("No amount to loop with for autodoc surgery step.")
	surgery_timer_id = addtimer(CALLBACK(src, PROC_REF(loop_surgery_operation)), time_to_loop * (automatic_mode ? 1.5 : 1) * surgery_time_multiplier, TIMER_UNIQUE|TIMER_STOPPABLE)

/// Opens the incision on a limb.
/obj/machinery/autodoc/proc/open_incision(mob/living/carbon/human/updating_human, datum/limb/operated_limb)
	if(operated_limb.surgery_open_stage)
		return
	operated_limb.createwound(CUT, 1)
	operated_limb.clamp_bleeder() // Hemostat function, clamp bleeders.
	operated_limb.surgery_open_stage = 2 // Can immediately proceed to other surgery steps.
	updating_human.updatehealth()
	return INCISION_MANAGER_MAX_DURATION

/// Closes the incision on a limb.
/obj/machinery/autodoc/proc/close_incision(mob/living/carbon/human/updating_human, datum/limb/operated_limb)
	if(operated_limb.surgery_open_stage != 2)
		return
	operated_limb.surgery_open_stage = 0
	operated_limb.germ_level = 0
	operated_limb.remove_limb_flags(LIMB_BLEEDING)
	updating_human.updatehealth()
	return CAUTERY_MAX_DURATION

/// Opens the encased limb.
/obj/machinery/autodoc/proc/open_encased(datum/limb/operated_limb)
	if(!operated_limb.encased)
		return
	if(operated_limb.surgery_open_stage == 2)
		operated_limb.surgery_open_stage = 2.5
		return SAW_OPEN_ENCASED_MAX_DURATION
	if(operated_limb.surgery_open_stage == 2.5)
		operated_limb.surgery_open_stage = 3
		return RETRACT_OPEN_ENCASED_MAX_DURATION

/// Closes the encased limb.
/obj/machinery/autodoc/proc/close_encased(datum/limb/operated_limb)
	if(!operated_limb.encased)
		return
	if(operated_limb.surgery_open_stage == 3)
		operated_limb.surgery_open_stage = 2.5
		return RETRACT_CLOSE_ENCASED_MAX_DURATION
	if(operated_limb.surgery_open_stage == 2.5)
		operated_limb.surgery_open_stage = 2
		return BONEGEL_CLOSE_ENCASED_MAX_DURATION

/obj/machinery/autodoc/event
	required_skill_level = SKILL_SURGERY_DEFAULT

/////////////////////////////////////////////////////////////

//Auto Doc console that links up to it.
/obj/machinery/computer/autodoc_console
	name = "autodoc medical system control console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	screen_overlay = "sleeperconsole_emissive"
	light_color = LIGHT_COLOR_EMISSIVE_RED
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP) //Valid access while locked
	density = FALSE
	idle_power_usage = 40
	dir = EAST
	/// The radio used to send messages with.
	var/obj/item/radio/headset/mainship/doc/radio
	/// The blood pack to transfer blood from.
	var/obj/item/reagent_containers/blood/OMinus/blood_pack
	/// The connected autodoc.
	var/obj/machinery/autodoc/connected = null
	/// Are notifications for patient discharges turned on?
	var/release_notice = TRUE
	/// Do users need access to interact with this?
	var/locked = FALSE

/obj/machinery/computer/autodoc_console/Initialize(mapload)
	. = ..()
	connected = locate(/obj/machinery/autodoc, get_step(src, REVERSE_DIR(dir)))
	if(connected)
		connected.connected = src
	radio = new(src)
	blood_pack = new(src)

/obj/machinery/computer/autodoc_console/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(blood_pack)
	if(connected)
		connected.connected = null
		connected = null
	return ..()

/obj/machinery/computer/autodoc_console/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(!connected || !connected.is_operational())
		return FALSE
	if(locked && !allowed(user))
		return FALSE
	return TRUE

/obj/machinery/computer/autodoc_console/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat = ""

	if(locked)
		dat += "<hr>Lock Console</span> | <a href='byond://?src=[text_ref(src)];locktoggle=1'>Unlock Console</a><BR>"
	else
		dat += "<hr><a href='byond://?src=[text_ref(src)];locktoggle=1'>Lock Console</a> | Unlock Console<BR>"

	if(release_notice)
		dat += "<hr>Notifications On</span> | <a href='byond://?src=[text_ref(src)];noticetoggle=1'>Notifications Off</a><BR>"
	else
		dat += "<hr><a href='byond://?src=[text_ref(src)];noticetoggle=1'>Notifications On</a> | Notifications Off<BR>"

	if(connected.automatic_mode)
		dat += "<hr>[span_notice("Automatic Mode")] | <a href='byond://?src=[text_ref(src)];automatictoggle=1'>Manual Mode</a>"
	else
		dat += "<hr><a href='byond://?src=[text_ref(src)];automatictoggle=1'>Automatic Mode</a> | Manual Mode"

	dat += "<hr><font color='#487553'><B>Occupant Statistics:</B></FONT><BR>"
	if(!connected.occupant)
		dat += "No occupant detected."
		var/datum/browser/popup = new(user, "autodoc", "<div align='center'>Autodoc Console</div>", 600, 600)
		popup.set_content(dat)
		popup.open()
		return

	var/t1
	switch(connected.occupant.stat)
		if(CONSCIOUS)
			t1 = "Conscious"
		if(UNCONSCIOUS)
			t1 = "<font color='#487553'>Unconscious</font>"
		if(DEAD)
			t1 = "<font color='#b54646'>*Dead*</font>"
	var/operating
	switch(connected.active_surgery)
		if(0)
			operating = "Not in surgery"
		if(1)
			operating = "<font color='#b54646'><B>SURGERY IN PROGRESS: MANUAL EJECTION ONLY TO BE ATTEMPTED BY TRAINED OPERATORS!</B></FONT>"
	var/health_ratio = connected.occupant.health * 100 / connected.occupant.maxHealth
	dat += "[health_ratio > 50 ? "<font color='#487553'>" : "<font color='#b54646'>"]\tHealth %: [round(health_ratio)] ([t1])</FONT><BR>"
	var/pulse = connected.occupant.handle_pulse()
	dat += "[pulse == PULSE_NONE || pulse == PULSE_THREADY ? "<font color='#b54646'>" : "<font color='#487553'>"]\t-Pulse, bpm: [connected.occupant.get_pulse(GETPULSE_TOOL)]</FONT><BR>"
	dat += "[connected.occupant.getBruteLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Brute Damage %: [connected.occupant.getBruteLoss()]</FONT><BR>"
	dat += "[connected.occupant.getOxyLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Respiratory Damage %: [connected.occupant.getOxyLoss()]</FONT><BR>"
	dat += "[connected.occupant.getToxLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Toxin Content %: [connected.occupant.getToxLoss()]</FONT><BR>"
	dat += "[connected.occupant.getFireLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Burn Severity %: [connected.occupant.getFireLoss()]</FONT><BR>"

	dat += "<hr> Surgery Queue:<br>"

	var/list/surgeryqueue = list()

	var/datum/data/record/N = null
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (R.fields["name"] == connected.occupant.real_name)
			N = R
	if(isnull(N))
		N = create_medical_record(connected.occupant)

	if(connected.automatic_mode)
		var/list/autosurgeries = N.fields["autodoc_data"]
		if(length(autosurgeries))
			dat += "[span_danger("Automatic Mode Ready.")]<br>"
		else

			dat += "[span_danger("Automatic Mode Unavailable, Scan Patient First.")]<br>"
	else
		if(!isnull(N.fields["autodoc_manual"]))
			for(var/datum/autodoc_surgery/A in N.fields["autodoc_manual"])
				switch(A.surgery_category)
					if(SURGERY_CATEGORY_EXTERNAL)
						switch(A.surgery_procedure)
							if(SURGERY_PROCEDURE_EXTERNAL_BRUTE)
								surgeryqueue["brute"] = 1
								dat += "Surgical Brute Damage Treatment"
							if(SURGERY_PROCEDURE_EXTERNAL_BURN)
								surgeryqueue["burn"] = 1
								dat += "Surgical Burn Damage Treatment"
							if(SURGERY_PROCEDURE_EXTERNAL_TOXIN)
								surgeryqueue["toxin"] = 1
								dat += "Toxin Damage Chelation"
							if(SURGERY_PROCEDURE_EXTERNAL_DIALYSIS)
								surgeryqueue["dialysis"] = 1
								dat += "Dialysis"
							if(SURGERY_PROCEDURE_EXTERNAL_BLOOD)
								surgeryqueue["blood"] = 1
								dat += "Blood Transfer"
					if(SURGERY_CATEGORY_ORGAN)
						switch(A.surgery_procedure)
							if(SURGERY_PROCEDURE_ORGAN_DAMAGE)
								surgeryqueue["organdamage"] = 1
								dat += "Surgical Organ Damage Treatment"
							if(SURGERY_PROCEDURE_ORGAN_EYES)
								surgeryqueue["eyes"] = 1
								dat += "Corrective Eye Surgery"
							if(SURGERY_PROCEDURE_ORGAN_GERMS)
								surgeryqueue["organgerms"] = 1
								dat += "Organ Infection Treatment"
					if(SURGERY_CATEGORY_LIMB)
						switch(A.surgery_procedure)
							if(SURGERY_PROCEDURE_LIMB_INTERNAL)
								surgeryqueue["internal"] = 1
								dat += "Internal Bleeding Surgery"
							if(SURGERY_PROCEDURE_LIMB_BROKEN)
								surgeryqueue["broken"] = 1
								dat += "Broken Bone Surgery"
							if(SURGERY_PROCEDURE_LIMB_MISSING)
								surgeryqueue["missing"] = 1
								dat += "Limb Replacement Surgery"
							if(SURGERY_PROCEDURE_LIMB_NECROTIZED)
								surgeryqueue["necro"] = 1
								dat += "Necrosis Removal Surgery"
							if(SURGERY_PROCEDURE_LIMB_IMPLANTS)
								surgeryqueue["shrapnel"] = 1
								dat += "Foreign Body Removal Surgery"
							if(SURGERY_PROCEDURE_LIMB_GERMS)
								surgeryqueue["limbgerm"] = 1
								dat += "Limb Disinfection Procedure"
							if(SURGERY_PROCEDURE_LIMB_FACIAL)
								surgeryqueue["facial"] = 1
								dat += "Facial Reconstruction Surgery"
							if(SURGERY_PROCEDURE_LIMB_OPEN)
								surgeryqueue["open"] = 1
								dat += "Close Open Incision"
				dat += "<br>"

	dat += "<hr> Med-Pod Status: [operating] "
	dat += "<hr><a href='byond://?src=[text_ref(src)];clear=1'>Clear Surgery Queue</a>"
	dat += "<hr><a href='byond://?src=[text_ref(src)];refresh=1'>Refresh Menu</a>"
	dat += "<hr><a href='byond://?src=[text_ref(src)];surgery=1'>Begin Surgery Queue</a>"
	dat += "<hr><a href='byond://?src=[text_ref(src)];ejectify=1'>Eject Patient</a>"
	if(!connected.active_surgery)
		if(connected.automatic_mode)
			dat += "<hr>Manual Surgery Interface Unavailable, Automatic Mode Engaged."
		else
			dat += "<hr>Manual Surgery Interface<hr>"
			dat += "<b>Trauma Surgeries</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["brute"]))
				dat += "<a href='byond://?src=[text_ref(src)];brute=1'>Surgical Brute Damage Treatment</a><br>"
			if(isnull(surgeryqueue["burn"]))
				dat += "<a href='byond://?src=[text_ref(src)];burn=1'>Surgical Burn Damage Treatment</a><br>"
			dat += "<b>Orthopedic Surgeries</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["broken"]))
				dat += "<a href='byond://?src=[text_ref(src)];broken=1'>Broken Bone Surgery</a><br>"
			if(isnull(surgeryqueue["internal"]))
				dat += "<a href='byond://?src=[text_ref(src)];internal=1'>Internal Bleeding Surgery</a><br>"
			if(isnull(surgeryqueue["shrapnel"]))
				dat += "<a href='byond://?src=[text_ref(src)];shrapnel=1'>Foreign Body Removal Surgery</a><br>"
			if(isnull(surgeryqueue["missing"]))
				dat += "<a href='byond://?src=[text_ref(src)];missing=1'>Limb Replacement Surgery</a><br>"
			dat += "<b>Organ Surgeries</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["organdamage"]))
				dat += "<a href='byond://?src=[text_ref(src)];organdamage=1'>Surgical Organ Damage Treatment</a><br>"
			if(isnull(surgeryqueue["organgerms"]))
				dat += "<a href='byond://?src=[text_ref(src)];organgerms=1'>Organ Infection Treatment</a><br>"
			if(isnull(surgeryqueue["eyes"]))
				dat += "<a href='byond://?src=[text_ref(src)];eyes=1'>Corrective Eye Surgery</a><br>"
			dat += "<b>Hematology Treatments</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["blood"]))
				dat += "<a href='byond://?src=[text_ref(src)];blood=1'>Blood Transfer</a><br>"
			if(isnull(surgeryqueue["toxin"]))
				dat += "<a href='byond://?src=[text_ref(src)];toxin=1'>Toxin Damage Chelation</a><br>"
			if(isnull(surgeryqueue["dialysis"]))
				dat += "<a href='byond://?src=[text_ref(src)];dialysis=1'>Dialysis</a><br>"
			if(isnull(surgeryqueue["necro"]))
				dat += "<a href='byond://?src=[text_ref(src)];necro=1'>Necrosis Removal Surgery</a><br>"
			if(isnull(surgeryqueue["limbgerm"]))
				dat += "<a href='byond://?src=[text_ref(src)];limbgerm=1'>Limb Disinfection Procedure</a><br>"
			dat += "<b>Special Surgeries</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["facial"]))
				dat += "<a href='byond://?src=[text_ref(src)];facial=1'>Facial Reconstruction Surgery</a><br>"
			if(isnull(surgeryqueue["open"]))
				dat += "<a href='byond://?src=[text_ref(src)];open=1'>Close Open Incision</a><br>"

	var/datum/browser/popup = new(user, "autodoc", "<div align='center'>Autodoc Console</div>", 600, 600)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/autodoc_console/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!connected)
		return

	if(ishuman(connected.occupant))
		// manual surgery handling
		var/datum/data/record/N = null
		for(var/i in GLOB.datacore.medical)
			var/datum/data/record/R = i
			if(R.fields["name"] == connected.occupant.real_name)
				N = R

		if(isnull(N))
			N = create_medical_record(connected.occupant)

		if(href_list["brute"])
			N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_BRUTE)

		if(href_list["burn"])
			N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_BURN)

		if(href_list["toxin"])
			N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_TOXIN)

		if(href_list["dialysis"])
			N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_DIALYSIS)

		if(href_list["blood"])
			N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_EXTERNAL, SURGERY_PROCEDURE_EXTERNAL_BLOOD)

		if(href_list["organgerms"])
			N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_ORGAN, SURGERY_PROCEDURE_ORGAN_GERMS)

		if(href_list["eyes"])
			N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, connected.occupant.get_organ_slot(ORGAN_SLOT_EYES), SURGERY_CATEGORY_ORGAN, SURGERY_PROCEDURE_ORGAN_EYES)

		var/needed = FALSE // This is to stop someone from just brainlessly choosing everything and getting benefits from it.
		if(href_list["organdamage"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				for(var/x in L.internal_organs)
					var/datum/internal_organ/I = x
					if(I.robotic == ORGAN_ASSISTED || I.robotic == ORGAN_ROBOT)
						continue
					if(I.damage > 0)
						N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, I, SURGERY_CATEGORY_ORGAN, SURGERY_PROCEDURE_ORGAN_DAMAGE)
						needed = TRUE
			if(!needed)
				N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_ORGAN, SURGERY_PROCEDURE_ORGAN_DAMAGE)

		if(href_list["internal"])
			needed = FALSE
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(length(L.wounds))
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_INTERNAL)
					needed = TRUE
			if(!needed)
				N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_INTERNAL)

		if(href_list["broken"])
			needed = FALSE
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(L.limb_status & LIMB_BROKEN)
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_BROKEN)
					needed = TRUE
			if(!needed)
				N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_BROKEN)

		if(href_list["missing"])
			needed = FALSE
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(L.limb_status & LIMB_DESTROYED && !(L.parent.limb_status & LIMB_DESTROYED) && L.body_part != HEAD)
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_MISSING)
					needed = TRUE
			if(!needed)
				N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_MISSING)

		if(href_list["necro"])
			needed = FALSE
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(L.limb_status & LIMB_NECROTIZED)
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_NECROTIZED)
					needed = TRUE
			if(!needed)
				N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_NECROTIZED)

		if(href_list["shrapnel"])
			needed = FALSE
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				var/skip_embryo_check = FALSE
				var/obj/item/alien_embryo/A = locate() in connected.occupant
				for(var/obj/item/embedded AS in L.implants)
					if(embedded.is_beneficial_implant())
						continue
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_IMPLANTS)
					needed = TRUE
					if(L.body_part == CHEST)
						skip_embryo_check = TRUE
				if(A && L.body_part == CHEST && !skip_embryo_check) //If we're not already doing a shrapnel removal surgery of the chest proceed.
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_IMPLANTS)
					needed = TRUE

			if(!needed)
				N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_IMPLANTS)

		if(href_list["limbgerm"])
			N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_GERMS)

		if(href_list["facial"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(!istype(L, /datum/limb/head))
					continue
				var/datum/limb/head/J = L
				if(J.disfigured || J.face_surgery_stage)
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_FACIAL)
				else
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_FACIAL)
				break

		if(href_list["open"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(L.surgery_open_stage)
					N.fields["autodoc_manual"] += new /datum/autodoc_surgery(L, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_OPEN)
					needed = TRUE
			if(!needed)
				N.fields["autodoc_manual"] += new /datum/autodoc_surgery(null, null, SURGERY_CATEGORY_LIMB, SURGERY_PROCEDURE_LIMB_OPEN)

		// The rest
		if(href_list["clear"])
			N.fields["autodoc_manual"] = list()

	if(href_list["locktoggle"]) //Toggle the autodoc lock on/off if we have authorization.
		if(allowed(usr))
			locked = !locked
			connected.locked = !connected.locked
		else
			to_chat(usr, span_warning("Access denied."))
			playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)

	if(href_list["noticetoggle"]) //Toggle notifications on/off if we have authorization.
		if(allowed(usr))
			release_notice = !release_notice
		else
			to_chat(usr, span_warning("Access denied."))
			playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)

	if(href_list["automatictoggle"] && !connected.is_active())
		connected.automatic_mode = !connected.automatic_mode
		if(!connected.automatic_mode && connected.autostart_timer_id)
			deltimer(connected.autostart_timer_id)
			connected.autostart_timer_id = null
			connected.say("Automatic mode disengaged, awaiting manual inputs.")
		if(connected.automatic_mode && !connected.autostart_timer_id)
			connected.say("Automatic mode engaged, initialising procedures.")
			connected.autostart_timer_id = addtimer(CALLBACK(connected, TYPE_PROC_REF(/obj/machinery/autodoc, auto_start)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

	if(href_list["surgery"])
		if(connected.occupant)
			connected.begin_surgery_operation()

	if(href_list["ejectify"])
		connected.try_ejecting(usr)

	updateUsrDialog()


/obj/machinery/computer/autodoc_console/examine(mob/living/user)
	. = ..()
	if(locked)
		. += span_warning("It's currently locked down!")
	if(release_notice)
		. += span_notice("Release notifications are turned on.")

/obj/machinery/autodoc/examine(mob/living/user)
	. = ..()
	to_chat(user, span_notice("Its metal reservoir contains [stored_metal] of [stored_metal_max] units."))
	if(!occupant) //Allows us to reference medical files/scan reports for cryo via examination.
		return
	if(!ishuman(occupant))
		return
	var/active = ""
	if(active_surgery)
		active += " <b><u>Surgical procedures are in progress.</u></b>"
	if(!hasHUD(user,"medical"))
		return
	. += span_notice("It contains: [occupant].[active]")
	if(surgery_timer_id)
		. += span_notice("Next surgery step in [timeleft(surgery_timer_id) / 10] seconds.")
	var/datum/data/record/medical_record = find_medical_record(occupant)
	if(!isnull(medical_record?.fields["historic_scan"]))
		. += "<a href='byond://?src=[text_ref(src)];scanreport=1'>Occupant's body scan from [medical_record.fields["historic_scan_time"]]...</a>"
	else
		. += "[span_deptradio("No body scan report on record for occupant")]"

/obj/machinery/autodoc/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!href_list["scanreport"])
		return
	if(!hasHUD(usr,"medical"))
		return
	if(!ishuman(occupant))
		return
	var/datum/data/record/medical_record = find_medical_record(occupant)
	var/datum/historic_scan/scan = medical_record.fields["historic_scan"]
	scan.ui_interact(usr)

//Autodoc but faster
/obj/machinery/autodoc/crash
	surgery_time_multiplier = 0.5
