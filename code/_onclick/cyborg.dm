/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/click(var/atom/A, var/mods)
	if(lockcharge || is_mob_incapacitated(TRUE))
		return 1

	if(mods["middle"])
		cycle_modules()
		return 1

	if (mods["ctrl"] && mods["shift"])
		if (!A.BorgCtrlShiftClick(src))
			return 1

	else if (mods["ctrl"])
		if (!A.BorgCtrlClick(src))
			return 1

	else if(mods["shift"])
		if (!A.BorgShiftClick(src))
			return 1

	if(mods["alt"]) // alt and alt-gr (rightalt)
		if (!A.BorgAltClick(src))
			return 1


	if(aiCamera.in_camera_mode)
		aiCamera.camera_mode_off()
		if(is_component_functioning("camera"))
			aiCamera.captureimage(A, usr)
		else
			to_chat(src, "<span class='userdanger'>Your camera isn't functional.</span>")
		return 1

	face_atom(A)
	if (world.time <= next_move) return
	var/obj/item/W = get_active_hand()

	// Cyborgs have no range-checking unless there is item use
	if(!W)
		A.add_hiddenprint(src)
		A.attack_robot(src)
		return 1

	// buckled cannot prevent machine interlinking but stops arm movement
	if( buckled )
		return 1

	if(W == A)
		next_move = world.time + 8

		W.attack_self(src)
		return 1

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
	if(A == loc || (A in loc) || (A in contents))
		// No adjacency checks
		next_move = world.time + 8

		var/resolved = A.attackby(W,src)
		if(!resolved && A && W)
			W.afterattack(A, src, 1, mods)
		return 1

	if(!isturf(loc))
		return 1

	// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc && isturf(A.loc.loc))
	if(isturf(A) || isturf(A.loc))
		if(A.Adjacent(src)) // see adjacent.dm
			next_move = world.time + 10

			var/resolved = A.attackby(W, src)
			if(!resolved && A && W)
				W.afterattack(A, src, 1, mods)
			return 1
		else
			next_move = world.time + 10
			W.afterattack(A, src, 0, mods)
			return 1
	return 0



//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs

/atom/proc/BorgCtrlShiftClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	return 1

/obj/machinery/door/airlock/BorgCtrlShiftClick()
	AICtrlShiftClick()

/atom/proc/BorgShiftClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	return 1

/obj/machinery/door/airlock/BorgShiftClick()  // Opens and closes doors! Forwards to AI code.
	AIShiftClick()


/atom/proc/BorgCtrlClick(var/mob/living/silicon/robot/user) //forward to human click if not overriden
	return 1

/obj/machinery/door/airlock/BorgCtrlClick() // Bolts doors. Forwards to AI code.
	AICtrlClick()

/obj/machinery/power/apc/BorgCtrlClick() // turns off/on APCs. Forwards to AI code.
	AICtrlClick()

/obj/machinery/turretid/BorgCtrlClick() //turret control on/off. Forwards to AI code.
	AICtrlClick()

/atom/proc/BorgAltClick(var/mob/living/silicon/robot/user)
	return 1

/obj/machinery/door/airlock/BorgAltClick() // Eletrifies doors. Forwards to AI code.
	AIAltClick()

/obj/machinery/turretid/BorgAltClick() //turret lethal on/off. Forwards to AI code.
	AIAltClick()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A)
	A.attack_robot(src)
/mob/living/silicon/robot/RangedAttack(atom/A)
	A.attack_robot(src)

/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
	return
