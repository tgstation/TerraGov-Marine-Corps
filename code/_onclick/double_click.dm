
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


/mob/proc/ShiftMiddleDblClickOn(atom/A)
	A.ShiftMiddleDblClick(src)

/atom/proc/ShiftMiddleDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_SHIFT_MIDDLE, user)


/mob/proc/CtrlShiftDblClickOn(atom/A)
	A.CtrlShiftDblClick(src)

/atom/proc/CtrlShiftDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_CTRL_SHIFT, user)


/mob/proc/CtrlMiddleDblClickOn(atom/A)
	A.CtrlMiddleDblClick(src)

/atom/proc/CtrlMiddleDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_CTRL_MIDDLE, user)


/mob/proc/MiddleDblClickOn(atom/A)
	A.MiddleDblClick(src)

/atom/proc/MiddleDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_MIDDLE, user)


/mob/proc/ShiftDblClickOn(atom/A)
	A.ShiftDblClick(src)

/atom/proc/ShiftDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_SHIFT, user)


/mob/proc/AltDblClickOn(atom/A)
	A.AltDblClick(src)

/atom/proc/AltDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_ALT, user)


/mob/proc/CtrlDblClickOn(atom/A)
	A.CtrlDblClick(src)

/atom/proc/CtrlDblClick(mob/user)
	SEND_SIGNAL(src, COMSIG_DBLCLICK_CTRL, user)
