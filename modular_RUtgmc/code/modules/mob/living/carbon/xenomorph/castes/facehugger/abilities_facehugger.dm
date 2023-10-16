#define HUG_RANGE 1

// ***************************************
// *********** Hug
// ***************************************

/datum/action/xeno_action/activable/pounce_hugger
	name = "Pounce"
	action_icon_state = "pounce"
	desc = "Leap at your target and knock them down, if you jump close you will hug the target."
	ability_name = "pounce"
	plasma_cost = 25
	cooldown_timer = 5 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_POUNCE,
	)
	use_state_flags = XACT_USE_BUCKLED
	///How far can we leap.
	var/range = 6
	///For how long will we stun the victim
	var/victim_paralyze_time = 1 SECONDS
	///For how long will we freeze upon hitting our target
	var/freeze_on_hit_time = 1 SECONDS
	///How long is the windup before leap
	var/windup_time = 1 SECONDS
	///Where do we start the leap from
	var/start_turf

// TODO: merge this ability into runner pounce (can't do it right now - the runner's pounce has too many unnecessary sounds/messages)
/datum/action/xeno_action/activable/pounce_hugger/proc/pounce_complete()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/caster = owner
	caster.pass_flags = initial(caster.pass_flags)
	caster.icon_state = "[caster.xeno_caste.caste_name] Walking"
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENO_LIVING_THROW_HIT))

/datum/action/xeno_action/activable/pounce_hugger/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	target.hitby(owner, speed)
	pounce_complete()

/datum/action/xeno_action/activable/pounce_hugger/proc/mob_hit(datum/source, mob/living/M)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return

	var/mob/living/carbon/xenomorph/facehugger/caster = owner

	caster.visible_message(span_danger("[caster] leaps on [M]!"),
				span_xenodanger("We leap on [M]!"), null, 5)
	playsound(caster.loc, 'sound/voice/alien_roar_larva3.ogg', 25, TRUE) //TODO: I NEED ACTUAL HUGGERS SOUND DAMMED

	if(ishuman(M) && (M.dir in reverse_nearby_direction(caster.dir)))
		var/mob/living/carbon/human/H = M
		if(!H.check_shields(COMBAT_TOUCH_ATTACK, 30, "melee"))
			caster.Paralyze(6 SECONDS)
			caster.set_throwing(FALSE) //Reset throwing manually.
			return COMPONENT_KEEP_THROWING

	caster.forceMove(get_turf(M))
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(get_dist(start_turf, H) <= HUG_RANGE) //Check whether we hugged the target or just knocked it down
			caster.try_attach(H)
		else
			if(victim_paralyze_time)
				H.Paralyze(victim_paralyze_time)

			if(freeze_on_hit_time)
				caster.Immobilize(freeze_on_hit_time)

	pounce_complete()

/datum/action/xeno_action/activable/pounce_hugger/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/xeno_action/activable/pounce_hugger/proc/prepare_to_pounce()
	if(owner.layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		owner.layer = MOB_LAYER
		var/datum/action/xeno_action/xenohide/hide_action = owner.actions_by_path[/datum/action/xeno_action/xenohide]
		hide_action?.button?.cut_overlay(mutable_appearance('modular_RUtgmc/icons/Xeno/actions.dmi', "selected_purple_frame", ACTION_LAYER_ACTION_ICON_STATE, FLOAT_PLANE)) // Removes Hide action icon border
	if(owner.buckled)
		owner.buckled.unbuckle_mob(owner)

/datum/action/xeno_action/activable/pounce_hugger/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/caster = owner
	caster.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/pounce_hugger/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/caster = owner

	prepare_to_pounce()
	if(!do_after(caster, windup_time, FALSE, caster, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), A, FALSE, XACT_USE_BUSY)))
		return fail_activate()

	caster.icon_state = "[caster.xeno_caste.caste_name] Thrown"

	caster.visible_message(span_xenowarning("\The [caster] leaps at [A]!"), \
	span_xenowarning("We leap at [A]!"))

	RegisterSignal(caster, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(caster, COMSIG_XENO_LIVING_THROW_HIT, PROC_REF(mob_hit))
	RegisterSignal(caster, COMSIG_MOVABLE_POST_THROW, PROC_REF(pounce_complete))

	succeed_activate()
	add_cooldown()
	caster.usedPounce = TRUE // this is needed for throwing code
	caster.pass_flags |= PASS_LOW_STRUCTURE|PASS_FIRE
	caster.pass_flags ^= PASS_MOB

	start_turf = get_turf(caster)
	if(ishuman(A) && get_turf(A) == start_turf)
		mob_hit(caster, A)
	caster.throw_at(A, range, 2, caster)

	return TRUE

	//AI stuff
/datum/action/xeno_action/activable/pounce_hugger/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/pounce_hugger/ai_should_use(atom/target)
	if(!ishuman(target))
		return FALSE
	if(!line_of_sight(owner, target, HUG_RANGE))
		return FALSE
	if(!can_use_action(override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	action_activate()
	LAZYINCREMENT(owner.do_actions, target)
	addtimer(CALLBACK(src, PROC_REF(decrease_do_action), target), windup_time)
	return TRUE

///Decrease the do_actions of the owner
/datum/action/xeno_action/activable/pounce_hugger/proc/decrease_do_action(atom/target)
	LAZYDECREMENT(owner.do_actions, target)

#undef HUG_RANGE
