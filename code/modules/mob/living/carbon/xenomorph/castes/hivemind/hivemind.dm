#define TIME_TO_TRANSFORM 1.6 SECONDS

/mob/living/carbon/xenomorph/hivemind
	caste_base_type = /mob/living/carbon/xenomorph/hivemind
	name = "Hivemind"
	real_name = "Hivemind"
	desc = "A glorious singular entity."

	icon_state = "hivemind_marker"
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	status_flags = GODMODE | INCORPOREAL
	resistance_flags = RESIST_ALL|BANISH_IMMUNE
	flags_pass = PASSFIRE //to prevent hivemind eye to catch fire when crossing lava
	density = FALSE
	throwpass = TRUE

	a_intent = INTENT_HELP

	health = 1000
	maxHealth = 1000
	plasma_stored = 5
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE

	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_MAXIMUM
	sight = SEE_MOBS|SEE_TURFS|SEE_OBJS
	see_in_dark = 8
	move_on_shuttle = TRUE

	hud_type = /datum/hud/hivemind
	hud_possible = list(PLASMA_HUD, HEALTH_HUD_XENO, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD)
	///The core of our hivemind
	var/obj/structure/xeno/hivemindcore/core
	///The minimum health we can have
	var/minimum_health = -300

/mob/living/carbon/xenomorph/hivemind/Initialize(mapload)
	. = ..()
	core = new(loc)
	core.parent = src
	RegisterSignal(src, COMSIG_XENOMORPH_CORE_RETURN, .proc/return_to_core)
	RegisterSignal(src, COMSIG_XENOMORPH_HIVEMIND_CHANGE_FORM, .proc/change_form)
	update_action_buttons()

/mob/living/carbon/xenomorph/hivemind/upgrade_possible()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/upgrade_xeno(newlevel, silent = FALSE)
	newlevel = XENO_UPGRADE_BASETYPE
	return ..()

/mob/living/carbon/xenomorph/hivemind/updatehealth()
	if(on_fire)
		ExtinguishMob()
	health = maxHealth - getFireLoss() - getBruteLoss() //Xenos can only take brute and fire damage.
	if(health <= 0 && !(status_flags & INCORPOREAL))
		setBruteLoss(0)
		setFireLoss(-minimum_health)
		change_form()
		remove_status_effect(/datum/status_effect/spacefreeze)
	health = maxHealth - getFireLoss() - getBruteLoss()
	med_hud_set_health()
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_HIVEMIND_MANIFESTATION))
		return
	update_wounds()

/mob/living/carbon/xenomorph/hivemind/handle_living_health_updates()
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_HIVEMIND_MANIFESTATION))
		return
	var/turf/T = loc
	if(!istype(T))
		return
	if(status_flags & INCORPOREAL || loc_weeds_type)
		if(health < minimum_health + maxHealth)
			setBruteLoss(0)
			setFireLoss(-minimum_health)
		if((health >= maxHealth)) //can't regenerate.
			updatehealth() //Update health-related stats, like health itself (using brute and fireloss), health HUD and status.
			return
		heal_wounds(XENO_RESTING_HEAL)
		updatehealth()
		return
	adjustBruteLoss(20 * XENO_RESTING_HEAL, TRUE)

/mob/living/carbon/xenomorph/hivemind/Destroy()
	if(!QDELETED(core))
		QDEL_NULL(core)
	else
		core = null
	return ..()


/mob/living/carbon/xenomorph/hivemind/on_death()
	if(!QDELETED(core))
		QDEL_NULL(core)
	return ..()

/mob/living/carbon/xenomorph/hivemind/gib()
	return_to_core()

/mob/living/carbon/xenomorph/hivemind/lay_down()
	return

/mob/living/carbon/xenomorph/hivemind/set_resting()
	return

/mob/living/carbon/xenomorph/hivemind/change_form()
	if(status_flags & INCORPOREAL && health != maxHealth)
		to_chat(src, span_xenowarning("You do not have the strength to manifest yet!"))
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_HIVEMIND_MANIFESTATION))
		return
	wound_overlay.icon_state = "none"
	TIMER_COOLDOWN_START(src, COOLDOWN_HIVEMIND_MANIFESTATION, TIME_TO_TRANSFORM)
	invisibility = 0
	flick(status_flags & INCORPOREAL ? "Hivemind_materialisation" : "Hivemind_materialisation_reverse", src)
	addtimer(CALLBACK(src, .proc/do_change_form), TIME_TO_TRANSFORM)

///Finish the form changing of the hivemind and give the needed stats
/mob/living/carbon/xenomorph/hivemind/proc/do_change_form()
	LAZYCLEARLIST(movespeed_modification)
	update_movespeed()
	if(status_flags & INCORPOREAL)
		status_flags = NONE
		resistance_flags = BANISH_IMMUNE
		flags_pass = NONE
		density = TRUE
		throwpass = FALSE
		hive.xenos_by_upgrade[upgrade] -= src
		upgrade = XENO_UPGRADE_MANIFESTATION
		set_datum(FALSE)
		hive.xenos_by_upgrade[upgrade] += src
		update_wounds()
		update_icon()
		update_action_buttons()
		return
	status_flags = initial(status_flags)
	resistance_flags = initial(resistance_flags)
	flags_pass = initial(flags_pass)
	density = initial(flags_pass)
	throwpass = initial(throwpass)
	hive.xenos_by_upgrade[upgrade] -= src
	upgrade = XENO_UPGRADE_BASETYPE
	set_datum(FALSE)
	hive.xenos_by_upgrade[upgrade] += src
	update_wounds()
	update_icon()
	update_action_buttons()

