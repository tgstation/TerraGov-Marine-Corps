///////////////////Reason defines///////////////////
#define DOAFTER_FAIL_STRING "Take [src]'s paddles back out to continue."
#define FAIL_REASON_TISSUE "Vital signs are weak. Repair damage and try again."
#define FAIL_REASON_ORGANS "Patient's organs are too damaged to sustain life. Surgical intervention required."
#define FAIL_REASON_DECAPITATED "Patient is missing their head."
#define FAIL_REASON_BRAINDEAD "Patient is braindead. Further attempts futile."
#define FAIL_REASON_DNR "Patient is missing intelligence patterns or has a DNR. Further attempts futile."
#define FAIL_REASON_SOUL "No soul detected. Please try again."

///////////////////Defibrillators///////////////////
/obj/item/defibrillator
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to resuscitate patients."
	icon = 'icons/obj/items/defibrillator.dmi'
	icon_state = "defib"
	item_state = "defib"
	flags_atom = CONDUCT
	flags_item = NOBLUDGEON
	flags_equip_slot = ITEM_SLOT_BELT
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_NORMAL

	/// if the defibrillator is ready to use (paddles out)
	var/ready = FALSE
	/// whether this defibrillator has to be turned on to use
	var/ready_needed = TRUE
	/// The base number to use for healing amount when the defibrillator fails from too much damage
	var/damage_threshold = 8
	/// How much charge is used on a shock, with a 1320 power cell, allows 20 uses
	var/charge_cost = 66
	/// The cooldown for toggling.
	var/defib_cooldown = 0
	/// The cooldown for shocking.
	var/shock_cooldown = 0
	/// The defibrillator's power cell
	var/obj/item/cell/dcell = null
	var/datum/effect_system/spark_spread/sparks


