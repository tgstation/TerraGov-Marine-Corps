// ***************************************
// *********** Nightfall
// ***************************************

/datum/action/xeno_action/activable/nightfall
	name = "Nightfall"
	action_icon_state = "nightfall"
	ability_name = "Nightfall"
	mechanics_text = "Shut down all electrical lights nearby for 10 seconds."
	cooldown_timer = 45 SECONDS
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_NIGHTFALL
	/// How far nightfall will have an effect
	var/range = 12
	/// How long till the lights go on again
	var/duration = 10 SECONDS

/datum/action/xeno_action/activable/nightfall/on_cooldown_finish()
	to_chat(owner, span_notice("We gather enough mental strength to shut down lights again."))
	return ..()

/datum/action/xeno_action/activable/nightfall/use_ability()
	playsound(owner, 'sound/magic/nightfall.ogg', 50, 1)
	succeed_activate()
	add_cooldown()
	for(var/atom/light AS in GLOB.nightfall_toggleable_lights)
		if(isnull(light.loc) || (owner.loc.z != light.loc.z) || (get_dist(owner, light) >= range))
			continue
		light.turn_light(null, FALSE, duration, TRUE, TRUE, TRUE)


// ***************************************
// *********** Gravity Crush
// ***************************************
#define WINDUP_GRAV 1 SECONDS

/datum/action/xeno_action/activable/gravity_crush
	name = "Gravity Crush"
	action_icon_state = "fortify"
	mechanics_text = "Increases the localized gravity in an area and crushes everything in it."
	ability_name = "Gravity crush"
	plasma_cost = 200
	cooldown_timer = 30 SECONDS
	keybind_signal = COMSIG_XENOABILITY_GRAVITY_CRUSH
	/// How far can we use gravity crush
	var/king_crush_dist = 5
	/// A list of all things that had a fliter applied
	var/list/filters_applied = list()

/datum/action/xeno_action/activable/gravity_crush/on_cooldown_finish()
	to_chat(owner, span_warning("Our psychic aura restores itself. We are ready to gravity crush again."))
	return ..()

/datum/action/xeno_action/activable/gravity_crush/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!line_of_sight(owner, A, king_crush_dist))
		if(!silent)
			to_chat(owner, span_warning("We must get closer to crush, our mind cannot reach this far."))
		return FALSE

/datum/action/xeno_action/activable/gravity_crush/use_ability(atom/A)
	owner.face_atom(A) //Face towards the target so we don't look silly
	var/list/turfs = RANGE_TURFS(1, A)
	playsound(A, 'sound/effects/bomb_fall.ogg', 50, FALSE)
	apply_filters(turfs)
	if(!do_after(owner, WINDUP_GRAV, FALSE, owner, BUSY_ICON_DANGER))
		remove_all_filters()
		//Consume plasma when cancelling
		succeed_activate()
		return
	do_grav_crush(turfs)
	remove_all_filters()
	succeed_activate()
	add_cooldown()
	A.visible_message(span_warning("[A] collapses inward as its gravity suddenly increases!"))

///Remove all filters of items in filters_applied
/datum/action/xeno_action/activable/gravity_crush/proc/remove_all_filters()
	for(var/atom/thing AS in filters_applied)
		if(QDELETED(thing))
			continue
		thing.remove_filter("crushblur")
	filters_applied.Cut()

///Apply a filter on all items in the list of turfs
/datum/action/xeno_action/activable/gravity_crush/proc/apply_filters(list/turfs)
	for(var/turf/targeted AS in turfs)
		targeted.add_filter("crushblur", 1, radial_blur_filter(0.3))
		filters_applied += targeted
		for(var/atom/movable/item AS in targeted.contents)
			item.add_filter("crushblur", 1, radial_blur_filter(0.3))
			filters_applied += item

///Will crush every item on the turfs (unless they are a friendly xeno or dead)
/datum/action/xeno_action/activable/gravity_crush/proc/do_grav_crush(list/turfs)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/turf/targeted AS in turfs)
		for(var/atom/movable/item AS in targeted.contents)
			if(isliving(item))
				var/mob/living/mob_crushed = item
				if(mob_crushed.stat == DEAD)//No abuse of that mechanic for some permadeath
					continue
				if(isxeno(mob_crushed))
					var/mob/living/carbon/xenomorph/xeno = mob_crushed
					if(xeno.hive == xeno_owner.hive)
						continue
				mob_crushed.ex_act(EXPLODE_LIGHT)
				continue
			item.ex_act(EXPLODE_HEAVY)	//crushing without damaging the nearby area

/datum/action/xeno_action/activable/gravity_crush/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/gravity_crush/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Psychic Summon
// ***************************************

/datum/action/xeno_action/psychic_summon
	name = "Psychic Summon"
	action_icon_state = "stomp"
	mechanics_text = "Summons all xenos in a hive to the caller's location, uses all plasma to activate."
	ability_name = "Psychic summon"
	plasma_cost = 900 //uses all an young kings plasma
	cooldown_timer = 10 MINUTES
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_HIVE_SUMMON

/datum/action/xeno_action/activable/psychic_summon/on_cooldown_finish()
	to_chat(owner, span_warning("The hives power swells. We may summon our sisters again."))
	return ..()

/datum/action/xeno_action/psychic_summon/can_use_action(silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(length(X.hive.get_all_xenos()) <= 1)
		if(!silent)
			to_chat(owner, span_notice("We have no hive to call. We are alone on our throne of nothing."))
		return FALSE

/datum/action/xeno_action/psychic_summon/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	log_game("[key_name(owner)] has begun summoning hive in [AREACOORD(owner)]")
	xeno_message("King: \The [owner] has begun a psychic summon in <b>[get_area(owner)]</b>!", hivenumber = X.hivenumber)
	var/list/allxenos = X.hive.get_all_xenos()
	for(var/mob/living/carbon/xenomorph/sister AS in allxenos)
		sister.add_filter("summonoutline", 2, outline_filter(1, COLOR_VIOLET))

	if(!do_after(X, 15 SECONDS, FALSE, X, BUSY_ICON_HOSTILE))
		for(var/mob/living/carbon/xenomorph/sister AS in allxenos)
			sister.remove_filter("summonoutline")
		return fail_activate()

	for(var/mob/living/carbon/xenomorph/sister AS in allxenos)
		sister.remove_filter("summonoutline")
		sister.forceMove(get_turf(X))
	log_game("[key_name(owner)] has summoned hive ([length(allxenos)] Xenos) in [AREACOORD(owner)]")
	X.emote("roar")

	add_cooldown()
	succeed_activate()
