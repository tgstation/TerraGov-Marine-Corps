/obj/docking_port/stationary/crashmode
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12
	id = "crashmodedock"

/obj/docking_port/stationary/crashmode/loading
	id = "crashmodeloading"

	
/obj/docking_port/mobile/crashmode
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12

	var/list/spawnpoints = list()
	var/list/marine_spawns_by_job = list()
	var/list/airlocks = list()

/obj/docking_port/mobile/crashmode/register()
	. = ..()
	SSshuttle.canterbury = src

/obj/docking_port/mobile/crashmode/proc/lockdown_airlocks()
	for(var/i in airlocks)
		var/obj/machinery/door/poddoor/almayer/D = i
		D.close()
		D.locked = TRUE

/obj/docking_port/mobile/crashmode/proc/unlock_airlocks()
	for(var/i in airlocks)
		var/obj/machinery/door/poddoor/almayer/D = i
		D.locked = FALSE

// Obj injection

/obj/machinery/door/poddoor/almayer/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	if(!istype(port, /obj/docking_port/mobile/crashmode))
		return
	var/obj/docking_port/mobile/crashmode/D = port
	D.airlocks += src