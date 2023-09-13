/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/shuttles/"
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
	shuttle_id = SHUTTLE_ALAMO
	name = "Alamo"

/datum/map_template/shuttle/dropship_two
	shuttle_id = SHUTTLE_NORMANDY
	name = "Normandy"

/datum/map_template/shuttle/cas
	shuttle_id = SHUTTLE_CAS
	name = "Condor Jet"

/datum/map_template/shuttle/minidropship
	shuttle_id = SHUTTLE_TADPOLE
	name = "Tadpole Drop Shuttle"
	suffix = "_standard" // remember to also add an image to icons/ui_icons/dropshippicker and /datum/asset/simple/dropshippicker
	description = "The plain and simple old Tadpole-03 model."
	///shuttle switch console name
	var/display_name = "Tadpole Standard Model"
	var/admin_enable = TRUE

/datum/map_template/shuttle/minidropship/old
	suffix = "_big"
	description = "Tadpole-01, the old model barely in service for TGMC, replaced by the newer Tadpole-03. Much like an APC, is pretty armored. Very lacking in firing angle."
	display_name = "Tadpole Carrier Model"

/datum/map_template/shuttle/minidropship/food
	suffix = "_food"
	description = "A Tadpole modified to provide foods and services. Who the hell let this on the military catalogue? Bounty on that guy."
	display_name = "Tadpole Food-truck Model"
	admin_enable = FALSE

/datum/map_template/shuttle/minidropship/factorio
	suffix = "_factorio"
	description = "A Tadpole model for hauling, engineering and general maintenance. Patented by Nakamura Engineering, and is a rather reliable way to transport goods."
	display_name = "Tadpole NK-Haul Model"

/datum/map_template/shuttle/minidropship/mobile_bar
	suffix =	"_mobile_bar"
	description =	"A Tadpole modified to provide drinks and disservices. God dammit it's him again, I thought we got rid of him."
	display_name =	"Tadpole Mobile-Bar Model"
	admin_enable = FALSE

/datum/map_template/shuttle/minidropship/combat_tad
	suffix = "_combat_tad"
	description = "A Tadpole model modified to have three weapon hardpoints instead of just one, the majority of the other standard features had to be scrapped to fit all three of them on."
	display_name = "Tadpole Combat Model"

/datum/map_template/shuttle/minidropship/umbilical
	suffix =	"_umbilical"
	description = "A high-point orbital shuttle with a tactical umbilical airlock for insertion of ground troops."
	display_name = "Tadpole Umbilical Model"

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

/datum/map_template/shuttle/tgs_canterbury
	shuttle_id = SHUTTLE_CANTERBURY
	name = "Canterbury"

/datum/map_template/shuttle/tgs_bigbury
	shuttle_id = SHUTTLE_BIGBURY
	name = "Bigbury"

/datum/map_template/shuttle/escape_shuttle
	shuttle_id = SHUTTLE_ESCAPE_SHUTTLE
	name = "Escape Shuttle"
