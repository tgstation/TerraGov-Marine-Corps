/obj/item/defibrillator
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to resuscitate incapacitated patients."
	icon = 'icons/obj/items/defibrillator.dmi'
	icon_state = "defib"
	item_state = "defib"
	flags_atom = CONDUCT
	flags_item = NOBLUDGEON
	flags_equip_slot = ITEM_SLOT_BELT
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_NORMAL

	/// Is this defibrillator currently ready
	var/ready = FALSE
	/// Whether this defibrillator has to be ready to use
	var/ready_needed = TRUE
	/// The base healing number with this defibrillator, this will be multiplied based on user skill
	var/damage_threshold = 8
	/// The charge cost of this defibrillator
	var/charge_cost = 66
	/// The cooldown for *toggling* this defibrillator
	var/defib_cooldown = 0
	/// The cooldown for *using* this defibrillator (on someone)
	var/shock_cooldown = 0
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
	overlays.Cut()

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
	var/maxuses = 0
	var/currentuses = 0
	maxuses = round(dcell.maxcharge / charge_cost)
	currentuses = round(dcell.charge / charge_cost)
	. += span_info("It has <b>[currentuses]</b> out of <b>[maxuses]</b> uses left in its internal battery.")


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

	defib_cooldown = world.time + 1 SECONDS
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

/mob/living/proc/get_ghost(bypass_client_check = FALSE)
	if(client) //Let's call up the correct ghost!
		return null
	for(var/mob/dead/observer/ghost AS in GLOB.observer_list)
		if(!ghost) //Observers hard del often so lets just be safe
			continue
		if(isnull(ghost.can_reenter_corpse))
			continue
		if(ghost.can_reenter_corpse.resolve() != src)
			continue
		if(ghost.client || bypass_client_check)
			return ghost
	return null

/mob/living/carbon/human/proc/has_working_organs()
	var/datum/internal_organ/heart/heart = internal_organs_by_name["heart"]

	if(!heart || heart.organ_status == ORGAN_BROKEN || !has_brain())
		return FALSE

	return TRUE

/obj/item/defibrillator/attack(mob/living/carbon/human/H, mob/living/carbon/human/user)
	defibrillate(H,user)

/// Clowncar proc to check a bunch of different reasons someone could be unrevivable.
/obj/item/defibrillator/proc/check_revive(mob/living/carbon/human/H, mob/living/carbon/human/user)
	// The patient is a xenomorph
	if(!ishuman(H))
		to_chat(user, span_warning("You can't defibrilate [H]. You don't even know where to put the paddles!"))
		return

	// Defibrillator isn't active
	if(!ready)
		to_chat(user, span_warning("Take [src]'s paddles out first."))
		return

	// No power
	if(dcell.charge <= charge_cost)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Internal battery depleted. Cannot analyze nor administer shock."))
		return

	// They aren't even dead
	if(H.stat != DEAD)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient is not in a valid state."))
		return

	// Heart broken
	if(!H.has_working_organs() && !(H.species.species_flags & ROBOTIC_LIMBS))
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's heart is failing. Immediate surgical intervention required."))
		return

	// Wearing armor
	if((H.wear_suit && H.wear_suit.flags_atom & CONDUCT))
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's chest is obscured. Remove suit or armor and try again."))
		return

	// Unrevivable. NPC, missing a head, or something else. Also synthetics won't expire from this.
	if((HAS_TRAIT(H, TRAIT_UNDEFIBBABLE) && !issynth(H)) || H.suiciding)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's general condition does not allow revival."))
		return

	// No ghost detected. DNR or an NPC.
	if(!H.mind && !H.get_ghost(TRUE))
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient is missing intelligence patterns or has a DNR."))
		return

	// Moved out of their body. Or decapitated robots/synths.
	if(!H.client)
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Patient's soul has departed. Please try again."))
		return

	return TRUE

///Split proc that actually does the defibrillation. Separated to be used more easily by medical gloves
/obj/item/defibrillator/proc/defibrillate(mob/living/carbon/human/H, mob/living/carbon/human/user)
	if(user.do_actions) // Too busy to defibrillate.
		to_chat(user, span_warning("You're too busy to defibrillate [H]!"))
		return

	if(shock_cooldown > world.time) // Shocking has been made a separate cooldown so you can immediately shock after turning it on.
		to_chat(user, span_warning("The defibrillator is recharging!"))
		return

	shock_cooldown = world.time + 1 SECONDS

	var/defib_heal_amt = damage_threshold

	//job knowledge requirement
	var/skill = user.skills.getRating(SKILL_MEDICAL)
	if(skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = SKILL_TASK_AVERAGE - (SKILL_TASK_VERY_EASY * skill) // 3 seconds with medical skill, 5 without
		if(!do_after(user, fumbling_time, NONE, H, BUSY_ICON_UNSKILLED))
			return

	defib_heal_amt *= skill * 0.5 //more healing power when used by a doctor (this means non-trained don't heal)

	var/mob/dead/observer/G = H.get_ghost()
	if(G)
		notify_ghost(G, span_bigdeadsay("<b>Your heart is being defibrillated!</b>"), ghost_sound = 'sound/effects/gladosmarinerevive.ogg')
		G.reenter_corpse()

	if(!check_revive(H, user))
		return

	user.visible_message(span_notice("[user] starts setting up the paddles on [H]'s chest."),
	span_notice("You start setting up the paddles on [H]'s chest."))
	if(defib_heal_amt == 0)
		to_chat(user, span_warning("Using a defibrillator without training is awkward."))
	playsound(get_turf(src),'sound/items/defib_charge.ogg', 25, 0) // This needs to be exactly 7 seconds, so don't vary it.

	if(!do_after(user, 7 SECONDS, NONE, H, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		user.visible_message(span_warning("[user] stops setting up the paddles on [H]'s chest."),
		span_warning("You stop setting up the paddles on [H]'s chest."))
		return

	if(!check_revive(H, user))
		return

	//Do this now, order doesn't matter
	sparks.start()
	dcell.use(charge_cost)
	update_icon()
	playsound(get_turf(src), 'sound/items/defib_release.ogg', 25)
	user.visible_message(span_notice("[user] shocks [H] with the paddles."),
	span_notice("You shock [H] with the paddles."))
	H.visible_message(span_danger("[H]'s body convulses a bit."))
	shock_cooldown = world.time + 20 //2 second cooldown before you can shock again

	if(!check_revive(H, user))
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
		user.visible_message(span_warning("[icon2html(src, viewers(user))] \The [src] buzzes: Resuscitation failed. Vital signs are too weak, repair damage and try again."))
		playsound(get_turf(src), 'sound/items/defib_failed.ogg', 35, 0)
		return

	user.visible_message(span_notice("[icon2html(src, viewers(user))] \The [src] beeps: Resuscitation successful."))
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

	//Checks if our "patient" is wearing a camera. Then it turns it on if it's off.
	if(istype(H.wear_ear, /obj/item/radio/headset/mainship))
		var/obj/item/radio/headset/mainship/cam_headset = H.wear_ear
		if(!(cam_headset?.camera?.status))
			cam_headset.camera.toggle_cam(null, FALSE)

	REMOVE_TRAIT(H, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
	if(user.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.revives++
		personal_statistics.mission_revives++
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

/obj/item/defibrillator/gloves/update_icon_state()
	return //The parent has some behaviour we don't want
