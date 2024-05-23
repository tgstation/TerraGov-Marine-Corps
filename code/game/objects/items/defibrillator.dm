/obj/item/defibrillator
	name = "emergency defibrillator"
	desc = "A device that delivers powerful shocks to resuscitate incapacitated patients."
	icon = 'icons/obj/items/defibrillator.dmi'
	icon_state = "defib"
	worn_icon_state = "defib"
	atom_flags = CONDUCT
	item_flags = NOBLUDGEON
	equip_slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_NORMAL
	///If the defibrillator is ready to use (paddles out)
	var/ready = FALSE
	///Whether this defibrillator has to be turned on to use
	var/ready_needed = TRUE
	///The base healing number. This will be multiplied using DEFIBRILLATOR_HEALING_TIMES_SKILL.
	var/damage_threshold = DEFIBRILLATOR_BASE_HEALING_VALUE
	///How much charge is used on a shock
	var/charge_cost = 66
	///The cooldown for toggling.
	var/defib_cooldown = 0
	///The defibrillator's power cell
	var/obj/item/cell/dcell = null
	///Var for quickly creating sparks on shock
	var/datum/effect_system/spark_spread/sparks


/obj/item/defibrillator/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is putting the live paddles on [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide."))
	return (FIRELOSS)


/obj/item/defibrillator/Initialize(mapload)
	. = ..()
	sparks = new
	sparks.set_up(5, 0, src)
	sparks.attach(src)
	set_dcell(new /obj/item/cell())
	update_icon()


/obj/item/defibrillator/Destroy()
	QDEL_NULL(sparks)
	if(dcell)
		UnregisterSignal(dcell, COMSIG_QDELETING)
		QDEL_NULL(dcell)
	return ..()


/obj/item/defibrillator/update_icon_state()
	icon_state = initial(icon_state)
	if(ready)
		icon_state += "_out"

/obj/item/defibrillator/update_overlays()
	. = ..()
	if(dcell?.charge)
		switch(round(dcell.charge * 100 / dcell.maxcharge))
			if(67 to INFINITY)
				overlays += "+full"
			if(34 to 66)
				overlays += "+half"
			if(3 to 33)
				overlays += "+low"
			if(0 to 3)
				overlays += "+empty"
	else // No cell.
		overlays += "+empty"


/obj/item/defibrillator/examine(mob/user)
	. = ..()
	. += charge_information()


///Returns the amount of charges left and how to recharge the defibrillator.
/obj/item/defibrillator/proc/charge_information(mob/living/carbon/human/user)
	if(!dcell)
		return

	var/message
	message += span_info("It has [round(dcell.charge / charge_cost)] out of [round(dcell.maxcharge / charge_cost)] uses left in its internal battery.\n")
	if(dcell.charge < charge_cost)
		message += span_alert("The battery is empty.\n")
	else if(round(dcell.charge * 100 / dcell.maxcharge) <= 33)
		message += span_alert("The battery is low.\n")

	if(!message)
		return
	return "[message]You can click-drag this unit on a corpsman backpack to recharge it."


/obj/item/defibrillator/attack_self(mob/living/carbon/human/user)
	if(!ready_needed)
		return
	if(!istype(user))
		return
	if(defib_cooldown > world.time)
		user.visible_message(span_warning("You've toggled [src] too recently!"))
		return

	//Job knowledge requirement
	var/skill = user.skills.getRating(SKILL_MEDICAL)
	if(skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		if(!do_after(user, SKILL_TASK_EASY - (SKILL_TASK_VERY_EASY * skill), NONE, src, BUSY_ICON_UNSKILLED))
			return

	defib_cooldown = world.time + 1 SECONDS
	ready = !ready
	user.visible_message(span_notice("[user] turns [src] [ready? "on and opens the cover" : "off and closes the cover"]."),
	span_notice("You turn [src] [ready? "on and open the cover" : "off and close the cover"]."))
	playsound(get_turf(src), SFX_SPARKS, 25, TRUE, 4)
	if(ready)
		playsound(get_turf(src), 'sound/items/defib_safetyOn.ogg', 30, 0)
	else
		w_class = initial(w_class)
		playsound(get_turf(src), 'sound/items/defib_safetyOff.ogg', 30, 0)
	update_icon()


///Wrapper to guarantee powercells are properly nulled and avoid hard deletes.
/obj/item/defibrillator/proc/set_dcell(obj/item/cell/new_cell)
	if(dcell)
		UnregisterSignal(dcell, COMSIG_QDELETING)
	dcell = new_cell
	if(dcell)
		RegisterSignal(dcell, COMSIG_QDELETING, PROC_REF(on_cell_deletion))


///Called by the deletion of the referenced powercell.
/obj/item/defibrillator/proc/on_cell_deletion(obj/item/cell/source, force)
	SIGNAL_HANDLER
	stack_trace("Powercell deleted while powering the defib, this isn't supposed to happen normally.")
	set_dcell(null)

/obj/item/defibrillator/attack(mob/living/carbon/human/patient, mob/living/carbon/human/user)
	defibrillate(patient,user)

///Proc for checking that the defib is ready to operate
/obj/item/defibrillator/proc/defib_ready(mob/living/carbon/human/patient, mob/living/carbon/human/user)
	if(!ready)
		to_chat(user, span_warning("Take the paddles out to continue."))
		return FALSE
	if(!ishuman(patient))
		to_chat(user, span_warning("The instructions on [src] don't mention how to resuscitate that..."))
		return FALSE
	if(patient.stat != DEAD)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient is not in a valid state. Operation aborted."))
		return FALSE
	if(patient.wear_suit && (patient.wear_suit.atom_flags & CONDUCT)) // something conductive on their chest
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's chest is obscured. Remove suit or armor and try again."))
		return FALSE
	return TRUE

///Split proc that actually does the defibrillation. Separated to be used more easily by medical gloves
/obj/item/defibrillator/proc/defibrillate(mob/living/carbon/human/patient, mob/living/carbon/human/user)
	if(user.do_actions) //Currently doing something
		user.visible_message(span_warning("You're already doing something!"))
		return

	if(defib_cooldown > world.time)
		user.visible_message(span_warning("\The [src] has been used too recently, wait a second!"))
		return

	defib_cooldown = world.time + 2 SECONDS

	//job knowledge requirement
	var/medical_skill = user.skills.getRating(SKILL_MEDICAL)
	if(medical_skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = SKILL_TASK_AVERAGE - (SKILL_TASK_VERY_EASY * medical_skill) // 3 seconds with medical medical_skill, 5 without
		if(!do_after(user, fumbling_time, NONE, patient, BUSY_ICON_UNSKILLED))
			return

	var/defib_heal_amt = DEFIBRILLATOR_HEALING_TIMES_SKILL(medical_skill)

	if(dcell.charge <= charge_cost) // This is split from defib_ready because we don't want to check charge AFTER delivering shock
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Internal battery depleted. Seek recharger. Cannot analyze nor administer shock."))
		to_chat(user, span_boldwarning("You can recharge the defibrillator by click-dragging it onto a corpsman backpack or satchel, or putting it in a recharger."))
		return

	if(!defib_ready(patient, user))
		return

	var/blocking_fail_reason
	if(patient.check_defib() & (DEFIB_PERMADEATH_STATES))
		// Special bit for preventing the do_after if they can't come back.
		// We'll check the rest of the check_defib states along with these after shocking, incase their status changes mid defib.
		switch(patient.check_defib())
			if(DEFIB_FAIL_DECAPITATED)
				if(patient.species.species_flags & DETACHABLE_HEAD) // special message for synths/robots missing their head
					blocking_fail_reason = "Patient is missing their head. Reattach and try again."
				else
					blocking_fail_reason = "Patient is missing their head. Further attempts futile."
			if(DEFIB_FAIL_BRAINDEAD)
				blocking_fail_reason = "Patient is braindead. Further attempts futile."
			if(DEFIB_FAIL_NPC)
				blocking_fail_reason = "Patient is missing intelligence patterns. Further attempts futile."
	if(blocking_fail_reason)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Resuscitation impossible - [blocking_fail_reason]"))
		return

	var/mob/dead/observer/ghost = patient.get_ghost()
	// For robots, we want to use the more relaxed bitmask as we are doing this before their IMMEDIATE_DEFIB trait is handled and they might
	// still be unrevivable because of too much damage.
	var/alerting_ghost = isrobot(patient) ? (patient.check_defib() & DEFIB_RELAXED_REVIVABLE_STATES) : (patient.check_defib(DEFIBRILLATOR_HEALING_TIMES_SKILL(user.skills.getRating(SKILL_MEDICAL))) & DEFIB_STRICT_REVIVABLE_STATES)
	if(ghost && alerting_ghost)
		notify_ghost(ghost, assemble_alert(
			title = "Revival Imminent!",
			message = "Someone is trying to resuscitate your body! Stay in your body if you want to be resurrected!",
			color_override = "purple"
		), ghost_sound = 'sound/effects/gladosmarinerevive.ogg')
		ghost.reenter_corpse()

	user.visible_message(span_notice("[user] starts setting up the paddles on [patient]'s chest."),
	span_notice("You start setting up the paddles on [patient]'s chest."))
	playsound(get_turf(src),'sound/items/defib_charge.ogg', 25, 0) // Don't vary this, it should be exactly 7 seconds

	if(!do_after(user, 7 SECONDS, NONE, patient, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL)) // 7 seconds revive time
		to_chat(user, span_warning("You stop setting up the paddles on [patient]'s chest."))
		return

	//Do the defibrillation effects now. We're checking revive parameters in a moment.
	sparks.start()
	dcell.use(charge_cost)
	update_icon()
	playsound(get_turf(src), 'sound/items/defib_release.ogg', 25, 1)
	user.visible_message(span_notice("[user] shocks [patient] with the paddles."),
	span_notice("You shock [patient] with the paddles."))
	patient.visible_message(span_warning("[patient]'s body convulses a bit."))
	defib_cooldown = world.time + 10 //1 second cooldown before you can shock again

	if(!defib_ready(patient, user))
		return

	//At this point, the defibrillator is ready to work
	if(HAS_TRAIT(patient, TRAIT_IMMEDIATE_DEFIB))
	 	//This trait allows some species to be healed so they may always be resuscitated regardless of user skill
		patient.setOxyLoss(0)
		patient.updatehealth()

		var/heal_target = patient.get_death_threshold() - patient.health + 1
		var/all_loss = patient.getBruteLoss() + patient.getFireLoss() + patient.getToxLoss()
		if(all_loss && (heal_target > 0))
			var/brute_ratio = patient.getBruteLoss() / all_loss
			var/burn_ratio = patient.getFireLoss() / all_loss
			var/tox_ratio = patient.getToxLoss() / all_loss
			if(tox_ratio)
				patient.adjustToxLoss(-(tox_ratio * heal_target))
			patient.heal_overall_damage(brute_ratio*heal_target, burn_ratio*heal_target, TRUE) // explicitly also heals robot parts

	else if(!issynth(patient)) // TODO make me a trait :)
		patient.adjustBruteLoss(-defib_heal_amt)
		patient.adjustFireLoss(-defib_heal_amt)
		patient.adjustToxLoss(-defib_heal_amt)
		patient.setOxyLoss(0)

	patient.updatehealth() // update health because it usually doesn't update for the dead
	//the defibrillator is checking parameters now

	var/fail_reason
	// We're keeping permadeath states from earlier in here in case something changes mid revive
	switch(patient.check_defib())
		if(DEFIB_FAIL_DECAPITATED)
			if(patient.species.species_flags & DETACHABLE_HEAD) // special message for synths/robots missing their head
				fail_reason = "Patient is missing their head. Reattach and try again."
			else
				fail_reason = "Patient is missing their head. Further attempts futile."
		if(DEFIB_FAIL_BRAINDEAD)
			fail_reason = "Patient is braindead. Further attempts futile."
		if(DEFIB_FAIL_NPC)
			fail_reason = "Patient is missing intelligence patterns. Further attempts futile."
		if(DEFIB_FAIL_TOO_MUCH_DAMAGE)
			fail_reason = "Vital signs are weak. Repair damage and try again."
		if(DEFIB_FAIL_BAD_ORGANS)
			fail_reason = "Patient's heart is too damaged to sustain life. Surgical intervention required."
		if(DEFIB_FAIL_CLIENT_MISSING)
			fail_reason = "No soul detected. Please try again."

	if(fail_reason)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Resuscitation failed - [fail_reason]"))
		playsound(src, 'sound/items/defib_failed.ogg', 50, FALSE)
		return

	to_chat(patient, span_notice("<i><font size=4>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane...</font></i>"))
	user.visible_message(span_notice("[icon2html(src, viewers(user))] \The [src] beeps: Resuscitation successful."))
	playsound(get_turf(src), 'sound/items/defib_success.ogg', 50, 0)
	patient.updatehealth()
	patient.resuscitate() // time for a smoke

	//Checks if the patient is wearing a camera. Then it turns it on if it's off.
	if(istype(patient.wear_ear, /obj/item/radio/headset/mainship))
		var/obj/item/radio/headset/mainship/cam_headset = patient.wear_ear
		if(!(cam_headset?.camera?.status))
			cam_headset.camera.toggle_cam(null, FALSE)
	if(user.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.revives++
		personal_statistics.mission_revives++
	GLOB.round_statistics.total_human_revives[patient.faction]++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_human_revives[patient.faction]")

	if(CHECK_BITFIELD(patient.status_flags, XENO_HOST))
		var/obj/item/alien_embryo/friend = locate() in patient
		START_PROCESSING(SSobj, friend)

	notify_ghosts("<b>[user]</b> has brought <b>[patient.name]</b> back to life!", source = patient, action = NOTIFY_ORBIT)

/obj/item/defibrillator/civi
	name = "emergency defibrillator"
	desc = "A device that delivers powerful shocks to resuscitate incapacitated patients. This one appears to be a civillian model."
	icon_state = "civ_defib_full"
	worn_icon_state = "defib"

/obj/item/defibrillator/internal
	icon = 'icons/obj/clothing/gloves.dmi' //even though you'll never see this directly, it shows up in the chat panel due to icon2html
	ready = TRUE
	ready_needed = FALSE
	///Parent item containing this defib
	var/obj/parent_obj

/obj/item/defibrillator/internal/Initialize(mapload, obj/new_parent)
	if(!istype(new_parent))
		return INITIALIZE_HINT_QDEL
	parent_obj = new_parent
	return ..()

/obj/item/defibrillator/internal/Destroy()
	parent_obj = null
	return ..()

/obj/item/defibrillator/internal/update_icon()
	. = ..()
	parent_obj.update_icon()

/obj/item/clothing/gloves/defibrillator
	name = "advanced medical combat gloves"
	desc = "Advanced medical gauntlets with small but powerful electrodes to resuscitate incapacitated patients."
	icon_state = "defib_out_full"
	worn_icon_state = "defib_gloves"
	soft_armor = list(MELEE = 25, BULLET = 15, LASER = 10, ENERGY = 15, BOMB = 15, BIO = 5, FIRE = 15, ACID = 15)
	cold_protection_flags = HANDS
	heat_protection_flags = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	///The internal defib item
	var/obj/item/defibrillator/internal/internal_defib

/obj/item/clothing/gloves/defibrillator/Initialize(mapload)
	. = ..()
	internal_defib = new(src, src)
	update_icon()

/obj/item/clothing/gloves/defibrillator/Destroy()
	internal_defib = null
	return ..()

/obj/item/clothing/gloves/defibrillator/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(user.gloves == src)
		RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	else
		UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)

/obj/item/clothing/gloves/defibrillator/unequipped(mob/living/carbon/human/user, slot)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK) //Unregisters in the case of getting delimbed

/obj/item/clothing/gloves/defibrillator/examine(mob/user)
	. = ..()
	. += internal_defib.charge_information()

/obj/item/clothing/gloves/defibrillator/update_icon_state()
	. = ..()
	if(!internal_defib) //should only happen on init
		return
	icon_state = internal_defib.icon_state

//when you are wearing these gloves, this will call the normal attack code to begin defibing the target
/obj/item/clothing/gloves/defibrillator/proc/on_unarmed_attack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	SIGNAL_HANDLER
	if(user.a_intent != INTENT_HELP)
		return
	if(istype(user) && istype(target))
		INVOKE_ASYNC(internal_defib, TYPE_PROC_REF(/obj/item/defibrillator, defibrillate), target, user)
