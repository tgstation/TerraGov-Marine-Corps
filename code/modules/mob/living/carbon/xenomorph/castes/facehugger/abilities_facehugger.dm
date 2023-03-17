// ***************************************
// *********** Hug
// ***************************************
/datum/action/xeno_action/activable/pounce_hugger
	name = "Pounce"
	action_icon_state = "pounce"
	desc = "Leap at your target and knock them down, if you jump close you will hug the target."
	ability_name = "pounce"
	cooldown_timer = 5 SECONDS
	plasma_cost = 25
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_POUNCE,
	)
	use_state_flags = XACT_USE_BUCKLED
	///How far can we leap.
	var/range = 6
	///Range for Hug
	var/hug_range = 1
	///For how long will we stun the victim
	var/victim_paralyze_time = 1 SECONDS
	///For how long will we freeze upon hitting our target
	var/freeze_on_hit_time = 1 SECONDS
	///How long is the windup before leap
	var/windup_time = 1 SECONDS
	///Where do we start the leap from
	var/start_point


/datum/action/xeno_action/activable/pounce_hugger/proc/pounce_complete()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/caster = owner
	caster.icon_state = "[caster.xeno_caste.caste_name] Walking"
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENO_LIVING_THROW_HIT))


/datum/action/xeno_action/activable/pounce_hugger/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/caster = owner
	if(!istype(target, /obj/structure/table) && !istype(target, /obj/structure/rack))
		target.hitby(caster, speed) //This resets throwing.
	pounce_complete()

/datum/action/xeno_action/activable/pounce_hugger/proc/mob_hit(datum/source, mob/living/M, test1)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return
	var/mob/living/carbon/xenomorph/facehugger/caster = owner

	caster.visible_message(span_danger("[caster] leaps on [M]!"),
					span_xenodanger("We leap on [M]!"), null, 5)
	playsound(caster.loc, 'sound/voice/alien_roar_larva3.ogg', 25, TRUE)

	if(ishuman(M) && (M.dir in reverse_nearby_direction(caster.dir)))
		var/mob/living/carbon/human/H = M
		if(!H.check_shields(COMBAT_TOUCH_ATTACK, 30, "melee"))
			caster.Paralyze(10 SECONDS)
			caster.set_throwing(FALSE) //Reset throwing manually.
			return COMPONENT_KEEP_THROWING


	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(get_dist(start_point, H) <= hug_range) //Check whether we hugged the target or just knocked it down
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
		for(var/datum/action/xeno_action/xenohide)
			xenohide.button.cut_overlay(mutable_appearance('icons/mob/actions.dmi', "selected_purple_frame", ACTION_LAYER_ACTION_ICON_STATE, FLOAT_PLANE)) // Убирает рамку вокруг способности Hide, так, как ты больше не прячешься
	if(owner.buckled)
		owner.buckled.unbuckle_mob(owner)

/datum/action/xeno_action/activable/pounce_hugger/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/caster = owner

	prepare_to_pounce()
	if(!do_after(caster, windup_time, FALSE, caster, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .proc/can_use_ability, A, FALSE, XACT_USE_BUSY)))
		return fail_activate()

	caster.icon_state = "[caster.xeno_caste.caste_name] Thrown"

	caster.visible_message(span_xenowarning("\The [caster] leaps at [A]!"), \
	span_xenowarning("We leap at [A]!"))


	RegisterSignal(caster, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(caster, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)
	RegisterSignal(caster, COMSIG_MOVABLE_POST_THROW, .proc/pounce_complete)
	succeed_activate()
	add_cooldown()

	start_point = get_turf(caster)
	caster.throw_at(A, range, 2, caster) //Victim, distance, speed

	return TRUE

/datum/action/xeno_action/activable/pounce_hugger/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/pounce_hugger/ai_should_use(atom/target)
	if(!ishuman(target))
		return FALSE
	if(!line_of_sight(owner, target, hug_range))
		return FALSE
	if(!can_use_action(override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	action_activate()
	LAZYINCREMENT(owner.do_actions, target)
	addtimer(CALLBACK(src, .proc/decrease_do_action, target), windup_time)
	return TRUE

///Decrease the do_actions of the owner
/datum/action/xeno_action/activable/pounce_hugger/proc/decrease_do_action(atom/target)
	LAZYDECREMENT(owner.do_actions, target)
