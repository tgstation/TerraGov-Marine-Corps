/obj/item/defibrillator
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to restore fibrillating patients. Can optionally bring people back from the dead."
	icon = 'icons/obj/items/defibrillator.dmi'
	icon_state = "defib_full"
	item_state = "defib"
	flags_atom = CONDUCT
	flags_item = NOBLUDGEON
	flags_equip_slot = ITEM_SLOT_BELT
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_NORMAL

	var/ready = FALSE
	///wether readying is needed
	var/ready_needed = TRUE
	var/damage_threshold = 8 //This is the maximum non-oxy damage the defibrillator will heal to get a patient above -100, in all categories
	var/charge_cost = 66 //How much energy is used.
	var/obj/item/cell/dcell = null
	var/datum/effect_system/spark_spread/sparks
	var/defib_cooldown = 0 //Cooldown for toggling the defib


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
	icon_state = "defib"
	if(ready)
		icon_state += "_out"
	if(dcell?.charge)
		switch(round(dcell.charge * 100 / dcell.maxcharge))
			if(67 to INFINITY)
				icon_state += "_full"
			if(34 to 66)
				icon_state += "_half"
			if(1 to 33)
				icon_state += "_low"
	else
		icon_state += "_empty"


/obj/item/defibrillator/examine(mob/user)
	. = ..()
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
	return span_notice("[message] You can click-drag defibrillator on corpsman backpack to recharge it.")


