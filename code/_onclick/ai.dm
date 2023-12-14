#define AI_MAX_RAILGUN_SHOTS_FIRED_UPPER_RANGE 20
#define AI_MAX_RAILGUN_SHOTS_FIRED_LOWER_RANGE 10
#define AI_RAILGUN_HUMAN_EXCLUSION_RANGE 6
#define AI_RAILGUN_AUTOTARGET_RANGE 6
#define AI_RAILGUN_FIRING_TIME_DELAY 0.9 SECONDS
#define AI_RAILGUN_FIRING_WINDUP_DELAY 8 SECONDS
#define AI_RAILGUN_HUMAN_EXCLUSION_NEGATIVE -4
#define AI_RAILGUN_HUMAN_EXCLUSION_POSITIVE 4



/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/

/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(control_disabled || incapacitated() || controlling)
		return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(atom/A, location, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, params) & COMSIG_MOB_CLICK_CANCELED)
		return

	if(!controlling && !can_interact_with(A))
		return

	if(multicam_on)
		var/turf/T = get_turf(A)
		if(T)
			for(var/atom/movable/screen/movable/pic_in_pic/ai/P in T.vis_locs)
				if(P.ai == src)
					P.Click(params)
					break

	if(check_click_intercept(params, A))
		return

	if(control_disabled || incapacitated())
		return

	var/turf/pixel_turf = get_turf_pixel(A)
	if(isnull(pixel_turf))
		return
	if(!controlling && !can_see(A))
		if(isturf(A)) //On unmodified clients clicking the static overlay clicks the turf underneath
			return //So there's no point messaging admins
		message_admins("[ADMIN_LOOKUPFLW(src)] might be running a modified client! (failed can_see on AI click of [A] (Turf Loc: [ADMIN_VERBOSEJMP(pixel_turf)]))")
		var/message = "[key_name(src)] might be running a modified client! (failed can_see on AI click of [A] (Turf Loc: [AREACOORD(pixel_turf)]))"
		log_admin(message)
		send2tgs_adminless_only("NOCHEAT", message)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return

	if(world.time <= next_move)
		return

	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_ai(src)

/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user)
	return


/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/
/mob/living/silicon/ai/CtrlShiftClickOn(atom/A)
	A.AICtrlShiftClick(src)

/mob/living/silicon/ai/ShiftClickOn(atom/A)
	A.AIShiftClick(src)
	return TRUE

/mob/living/silicon/ai/CtrlClickOn(atom/A)
	A.AICtrlClick(src)

/mob/living/silicon/ai/MiddleClickOn(atom/A)
	A.AIMiddleClick(src)

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/


/* Atom Procs */
/atom/proc/AICtrlClick()
	return

/atom/proc/AIShiftClick()
	return

/atom/proc/AICtrlShiftClick()
	return

/atom/proc/AIMiddleClick()
	return

/* Airlocks */
/obj/machinery/door/airlock/AICtrlClick(mob/living/silicon/ai/user) // Bolts doors
	if(aiControlDisabled)
		to_chat(user, span_notice("[src] AI remote control has been disabled."))
		return
	if(emergency)
		to_chat(user, span_notice("You can't lock a door that's on emergency access."))
		return
	if(locked)
		bolt_raise(user)
	else if(hasPower())
		bolt_drop(user)

/obj/machinery/door/airlock/AIShiftClick(mob/living/silicon/ai/user)  // Opens and closes doors!
	if(aiControlDisabled)
		to_chat(user, span_notice("[src] AI remote control has been disabled."))
		return
	user_toggle_open(user)

/obj/machinery/door/airlock/AICtrlShiftClick(mob/living/silicon/ai/user)
	if(aiControlDisabled)
		to_chat(user, span_notice("[src] AI remote control has been disabled."))
		return
	if(locked || !hasPower())
		to_chat(user, span_notice("Emergency access mechanism inaccessible."))
		return
	if(emergency)
		to_chat(user, span_notice("[src] emergency access has been disabled."))
		emergency_off(user)
	else
		to_chat(user, span_notice("[src] emergency access has been enabled."))
		emergency_on(user)

/obj/machinery/door/airlock/dropship_hatch/AICtrlClick(mob/living/silicon/ai/user)
	return

/obj/machinery/door/airlock/hatch/cockpit/AICtrlClick(mob/living/silicon/ai/user)
	return



/* APC */
/obj/machinery/power/apc/AICtrlClick(mob/living/silicon/ai/user) // turns off/on APCs.
	toggle_breaker(user)

/* Firealarm */
/obj/machinery/firealarm/AICtrlClick(mob/living/silicon/ai/user) // toggle the fire alarm
	var/area/A = get_area(src)
	if(A.flags_alarm_state & ALARM_WARNING_FIRE)
		reset()
	else
		alarm()

