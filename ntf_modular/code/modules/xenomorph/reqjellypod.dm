/obj/structure/xeno/resin_stew_pod
	name = "ambrosia jelly pot"
	desc = "A large pot of thick viscious liquid churning together endlessly into large mounds of incredibly valuable, golden jelly."
	icon = 'ntf_modular/icons/xeno/resin_pod.dmi'
	icon_state = "stewpod"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 250
	layer = BELOW_OBJ_LAYER
	pixel_x = -16
	pixel_y = -16
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	hit_sound = SFX_ALIEN_RESIN_MOVE
	destroy_sound = SFX_ALIEN_RESIN_MOVE
	///How many actual jellies the pod has stored
	var/chargesleft = 0
	///Max amount of jellies the pod can hold
	var/maxcharges = 100
	///Slowprocess ticks of progress towards next jelly
	var/jelly_progress = 0
	///info to add to desc, updated by process()
	var/extra_desc
	///ckey of the player that created it
	var/creator_ckey
	///Slowprocess ticks without suitable owner
	var/decay = 0

/obj/structure/xeno/resin_stew_pod/Initialize(mapload, _hivenumber)
	. = ..()
	GLOB.hive_datums[hivenumber].req_jelly_pods += src
	START_PROCESSING(SSslowprocess, src)
	SSminimaps.add_marker(src, ((MINIMAP_FLAG_ALL) ^ (MINIMAP_FLAG_SURVIVOR)), image('ntf_modular/icons/UI_icons/map_blips.dmi', null, "ambrosia", MINIMAP_LABELS_LAYER))

/obj/structure/xeno/resin_stew_pod/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/resin_stew_pod/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(extra_desc)
		. += extra_desc
	var/mob/living/carbon/xenomorph/creator = GLOB.mobs_by_ckey_list[creator_ckey]
	if(isobserver(creator))
		var/mob/dead/observer/ghost_creator = creator
		creator = ghost_creator.can_reenter_corpse?.resolve()
	if(!isxeno(creator) || !issamexenohive(creator))
		return
	else
		. += "It belongs to [creator]."

/obj/structure/xeno/resin_stew_pod/process()
	var/mob/living/carbon/xenomorph/creator = GLOB.mobs_by_ckey_list[creator_ckey]
	if(isobserver(creator))
		var/mob/dead/observer/ghost_creator = creator
		creator = ghost_creator.can_reenter_corpse?.resolve()
	if(!isxeno(creator) || !issamexenohive(creator) || creator.stat == DEAD || !(creator.client) || (creator.client.inactivity > 15 MINUTES))
		if(decay >= 180) //15 minutes without a suitable owner will destroy it
			qdel(src)
			return
		extra_desc = "It has [chargesleft] jelly globules remaining and appears to be decaying."
		decay++
		return
	decay = max(0, decay - 5)
	var/progress_needed = GLOB.hive_datums[hivenumber].req_jelly_progress_required
	if(chargesleft < maxcharges)
		if(jelly_progress <= progress_needed)
			jelly_progress++
		else
			jelly_progress = 0
			chargesleft++
	if(chargesleft < maxcharges)
		extra_desc = "It has [chargesleft] jelly globules remaining and will create a new jelly in [(progress_needed - jelly_progress)*5] seconds"
	else
		extra_desc = "It has [chargesleft] jelly globules remaining and seems latent."

