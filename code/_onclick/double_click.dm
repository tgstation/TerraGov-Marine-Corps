
// Default behavior: ignore double clicks (the second click that makes the doubleclick call already calls for a normal click)
/mob/proc/DblClickOn(atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["middle"])
		ShiftMiddleDblClickOn(A)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftDblClickOn(A)
		return
	if(modifiers["ctrl"] && modifiers["middle"])
		CtrlMiddleDblClickOn(A)
		return
	if(modifiers["middle"])
		MiddleDblClickOn(A)
		return
	if(modifiers["shift"])
		ShiftDblClickOn(A)
		return
	if(modifiers["alt"])
		AltDblClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlDblClickOn(A)
		return
	return


/mob/proc/ShiftMiddleDblClickOn(atom/A)
	A.ShiftMiddleDblClick(src)
	return

/atom/proc/ShiftMiddleDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_SHIFT_MIDDLE, user)
	return


/mob/proc/CtrlShiftDblClickOn(atom/A)
	A.CtrlShiftDblClick(src)
	return

/atom/proc/CtrlShiftDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_CTRL_SHIFT, user)
	return


/mob/proc/CtrlMiddleDblClickOn(atom/A)
	A.CtrlMiddleDblClick(src)
	return

/atom/proc/CtrlMiddleDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_CTRL_MIDDLE, user)
	return


/mob/proc/MiddleDblClickOn(atom/A)
	A.MiddleDblClick(src)
	return

/atom/proc/MiddleDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_MIDDLE, user)
	return


/mob/proc/ShiftDblClickOn(atom/A)
	A.ShiftDblClick(src)
	return

/atom/proc/ShiftDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_SHIFT, user)
	return


/mob/proc/AltDblClickOn(atom/A)
	A.AltDblClick(src)
	return

/atom/proc/AltDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_ALT, user)
	return


/mob/proc/CtrlDblClickOn(atom/A)
	A.CtrlDblClick(src)
	return

/atom/proc/CtrlDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_CTRL, user)
	return
