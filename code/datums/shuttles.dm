/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/shuttles/"
	///Name of the file to load (without the .dmm extension)
	var/file_name
	var/suffix
	var/port_id
	var/shuttle_id = "SHOULD NEVER EXIST"

	var/description
	var/prerequisites
	var/admin_notes

	var/credit_cost = INFINITY
	var/can_be_bought = FALSE

	var/list/movement_force // If set, overrides default movement_force on shuttle

	var/port_x_offset
	var/port_y_offset

/datum/map_template/shuttle/proc/prerequisites_met()
	return TRUE

/datum/map_template/shuttle/New()
	if(shuttle_id == "SHOULD NEVER EXIST")
		stack_trace("invalid shuttle datum")
	//shuttle_id = "[port_id]_[suffix]"
	if(file_name)
		mappath = "[prefix][file_name].dmm"
	else	//TO-DO: change all the other shuttles to use file_name so this else statement is no longer necessary
		mappath = "[prefix][shuttle_id][suffix].dmm"
	return ..()

/datum/map_template/shuttle/preload_size(path, cache)
	. = ..(path, TRUE) // Done this way because we still want to know if someone actualy wanted to cache the map
	if(!cached_map)
		return

	discover_port_offset()

	if(!cache)
		cached_map = null

/datum/map_template/shuttle/proc/discover_port_offset()
	var/key
	var/list/models = cached_map.grid_models
	for(key in models)
		if(findtext(models[key], "[/obj/docking_port/mobile]")) // Yay compile time checks
			break // This works by assuming there will ever only be one mobile dock in a template at most

	for(var/i in cached_map.gridSets)
		var/datum/grid_set/gset = i
		var/ycrd = gset.ycrd
		for(var/line in gset.gridLines)
			var/xcrd = gset.xcrd
			for(var/j in 1 to length(line) step cached_map.key_len)
				if(key == copytext(line, j, j + cached_map.key_len))
					port_x_offset = xcrd
					port_y_offset = ycrd
					return
				++xcrd
			--ycrd

/datum/map_template/shuttle/load(turf/T, centered, register=TRUE)
	. = ..()
	if(!.)
		return
	var/list/turfs = block(	locate(.[MAP_MINX], .[MAP_MINY], .[MAP_MINZ]),
							locate(.[MAP_MAXX], .[MAP_MAXY], .[MAP_MAXZ]))
	for(var/i in 1 to length(turfs))
		var/turf/place = turfs[i]
		if(istype(place, /turf/open/space)) // This assumes all shuttles are loaded in a single spot then moved to their real destination.
			continue
		if(length(place.baseturfs) < 2) // Some snowflake shuttle shit
			continue
		place.baseturfs.Insert(3, /turf/baseturf_skipover/shuttle)

		for(var/obj/docking_port/mobile/port in place)
			port.calculate_docking_port_information(src)
			if(register)
				port.register()
			if(isnull(port_x_offset))
				continue
			switch(port.dir) // Yeah this looks a little ugly but mappers had to do this in their head before
				if(NORTH)
					port.width = width
					port.height = height
					port.dwidth = port_x_offset - 1
					port.dheight = port_y_offset - 1
				if(EAST)
					port.width = height
					port.height = width
					port.dwidth = height - port_y_offset
					port.dheight = port_x_offset - 1
				if(SOUTH)
					port.width = width
					port.height = height
					port.dwidth = width - port_x_offset
					port.dheight = height - port_y_offset
				if(WEST)
					port.width = height
					port.height = width
					port.dwidth = port_y_offset - 1
					port.dheight = width - port_x_offset

//Whatever special stuff you want
/datum/map_template/shuttle/proc/post_load(obj/docking_port/mobile/M)
	if(movement_force)
		M.movement_force = movement_force.Copy()

// Shuttles start here:
/datum/map_template/shuttle/dropship_one
	name = "Alamo"
	file_name = "alamo"
	shuttle_id = SHUTTLE_DROPSHIP

/datum/map_template/shuttle/dropship_two
	name = "Normandy"
	file_name = "normandy"
	shuttle_id = SHUTTLE_NORMANDY

/datum/map_template/shuttle/cas
	name = "Condor Jet"
	file_name = "casplane"
	shuttle_id = SHUTTLE_CAS

/*----------------- Flyable shuttle types -----------------*/
//The 2 variables in this type could go on /shuttle, but the reason this type exists is to use subtypesof() in the shuttle picker
/datum/map_template/shuttle/flyable
	file_name = "dropship"	//Loads the standard dropship because the checker thing requires every map_template to have a valid file path
	shuttle_id = "ONLY PUTTING THIS BECAUSE IT RUNTIMES IF THIS IS NULL. AWFUL."
	///Name used for the shuttle picker console
	var/display_name = "Standard Shuttle"
	///If TRUE, this type of shuttle is only available to players if the gamemode or an admin permits it
	var/restricted = FALSE

/datum/map_template/shuttle/flyable/dropship
	name = "Alamo Dropship"
	description = "A large and reliable vessel. The standard model of the Alamo has a large cargo and personnel capacity.\
				It features 2 sentry deployment ports on the front and 2 manned side turrets."
	display_name = "Standard Dropship"
	file_name = "dropship"
	shuttle_id = SHUTTLE_DROPSHIP