/* Weeds */
/obj/alien/weeds/node/AICtrlShiftClick(mob/living/silicon/ai/user)
	var/turf/firedturf = get_turf(src)
	firedturf.AICtrlShiftClick(user)

/obj/alien/weeds/AICtrlShiftClick(mob/living/silicon/ai/user)
	var/turf/firedturf = get_turf(src)
	firedturf.AICtrlShiftClick(user)

/* Xenos */
/mob/living/carbon/xenomorph/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_NORMAL)

/mob/living/carbon/xenomorph/shrike/AIMiddleClick(mob/living/silicon/ai/user) //xenomorph leadership castes get some reduction in ping cooldown
	user.ai_ping(src, COOLDOWN_AI_PING_LOW)

/mob/living/carbon/xenomorph/queen/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_LOW)

/mob/living/carbon/xenomorph/king/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_LOW)

/* Xeno structures */
/obj/structure/xeno/silo/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_EXTRA_LOW)

/obj/structure/xeno/xeno_turret/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_EXTRA_LOW)

/obj/structure/xeno/evotower/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_EXTRA_LOW)

/obj/structure/xeno/psychictower/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_EXTRA_LOW)

/obj/structure/xeno/pherotower/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_EXTRA_LOW)

/obj/structure/xeno/spawner/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_EXTRA_LOW)

/obj/structure/xeno/spawner/plant/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_LOW)

/obj/structure/xeno/tunnel/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_LOW)

/obj/structure/xeno/trap/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_NORMAL)

/* acid */

/obj/effect/xenomorph/acid/AIMiddleClick(mob/living/silicon/ai/user)
	user.ai_ping(src, COOLDOWN_AI_PING_NORMAL)


/* Turf */

//
// Override TurfAdjacent for AltClicking
//
/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(T))

/obj/structure/ladder/attack_ai(mob/living/silicon/ai/AI)
	var/turf/TU = get_turf(up)
	var/turf/TD = get_turf(down)
	if(up && down)
		switch(tgui_alert(AI, "Go up or down the ladder?", "Ladder", list("Up", "Down", "Cancel")))
			if("Up")
				TU.move_camera_by_click()
			if("Down")
				TD.move_camera_by_click()
			if("Cancel")
				return
	else if(up)
		TU.move_camera_by_click()

	else if(down)
		TD.move_camera_by_click()

/turf/AIShiftClick(mob/living/silicon/ai/user)
	if(!user.linked_artillery)
		to_chat(user, span_notice("No linked mortar found."))
		return

	var/area/A = get_area(src)
	if(istype(A) && A.ceiling >= CEILING_UNDERGROUND)
		to_chat(user, span_warning("You cannot hit the target. It is probably underground."))
		return
	to_chat(user, span_notice("Sending targeting information to [user.linked_artillery]. COORDINATES: X:[x] Y:[y]"))
	user.linked_artillery.recieve_target(src,user)



/turf/AICtrlClick(mob/living/silicon/ai/user)
	var/message = "Rangefinding of selected turf at [loc]. COORDINATES: X:[x] Y:[y]"
	var/area/A = get_area(src)
	if(istype(A) && A.ceiling >= CEILING_UNDERGROUND)
		message += " It is underground."
	to_chat(user, span_notice(message))

