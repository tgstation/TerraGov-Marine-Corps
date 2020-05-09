// -- Docks
/obj/docking_port/stationary/crashmode
	id = "canterbury_dock"
	name = "Canterbury Crash Site"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12


/obj/docking_port/stationary/crashmode/loading
	id = "canterbury_loadingdock"
	name = "Low Orbit"

/obj/docking_port/stationary/crashmode/loading/on_crash()
	return // No explosions please and thank you.

// -- Shuttles
/obj/docking_port/mobile/crashmode
	name = "TGS Canterbury"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12

	callTime = 10 MINUTES
	ignitionTime = 5 SECONDS
	prearrivalTime = 12 SECONDS

	var/list/spawnpoints = list()
	var/list/latejoins = list()
	var/list/spawns_by_job = list()

/obj/docking_port/mobile/crashmode/register()
	. = ..()
	SSshuttle.canterbury = src
