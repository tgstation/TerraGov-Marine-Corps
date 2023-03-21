/// This component powers things in a range via signal intercepts instead of via area
/datum/component/mobile_power
	/// machines this will power
	var/list/machines_to_power
	/// area size
	var/size = 10
	/// active state
	var/active = FALSE
	/// power used this tick
	var/power_used = 0

/datum/component/mobile_power/Initialize(active, size)
	. = ..()
	if(!istype(parent, /obj/machinery/power/port_gen))
		return COMPONENT_INCOMPATIBLE

	if(!isnull(active))
		src.active = active
	if(!isnull(size))
		src.size = size

	find_machines_in_range()
	RegisterSignal(SSdcs, COMSIG_GLOB_MACHINERY_ANCHORED_CHANGE, PROC_REF(glob_anchor_changed))

	if(active)
		activate()

	RegisterSignal(parent, COMSIG_OBJ_SETANCHORED, PROC_REF(parent_anchored))
	RegisterSignal(parent, COMSIG_PORTGEN_POWER_TOGGLE, PROC_REF(power_toggle))
	RegisterSignal(parent, COMSIG_PORTGEN_PROCESS, PROC_REF(parent_process))

/datum/component/mobile_power/Destroy(force, silent)
	UnregisterSignal(SSdcs, COMSIG_GLOB_MACHINERY_ANCHORED_CHANGE)
	UnregisterSignal(parent, list(
		COMSIG_OBJ_SETANCHORED,
		COMSIG_PORTGEN_POWER_TOGGLE,
		COMSIG_PORTGEN_PROCESS,
	))
	clear_machines()
	return ..()

/// Remove all machines in our machine list
/datum/component/mobile_power/proc/clear_machines()
	if(LAZYLEN(machines_to_power))
		for(var/obj/machinery/M AS in machines_to_power)
			UnregisterSignal(M, list(
				COMSIG_OBJ_SETANCHORED,
				COMSIG_MACHINERY_POWERED,
				COMSIG_MACHINERY_USE_POWER
			))
			LAZYREMOVE(machines_to_power, M)

/// Handle parent being anchored/unanchored
/datum/component/mobile_power/proc/parent_anchored(obj/source, anchorstate)
	SIGNAL_HANDLER
	if(!anchorstate)
		clear_machines()
		return
	find_machines_in_range()

/// Parent ticks over, reset power usage
/datum/component/mobile_power/proc/parent_process()
	SIGNAL_HANDLER
	power_used = 0

/// Parent active state toggled
/datum/component/mobile_power/proc/power_toggle(datum/source, active)
	SIGNAL_HANDLER
	if(active)
		activate()
	else
		deactivate()

/// Find new machines anchored inside our area
/datum/component/mobile_power/proc/glob_anchor_changed(obj/machinery/machine, anchorstate)
	SIGNAL_HANDLER
	if(!anchorstate)
		return
	var/obj/machinery/power/port_gen/PG = parent
	if(PG.z != machine.z)
		return
	if(get_dist(PG, machine) > size)
		return
	LAZYADD(machines_to_power, machine)
	RegisterSignal(machine, COMSIG_OBJ_SETANCHORED, PROC_REF(obj_anchor_changed))
	if(active)
		RegisterSignal(machine, COMSIG_MACHINERY_POWERED, PROC_REF(powered))
		RegisterSignal(machine, COMSIG_MACHINERY_USE_POWER, PROC_REF(use_power))

/// Deal with one of our machines being unanchored
/datum/component/mobile_power/proc/obj_anchor_changed(obj/source, anchorstate)
	SIGNAL_HANDLER
	if(anchorstate)
		return
	UnregisterSignal(source, list(
		COMSIG_OBJ_SETANCHORED,
		COMSIG_MACHINERY_POWERED,
		COMSIG_MACHINERY_USE_POWER
	))
	LAZYREMOVE(machines_to_power, source)

/// Populate the machine list, do this as little as possible, range() is expensive
/datum/component/mobile_power/proc/find_machines_in_range()
	clear_machines()
	// see urange(), it is cheaper for large ranges
	for(var/obj/machinery/M in (size > 7 ? urange(size, parent) : range(size, parent)))
		if(!M.anchored)
			continue
		LAZYADD(machines_to_power, M)
		RegisterSignal(M, COMSIG_OBJ_SETANCHORED, PROC_REF(obj_anchor_changed))

/// Enable power
/datum/component/mobile_power/proc/activate()
	for(var/obj/machinery/M AS in machines_to_power)
		RegisterSignal(M, COMSIG_MACHINERY_POWERED, PROC_REF(powered))
		RegisterSignal(M, COMSIG_MACHINERY_USE_POWER, PROC_REF(use_power))

/// Disable power
/datum/component/mobile_power/proc/deactivate()
	for(var/obj/machinery/M AS in machines_to_power)
		UnregisterSignal(M, list(
			COMSIG_MACHINERY_POWERED,
			COMSIG_MACHINERY_USE_POWER
		))

/// Handle powered() machine checks
/datum/component/mobile_power/proc/powered()
	SIGNAL_HANDLER
	var/obj/machinery/power/port_gen/PG = parent
	if((power_used) > (PG.power_gen * PG.power_output))
		return // not enough power
	return COMPONENT_POWERED

/// Handle use_power() machine checks
/datum/component/mobile_power/proc/use_power(obj/machinery/machine, amount, chan, list/power_sources)
	SIGNAL_HANDLER
	if(length(power_sources))
		return // something else already provided power
	var/obj/machinery/power/port_gen/PG = parent
	if((power_used + amount) > (PG.power_gen * PG.power_output))
		return // not enough power
	power_sources += src
	power_used += amount
	return COMPONENT_POWER_USED