/obj/item/defibrillator/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is putting the live paddles on [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide."))
	return (FIRELOSS)


/obj/item/defibrillator/Initialize(mapload)
	. = ..()
	sparks = new
	sparks.set_up(5, 0, src)
	sparks.attach(src)
	set_dcell(new /obj/item/cell/defibrillator())
	update_icon()


/obj/item/defibrillator/Destroy()
	QDEL_NULL(sparks)
	if(dcell)
		UnregisterSignal(dcell, COMSIG_QDELETING)
		QDEL_NULL(dcell)
	return ..()


/obj/item/defibrillator/update_icon()
	. = ..()
	icon_state = initial(icon_state)

	if(ready)
		icon_state += "_out"

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
	. += span_infoplain("It has [round(dcell.charge / charge_cost)] out of [round(dcell.maxcharge / charge_cost)] uses left in its internal battery.")
	. += maybe_message_recharge_hint()


/**
 * Message user with a hint to recharge defibrillator
 * and how to do it if the battery is low.
*/
/obj/item/defibrillator/proc/maybe_message_recharge_hint(mob/living/carbon/human/user)
	if(!dcell)
		return

	var/message
	if(dcell.charge < charge_cost)
		message = "The battery is empty."
	else if(round(dcell.charge * 100 / dcell.maxcharge) <= 33)
		message = "The battery is low."

	if(!message)
		return
	return span_alert("[message] You can click-drag this unit on a corpsman backpack to recharge it.")


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
	playsound(get_turf(src), "sparks", 25, TRUE, 4)
	if(ready)
		w_class = WEIGHT_CLASS_BULKY // Prevent pulling out more full defibs when one runs out
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

/obj/item/defibrillator/attack(mob/living/carbon/human/H, mob/living/carbon/human/user)
	defibrillate(H,user)

///Split proc that actually does the defibrillation. Separated to be used more easily by medical gloves
/obj/item/defibrillator/proc/defibrillate(mob/living/carbon/human/H, mob/living/carbon/human/user)
	if(user.do_actions) //Currently doing something
		user.visible_message(span_warning("You're already doing something!"))
		return

	if(shock_cooldown > world.time) // separated from defib_cooldown so you can shock instantly after defibrillating someone
		user.visible_message(span_warning("\The [src] is recharging, wait a second!"))
		return

	shock_cooldown = world.time + 2 SECONDS

	//job knowledge requirement
	var/skill = user.skills.getRating(SKILL_MEDICAL)
	if(skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = SKILL_TASK_EASY - (SKILL_TASK_VERY_EASY * skill)
		if(!do_after(user, fumbling_time, NONE, H, BUSY_ICON_UNSKILLED))
			return
	var/defib_heal_amt = damage_threshold
	defib_heal_amt *= skill * 0.5 // Untrained don't heal.

	if(!ishuman(H))
		to_chat(user, span_warning("You can't defibrilate [H]. You don't even know where to put the paddles!"))
		return
	if(dcell.charge <= charge_cost)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Internal battery depleted, seek recharger. Cannot analyze nor administer shock."))
		to_chat(user, maybe_message_recharge_hint())
		return
	if(!ready)
		to_chat(user, span_warning(DOAFTER_FAIL_STRING))
		return
	if(H.stat == DEAD && H.wear_suit && H.wear_suit.flags_atom & CONDUCT) // Dead, chest obscured
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's chest is obscured, operation aborted. Remove suit or armor and try again."))
		playsound(src, 'sound/items/defib_failed.ogg', 40, FALSE)
		return
	if(H.stat != DEAD) // They aren't even dead
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient is not in a valid state. Operation aborted."))
		playsound(src, 'sound/items/defib_failed.ogg', 40, FALSE)
		return

	var/mob/dead/observer/G = H.get_ghost()
	if(G)
		notify_ghost(G, "<font size=4.8><br><b>Your heart is being defibrillated.</b><br></font>", ghost_sound = 'sound/effects/gladosmarinerevive.ogg')
		G.reenter_corpse()

	user.visible_message(span_notice("[user] starts setting up the paddles on [H]'s chest."),
	span_notice("You start setting up the paddles on [H]'s chest."))
	playsound(get_turf(src),'sound/items/defib_charge.ogg', 25, 0) // Don't vary this

	if(!do_after(user, 7 SECONDS, NONE, H, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL)) // 7 seconds revive time
		to_chat(user, span_warning("You stop setting up the paddles on [H]'s chest."))
		return

	// Do this now
	sparks.start()
	H.visible_message(span_warning("[H]'s body convulses a bit."))
	playsound(src, 'sound/items/defib_release.ogg', 25, FALSE)
	dcell.use(charge_cost)
	update_icon()
	H.updatehealth()

	var/defib_result = H.check_defib()
	var/fail_reason

	switch(defib_result)
		if(DEFIB_FAIL_TISSUE_DAMAGE) // checks damage threshold in human_defines.dm, whatever is defined for their species
			fail_reason = FAIL_REASON_TISSUE // also, if this is the fail reason, heals brute&burn based on skill
		if(DEFIB_FAIL_BAD_ORGANS)
			fail_reason = FAIL_REASON_ORGANS
		if(DEFIB_FAIL_DECAPITATED)
			if(H.species.species_flags & DETACHABLE_HEAD) // special message for synths/robots missing their head
				fail_reason = "Patient is missing their head. Reattach and try again."
			else
				fail_reason = FAIL_REASON_DECAPITATED
		if(DEFIB_FAIL_BRAINDEAD)
			fail_reason = FAIL_REASON_BRAINDEAD
		if(DEFIB_FAIL_CLIENT_MISSING)
			if(H.mind && !H.client) // no client, like a DNR mob or colonist
				fail_reason = FAIL_REASON_DNR
			else if(HAS_TRAIT(H, TRAIT_UNDEFIBBABLE))
				fail_reason = FAIL_REASON_DNR
			else
				fail_reason = FAIL_REASON_SOUL // deadheads that exit their body *after* defib starts

	if(fail_reason)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Resuscitation failed - [fail_reason]"))
		playsound(src, 'sound/items/defib_failed.ogg', 50, FALSE)
		if(!issynth(H) && fail_reason == FAIL_REASON_TISSUE) // Heal them if this is failing because of too much damage.
			H.adjustBruteLoss(-defib_heal_amt)
			H.adjustFireLoss(-defib_heal_amt)
			H.updatehealth() // Adjust procs won't update health
		return


	if(HAS_TRAIT(H, TRAIT_IMMEDIATE_DEFIB)) // if they're a robot or something, heal them to one hit from death
		H.setOxyLoss(0)

		var/heal_target = H.get_death_threshold() - H.health + 1
		var/all_loss = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss()
		if(all_loss && (heal_target > 0))
			var/brute_ratio = H.getBruteLoss() / all_loss
			var/burn_ratio = H.getFireLoss() / all_loss
			var/tox_ratio = H.getToxLoss() / all_loss
			if(tox_ratio)
				H.adjustToxLoss(-(tox_ratio * heal_target))
				H.heal_overall_damage(brute_ratio*heal_target, burn_ratio*heal_target, TRUE) // explicitly also heals robot parts

		// Adjust procs won't do it
		H.updatehealth()


	if(!issynth(H))
		// Humans, doesn't do anything for synths
		// The health target is -52 health
		var/death_threshold = H.get_death_threshold()
		var/crit_threshold
		var/hardcrit_target = crit_threshold + death_threshold * 0
		var/total_brute = H.getBruteLoss()
		var/total_burn = H.getFireLoss()

		H.setStaminaLoss(-250) // stamina victims shouldn't die instantly when coming back to life.
		if(H.health > hardcrit_target)
			H.adjustOxyLoss(H.health - hardcrit_target + 2) // So they remain in crit.

		var/overall_damage = total_brute + total_burn + H.getToxLoss() + H.getOxyLoss() + H.getCloneLoss()
		var/mobhealth = H.health
		H.adjustCloneLoss((mobhealth - hardcrit_target) * (H.getCloneLoss() / overall_damage))
		H.adjustOxyLoss((mobhealth - hardcrit_target) * (H.getOxyLoss() / overall_damage) + 0.1)
		H.adjustToxLoss((mobhealth - hardcrit_target) * (H.getToxLoss() / overall_damage))
		H.adjustFireLoss((mobhealth - hardcrit_target) * (total_burn / overall_damage))
		H.adjustBruteLoss((mobhealth - hardcrit_target) * (total_brute / overall_damage))

		// Adjust procs won't do it
		H.updatehealth()


	to_chat(H, span_notice("<i><font size=4>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane...</font></i>"))
	user.visible_message(span_notice("[icon2html(src, viewers(user))] \The [src] beeps: Resuscitation successful."))
	playsound(get_turf(src), 'sound/items/defib_success.ogg', 50, 0)
	H.resuscitate() // time for a smoke

	//Checks if our "patient" is wearing a camera. Then it turns it on if it's off.
	if(istype(H.wear_ear, /obj/item/radio/headset/mainship))
		var/obj/item/radio/headset/mainship/cam_headset = H.wear_ear
		if(!(cam_headset?.camera?.status))
			cam_headset.camera.toggle_cam(null, FALSE)
	if(user.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.revives++
		personal_statistics.mission_revives++
	GLOB.round_statistics.total_human_revives[H.faction]++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_human_revives[H.faction]")

	if(CHECK_BITFIELD(H.status_flags, XENO_HOST))
		var/obj/item/alien_embryo/friend = locate() in H
		START_PROCESSING(SSobj, friend)

	notify_ghosts("<b>[user]</b> has brought <b>[H.name]</b> back to life!", source = H, action = NOTIFY_ORBIT)

/obj/item/defibrillator/civi
	name = "civilian defibrillator"
	desc = "A handheld emergency defibrillator, used to resuscitate patients. Appears to be a civilian model."
	icon_state = "civ_defib"
	item_state = "defib"


/obj/item/defibrillator/gloves
	name = "advanced medical combat gloves"
	desc = "Advanced medical gloves, these include small electrodes to defibrilate a patiant. No more bulky units!"
	icon_state = "defib_gloves"
	item_state = "defib_gloves"
	ready = TRUE
	ready_needed = FALSE
	flags_equip_slot = ITEM_SLOT_GLOVES
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	item_state_worn = TRUE
	siemens_coefficient = 0.50
	blood_sprite_state = "bloodyhands"
	flags_armor_protection = HANDS
	flags_equip_slot = ITEM_SLOT_GLOVES
	attack_verb = "zaps"
	soft_armor = list(MELEE = 25, BULLET = 15, LASER = 10, ENERGY = 15, BOMB = 15, BIO = 5, FIRE = 15, ACID = 15)
	flags_cold_protection = HANDS
	flags_heat_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/defibrillator/gloves/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(user.gloves == src)
		RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	else
		UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)

/obj/item/defibrillator/gloves/unequipped(mob/living/carbon/human/user, slot)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK) //Unregisters in the case of getting delimbed

//when you are wearing these gloves, this will call the normal attack code to begin defibing the target
/obj/item/defibrillator/gloves/proc/on_unarmed_attack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.a_intent != INTENT_HELP)
		return
	if(istype(user) && istype(target))
		defibrillate(target, user)

/obj/item/defibrillator/gloves/update_icon()
	SHOULD_CALL_PARENT(FALSE)
	return //The parent has some behaviour we don't want

#undef DOAFTER_FAIL_STRING
#undef FAIL_REASON_TISSUE
#undef FAIL_REASON_ORGANS
#undef FAIL_REASON_DECAPITATED
#undef FAIL_REASON_BRAINDEAD
#undef FAIL_REASON_DNR
#undef FAIL_REASON_SOUL
