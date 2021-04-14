/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(control_disabled || incapacitated())
		return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(atom/A, location, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(!can_interact_with(A))
		return

	if(multicam_on)
		var/turf/T = get_turf(A)
		if(T)
			for(var/obj/screen/movable/pic_in_pic/ai/P in T.vis_locs)
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
	if(!can_see(A))
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

/* Airlocks */
/obj/machinery/door/airlock/AICtrlClick(mob/living/silicon/ai/user) // Bolts doors
	if(z != user.z)
		return

	if(locked)
		bolt_raise(usr)
	else if(hasPower())
		bolt_drop(usr)

/obj/machinery/door/airlock/AIShiftClick(mob/living/silicon/ai/user)  // Opens and closes doors!
	if(z != user.z)
		return

	user_toggle_open(usr)


/* APC */
/obj/machinery/power/apc/AICtrlClick(mob/living/silicon/ai/user) // turns off/on APCs.
	if(z != user.z)
		return
	toggle_breaker(usr)

/* Firealarm */
/obj/machinery/firealarm/AICtrlClick(mob/living/silicon/ai/user) // turn on the fire alarm
	if(z != user.z)
		return
	alarm()

/obj/machinery/firealarm/AICtrlShiftClick(mob/living/silicon/ai/user) // turn off the fire alarm
	if(z != user.z)
		return
	reset()


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