/datum/map_template/shuttle/flyable/dropship/command
	name = "Alamo Mobile Command Center"
	description = "This configuration provides a posting for a commanding officer, trading some space for the installation of a small CIC. .\
				The command center features a map table, an overwatch console, and an ion cannon for orbital bombardment.\
				Armaments consist of 1 sentry deployment port and 2 manned turrets."
	display_name = "Tactical Command Vessel"
	file_name = "dropship_command"
	suffix = "_command"
	shuttle_id = null	//Variants null for now until all variants are ready; interferes with default dropship spawning

/datum/map_template/shuttle/flyable/dropship/medical
	name = "St. Alamo Marine's Hospital"
	description = "Tightly packed with medical supplies and equipment, with less general space as a result.\
				Features an advanced medbay capable of treating the worst wounds. Lacks any armaments and only has space for one vehicle."
	display_name = "Mobile Field Hospital"
	file_name = "dropship_medical"
	suffix = "_medical"
	shuttle_id = null

/datum/map_template/shuttle/flyable/dropship/logistics
	name = "Alamo Support Dropship"
	description = "The largest shuttle available with a focus on deployment of supplies, troops, and vehicles.\
				While it lacks any armaments and has reduced capacity, it has 2 airlift elevators for vehicles and personnel to be deployed or extracted without landing.\
				A supply beacon comes pre-installed and has a supply pod launcher for manual supply drops."
	display_name = "Logistical Support Specialist"
	file_name = "dropship_logistics"
	suffix = "_logistics"
	shuttle_id = null

/datum/map_template/shuttle/flyable/mini
	name = "Tadpole Shuttle"
	description = "The plain and simple old Tadpole-03 model."
	display_name = "Tadpole Standard Model"
	file_name = "minidropship_standard"
	suffix = "_standard" // remember to also add an image to icons/ui_icons/dropshippicker and /datum/asset/simple/dropshippicker
	shuttle_id = SHUTTLE_MINI

/datum/map_template/shuttle/flyable/mini/old
	description = "Tadpole-01, the old model barely in service for TGMC, replaced by the newer Tadpole-03. Much like an APC, is pretty armored. Very lacking in firing angle."
	display_name = "Tadpole Carrier Model"
	file_name = "minidropship_big"
	suffix = "_big"

/datum/map_template/shuttle/flyable/mini/factorio
	description = "A Tadpole model for hauling, engineering and general maintenance. Patented by Nakamura Engineering, and is a rather reliable way to transport goods."
	display_name = "Tadpole NK-Haul Model"
	file_name = "minidropship_factorio"
	suffix = "_factorio"

/datum/map_template/shuttle/flyable/mini/umbilical
	description = "A high-point orbital shuttle with a tactical umbilical airlock for insertion of ground troops."
	display_name = "Tadpole Umbilical Model"
	file_name = "minidropship_umbilical"
	suffix = "_umbilical"

/datum/map_template/shuttle/flyable/mini/food
	description = "A Tadpole modified to provide foods and services. Who the hell let this on the military catalogue? Bounty on that guy."
	display_name = "Tadpole Food Truck Model"
	file_name = "minidropship_food"
	suffix = "_food"

/datum/map_template/shuttle/flyable/mini/outrider
	description = "An asymmetric tadpole designed with vehicle transport in mind. Built with a wide umbilical to allow fluid heavy-vehicle movement."
	display_name = "Tadpole Outrider Model"
	file_name = "minidropship_outrider"
	suffix = "_outrider"
/*---------------------------------------------------------------*/

/datum/map_template/shuttle/escape_pod
	shuttle_id = SHUTTLE_ESCAPE_POD
	name = "Escape Pod"

/datum/map_template/shuttle/small_ert
	shuttle_id = SHUTTLE_DISTRESS
	name = "Distress"

/datum/map_template/shuttle/small_ert/pmc
	shuttle_id = SHUTTLE_DISTRESS_PMC
	name = "Distress PMC"

/datum/map_template/shuttle/small_ert/upp
	shuttle_id = SHUTTLE_DISTRESS_UPP
	name = "Distress UPP"

/datum/map_template/shuttle/small_ert/ufo
	shuttle_id = SHUTTLE_DISTRESS_UFO
	name = "Small UFO"

/datum/map_template/shuttle/big_ert
	shuttle_id = SHUTTLE_BIG_ERT
	name = "Big ERT"

/datum/map_template/shuttle/supply
	shuttle_id = SHUTTLE_SUPPLY
	name = SHUTTLE_SUPPLY

/datum/map_template/shuttle/supply/vehicle
	shuttle_id = SHUTTLE_VEHICLE_SUPPLY
	name = SHUTTLE_VEHICLE_SUPPLY

/datum/map_template/shuttle/tgs_canterbury
	shuttle_id = SHUTTLE_CANTERBURY
	name = "Canterbury"

/datum/map_template/shuttle/tgs_bigbury
	shuttle_id = SHUTTLE_BIGBURY
	name = "Bigbury"

/datum/map_template/shuttle/escape_shuttle
	shuttle_id = SHUTTLE_ESCAPE_SHUTTLE
	name = "Escape Shuttle"