/mob/living/carbon/xenomorph/hivemind/flamer_fire_act(burnlevel)
	return_to_core()
	to_chat(src, span_xenonotice("We were on top of fire, we got moved to our core."))

/mob/living/carbon/xenomorph/hivemind/proc/check_weeds(turf/T, strict_turf_check = FALSE)
	SHOULD_BE_PURE(TRUE)
	if(isnull(T))
		return FALSE
	. = TRUE
	if(locate(/obj/flamer_fire) in T)
		return FALSE
	for(var/obj/alien/weeds/W in range(strict_turf_check ? 0 : 1, T ? T : get_turf(src)))
		if(QDESTROYING(W))
			continue
		return
	return FALSE

/mob/living/carbon/xenomorph/hivemind/handle_weeds_adjacent_removed()
	if(loc_weeds_type || check_weeds(get_turf(src)))
		return
	return_to_core()
	to_chat(src, "<span class='xenonotice'>We had no weeds nearby, we got moved to our core.")
	return

/mob/living/carbon/xenomorph/hivemind/proc/return_to_core()
	if(!(status_flags & INCORPOREAL) && !TIMER_COOLDOWN_CHECK(src, COOLDOWN_HIVEMIND_MANIFESTATION))
		do_change_form()
	forceMove(get_turf(core))

///Start the teleportation process to send the hivemind manifestation to the selected turf
/mob/living/carbon/xenomorph/hivemind/proc/start_teleport(turf/T)
	if(!isopenturf(T))
		to_chat(src, span_notice("You cannot teleport into a wall"))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_HIVEMIND_MANIFESTATION, TIME_TO_TRANSFORM)
	flick("Hivemind_materialisation_fast_reverse", src)
	addtimer(CALLBACK(src, .proc/end_teleport, T), TIME_TO_TRANSFORM / 2)

///Finish the teleportation process to send the hivemind manifestation to the selected turf
/mob/living/carbon/xenomorph/hivemind/proc/end_teleport(turf/T)
	flick("Hivemind_materialisation_fast", src)
	if(!check_weeds(T, TRUE))
		to_chat(src, span_warning("The weeds on our destination were destroyed"))
	else
		forceMove(T)

/mob/living/carbon/xenomorph/hivemind/Move(NewLoc, Dir = 0)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_HIVEMIND_MANIFESTATION))
		return
	if(!(status_flags & INCORPOREAL))
		return ..()
	if(!check_weeds(NewLoc))
		return FALSE

	// FIXME: Port canpass refactor from tg
	// Don't allow them over the timed_late doors
	var/obj/machinery/door/poddoor/timed_late/door = locate() in NewLoc
	if(door && !door.CanPass(src, NewLoc))
		return FALSE

	abstract_move(NewLoc)

/mob/living/carbon/xenomorph/hivemind/receive_hivemind_message(mob/living/carbon/xenomorph/speaker, message)
	var/track =  "<a href='?src=[REF(src)];hivemind_jump=[REF(speaker)]'>(F)</a>"
	show_message("[track] [speaker.hivemind_start()] [span_message("hisses, '[message]'")][speaker.hivemind_end()]", 2)

/mob/living/carbon/xenomorph/hivemind/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_HIVEMIND_MANIFESTATION))
		return
	if(href_list["hivemind_jump"])
		var/mob/living/carbon/xenomorph/xeno = locate(href_list["hivemind_jump"])
		if(!istype(xeno))
			return
		jump(xeno)

/// Jump hivemind's camera to the passed xeno, if they are on/near weeds
/mob/living/carbon/xenomorph/hivemind/proc/jump(mob/living/carbon/xenomorph/xeno)
	if(!check_weeds(get_turf(xeno), TRUE))
		balloon_alert(src, "No nearby weeds")
		return
	if(!(status_flags & INCORPOREAL))
		start_teleport(get_turf(xeno))
		return
	abstract_move(get_turf(xeno))

/// Hivemind just doesn't have any icons to update, disabled for now
/mob/living/carbon/xenomorph/hivemind/update_icon()
	if(status_flags & INCORPOREAL)
		icon_state = "hivemind_marker"
		return
	icon_state = "Hivemind"

/mob/living/carbon/xenomorph/hivemind/update_icons()
	return

/mob/living/carbon/xenomorph/hivemind/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD_XENO]
	if(!holder)
		return

	if(status_flags & INCORPOREAL)
		holder.icon_state = ""

	var/amount = round(health * 100 / maxHealth, 10)
	if(!amount)
		amount = 1 //don't want the 'zero health' icon when we still have 4% of our health
	holder.icon_state = "xenohealth[amount]"

