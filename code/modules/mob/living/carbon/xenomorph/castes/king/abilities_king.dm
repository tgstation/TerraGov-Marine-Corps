// ***************************************
// *********** Nightfall
// ***************************************

/datum/action/xeno_action/activable/nightfall
	name = "Nightfall"
	action_icon_state = "nightfall"
	ability_name = "Nightfall"
	mechanics_text = "Shut down all electrical lights for 5 seconds"
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
	playsound(target,'sound/magic/nightfall.ogg', 50, 1)

	for(var/atom/light AS in GLOB.lights)
		light.turn_light(null, FALSE, duration, TRUE, TRUE, get_turf(owner), range)

	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Gravity Crush
// ***************************************

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
	var/list/turfs = RANGE_TURFS(2, A)
	for(var/turf/targetted AS in turfs)
		targetted.add_filter("crushblur", 1, list("type"="radial_blur", "size" = 0.3))
	if(!do_after(owner, 2 SECONDS, FALSE, owner, BUSY_ICON_DANGER))
		for(var/turf/targetted as() in turfs)
			targetted.remove_filter("crushblur")
		return fail_activate()
	succeed_activate()
	add_cooldown()
	A.visible_message("<span class='warning'> [A] collapses inward as it's gravity suddenly increases!</span>")
	playsound(A, 'sound/effects/bomb_fall.ogg', 75, FALSE)
	for(var/turf/targetted as() in turfs)
		for(var/atom/movable/item as() in targetted.contents)
			if(ismob(item))
				return
			item.ex_act(EXPLODE_HEAVY)	//crushing without damaging the nearby area
		addtimer(CALLBACK(targetted, /atom.proc/remove_filter, "crushblur"), 1 SECONDS)

/datum/action/xeno_action/activable/gravity_crush/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/gravity_crush/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE

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
	for(var/mob/living/carbon/xenomorph/sister as() in allxenos)
		sister.add_filter("summonoutline", 2, list("type" = "outline", "size" = 1, "color" = COLOR_VIOLET))

	if(!do_after(X, 15 SECONDS, FALSE, X, BUSY_ICON_HOSTILE))
		for(var/mob/living/carbon/xenomorph/sister as() in allxenos)
			sister.remove_filter("summonoutline")
		return fail_activate()

	for(var/mob/living/carbon/xenomorph/sister as() in allxenos)
		sister.remove_filter("summonoutline")
		sister.forceMove(get_turf(X))
	log_game("[key_name(owner)] has summoned hive ([length(allxenos)] Xenos) in [AREACOORD(owner)]")
	X.emote("roar")

	add_cooldown()
	succeed_activate()
