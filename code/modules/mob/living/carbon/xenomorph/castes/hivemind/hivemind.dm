/mob/living/carbon/xenomorph/hivemind
	caste_base_type = /mob/living/carbon/xenomorph/hivemind
	name = "Hivemind"
	real_name = "Hivemind"
	desc = "A glorious singular entity."

	icon_state = "hivemind_marker"
	icon = 'icons/mob/cameramob.dmi'

	status_flags = GODMODE | INCORPOREAL
	resistance_flags = RESIST_ALL
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
	update_core()
	RegisterSignal(src, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED, .proc/check_weeds_and_move)
	RegisterSignal(src, COMSIG_XENOMORPH_CORE_RETURN, .proc/return_to_core)
	hivemind_core_alert() //Alert the hive and marines

/mob/living/carbon/xenomorph/hivemind/Destroy()
	if(!QDELETED(core))
		QDEL_NULL(core)
	else
		core = null
	return ..()

/obj/flamer_fire/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isxenohivemind(mover))
		return FALSE

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
	show_message("[track] [speaker.hivemind_start()] <span class='message'>hisses, '[message]'</span>[speaker.hivemind_end()]", 2)

/mob/living/carbon/xenomorph/hivemind/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["hivemind_jump"])
		var/mob/living/carbon/xenomorph/xeno = locate(href_list["hivemind_jump"])
		if(!istype(xeno))
			return
		if(!check_weeds(get_turf(xeno)))
			to_chat(src, "<span class='warning'>They are not near any weeds we can jump to.</span>")
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

/mob/living/carbon/xenomorph/hivemind/CtrlClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/CtrlShiftClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/ShiftClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/CtrlClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/AltClickOn(atom/A)
	return FALSE

/mob/living/carbon/xenomorph/hivemind/a_intent_change()
	return //Unable to change intent, forced help intent

/// Hiveminds specifically have no health hud element
/mob/living/carbon/xenomorph/hivemind/med_hud_set_health()
	return

/// Hiveminds specifically have no status hud element
/mob/living/carbon/xenomorph/hivemind/med_hud_set_status()
	return


// =================
// hivemind core
/obj/effect/alien/hivemindcore
	name = "hivemind core"
	desc = "A very weird, pulsating node. This looks almost alive."
	max_integrity = 600
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "weed_hivemind4"
	var/mob/living/carbon/xenomorph/hivemind/parent
	var/core_regeneration = 50 //Regenerates this amount once every 5 seconds.

/obj/effect/alien/hivemindcore/Initialize(mapload)
	. = ..()
	set_light(7, 5, LIGHT_COLOR_PURPLE)

/obj/effect/alien/hivemindcore/examine(mob/user)
	. = ..()
	if(!isxeno(user) && isobserver(user))
		return
	to_chat(user, "<span class='xenowarning'>This [name] belongs to [parent.name].\n It has [obj_integrity] of [max_integrity] health remaining.</br></span>")


///Core regenerates when it is at less than maximum hit points
/obj/effect/alien/hivemindcore/process()
	//Regenerate if we're at less than max integrity
	if(obj_integrity < max_integrity)
		obj_integrity = min(max_integrity, obj_integrity + parent.xeno_caste.core_regeneration) //Core regenerates.
		return

	//If we're at max integrity, stop regenerating and processing.
	STOP_PROCESSING(SSslowprocess, src)
	return PROCESS_KILL


/obj/effect/alien/hivemindcore/Destroy()
	if(isnull(parent))
		return ..()
	parent.playsound_local(parent, get_sfx("alien_help"), 30, TRUE)
	to_chat(parent, "<span class='xenohighdanger'>Your core has been destroyed!</span>")
	xeno_message("<span class='xenoannounce'>A sudden tremor ripples through the hive... \the [parent] has been slain!</span>", 2, parent.hivenumber)
	STOP_PROCESSING(SSslowprocess, src)
	parent.ghostize()
	if(!QDELETED(parent))
		QDEL_NULL(parent)
	else
		parent = null
	return ..()

//hivemind cores

