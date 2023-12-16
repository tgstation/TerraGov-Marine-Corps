/mob/living/carbon/xenomorph/baneling
	caste_base_type = /mob/living/carbon/xenomorph/baneling
	name = "Baneling"
	desc = "An oozy, squishy alien that can roll in agile speeds, storing various dangerous chemicals in its sac..."
	icon = 'icons/Xeno/castes/baneling.dmi'
	icon_state = "Baneling Walking"
	bubble_icon = "alienleft"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16
	old_x = -16

/mob/living/carbon/xenomorph/baneling/UnarmedAttack(atom/A, has_proximity, modifiers)
	/// We dont wanna be able to slash while balling
	if(m_intent == MOVE_INTENT_RUN)
		return
	return ..()

// ***************************************
// *********** Icon
// ***************************************
/mob/living/carbon/xenomorph/baneling/handle_special_state()
	. = ..()
	if(m_intent == MOVE_INTENT_RUN)
		icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Running"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/baneling/handle_special_wound_states(severity)
	. = ..()
	if(m_intent == MOVE_INTENT_RUN)
		return "baneling_wounded_running_[severity]"

/obj/structure/xeno/baneling_pod
	name = "Baneling pod"
	desc = "A resin structure filled with an oozing slimy pod that swells constantly. It is filled to the brim with small, crawling figures, merging what seems to be other pods inside."
	icon = 'icons/Xeno/castes/baneling.dmi'
	icon_state = "Baneling Pod"
	max_integrity = 100
	density = FALSE
	obj_flags = CAN_BE_HIT | PROJ_IGNORE_DENSITY
	xeno_structure_flags = CRITICAL_STRUCTURE

/obj/structure/xeno/baneling_pod/Initialize(mapload, _hivenumber, xeno, ability_ref)
	. = ..()
	RegisterSignal(xeno, COMSIG_MOB_PRE_DEATH, PROC_REF(handle_baneling_death))
	RegisterSignal(xeno, COMSIG_QDELETING, PROC_REF(qdel_pod))
	RegisterSignal(ability_ref, COMSIG_ACTION_TRIGGER, PROC_REF(qdel_pod))
	addtimer(CALLBACK(src, PROC_REF(increase_charge), xeno), BANELING_CHARGE_GAIN_TIME)

/obj/structure/xeno/baneling_pod/proc/qdel_pod(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// We eject and kill our stored baneling if we have one
/obj/structure/xeno/baneling_pod/obj_destruction()
	if(length(contents) <= 0)
		return ..()
	for(var/mob/living/carbon/xenomorph/xeno in contents)
		if(xeno.stat != DEAD)
			REMOVE_TRAIT(xeno, TRAIT_STASIS, BANELING_STASIS_TRAIT)
			xeno.forceMove(get_turf(loc))
	return ..()

/// Teleports baneling inside of itself, checks for charge and then respawns baneling
/obj/structure/xeno/baneling_pod/proc/handle_baneling_death(datum/source)
	SIGNAL_HANDLER
	if(isnull(source))
		return
	var/mob/living/carbon/xenomorph/xeno_ref = source
	cleanup_baneling(xeno_ref)
	xeno_ref.forceMove(src)
	ADD_TRAIT(xeno_ref, TRAIT_STASIS, BANELING_STASIS_TRAIT)
	if(xeno_ref.stored_charge >= BANELING_CHARGE_MAX)
		addtimer(CALLBACK(src, PROC_REF(increase_charge), xeno_ref), BANELING_CHARGE_GAIN_TIME)
	if(xeno_ref.stored_charge >= 1)
		xeno_ref.stored_charge--
		addtimer(CALLBACK(src, PROC_REF(spawn_baneling), xeno_ref), BANELING_CHARGE_RESPAWN_TIME)
		to_chat(xeno_ref.client, span_xenohighdanger("We have perished and detonated. We will reform in [BANELING_CHARGE_RESPAWN_TIME/10] seconds in our pod..."))
	else
		/// The respawn takes 4 times longer than consuming a charge would
		to_chat(xeno_ref.client, span_xenohighdanger("We have perished and detonated. We will reform in [(BANELING_CHARGE_RESPAWN_TIME*4)/10] seconds in our pod..."))
		addtimer(CALLBACK(src, PROC_REF(spawn_baneling), xeno_ref), BANELING_CHARGE_RESPAWN_TIME*4)
	return COMPONENT_CANCEL_DEATH

/// Handles cleaning up the baneling before teleporting it back to the pod
/obj/structure/xeno/baneling_pod/proc/cleanup_baneling(mob/living/carbon/xenomorph/baneling)
	// Sticky grenades
	for (var/obj/item/explosive/grenade/sticky/nade in baneling)
		nade.clean_refs()
		nade.forceMove(get_turf(baneling))
	// Fire
	baneling.ExtinguishMob()

/// Increase our current charge
/obj/structure/xeno/baneling_pod/proc/increase_charge(datum/source)
	var/mob/living/carbon/xenomorph/xeno_ref = source
	if(xeno_ref.stored_charge >= BANELING_CHARGE_MAX)
		return
	xeno_ref.stored_charge++
	if(xeno_ref.stored_charge != BANELING_CHARGE_MAX)
		addtimer(CALLBACK(src, PROC_REF(increase_charge), xeno_ref), BANELING_CHARGE_GAIN_TIME)

/// Rejuvinates and respawns the baneling
/obj/structure/xeno/baneling_pod/proc/spawn_baneling(datum/source)
	var/mob/living/carbon/xenomorph/xeno_ref = source
	REMOVE_TRAIT(xeno_ref, TRAIT_STASIS, BANELING_STASIS_TRAIT)
	xeno_ref.forceMove(get_turf(loc))
	xeno_ref.revive(FALSE)
	SEND_SOUND(xeno_ref, sound('sound/effects/xeno_evolveready.ogg'))
	INVOKE_ASYNC(xeno_ref, TYPE_PROC_REF(/atom, do_jitter_animation), 1000)
