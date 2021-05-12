// ***************************************
// *********** Nightfall
// ***************************************

/datum/action/xeno_action/activable/nightfall
	name = "Nightfall"
	action_icon_state = "nightfall"
	ability_name = "Nightfall"
	mechanics_text = "Shut down all electrical lights for five seconds."
	cooldown_timer = 1 MINUTES
	plasma_cost = 100
	/// How far nightfall will have an effect
	var/range = 7
	/// How long till the lights go on again
	var/duration = 5 SECONDS

/datum/action/xeno_action/activable/nightfall/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to shut down lights again.</span>")
	return ..()

/datum/action/xeno_action/activable/nightfall/use_ability()
	playsound(owner, 'sound/magic/nightfall.ogg', 50, 1)
	for(var/atom/light AS in GLOB.nightfall_toggleable_lights)
		if((owner.loc.z != light.loc.z) || (get_dist(owner, light) >= range))
			continue
		light.turn_light(null, FALSE, duration, TRUE, TRUE)
	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Gravity Crush
// ***************************************
#define ADD_FILTER (1<<0)
#define REMOVE_FILTER (1<<1)
#define GRAV_CRUSH (1<<2)

#define WINDUP_GRAV 2 SECONDS

/datum/action/xeno_action/activable/gravity_crush
	name = "Gravity Crush"
	action_icon_state = "fortify"
	mechanics_text = "Increases the localized gravity in an area and crushes structures."
	ability_name = "Gravity crush"
	plasma_cost = 100
	cooldown_timer = 30 SECONDS
	keybind_signal = COMSIG_XENOABILITY_GRAVITY_CRUSH
	/// How far can we use gravity crush
	var/king_crush_dist = 5

/datum/action/xeno_action/activable/gravity_crush/on_cooldown_finish()
	to_chat(owner, "<span class='warning'>Our psychic aura restores itself. We are ready to gravity crush again.</span>")
	return ..()

/datum/action/xeno_action/activable/gravity_crush/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!owner.line_of_sight(A, king_crush_dist))
		if(!silent)
			to_chat(owner, "<span class='warning'>We must get closer to crush, our mind cannot reach this far.</span>")
		return FALSE

/datum/action/xeno_action/activable/gravity_crush/use_ability(atom/A)
	var/list/turfs = RANGE_TURFS(1, A)
	playsound(A, 'sound/effects/bomb_fall.ogg', 75, FALSE)
	act_on_turfs(ADD_FILTER, turfs)
	if(!do_after(owner, WINDUP_GRAV, FALSE, owner, BUSY_ICON_DANGER))
		act_on_turfs(REMOVE_FILTER, turfs)
		return fail_activate()
	act_on_turfs(REMOVE_FILTER|GRAV_CRUSH, turfs)
	succeed_activate()
	add_cooldown()
	A.visible_message("<span class='warning'>[A] collapses inward as its gravity suddenly increases!</span>")

///Will do the selected actions on all turfs and items in the turf in the list of turfs
/datum/action/xeno_action/activable/gravity_crush/proc/act_on_turfs(action_flags, list/turfs)
	for(var/turf/targetted AS in turfs)
		if(action_flags & ADD_FILTER)
			targetted.add_filter("crushblur", 1, radial_blur_filter(0.3))
		if(action_flags & REMOVE_FILTER)
			targetted.remove_filter("crushblur")
		for(var/atom/movable/item AS in targetted.contents)
			if(action_flags & ADD_FILTER)
				item.add_filter("crushblur", 1, radial_blur_filter(0.3))
				addtimer(CALLBACK(item, /atom.proc/remove_filter, "crushblur"), WINDUP_GRAV) //Fail safe if the item moves out of the zone.
			if(action_flags & REMOVE_FILTER)
				item.remove_filter("crushblur")
			if(action_flags & GRAV_CRUSH)
				if(isliving(item))
					var/mob/living/mob_crushed = item
					if(mob_crushed.stat == DEAD)//No abuse of that mechanic for some permadeath
						continue
					if(mob_crushed.faction == FACTION_XENO) //Don't harm the xeno. I thought it was better than a istype, could be wrong
						continue
				item.ex_act(EXPLODE_HEAVY)	//crushing without damaging the nearby area

/datum/action/xeno_action/activable/gravity_crush/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/gravity_crush/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE

#undef ADD_FILTER
#undef REMOVE_FILTER
#undef GRAV_CRUSH

// ***************************************
// *********** Psychic Summon
// ***************************************

/datum/action/xeno_action/psychic_summon
	name = "Psychic Summon"
	action_icon_state = "stomp"
	mechanics_text = "Summons all xenos in a hive to the caller's location, uses all plasma to activate."
	ability_name = "Psychic summon"
	plasma_cost = 1100 //uses all an elder kings plasma
	cooldown_timer = 10 MINUTES
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_HIVE_SUMMON

/datum/action/xeno_action/activable/psychic_summon/on_cooldown_finish()
	to_chat(owner, "<span class='warning'>The hives power swells. We may summon our sisters again.</span>")
	return ..()

/datum/action/xeno_action/psychic_summon/can_use_action(silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(length(X.hive.get_all_xenos()) <= 1)
		if(!silent)
			to_chat(owner, "<span class='notice'>We have no hive to call. We are alone on our throne of nothing.</span>")
		return FALSE

/datum/action/xeno_action/psychic_summon/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	log_game("[key_name(owner)] has begun summoning hive in [AREACOORD(owner)]")
	xeno_message("King: \The [owner] has begun a psychic summon in <b>[get_area(owner)]</b>!", "xenoannounce", 3, X.hivenumber)
	var/list/allxenos = X.hive.get_all_xenos()
	for(var/mob/living/carbon/xenomorph/sister AS in allxenos)
		sister.add_filter("summonoutline", 2, list("type" = "outline", "size" = 1, "color" = COLOR_VIOLET))

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
