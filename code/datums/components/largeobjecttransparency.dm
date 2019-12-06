///Makes large icons partially see through if high priority atoms are behind them.
/datum/component/largetransparency
	var/extra_x //How far this should check for horizontally. This goes in both directions,0 means that only directly above gets checked.
	var/y_size //How far up this should look.
	var/list/registered_turfs
	var/amounthidden = 0

/datum/component/largetransparency/Initialize(_y_size = 1, _extra_x = 0)
	extra_x = _extra_x
	y_size = _y_size
	registered_turfs = list()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/OnMove)

/datum/component/largetransparency/Destroy()
	registered_turfs.Cut()
	return ..()

/datum/component/largetransparency/RegisterWithParent()
	var/turf/tu = get_turf(parent)
	var/turf/tu1
	var/turf/tu2
	for(var/i in 1 to y_size)
		tu = get_step(tu, NORTH)
		tu1 = tu
		tu2 = tu
		registered_turfs.Add(tu)
		for(var/r in 1 to extra_x)
			tu1 = get_step(tu1, EAST)
			tu2 = get_step(tu2, WEST)
			registered_turfs.Add(tu1)
			registered_turfs.Add(tu2)
	for(var/t in registered_turfs)
		RegisterSignal(t, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON), .proc/objectEnter)
		RegisterSignal(t, COMSIG_ATOM_EXITED, .proc/objectLeave)
		RegisterSignal(t, COMSIG_TURF_CHANGE, .proc/OnTurfChange)
		for(var/a in t)
			var/atom/at = a
			if(!(at.flags_atom & CRITICAL_ATOM))
				continue
			amounthidden++
	if(amounthidden)
		reduceAlpha()

/datum/component/largetransparency/UnregisterFromParent()
	for(var/t in registered_turfs)
		UnregisterSignal(t, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_TURF_CHANGE, COMSIG_ATOM_INITIALIZED_ON))
	registered_turfs.Cut()

/datum/component/largetransparency/proc/OnMove()
	amounthidden = 0
	restoreAlpha()
	UnregisterFromParent()
	RegisterWithParent()

/datum/component/largetransparency/proc/OnTurfChange()
	addtimer(CALLBACK(src, .proc/OnMove, 1)) //*pain

/datum/component/largetransparency/proc/objectEnter(atom/source, atom/thing)
	if(!(thing.flags_atom & CRITICAL_ATOM))
		return
	if(!amounthidden)
		reduceAlpha()
	amounthidden++

/datum/component/largetransparency/proc/objectLeave(atom/source, atom/thing)
	if(!(thing.flags_atom & CRITICAL_ATOM))
		return
	amounthidden = max(0, amounthidden - 1)
	if(!amounthidden)
		restoreAlpha()

/datum/component/largetransparency/proc/reduceAlpha()
	var/atom/par = parent
	par.alpha = 140
	par.mouse_opacity = 0

/datum/component/largetransparency/proc/restoreAlpha()
	var/atom/par = parent
	par.alpha = 255
	par.mouse_opacity = 2