/mob/living/carbon/xenomorph/hivemind/DblClickOn(atom/A, params)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_HIVEMIND_MANIFESTATION))
		return
	var/list/modifiers = params2list(params)
	if(modifiers["right"])
		return
	var/turf/target_turf = get_turf(A)
	if(!check_weeds(target_turf, TRUE))
		return
	if(!(status_flags & INCORPOREAL))
		start_teleport(target_turf)
		return
	abstract_move(target_turf)

/mob/living/carbon/xenomorph/hivemind/CtrlClick(mob/user)
	if(!(status_flags & INCORPOREAL))
		return ..()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/CtrlShiftClickOn(atom/A)
	if(!(status_flags & INCORPOREAL))
		return ..()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/a_intent_change()
	return //Unable to change intent, forced help intent

/// Hiveminds specifically have no status hud element
/mob/living/carbon/xenomorph/hivemind/med_hud_set_status()
	return

/mob/living/carbon/xenomorph/hivemind/update_progression()
	return

/obj/flamer_fire/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isxenohivemind(mover))
		return FALSE


// =================
// hivemind core
/obj/structure/xeno/hivemindcore
	name = "hivemind core"
	desc = "A very weird, pulsating node. This looks almost alive."
	max_integrity = 600
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "weed_hivemind4"
	var/mob/living/carbon/xenomorph/hivemind/parent
	xeno_structure_flags = CRITICAL_STRUCTURE|DEPART_DESTRUCTION_IMMUNE
	///The cooldown of the alert hivemind gets when a hostile is near it's core
	COOLDOWN_DECLARE(hivemind_proxy_alert_cooldown)
	///The hive this core belongs to
	var/datum/hive_status/associated_hive

/obj/structure/xeno/hivemindcore/Initialize(mapload)
	. = ..()
	new /obj/alien/weeds/node(loc)
	set_light(7, 5, LIGHT_COLOR_PURPLE)
	for(var/turfs in RANGE_TURFS(XENO_HIVEMIND_DETECTION_RANGE, src))
		RegisterSignal(turfs, COMSIG_ATOM_ENTERED, .proc/hivemind_proxy_alert)
	associated_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]

/obj/structure/xeno/hivemindcore/Destroy()
	if(isnull(parent))
		return ..()
	parent.playsound_local(parent, get_sfx("alien_help"), 30, TRUE)
	to_chat(parent, span_xenohighdanger("Your core has been destroyed!"))
	xeno_message("A sudden tremor ripples through the hive... \the [parent] has been slain!", "xenoannounce", 5, parent.hivenumber)
	GLOB.key_to_time_of_role_death[parent.key] = world.time
	GLOB.key_to_time_of_death[parent.key] = world.time
	parent.ghostize()
	if(!QDELETED(parent))
		QDEL_NULL(parent)
	else
		parent = null
	return ..()

//hivemind cores

/obj/structure/xeno/hivemindcore/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(isxenoqueen(X))
		var/choice = tgui_alert(X, "Are you sure you want to destroy the hivemind?", "Destroy hivemind", list("Yes", "Cancel"))
		if(choice == "Yes")
			deconstruct(FALSE)
			return

	X.visible_message(span_danger("[X] nudges its head against [src]."), \
	span_danger("You nudge your head against [src]."))

/obj/structure/xeno/hivemindcore/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(isnull(parent))
		return
	var/health_percent = round((max_integrity / obj_integrity) * 100)
	switch(health_percent)
		if(-INFINITY to 25)
			to_chat(parent, span_xenohighdanger("Your core is under attack, and dangerous low on health!"))
		if(26 to 75)
			to_chat(parent, span_xenodanger("Your core is under attack, and low on health!"))
		if(76 to INFINITY)
			to_chat(parent, span_xenodanger("Your core is under attack!"))

/**
 * Proc checks if we should alert the hivemind, and if it can, it does so.
 * datum/source - the atom (in this case it should be a turf) sending the crossed signal
 * atom/movable/hostile - the atom that triggered the crossed signal, in this case we're looking for a mob
 */
/obj/structure/xeno/hivemindcore/proc/hivemind_proxy_alert(datum/source, atom/movable/hostile)
	SIGNAL_HANDLER
	if(!COOLDOWN_CHECK(src, hivemind_proxy_alert_cooldown)) //Proxy alert triggered too recently; abort
		return

	if(!isliving(hostile))
		return

	var/mob/living/living_triggerer = hostile
	if(living_triggerer.stat == DEAD) //We don't care about the dead
		return

	if(isxeno(hostile))
		var/mob/living/carbon/xenomorph/X = hostile
		if(X.hive == associated_hive) //Trigger proxy alert only for hostile xenos
			return

	to_chat(parent, span_xenoannounce("Our [src.name] has detected a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y])."))
	SEND_SOUND(parent, 'sound/voice/alien_help1.ogg')
	COOLDOWN_START(src, hivemind_proxy_alert_cooldown, XENO_HIVEMIND_DETECTION_COOLDOWN) //set the cooldown.