/obj/structure/xeno/resin_stew_pod/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if(issamexenohive(xeno_attacker))
		if(xeno_attacker.a_intent == INTENT_HARM && (xeno_attacker.xeno_flags & XENO_DESTROY_OWN_STRUCTURES))
			balloon_alert(xeno_attacker, "Destroying...")
			if(do_after(xeno_attacker, HIVELORD_TUNNEL_DISMANTLE_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
				deconstruct(FALSE)
			return

	if(!issamexenohive(xeno_attacker) && xeno_attacker.a_intent == INTENT_HARM)
		return ..()

	do
		if(!(chargesleft > 0))
			balloon_alert(xeno_attacker, "No jelly remaining")
			to_chat(xeno_attacker, span_xenonotice("We reach into \the [src], but only find dregs of resin. We should wait some more.") )
			return

		balloon_alert(xeno_attacker, "Retrieved jelly")
		var/obj/item/stack/req_jelly/new_jelly = new(xeno_attacker.loc, 1, hivenumber)
		new_jelly.add_to_stacks(xeno_attacker)
		chargesleft--
	while(do_mob(xeno_attacker, src, 1 SECONDS))

/obj/structure/xeno/resin_stew_pod/Destroy()
	if(loc && (chargesleft > 0))
		for(var/i = 1 to chargesleft)
			if(prob(95))
				var/obj/item/stack/req_jelly/new_jelly = new(loc, 1, hivenumber)
				new_jelly.add_to_stacks(src)
	GLOB.hive_datums[hivenumber].req_jelly_pods -= src
	. = ..()

///////////////////////
/// Requisition Jelly//
///////////////////////

/obj/item/stack/req_jelly
	name = "alien ambrosia"
	desc = "A beautiful, glittering mound of honey-like resin, might fetch a good price."
	icon = 'ntf_modular/icons/xeno/xeno_materials.dmi'
	icon_state = "reqjelly"
	max_amount = 100
	stack_name = "pile"
	singular_name = "globule"
	var/hivenumber = XENO_HIVE_NORMAL

/obj/item/stack/req_jelly/Initialize(mapload, new_amount, _hivenumber)
	if(_hivenumber) ///because admins can spawn them
		hivenumber = _hivenumber
	. = ..()
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	name = "[hive.prefix][name]"
	color = hive.color

/obj/item/stack/req_jelly/merge(obj/item/stack/S)
	if(!issamexenohive(S))
		return FALSE
	. = ..()

/obj/item/stack/req_jelly/change_stack(mob/user, new_amount)
	if(amount < 1 || amount < new_amount)
		stack_trace("[src] tried to change_stack() by [new_amount] amount for [user] user, while having [amount] amount itself.")
		return
	var/obj/item/stack/S = new type(user, new_amount, hivenumber)
	use(new_amount)
	user.put_in_hands(S)

/obj/item/stack/req_jelly/examine(mob/user)
	. = ..()
	var/list/value = get_export_value()
	. += "It is worth [value[1]] supply points and [value[2]] dropship points."

/obj/item/stack/req_jelly/attack(mob/living/carbon/patient, mob/living/user)
	if(!isxeno(user))
		to_chat(user, span_warning("You don't know how to use this."))
		return FALSE
	jellyrevive(patient,user)

/obj/item/stack/req_jelly/proc/jellyrevive(mob/living/carbon/human/patient, mob/living/carbon/user)
	if(user.do_actions) //Currently doing something
		balloon_alert(user, "busy!")
		return

	if(patient.stat != DEAD)
		to_chat(user, span_warning("[icon2html(src, viewers(user))] This one is not dead."))
		return FALSE

	if(isxeno(patient))
		to_chat(user, span_warning("[icon2html(src, viewers(user))] This would not help xenomorphs."))
		return FALSE

	var/defib_heal_amt = 40
	var/fail_reason = null

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
		to_chat(user, span_notice("[icon2html(src, viewers(user))] We cannot save them - [fail_reason]"))
		return


	var/mob/dead/observer/ghost = patient.get_ghost()
	// For robots, we want to use the more relaxed bitmask as we are doing this before their IMMEDIATE_DEFIB trait is handled and they might
	// still be unrevivable because of too much damage.
	var/alerting_ghost = isrobot(patient) ? (patient.check_defib() & DEFIB_REVIVABLE_STATES) : (patient.check_defib(issynth(patient) ? 0 : defib_heal_amt == DEFIB_POSSIBLE))
	if(ghost && alerting_ghost)
		notify_ghost(ghost, assemble_alert(
			title = "Revival Imminent!",
			message = "Someone is trying to resuscitate your body! Stay in it if you want to be resurrected!",
			color_override = "purple"
		), ghost_sound = 'sound/effects/gladosmarinerevive.ogg')
		ghost.reenter_corpse()

	user.visible_message(span_notice("[user] starts smearing jelly onto [patient]'s chest."),
	span_notice("You start smearing jelly [patient]'s chest."))
	playsound(get_turf(src),'sound/effects/urban/outdoors/derelict_plateau_2.ogg', 45, 0) // Don't vary this, it should be exactly 7 seconds
	//Haha, I varied it

	if(!do_after(user, 12 SECONDS, NONE, patient, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		to_chat(user, span_warning("You stop smearing jelly onto [patient]'s chest."))
		return

	// do the defibrillation effects now and check revive parameters in a moment
	. = TRUE
	playsound(get_turf(src), 'sound/effects/woosh_swoosh.ogg', 45, 1)
	user.visible_message(span_notice("[user] psychically shocks [patient]."),
	span_notice("You shock [patient] with your mind!"))
	patient.visible_message(span_warning("[patient]'s body convulses a bit."))

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
			fail_reason = "Vital signs are weak. Apply another."

	if(fail_reason)
		to_chat(user, span_notice("[icon2html(src, viewers(user))] We cannot save them - [fail_reason]."))
		playsound(src, 'sound/items/defib_failed.ogg', 45, FALSE)
		return

	ghost = patient.get_ghost(TRUE)
	if(ghost)
		ghost.reenter_corpse()

	if(!patient.client)
		to_chat(user, span_notice("[icon2html(src, viewers(user))] They have no soul, and may not appear alert temporarily or permanently."))

	to_chat(patient, span_notice("<i><font size=4>Thousands of minds will you to return to this mortal plane...</font></i>"))
	to_chat(user, span_notice("[icon2html(src, viewers(user))] They rise from their grave."))
	playsound(get_turf(src), 'sound/effects/woosh_swoosh.ogg', 45, 0)
	use(1)
	patient.updatehealth()
	patient.resuscitate() // time for a smoke
	patient.emote("gasp")
	patient.flash_act()
	patient.apply_effect(20, EFFECT_EYE_BLUR)
	patient.apply_effect(30 SECONDS, EFFECT_UNCONSCIOUS)

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
		for(var/obj/item/alien_embryo/friend in patient)
			START_PROCESSING(SSobj, friend)

	notify_ghosts("<b>[user]</b> has brought <b>[patient.name]</b> back to life!", source = patient, action = NOTIFY_ORBIT)