/obj/item/defibrillator/attack_self(mob/living/carbon/human/user)
	if(!ready_needed)
		return
	if(!istype(user))
		return
	if(defib_cooldown > world.time)
		return

	//Job knowledge requirement
	var/skill = user.skills.getRating(SKILL_MEDICAL)
	if(skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		if(!do_after(user, SKILL_TASK_AVERAGE - (SKILL_TASK_VERY_EASY * skill), NONE, src, BUSY_ICON_UNSKILLED)) // 3 seconds with medical skill, 5 without
			return

	defib_cooldown = world.time + 2 SECONDS
	ready = !ready
	user.visible_message(span_notice("[user] turns [src] [ready? "on and opens the cover" : "off and closes the cover"]."),
	span_notice("You turn [src] [ready? "on and open the cover" : "off and close the cover"]."))
	playsound(get_turf(src), "sparks", 25, TRUE, 4)
	if(ready)
		playsound(get_turf(src), 'sound/items/defib_safetyOn.ogg', 30, 0)
	else
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

/mob/living/proc/get_ghost()
	if(client) //Let's call up the correct ghost!
		return null
	for(var/mob/dead/observer/ghost AS in GLOB.observer_list)
		if(!ghost) //Observers hard del often so lets just be safe
			continue
		if(isnull(ghost.can_reenter_corpse))
			continue
		if(ghost.can_reenter_corpse.resolve() != src)
			continue
		if(ghost.client)
			return ghost
	return null

/mob/living/carbon/human/proc/has_working_organs()
	var/datum/internal_organ/heart/heart = internal_organs_by_name["heart"]

	if(!heart || heart.organ_status == ORGAN_BROKEN || !has_brain())
		return FALSE

	return TRUE

/obj/item/defibrillator/attack(mob/living/carbon/human/H, mob/living/carbon/human/user)
	defibrillate(H,user)

///Split proc that actually does the defibrillation. Separated to be used more easily by medical gloves
/obj/item/defibrillator/proc/defibrillate(mob/living/carbon/human/H, mob/living/carbon/human/user)
	if(user.do_actions) //Currently deffibing
		return

	if(defib_cooldown > world.time) //Both for pulling the paddles out (2 seconds) and shocking (1 second)
		return

	defib_cooldown = world.time + 2 SECONDS

	var/defib_heal_amt = damage_threshold

	//job knowledge requirement
	var/skill = user.skills.getRating(SKILL_MEDICAL)
	if(skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = SKILL_TASK_AVERAGE - (SKILL_TASK_VERY_EASY * skill) // 3 seconds with medical skill, 5 without
		if(!do_after(user, fumbling_time, NONE, H, BUSY_ICON_UNSKILLED))
			return
	else
		defib_heal_amt *= skill * 0.5 //more healing power when used by a doctor (this means non-trained don't heal)

	if(!ishuman(H))
		to_chat(user, span_warning("You can't defibrilate [H]. You don't even know where to put the paddles!"))
		return
	if(!ready)
		to_chat(user, span_warning("Take [src]'s paddles out first."))
		return
	if(dcell.charge <= charge_cost)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Internal battery depleted. Cannot analyze nor administer shock."))
		to_chat(user, maybe_message_recharge_hint())
		return
	if(H.stat != DEAD)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Vital signs detected. Aborting."))
		return

	if((HAS_TRAIT(H, TRAIT_UNDEFIBBABLE ) && !issynth(H)) || H.suiciding) //synthetic species have no expiration date
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient is braindead. No remedy possible."))
		return

	if(!H.has_working_organs() && !(H.species.species_flags & ROBOTIC_LIMBS))
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's organs are too damaged to sustain life. Deliver patient to a MD for surgical intervention."))
		return

	if((H.wear_suit && H.wear_suit.flags_atom & CONDUCT))
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Paddles registering >100,000 ohms, Possible cause: Suit or Armor interferring."))
		return

	var/mob/dead/observer/G = H.get_ghost()
	if(G)
		G.reenter_corpse()
	else if(!H.client)
		//We couldn't find a suitable ghost, this means the person is not returning
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient has a DNR."))
		return

	user.visible_message(span_notice("[user] starts setting up the paddles on [H]'s chest."),
	span_notice("You start setting up the paddles on [H]'s chest."))
	playsound(get_turf(src),'sound/items/defib_charge.ogg', 25, 0) //Do NOT vary this tune, it needs to be precisely 7 seconds

	if(!do_after(user, 7 SECONDS, NONE, H, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		user.visible_message(span_warning("[user] stops setting up the paddles on [H]'s chest."),
		span_warning("You stop setting up the paddles on [H]'s chest."))
		return

	//Do this now, order doesn't matter
	sparks.start()
	dcell.use(charge_cost)
	update_icon()
	playsound(get_turf(src), 'sound/items/defib_release.ogg', 25, 1)
	user.visible_message(span_notice("[user] shocks [H] with the paddles."),
	span_notice("You shock [H] with the paddles."))
	H.visible_message(span_danger("[H]'s body convulses a bit."))
	defib_cooldown = world.time + 10 //1 second cooldown before you can shock again

	if(H.wear_suit && H.wear_suit.flags_atom & CONDUCT)
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

	if(!H.client) //Freak case, no client at all. This is a braindead mob (like a colonist)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: No soul detected, Attempting to revive..."))

	if(H.mind && !H.client) //Let's call up the correct ghost! Also, bodies with clients only, thank you.
		G = H.get_ghost()
		if(istype(G))
			user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Defibrillation failed. Patient's soul has almost departed, please try again."))
			return
		//We couldn't find a suitable ghost, this means the person is not returning
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient has a DNR."))
		return

	if(!H.client) //Freak case, no client at all. This is a braindead mob (like a colonist) or someone who didn't enter their body in time.
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

	H.updatehealth() //Make sure health is up to date since it's a purely derived value
	if(H.health <= H.get_death_threshold())
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Defibrillation failed. Vital signs are too weak, repair damage and try again."))
		playsound(get_turf(src), 'sound/items/defib_failed.ogg', 35, 0)
		return

	user.visible_message(span_notice("[icon2html(src, viewers(user))] \The [src] beeps: Defibrillation successful."))
	playsound(get_turf(src), 'sound/items/defib_success.ogg', 35, 0)
	H.set_stat(UNCONSCIOUS)
	H.emote("gasp")
	H.chestburst = 0 //reset our chestburst state
	H.regenerate_icons()
	H.reload_fullscreens()
	H.flash_act()
	H.apply_effect(10, EYE_BLUR)
	H.apply_effect(20 SECONDS, PARALYZE)
	H.handle_regular_hud_updates()
	H.updatehealth() //One more time, so it doesn't show the target as dead on HUDs
	H.dead_ticks = 0 //We reset the DNR time
	REMOVE_TRAIT(H, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
	if(user.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.revives++
	GLOB.round_statistics.total_human_revives[H.faction]++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_human_revives[H.faction]")
	to_chat(H, span_notice("You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane."))

	if(CHECK_BITFIELD(H.status_flags, XENO_HOST))
		var/obj/item/alien_embryo/friend = locate() in H
		START_PROCESSING(SSobj, friend)

	notify_ghosts("<b>[user]</b> has brought <b>[H.name]</b> back to life!", source = H, action = NOTIFY_ORBIT)

/obj/item/defibrillator/civi
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to restore fibrillating patients. Can optionally bring people back from the dead. Appears to be a civillian model."
	icon_state = "civ_defib_full"
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

/obj/item/defibrillator/gloves/update_icon_state()
	return

