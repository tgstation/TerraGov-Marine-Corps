///Makes large icons partially see through if high priority atoms are behind them.
/datum/component/largeopacity
	var/extra_x //How far this should check for horizontally. This goes in both directions,0 means that only directly above gets checked.
	var/y_size //How far up this should look.
	var/list/registered_turfs
	var/amounthidden = 0

/datum/component/largeopacity/Initialize(_y_size = 1, _extra_x = 0)
	extra_x = _extra_x
	y_size = _y_size
	registered_turfs = list()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/OnMove)

/datum/component/largeopacity/Destroy()
	registered_turfs.Cut()
	return ..()

/datum/component/largeopacity/proc/OnMove()
	UnregisterFromParent()
	RegisterWithParent()
	amounthidden = 0 //needs to be one because unrobust code.
	objectLeave()

/datum/component/largeopacity/RegisterWithParent()
	var/turf/tu = get_turf(parent)
	var/turf/tu1
	var/turf/tu2
	for(var/i in 1 to y_size)
		tu = get_step(tu, NORTH)
		registered_turfs.Add(tu)
		for(var/r in 1 to extra_x)
			tu1 = get_step(tu, EAST)
			tu2 = get_step(tu, WEST)
			registered_turfs.Add(tu1)
			registered_turfs.Add(tu2)
	for(var/t in registered_turfs)
		RegisterSignal(t, COMSIG_ATOM_ENTERED, .proc/objectEnter)
		RegisterSignal(t, COMSIG_ATOM_EXITED, .proc/objectLeave)
		RegisterSignal(t, COMSIG_TURF_CHANGE, .proc/turfChange)

/datum/component/largeopacity/UnregisterFromParent()
	for(var/t in registered_turfs)
		UnregisterSignal(t, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	registered_turfs.Cut()

/datum/component/largeopacity/proc/objectEnter()
	/*if(!(source.atom_flags & CRITICAL_OBJECT))
		return*/
	amounthidden++
	var/atom/par = parent
	par.alpha = 140
	par.mouse_opacity = 2

/datum/component/largeopacity/proc/objectLeave()
	amounthidden = max(0, amounthidden - 1)
	if(amounthidden)
		return
	var/atom/par = parent
	par.alpha = 255
	par.mouse_opacity = 0

/datum/component/largeopacity/proc/turfChange(turf/source)
	RegisterSignal(source, COMSIG_ATOM_ENTERED, .proc/objectEnter)
	RegisterSignal(source, COMSIG_ATOM_EXITED, .proc/objectLeave)
	RegisterSignal(source, COMSIG_TURF_CHANGE, .proc/turfChange)