/turf/AICtrlShiftClick(mob/living/silicon/ai/user)
	var/obj/effect/overlay/temp/laser_target/laser
	var/area/A = get_area(loc)
	if(HAS_TRAIT(user, TRAIT_IS_FIRING_RAILGUN))
		to_chat(user, span_warning("The rail guns are already targeting a location, wait for them to finish."))
		return
	if(!is_ground_level(user.eyeobj.z) || isdropshiparea(A)) //can't fire the railgun off the ground level, or at the DS
		to_chat(user, span_warning("Incompatible target location."))
		return
	if(SSmonitor.gamestate == SHUTTERS_CLOSED)
		to_chat(user, span_warning("The operation hasn't started yet."))
		return
	if(A.ceiling > CEILING_OBSTRUCTED)
		to_chat(user, span_warning("DEPTH WARNING: Target too deep for ordnance."))
		return
	if((GLOB.marine_main_ship?.rail_gun?.last_firing_ai + COOLDOWN_RAILGUN_FIRE) > world.time)
		to_chat(user, "[icon2html(src, user)] [span_warning("The rail gun hasn't cooled down yet!")]")
		return
	else if(!A)
		to_chat(user, "[icon2html(src, user)] [span_warning("No target detected!")]")
		return
	to_chat(user, span_notice("Firing orbital railguns at [src], COORDINATES: X:[x] Y:[y]"))
	ADD_TRAIT(user, TRAIT_IS_FIRING_RAILGUN, TRAIT_IS_FIRING_RAILGUN)
	///how many times we've fired the railgun this cycle
	var/timesfired = 0
	///max times we can fire within a single volley
	var/maxtimesfired = rand(AI_MAX_RAILGUN_SHOTS_FIRED_LOWER_RANGE,AI_MAX_RAILGUN_SHOTS_FIRED_UPPER_RANGE)
	var/obj/effect/overlay/temp/laser_target/RGL = new (src, 0, user.name)
	laser = RGL
	playsound(src, 'sound/effects/angry_beep.ogg', 55)
	if(!do_after(user, AI_RAILGUN_FIRING_WINDUP_DELAY, NONE, user, BUSY_ICON_GENERIC)) //initial windup time until firing begins
		QDEL_NULL(laser)
		REMOVE_TRAIT(user, TRAIT_IS_FIRING_RAILGUN, TRAIT_IS_FIRING_RAILGUN)
		return
	message_admins("[ADMIN_TPMONTY(user)] fired the railgun at [ADMIN_VERBOSEJMP(laser.loc)].")
	playsound(src, 'sound/effects/confirm_beep.ogg', 55)
	while(laser)
		if(timesfired >= maxtimesfired) //fire until we hit defined limit
			QDEL_NULL(laser)
			REMOVE_TRAIT(user, TRAIT_IS_FIRING_RAILGUN, TRAIT_IS_FIRING_RAILGUN)
			return
		if(!do_after(user, AI_RAILGUN_FIRING_TIME_DELAY, NONE, laser, BUSY_ICON_GENERIC)) //delay between shots
			QDEL_NULL(laser)
			REMOVE_TRAIT(user, TRAIT_IS_FIRING_RAILGUN, TRAIT_IS_FIRING_RAILGUN)
			break
		///used to check if we have valid targets
		var/list/mob/living/carbon/xenomorph/possible_xenos = list()
		for(var/mob/living/carbon/xenomorph/target_xeno AS in cheap_get_xenos_near(laser, AI_RAILGUN_AUTOTARGET_RANGE))
			if(target_xeno.stat != DEAD)
				possible_xenos += target_xeno
		//used to calculate nearby human mobs for avoidance purposes
		var/mob/living/carbon/human/possible_humans = list()
		//used for calculating zombies
		var/mob/living/carbon/human/possible_zombies = list()
		for(var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(laser, AI_RAILGUN_HUMAN_EXCLUSION_RANGE))
			if(iszombie(nearby_human)) //count zombies separately
				possible_zombies += nearby_human
			else if(nearby_human.stat != DEAD)
				possible_humans += nearby_human
		if(length(possible_zombies))
			var/mob/living/carbon/human/nuked_zombie = pick(possible_zombies)
			GLOB.marine_main_ship?.rail_gun?.fire_rail_gun(nuked_zombie, user, TRUE, TRUE)
			++timesfired
		else if(length(possible_xenos))
			var/mob/living/carbon/xenomorph/nuked_xeno = pick(possible_xenos)
			GLOB.marine_main_ship?.rail_gun?.fire_rail_gun(nuked_xeno, user, TRUE, TRUE)
			++timesfired
		else if(length(possible_humans))
			var/turf/targetturf = get_turf(laser)
			while(possible_humans)
				possible_humans = list()
				for(var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(targetturf, AI_RAILGUN_HUMAN_EXCLUSION_RANGE))
					if(nearby_human.stat != DEAD)
						possible_humans += nearby_human
				if(length(possible_humans))
					targetturf = locate(targetturf.x + rand(AI_RAILGUN_HUMAN_EXCLUSION_NEGATIVE, AI_RAILGUN_HUMAN_EXCLUSION_POSITIVE), targetturf.y + rand(AI_RAILGUN_HUMAN_EXCLUSION_NEGATIVE, AI_RAILGUN_HUMAN_EXCLUSION_POSITIVE), targetturf.z)
				else
					GLOB.marine_main_ship?.rail_gun?.fire_rail_gun(targetturf, user, TRUE, TRUE)
					++timesfired
					break
		else
			GLOB.marine_main_ship?.rail_gun?.fire_rail_gun(laser, user, TRUE, TRUE)
			++timesfired

#undef AI_MAX_RAILGUN_SHOTS_FIRED_UPPER_RANGE
#undef AI_MAX_RAILGUN_SHOTS_FIRED_LOWER_RANGE
#undef AI_RAILGUN_FIRING_TIME_DELAY
#undef AI_RAILGUN_FIRING_WINDUP_DELAY
#undef AI_RAILGUN_HUMAN_EXCLUSION_RANGE
#undef AI_RAILGUN_AUTOTARGET_RANGE
#undef AI_RAILGUN_HUMAN_EXCLUSION_NEGATIVE
#undef AI_RAILGUN_HUMAN_EXCLUSION_POSITIVE
