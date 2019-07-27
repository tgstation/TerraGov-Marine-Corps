/obj/docking_port/stationary/crashmode
	id = "canterbury_dock"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12

/obj/docking_port/stationary/crashmode/loading
	id = "canterbury_loadingdock"
	
/obj/docking_port/mobile/crashmode
	name = "tgs canterbury"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12

	var/list/spawnpoints = list()
	var/list/latejoins = list()
	var/list/marine_spawns_by_job = list()

/obj/docking_port/mobile/crashmode/register()
	. = ..()
	SSshuttle.canterbury = src
