/obj/docking_port/stationary/crashmode
	dir = SOUTH
	width = 15
	height = 25
	dwidth = 7
	dheight = 12
	id = "crashmodedock"


/obj/docking_port/mobile/crashmode
	dir = SOUTH
	width = 15
	height = 25
	dwidth = 7
	dheight = 12

	var/list/spawnpoints = list()
	var/list/marine_spawns_by_job = list()


/obj/docking_port/stationary/crashmode/loading
	id = "crashmodeloading"