/obj/effect/alien/hivemindcore/attack_alien(mob/living/carbon/xenomorph/X)
	if(isxenoqueen(X))
		var/choice = alert(X, "Are you sure you want to destroy the hivemind?", "Destroy hivemind", "Yes", "Cancel")
		if(choice == "Yes")
			deconstruct(FALSE)
			return

	X.visible_message("<span class='danger'>[X] nudges its head against [src].</span>", \
	"<span class='danger'>You nudge your head against [src].</span>")

/obj/effect/alien/hivemindcore/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(isnull(parent))
		return

	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

	var/health_percent = round((max_integrity / obj_integrity) * 100)
	switch(health_percent)
		if(-INFINITY to 25)
			to_chat(parent, "<span class='xenohighdanger'>Your core is under attack, and is dangerously low on health!</span>")
		if(26 to 75)
			to_chat(parent, "<span class='xenodanger'>Your core is under attack, and is low on health!</span>")
		if(76 to INFINITY)
			to_chat(parent, "<span class='xenodanger'>Your core is under attack!</span>")


/mob/living/carbon/xenomorph/hivemind/upgrade_xeno(newlevel) //where we also upgrade the max health of our core and restore it to maximum health
	. = ..()
	to_chat(src, "<span class='xenonotice'>Our core strengthens, and becomes more resilient!</span>")
	update_core()
	core.obj_integrity = core.max_integrity


///Update the core as a failsafe in the event that upgrade xeno didn't trigger, such as in the case of admin spawning, etc.
/mob/living/carbon/xenomorph/hivemind/proc/update_core()

	core.max_integrity = xeno_caste.core_maximum_hitpoints
	core.core_regeneration = xeno_caste.core_regeneration

	if(!CHECK_BITFIELD(core.datum_flags, DF_ISPROCESSING)) //Process and begin regenerating just in case our new max integrity is greater than our existing integrity upon updating
		START_PROCESSING(SSslowprocess, src)

/mob/living/carbon/xenomorph/hivemind/proc/hivemind_core_alert()

	if(!core) //Sanity check
		return FALSE

	if(is_centcom_level(core))
		return FALSE

	var/list/decoy_area_list = list()
	var/area/real_area = get_area(core) //Set our real area
	var/list/buffer_list = list() //Buffer list for randomization
	var/list/details = list() //The actual final list for the announcement

	for(var/area/core_areas in world) //Build the list of areas on the core's Z.
		if(core_areas.z != core.z) //Must be on the same Z
			continue
		decoy_area_list += core_areas //Add to the list of potential decoys

	decoy_area_list -= real_area //Remove the real area from our decoy list.
	buffer_list += sanitize(real_area.name) //Add the real location to our buffer list

	var/decoys
	var/area/decoy_area
	while(decoys < HIVEMIND_REPOSITION_CORE_DECOY_NUMBER) //Populate our list of areas
		decoy_area = pick(decoy_area_list) //Pick random area for our  decoy.
		decoy_area_list -= decoy_area //Remove it from our list of possible decoy options
		buffer_list += sanitize(decoy_area.name)
		++decoys

	var/buffer_list_pick
	while(length(buffer_list) > 0) //Now populate our randomized order list for the announcement
		buffer_list_pick = pick(buffer_list) //Get random entry in the list
		buffer_list -= buffer_list_pick //Remove that random entry from the buffer
		if(buffer_list.len > 0) //Add that random entry to the final list of areas
			details += ("[buffer_list_pick], ")
		else
			details += ("[buffer_list_pick].")

	var/hivemind_message = "<span class='alert'>[name] has moved its core to [real_area.name] (X: [core.x], Y: [core.y])!</span>" //Alert our fellow benos
	notify_ghosts(hivemind_message, source = src, action = NOTIFY_ORBIT)
	xeno_message(hivemind_message, 3, hivenumber)

	priority_announce("<b>Attention:</b> Anomalous energy readings detected in the following areas: <b>[details.Join(" ")]</b> Further investigation advised.", "Priority Alert", sound = 'sound/AI/commandreport.ogg') //Alert marines with hints

	return TRUE
