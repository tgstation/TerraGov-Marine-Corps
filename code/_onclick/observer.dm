/mob/dead/observer/DblClickOn(atom/A, params)
	if(check_click_intercept(params, A))
		return

	if(can_reenter_corpse && mind?.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return									// seems legit.

	// Things you might plausibly want to follow
	if(ismovableatom(A))
		ManualFollow(A)

	// Otherwise jump
	else if(A.loc)
		abstract_move(get_turf(A))
		update_parallax_contents()


/mob/dead/observer/ClickOn(atom/A, location, params)
	if(check_click_intercept(params, A))
		return

	if(SEND_SIGNAL(src, COMSIG_OBSERVER_CLICKON, A, params) & COMSIG_MOB_CLICK_CANCELED)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["middle"])
		ShiftMiddleClickOn(A)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"] && MiddleClickOn(A))
		return
	if(modifiers["shift"] && ShiftClickOn(A))
		return
	if(modifiers["alt"])
		return //Disabled for now. Need to sanitize the AltClickOn procs.
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return

	A.attack_ghost(src)


/mob/dead/observer/MouseWheelOn(atom/A, delta_x, delta_y, params)
	var/list/modifier = params2list(params)
	if(modifier["shift"])
		var/view_change = 0
		if(delta_y > 0)
			view_change = -1
		else
			view_change = 1
		add_view_range(view_change)


// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/dead/observer/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_GHOST, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE
	if(user.inquisitive_ghost)
		user.examinate(src)
		return TRUE
	return FALSE
