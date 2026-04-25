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
	///The base healing number when someone is shocked. Uses `DEFIBRILLATOR_HEALING_TIMES_SKILL` to change based on user skill.
	var/defibrillator_healing = DEFIBRILLATOR_BASE_HEALING_VALUE
	///How much charge is used on a shock
	var/charge_cost = 66
	///The defibrillator's power cell
	var/obj/item/cell/dcell = null
	///Var for quickly creating sparks on shock
	var/datum/effect_system/spark_spread/sparks
	///The cooldown for using the defib, applied to shocking *and* toggling
	COOLDOWN_DECLARE(defib_cooldown)


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
				. += "_full"
			if(34 to 66)
				. += "_half"
			if(3 to 33)
				. += "_low"
			if(-INFINITY to 3)
				. += "_empty"
	else // No cell.
		. += "_empty"


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
	return "[message]You can click-drag this unit on a corpsman backpack or satchel to recharge it."


/obj/item/defibrillator/attack_self(mob/living/carbon/human/user)
	if(!ready_needed)
		return
	if(!istype(user))
		return

	//Job knowledge requirement
	var/skill = user.skills.getRating(SKILL_MEDICAL)
	if(skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		if(!do_after(user, SKILL_TASK_AVERAGE - (SKILL_TASK_VERY_EASY * skill), NONE, src, BUSY_ICON_UNSKILLED))
			return

	ready = !ready
	user.visible_message(span_notice("[user] turns [src] [ready? "on and opens the cover" : "off and closes the cover"]."),
	span_notice("You turn [src] [ready? "on and open the cover" : "off and close the cover"]."))
	playsound(get_turf(src), SFX_SPARKS, 25, TRUE, 4)
	if(ready)
		playsound(get_turf(src), 'sound/items/defib_safetyOn.ogg', 45, 0)
	else
		playsound(get_turf(src), 'sound/items/defib_safetyOff.ogg', 45, 0)
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
		balloon_alert(user, "take the paddles out!")
		return FALSE
	if(!ishuman(patient))
		balloon_alert(user, "that's not a human!")
		return FALSE
	if(patient.stat != DEAD)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient is not in a valid state. Operation aborted."))
		return FALSE
	if(patient.wear_suit && (patient.wear_suit.atom_flags & CONDUCT)) // something conductive on their chest
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Paddles registering >100,000 ohms. Remove interfering suit or armor and try again."))
		return FALSE
	return TRUE

///Split proc that actually does the defibrillation. Separated to be used more easily by medical gloves
/obj/item/defibrillator/proc/defibrillate(mob/living/carbon/human/patient, mob/living/carbon/human/user)
	if(user.do_actions) //Currently doing something
		balloon_alert(user, "busy!")
		return

	if(!COOLDOWN_FINISHED(src, defib_cooldown))
		balloon_alert(user, "recharging!")
		return

	//job knowledge requirement
	var/medical_skill = user.skills.getRating(SKILL_MEDICAL)
	if(medical_skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = SKILL_TASK_AVERAGE - (SKILL_TASK_VERY_EASY * medical_skill) // 3 seconds with medical skill, 5 without
		if(!do_after(user, fumbling_time, NONE, patient, BUSY_ICON_UNSKILLED))
			return

	var/defib_heal_amt = DEFIBRILLATOR_HEALING_TIMES_SKILL(medical_skill, defibrillator_healing)

	if(dcell.charge <= charge_cost)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Internal battery depleted. Seek recharger. Cannot analyze nor administer shock."))
		to_chat(user, span_boldwarning("You can recharge the defibrillator by click-dragging it onto a corpsman backpack or satchel, or putting it in a recharger."))
		return

	if(!defib_ready(patient, user))
		return

	var/fail_reason
	switch(patient.check_defib())
		// A special bit for preventing the defib do_after if they can't come back
		// This will be ran again after shocking just in case their status changes
		if(DEFIB_FAIL_DECAPITATED)
			if(patient.species.species_flags & DETACHABLE_HEAD) // special message for synths/robots missing their head
				fail_reason = "Patient is missing their head. Reattach and try again."
			else
				fail_reason = "Patient is missing their head. Further attempts futile."
		if(DEFIB_FAIL_BRAINDEAD)
			fail_reason = "Patient's general condition does not allow revival. Further attempts futile."
	if(fail_reason)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Resuscitation impossible - [fail_reason]"))
		return

	var/mob/dead/observer/ghost = patient.get_ghost()
	// For robots, we want to use the more relaxed bitmask as we are doing this before their IMMEDIATE_DEFIB trait is handled and they might
	// still be unrevivable because of too much damage.
	var/alerting_ghost = isrobot(patient) ? (patient.check_defib() & DEFIB_REVIVABLE_STATES) : (patient.check_defib(issynth(patient) ? 0 : DEFIBRILLATOR_HEALING_TIMES_SKILL(user.skills.getRating(SKILL_MEDICAL), defibrillator_healing)) == DEFIB_POSSIBLE)
	if(ghost && alerting_ghost)
		notify_ghost(ghost, assemble_alert(
			title = "Revival Imminent!",
			message = "Someone is trying to resuscitate your body! Stay in it if you want to be resurrected!",
			color_override = "purple"
		), ghost_sound = 'sound/effects/gladosmarinerevive.ogg')
		ghost.reenter_corpse()

	user.visible_message(span_notice("[user] starts setting up the paddles on [patient]'s chest."),
	span_notice("You start setting up the paddles on [patient]'s chest."))
	playsound(get_turf(src),'sound/items/defib_charge.ogg', 45, 0) // Don't vary this, it should be exactly 7 seconds

	if(!do_after(user, 7 SECONDS, NONE, patient, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		to_chat(user, span_warning("You stop setting up the paddles on [patient]'s chest."))
		return

	if(!defib_ready(patient, user)) // we're doing this again just in case something has changed
		return

	// do the defibrillation effects now and check revive parameters in a moment
	. = TRUE
	sparks.start()
	dcell.use(charge_cost)
	update_icon()
	playsound(get_turf(src), 'sound/items/defib_release.ogg', 45, 1)
	user.visible_message(span_notice("[user] shocks [patient] with the paddles."),
	span_notice("You shock [patient] with the paddles."))
	patient.visible_message(span_warning("[patient]'s body convulses a bit."))

	COOLDOWN_START(src, defib_cooldown, DEFIBRILLATOR_COOLDOWN)

	var/datum/internal_organ/heart/heart = patient.get_organ_slot(ORGAN_SLOT_HEART)
	if(!issynth(patient) && !isrobot(patient) && heart && prob(25))
		heart.take_damage(5) //Allow the defibrillator to possibly worsen heart damage. Still rare enough to just be the "clone damage" of the defib

	//At this point, the defibrillator is ready to work
	//this trait allows some species to be healed to one hit from death, so the defibrillator can't fail from too much damage
	if(HAS_TRAIT(patient, TRAIT_IMMEDIATE_DEFIB))
		patient.setOxyLoss(0)
		patient.updatehealth()

		var/heal_target = patient.get_crit_threshold() - patient.health + 1
		var/all_loss = patient.getBruteLoss() + patient.getFireLoss() + patient.getToxLoss()
		if(all_loss && (heal_target > 0))
			var/brute_ratio = patient.getBruteLoss() / all_loss
			var/burn_ratio = patient.getFireLoss() / all_loss
			var/tox_ratio = patient.getToxLoss() / all_loss
			if(tox_ratio)
				patient.adjustToxLoss(-(tox_ratio * heal_target))
			patient.heal_overall_damage(brute_ratio*heal_target, burn_ratio*heal_target, TRUE) // explicitly also heals robot parts

		if(HAS_TRAIT_FROM(patient, TRAIT_IMMEDIATE_DEFIB, SUPERSOLDIER_TRAIT))
			heart.take_damage(15) // estimated to be 1/2 of the health of the heart so 2 zaps kill you

	else if(!issynth(patient)) // TODO make me a trait :)
		patient.adjustBruteLoss(-defib_heal_amt)
		patient.adjustFireLoss(-defib_heal_amt)
		patient.adjustToxLoss(-defib_heal_amt)
		patient.setOxyLoss(0)

	patient.updatehealth() // update health because it won't always update for the dead

	fail_reason = null // Clear the fail reason as we check again
	// We're keeping permadeath states from earlier here in case something changes mid revive
	switch(patient.check_defib())
		if(DEFIB_FAIL_DECAPITATED)
			if(patient.species.species_flags & DETACHABLE_HEAD) // special message for synths/robots missing their head
				fail_reason = "Patient is missing their head. Reattach and try again."
			else
				fail_reason = "Patient is missing their head. Further attempts futile."
		if(DEFIB_FAIL_BRAINDEAD)
			fail_reason = "Patient's general condition does not allow revival. Further attempts futile."
		if(DEFIB_FAIL_BAD_ORGANS)
			fail_reason = "Patient's heart is too damaged to sustain life. Surgical intervention required."
		if(DEFIB_FAIL_TOO_MUCH_DAMAGE)
			fail_reason = "Vital signs are weak. Repair damage and try again."

	if(fail_reason)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Resuscitation failed - [fail_reason]"))
		playsound(src, 'sound/items/defib_failed.ogg', 45, FALSE)
		return

	ghost = patient.get_ghost(TRUE)
	if(ghost)
		ghost.reenter_corpse()

	if(!patient.client)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: No soul detected. Patient may not appear alert temporarily or permanently."))

	to_chat(patient, span_notice("<i><font size=4>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane...</font></i>"))
	user.visible_message(span_notice("[icon2html(src, viewers(user))] \The [src] beeps: Resuscitation successful."))
	playsound(get_turf(src), 'sound/items/defib_success.ogg', 45, 0)
	patient.updatehealth()
	patient.resuscitate() // time for a smoke
	patient.emote("gasp")
	patient.flash_act()
	patient.apply_effect(10, EFFECT_EYE_BLUR)
	patient.apply_effect(20 SECONDS, EFFECT_UNCONSCIOUS)

	ghost = patient.get_ghost(TRUE) // just in case they re-entered their body
	if(ghost) // register a signal to bring them into their body on reconnect
		ghost.RegisterSignal(ghost, COMSIG_MOB_LOGIN, TYPE_PROC_REF(/mob/dead/observer, revived_while_away))

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
	icon_state = "civ_defib"
	worn_icon_state = "defib"

///used for advanced medical (defibrillator) gloves: defibrillator_gloves.dm
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
