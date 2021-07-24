/mob/living/carbon/xenomorph/hivemind
	caste_base_type = /mob/living/carbon/xenomorph/hivemind
	name = "Hivemind"
	real_name = "Hivemind"
	desc = "A glorious singular entity."

	icon_state = "hivemind_marker"
	icon = 'icons/mob/cameramob.dmi'

	status_flags = GODMODE | INCORPOREAL
	resistance_flags = RESIST_ALL
	flags_pass = PASSFIRE //to prevent hivemind eye to catch fire when crossing lava
	density = FALSE
	throwpass = TRUE

	a_intent = INTENT_HELP

	health = 1000
	maxHealth = 1000
	plasma_stored = 5
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_ZERO

	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_MAXIMUM
	sight = SEE_MOBS|SEE_TURFS|SEE_OBJS
	see_in_dark = 8
	move_on_shuttle = TRUE

	hud_type = /datum/hud/hivemind
	hud_possible = list(PLASMA_HUD, PHEROMONE_HUD, QUEEN_OVERWATCH_HUD)

	var/obj/effect/alien/hivemindcore/core

/mob/living/carbon/xenomorph/hivemind/Initialize(mapload)
	. = ..()
	core = new(loc)
	core.parent = src
	RegisterSignal(src, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED, .proc/check_weeds_and_move)
	RegisterSignal(src, COMSIG_XENOMORPH_CORE_RETURN, .proc/return_to_core)

/mob/living/carbon/xenomorph/hivemind/Destroy()
	if(!QDELETED(core))
		QDEL_NULL(core)
	else
		core = null
	return ..()

/mob/living/carbon/xenomorph/hivemind/flamer_fire_act()
	forceMove(get_turf(core))
	to_chat(src, "<span class='xenonotice'>We were on top of fire, we got moved to our core.")

/mob/living/carbon/xenomorph/hivemind/proc/check_weeds(turf/T)
	SHOULD_BE_PURE(TRUE)
	. = TRUE
	if(locate(/obj/flamer_fire) in T)
		return FALSE
	for(var/obj/effect/alien/weeds/W in range(1, T ? T : get_turf(src)))
		if(QDESTROYING(W))
			continue
		return
	return FALSE

/mob/living/carbon/xenomorph/hivemind/proc/check_weeds_and_move(turf/T)
	if(check_weeds(T))
		return TRUE
	return_to_core()
	to_chat(src, "<span class='xenonotice'>We had no weeds nearby, we got moved to our core.")
	return FALSE

/mob/living/carbon/xenomorph/hivemind/proc/return_to_core()
	forceMove(get_turf(core))

/mob/living/carbon/xenomorph/hivemind/Move(NewLoc, Dir = 0)
	if(!check_weeds(NewLoc))
		return FALSE

	// FIXME: Port canpass refactor from tg
	// Don't allow them over the timed_late doors
	var/obj/machinery/door/poddoor/timed_late/door = locate() in NewLoc
	if(door && !door.CanPass(src, NewLoc))
		return FALSE

	forceMove(NewLoc)

/mob/living/carbon/xenomorph/hivemind/receive_hivemind_message(mob/living/carbon/xenomorph/speaker, message)
	var/track =  "<a href='?src=[REF(src)];hivemind_jump=[REF(speaker)]'>(F)</a>"
	show_message("[track] [speaker.hivemind_start()] [span_message("hisses, '[message]'")][speaker.hivemind_end()]", 2)

/mob/living/carbon/xenomorph/hivemind/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["hivemind_jump"])
		var/mob/living/carbon/xenomorph/xeno = locate(href_list["hivemind_jump"])
		if(!istype(xeno))
			return
		if(!check_weeds(get_turf(xeno)))
			to_chat(src, span_warning("They are not near any weeds we can jump to."))
			return
		forceMove(get_turf(xeno))

/// Hivemind just doesn't have any icons to update, disabled for now
/mob/living/carbon/xenomorph/hivemind/update_icons()
	return FALSE

/mob/living/carbon/xenomorph/hivemind/set_lying_angle()
	CRASH("Something caused a hivemind to change its lying angle. Add checks to prevent that.")

/mob/living/carbon/xenomorph/hivemind/DblClickOn(atom/A, params)
	if(!istype(A, /obj/effect/alien/weeds))
		return

	forceMove(get_turf(A))

/mob/living/carbon/xenomorph/hivemind/CtrlClick(mob/user)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/CtrlShiftClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/CtrlClickOn(atom/A)
	if(istype(A, /obj/structure/mineral_door/resin))
		var/obj/structure/mineral_door/resin/door = A
		door.TryToSwitchState(src)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/AltClickOn(atom/A)
	if(istype(A, /obj/structure/mineral_door/resin))
		var/obj/structure/mineral_door/resin/door = A
		door.TryToSwitchState(src)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/a_intent_change()
	return //Unable to change intent, forced help intent

/// Hiveminds specifically have no health hud element
/mob/living/carbon/xenomorph/hivemind/med_hud_set_health()
	return

/// Hiveminds specifically have no status hud element
/mob/living/carbon/xenomorph/hivemind/med_hud_set_status()
	return

/obj/flamer_fire/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isxenohivemind(mover))
		return FALSE


// =================
// hivemind core
/obj/effect/alien/hivemindcore
	name = "hivemind core"
	desc = "A very weird, pulsating node. This looks almost alive."
	max_integrity = 600
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "weed_hivemind4"
	var/mob/living/carbon/xenomorph/hivemind/parent

/obj/effect/alien/hivemindcore/Initialize(mapload)
	. = ..()
	set_light(7, 5, LIGHT_COLOR_PURPLE)

/obj/effect/alien/hivemindcore/Destroy()
	if(isnull(parent))
		return ..()
	parent.playsound_local(parent, get_sfx("alien_help"), 30, TRUE)
	to_chat(parent, span_xenohighdanger("Your core has been destroyed!"))
	xeno_message("A sudden tremor ripples through the hive... \the [parent] has been slain!", "xenoannounce", 5, parent.hivenumber)
	parent.timeofdeath = world.time
	parent.ghostize()
	if(!QDELETED(parent))
		QDEL_NULL(parent)
	else
		parent = null
	return ..()

//hivemind cores

/obj/effect/alien/hivemindcore/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(isxenoqueen(X))
		var/choice = tgui_alert(X, "Are you sure you want to destroy the hivemind?", "Destroy hivemind", list("Yes", "Cancel"))
		if(choice == "Yes")
			deconstruct(FALSE)
			return

	X.visible_message(span_danger("[X] nudges its head against [src]."), \
	span_danger("You nudge your head against [src]."))

/obj/effect/alien/hivemindcore/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
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
