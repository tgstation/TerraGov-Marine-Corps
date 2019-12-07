///Makes large icons partially see through if high priority atoms are behind them.
/datum/component/largetransparency
	//Can be positive or negative. Determines how far away from parent the first registered turf is.
	var/x_offset
	var/y_offset
	//Has to be positive or 0.
	var/x_size
	var/y_size
	//The alpha values this switches in between.
	var/initial_alpha
	var/target_alpha
	//if this is supposed to prevent clicks if it's transparent.
	var/toggle_click
	var/list/registered_turfs
	var/amounthidden = 0

/datum/component/largetransparency/Initialize(_x_offset = 0, _y_offset = 1, _x_size = 0, _y_size = 1, _initial_alpha = null, _target_alpha = 140, _toggle_click = TRUE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	x_offset = _x_offset
	y_offset = _y_offset
	x_size = _x_size
	y_size = _y_size
	if(isnull(_initial_alpha))
		var/atom/at = parent
		initial_alpha = at.alpha
	else
		initial_alpha = _initial_alpha
	target_alpha = _target_alpha
	toggle_click = _toggle_click
	registered_turfs = list()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/OnMove)

/datum/component/largetransparency/Destroy()
	registered_turfs.Cut()
	return ..()

/datum/component/largetransparency/RegisterWithParent()
	var/turf/tu = get_turf(parent)
	if(!tu)
		return
	var/turf/lowleft_tu = locate(clamp(tu.x + x_offset, 0, world.maxx), clamp(tu.y + y_offset, 0, world.maxy), tu.z)
	var/turf/upright_tu = locate(min(lowleft_tu.x + x_size, world.maxx), min(lowleft_tu.y + y_size, world.maxy), tu.z)
	registered_turfs = block(lowleft_tu, upright_tu) //small problems with z level edges but nothing gamebreaking.
	//register the signals
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
	par.alpha = target_alpha
	if(toggle_click)
		par.mouse_opacity = 0

/datum/component/largetransparency/proc/restoreAlpha()
	var/atom/par = parent
	par.alpha = initial_alpha
	if(toggle_click)
		par.mouse_opacity = 2
