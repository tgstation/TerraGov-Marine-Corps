/// This is a define so we can have special behavior for when this is the fail reason
#define FAIL_REASON_TISSUE "Tissue damage too severe. Repair damage and try again."

/obj/item/defibrillator
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to resuscitate patients."
	icon = 'icons/obj/items/defibrillator.dmi'
	icon_state = "defib_full"
	worn_icon_state = "defib"
	atom_flags = CONDUCT
	item_flags = NOBLUDGEON
	equip_slot_flags = ITEM_SLOT_BELT
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
	return "[message] You can click-drag this unit on a corpsman backpack to recharge it."


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

	if(defib_cooldown > world.time)
		user.visible_message(span_warning("\The [src] has been used too recently, wait a second!"))
		return

	defib_cooldown = world.time + 2 SECONDS

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
		to_chat(user, span_warning("You can't defibrillate [H]. You don't even know where to put the paddles!"))
		return
	if(dcell.charge <= charge_cost)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Internal battery depleted, seek recharger. Cannot analyze nor administer shock."))
		to_chat(user, span_boldwarning("You can recharge the defibrillator by click-dragging it onto a corpsman backpack."))
		return
	if(!ready)
		to_chat(user, span_warning("Take the paddles out to continue."))
		return
	if(H.stat == DEAD && H.wear_suit && H.wear_suit.atom_flags & CONDUCT) // Dead, chest obscured
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's chest is obscured, operation aborted. Remove suit or armor and try again."))
		playsound(src, 'sound/items/defib_failed.ogg', 40, FALSE)
		return

	if(!H.has_working_organs() && !(H.species.species_flags & ROBOTIC_LIMBS))
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's organs are too damaged to sustain life. Deliver patient to a MD for surgical intervention."))
		return

	if((H.wear_suit && H.wear_suit.atom_flags & CONDUCT))
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Paddles registering >100,000 ohms, Possible cause: Suit or Armor interferring."))
	if(H.stat != DEAD) // They aren't even dead
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient is not in a valid state. Operation aborted."))
		playsound(src, 'sound/items/defib_failed.ogg', 40, FALSE)
		return

	var/mob/dead/observer/G = H.get_ghost()
	if(G)
		notify_ghost(G, assemble_alert(
			title = "Revival Imminent",
			message = "Someone is trying to resuscitate your body! Stay in it if you want to be resurrected!",
			color_override = "purple"
		), ghost_sound = 'sound/effects/gladosmarinerevive.ogg')
		G.reenter_corpse()

	user.visible_message(span_notice("[user] starts setting up the paddles on [H]'s chest."),
	span_notice("You start setting up the paddles on [H]'s chest."))
	playsound(get_turf(src),'sound/items/defib_charge.ogg', 25, 0) // Don't vary this

	if(!do_after(user, 7 SECONDS, NONE, H, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL)) // 7 seconds revive time
		to_chat(user, span_warning("You stop setting up the paddles on [H]'s chest."))
		return

	// Do this now, order doesn't really matter (we check the rest of revive parameters in a moment)
	sparks.start()
	H.visible_message(span_warning("[H]'s body convulses a bit."))
	playsound(src, 'sound/items/defib_release.ogg', 25, FALSE)
	dcell.use(charge_cost)
	update_icon()
	playsound(get_turf(src), 'sound/items/defib_release.ogg', 25, 1)
	user.visible_message(span_notice("[user] shocks [H] with the paddles."),
	span_notice("You shock [H] with the paddles."))
	H.visible_message(span_danger("[H]'s body convulses a bit."))
	defib_cooldown = world.time + 10 //1 second cooldown before you can shock again

	if(H.wear_suit && H.wear_suit.atom_flags & CONDUCT)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Defibrillation failed: Paddles registering >100,000 ohms, Possible cause: Suit or Armor interferring."))
		return

	var/datum/internal_organ/heart/heart = H.internal_organs_by_name["heart"]
	if(!issynth(H) && !isrobot(H) && heart && prob(25))
		heart.take_damage(5) //Allow the defibrillator to possibly worsen heart damage. Still rare enough to just be the "clone damage" of the defib

	if(HAS_TRAIT(H, TRAIT_UNDEFIBBABLE) || H.suiciding)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's brain has decayed too much. No remedy possible."))
		return

	if(!H.has_working_organs() && !(H.species.species_flags & ROBOTIC_LIMBS))
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Defibrillation failed. Patient's organs are too damaged to sustain life. Deliver patient to a MD for surgical intervention."))
		return

	if(H.species.species_flags & DETACHABLE_HEAD)	//But if their head's missing, they're still not coming back
		var/datum/limb/head/braincase = H.get_limb("head")
		if(braincase.limb_status & LIMB_DESTROYED)
			user.visible_message("[icon2html(src, viewers(user))] \The [src] buzzes: Positronic brain missing, cannot reboot.")
			return

	if(!H.client) //Either client disconnected after being dragged in, ghosted, or this mob isn't a player (but that is caught way earlier).
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: No soul detected, Attempting to revive..."))

	if(!H.mind) //Check if their ghost still exists if they aren't in their body.
		G = H.get_ghost(TRUE)
		if(istype(G))
			user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Defibrillation failed. Patient's soul has almost departed, please try again."))
			return
		//No mind and no associated ghost exists. This one is DNR.
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient has a DNR."))
		return

	if(!H.client) //No client, but has a mind. This means the player was in their body, but potentially disconnected.
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Defibrillation failed. No soul detected. Please try again."))
		playsound(get_turf(src), 'sound/items/defib_failed.ogg', 35, 0)
		return

	//At this point, the defibrillator is ready to work
	if(HAS_TRAIT(H, TRAIT_IMMEDIATE_DEFIB)) // this trait ignores user skill for the heal amount
		H.setOxyLoss(0)
		H.updatehealth()

		var/heal_target = H.get_death_threshold() - H.health + 1
		var/all_loss = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss()
		if(all_loss && (heal_target > 0))
			var/brute_ratio = H.getBruteLoss() / all_loss
			var/burn_ratio = H.getFireLoss() / all_loss
			var/tox_ratio = H.getToxLoss() / all_loss
			if(tox_ratio)
				H.adjustToxLoss(-(tox_ratio * heal_target))
			H.heal_overall_damage(brute_ratio*heal_target, burn_ratio*heal_target, TRUE) // explicitly also heals robit parts

	else if(!issynth(H)) // TODO make me a trait :)
		H.adjustBruteLoss(-defib_heal_amt)
		H.adjustFireLoss(-defib_heal_amt)
		H.adjustToxLoss(-defib_heal_amt)
		H.setOxyLoss(0)

	//the defibrillator is checking parameters now
	var/defib_result = H.check_defib()
	var/fail_reason

	switch(defib_result)
		if(DEFIB_FAIL_TISSUE_DAMAGE)
			fail_reason = "Tissue damage too severe. Repair damage and try again."
		if(DEFIB_FAIL_BAD_ORGANS)
			fail_reason = "Patient is missing intelligence patterns or has a DNR. Further attempts futile."
		if(DEFIB_FAIL_DECAPITATED)
			if(H.species.species_flags & DETACHABLE_HEAD) // special message for synths/robots missing their head
				fail_reason = "Patient is missing their head. Reattach and try again."
			else
				fail_reason = "Patient is missing their head."
		if(DEFIB_FAIL_BRAINDEAD)
			fail_reason = "Patient is braindead. Further attempts futile."
		if(DEFIB_FAIL_CLIENT_MISSING)
			if(!H.mind && !H.get_ghost(TRUE)) // confirmed NPC: colonist or something
				fail_reason = "Patient is missing intelligence patterns or has a DNR. Further attempts futile."
			else if(HAS_TRAIT(H, TRAIT_UNDEFIBBABLE))
				fail_reason = "Patient is missing intelligence patterns or has a DNR. Further attempts futile."
			else
				fail_reason = "No soul detected. Please try again." // deadheads that exit their body *after* defib starts

	if(fail_reason)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Resuscitation failed - [fail_reason]"))
		playsound(src, 'sound/items/defib_failed.ogg', 50, FALSE)
		return

	H.updatehealth()

	to_chat(H, span_notice("<i><font size=4>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane...</font></i>"))
	user.visible_message(span_notice("[icon2html(src, viewers(user))] \The [src] beeps: Resuscitation successful."))
	playsound(get_turf(src), 'sound/items/defib_success.ogg', 50, 0)
	H.resuscitate() // time for a smoke
	H.emote("gasp")
	H.chestburst = CARBON_NO_CHEST_BURST
	H.regenerate_icons()
	H.reload_fullscreens()
	H.flash_act()
	H.apply_effect(10, EYE_BLUR)
	H.apply_effect(20 SECONDS, PARALYZE)
	H.handle_regular_hud_updates()
	H.updatehealth() //One more time, so it doesn't show the target as dead on HUDs
	H.dead_ticks = 0 //We reset the DNR time

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
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to restore fibrillating patients. Can optionally bring people back from the dead. Appears to be a civillian model."
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
	desc = "Advanced medical gauntlets with small electrodes to resuscitate patients without a bulky unit."
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

#undef FAIL_REASON_TISSUE
