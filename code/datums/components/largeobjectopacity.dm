///Makes large icons partially see through if high priority atoms are behind them.
/datum/component/largeopacity
	var/extra_x //How far this should check for horizontally. This goes in both directions,0 means that only directly above gets checked.
	var/y_size //How far up this should look.
	var/amounthidden = 0

/datum/component/largeopacity/Initialize(_extra_x = 0, _y_size = 1)
	extra_x = _extra_x
	y_size = _y_size
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, .proc/UnregisterWithParent)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/RegisterWithParent)

/datum/component/largeopacity/RegisterWithParent()
	var/turf/tu = get_turf(parent)
	var/turf/tu1
	var/turf/tu2
	for(var/i in 1 to y_size)
		tu = get_step(tu, NORTH)
		RegisterSignal(tu, COMSIG_ATOM_ENTERED, .proc/disappear)
		for(var/i in 1 to extra_x)
			tu1 = get_step(tu, EAST)
			tu2 = get_step(tu, WEST)
			RegisterSignal(tu, COMSIG_ATOM_ENTERED, .proc/disappear)

/datum/component/largeopacity/UnregisterWithParent(datum/source, )
	var/turf/tu = get_turf(parent)
	var/turf/tu1
	var/turf/tu2
	for(var/i in 1 to y_size)
		tu = get_step(tu, NORTH)
		UnregisterSignal(tu, COMSIG_ATOM_ENTERED)
		for(var/i in 1 to extra_x)
			tu1 = get_step(tu, EAST)
			tu2 = get_step(tu, WEST)
			UnregisterSignal(tu, COMSIG_ATOM_ENTERED)

/datum/component/largeopacity/proc/disappear(atom/movable/source)
	/*if(!(source.atom_flags & CRITICAL_OBJECT))
		return*/
	amounthidden++
	var/atom/par = parent
	par.alpha = 140
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, .proc/objectLeave)

/datum/component/largeopacity/proc/objectLeave(atom/source)
	amounthidden--
	if(amounthidden)
		return
	var/atom/par = parent
	par.alpha = 255
