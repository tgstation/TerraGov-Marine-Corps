
/atom/movable/screen/text/nuke_timer
	maptext_x = 12
	maptext_y = -40
	// screen_loc = "LEFT,TOP-3"
	var/nuke_name
	var/datum/weakref/nuke_ref
	var/datum/weakref/owner_mob_ref

/atom/movable/screen/text/nuke_timer/Initialize(mapload, mob, nukename, reference_nuke)
	. = ..()
	if(!reference_nuke)
		stack_trace("Missing nuke ref for screen nuke timer!")
		stop_nuke_timer()

	nuke_ref = reference_nuke
	var/obj/machinery/nuclearbomb/nuke = nuke_ref.resolve()
	if(!nuke)
		CRASH("Invalid nuke ref for screen nuke timer!")
	if(!nukename)
		nuke_name = "Unknown Nuke"
	else
		nuke_name = nukename
	owner_mob_ref = WEAKREF(mob)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_STOP, PROC_REF(stop_nuke_timer))
	RegisterSignal(mob, COMSIG_MOB_GHOST, PROC_REF(stop_nuke_timer))
	RegisterSignal(mob, COMSIG_MOB_LOGOUT, PROC_REF(stop_nuke_timer))
	START_PROCESSING(SSfastprocess, src)

/atom/movable/screen/text/nuke_timer/process()
	var/obj/machinery/nuclearbomb/nuke = nuke_ref?.resolve()
	if(!nuke)
		CRASH("Invalid nuke ref for screen nuke timer!")
	var/nuke_time_left = timeleft(nuke.timer)
	var/time_formatted = time2text(nuke_time_left, "mm:ss")
	// Calculate the milliseconds left over from the timeleft() function.
	var/seconds = round(nuke_time_left MILLISECONDS)
	var/leftover_milliseconds = round(nuke_time_left - seconds * 10)
	maptext = "<span class='maptext' style=font-size:16pt;text-align:center valign='top'>Nuke ACTIVE: [nuke_name] [time_formatted]:[leftover_milliseconds]  </span>"

/atom/movable/screen/text/nuke_timer/proc/stop_nuke_timer()
	qdel(src)

/atom/movable/screen/text/nuke_timer/Destroy()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_NUKE_STOP)
	STOP_PROCESSING(SSfastprocess, src)
	if(!owner_mob_ref)
		return
	var/mob/owner = owner_mob_ref.resolve()
	if(!owner)
		return
	UnregisterSignal(owner, COMSIG_MOB_GHOST)
	UnregisterSignal(owner, COMSIG_MOB_LOGOUT)
	owner?.client.screen -= src
