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
	 //I mean I could start from a sane point (like the northeastern most) but this is good enough.
	var/turf/tu = get_turf(parent)
	var/turf/tu_east
	var/turf/tu_west
	for(var/i in 1 to y_size)
		tu = get_step(tu, NORTH)
		tu_east = tu
		tu_west = tu
		registered_turfs.Add(tu)
		for(var/r in 1 to extra_x)
			tu_east = get_step(tu_east, EAST)
			tu_west = get_step(tu_west, WEST)
			registered_turfs.Add(tu_east)
			registered_turfs.Add(tu_west)
	for(var/regist_tu in registered_turfs)
		if(!regist_tu)
			continue
		RegisterSignal(regist_tu, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON), .proc/objectEnter)
		RegisterSignal(regist_tu, COMSIG_ATOM_EXITED, .proc/objectLeave)
		RegisterSignal(regist_tu, COMSIG_TURF_CHANGE, .proc/OnTurfChange)
		for(var/thing in regist_tu)
			var/atom/at = thing
			if(!(at.flags_atom & CRITICAL_ATOM))
				continue
			amounthidden++
	if(amounthidden)
		reduceAlpha()

/datum/component/largetransparency/UnregisterFromParent()
	for(var/regist_tu in registered_turfs)
		UnregisterSignal(regist_tu, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_TURF_CHANGE, COMSIG_ATOM_INITIALIZED_ON))
	registered_turfs.Cut()

/datum/component/largetransparency/proc/OnMove()
	amounthidden = 0
	restoreAlpha()
	UnregisterFromParent()
	RegisterWithParent()

/datum/component/largetransparency/proc/OnTurfChange()
	INVOKE_NEXT_TICK(src, .proc/OnMove) //*pain

/datum/component/largetransparency/proc/objectEnter(datum/source, atom/thing)
	if(!(thing.flags_atom & CRITICAL_ATOM))
		return
	if(!amounthidden)
		reduceAlpha()
	amounthidden++

/datum/component/largetransparency/proc/objectLeave(datum/source, atom/thing)
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
