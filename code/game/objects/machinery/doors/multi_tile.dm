//Terribly sorry for the code doubling, but things go derpy otherwise.
/obj/machinery/door/airlock/multi_tile
	width = 2

/obj/machinery/door/airlock/multi_tile/close() //Nasty as hell O(n^2) code but unfortunately necessary
	for(var/turf/T in locs)
		for(var/obj/vehicle/multitile/M in T)
			if(M) return FALSE

	return ..()

/obj/machinery/door/airlock/multi_tile/handle_weldingtool_overlay(removing = FALSE)
	if(!removing)
		if(dir & NORTH|SOUTH)
			add_overlay(GLOB.welding_sparks_multitiledoor_vertical)
		else
			add_overlay(GLOB.welding_sparks_multitiledoor_horizontal)
	else
		if(dir & NORTH|SOUTH)
			cut_overlay(GLOB.welding_sparks_multitiledoor_vertical)
		else
			cut_overlay(GLOB.welding_sparks_multitiledoor_horizontal)


///Due to inheritance from parent we need no icon_state, just icon
/obj/machinery/door/airlock/multi_tile/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Door2x1glass.dmi'
	opacity = FALSE
	glass = TRUE
	assembly_type = /obj/structure/door_assembly/multi_tile


/obj/machinery/door/airlock/multi_tile/security
	name = "Security Airlock"
	icon = 'icons/obj/doors/Door2x1security.dmi'
	opacity = FALSE
	glass = TRUE


/obj/machinery/door/airlock/multi_tile/command
	name = "Command Airlock"
	icon = 'icons/obj/doors/Door2x1command.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/medical
	name = "Medical Airlock"
	icon = 'icons/obj/doors/Door2x1medbay.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/engineering
	name = "Engineering Airlock"
	icon = 'icons/obj/doors/Door2x1engine.dmi'
	opacity = FALSE
	glass = TRUE


/obj/machinery/door/airlock/multi_tile/research
	name = "Research Airlock"
	icon = 'icons/obj/doors/Door2x1research.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/secure
	name = "Secure Airlock"
	icon = 'icons/obj/doors/Door2x1_secure.dmi'
	openspeed = 34

/obj/machinery/door/airlock/multi_tile/secure2
	name = "Secure Airlock"
	icon = 'icons/obj/doors/Door2x1_secure2.dmi'
	openspeed = 31
	req_access = null

/obj/machinery/door/airlock/multi_tile/secure2_glass
	name = "Secure Airlock"
	icon = 'icons/obj/doors/Door2x1_secure2_glass.dmi'
	opacity = FALSE
	glass = TRUE
	openspeed = 31
	req_access = null



// MARINE MAIN SHIP

// GENETIC
/obj/machinery/door/airlock/multi_tile/mainship
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	openspeed = 4 //shorter open animation.

/obj/machinery/door/airlock/multi_tile/mainship/generic
	name = "\improper Glass Airlock"
	icon = 'icons/obj/doors/mainship/2x1generic.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/generic/noglass
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/2x1personaldoor.dmi'
	glass = FALSE

/obj/machinery/door/airlock/multi_tile/mainship/generic/canteen
	name = "\improper Canteen"

/obj/machinery/door/airlock/multi_tile/mainship/generic/cryo
	name = "\improper Cryogenics Bay"

/obj/machinery/door/airlock/multi_tile/mainship/generic/garden
	name = "\improper Garden"

/obj/machinery/door/airlock/multi_tile/mainship/generic/prep
	name = "\improper Squad Preparation Room"

/obj/machinery/door/airlock/multi_tile/mainship/generic/range
	name = "\improper Firing Range"

/obj/machinery/door/airlock/multi_tile/mainship/generic/rnr
	name = "\improper Rest and Recreation"

/obj/machinery/door/airlock/multi_tile/mainship/generic/mechbay
	name = "\improper Mech Pilot's Office"

/obj/machinery/door/airlock/multi_tile/mainship/blackgeneric
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/2x1almayerdoor.dmi'
	opacity = FALSE
	glass = FALSE

/obj/machinery/door/airlock/multi_tile/mainship/blackgeneric/glass
	name = "\improper Glass Airlock"
	icon = 'icons/obj/doors/mainship/2x1almayerdoor_glass.dmi'
	glass = TRUE

//PREP DOORS

/obj/machinery/door/airlock/multi_tile/mainship/marine
	name = "\improper Squad Preparations"
	icon = 'icons/obj/doors/mainship/2x1prepdoor.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/marine/requisitions
	name = "\improper Requisitions Bay"
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)

/obj/machinery/door/airlock/multi_tile/mainship/marine/general/sl
	name = "\improper Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER)

/obj/machinery/door/airlock/multi_tile/mainship/marine/general/smart
	name = "\improper Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP)

/obj/machinery/door/airlock/multi_tile/mainship/marine/general/corps
	name = "\improper Corpsman Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP)

/obj/machinery/door/airlock/multi_tile/mainship/marine/general/engi
	name = "\improper Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP)

/obj/machinery/door/airlock/multi_tile/mainship/marine/alpha
	name = "\improper Alpha Squad Preparations"
	icon = 'icons/obj/doors/mainship/2x1prepdoor_alpha.dmi'
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ALPHA)

/obj/machinery/door/airlock/multi_tile/mainship/marine/alpha/sl
	name = "\improper Alpha Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_ALPHA)
	req_one_access =  null

/obj/machinery/door/airlock/multi_tile/mainship/marine/alpha/engineer
	name = "\improper Alpha Squad Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ALPHA)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/alpha/medic
	name = "\improper Alpha Squad Medic Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ALPHA)
	req_one_access =  null

/obj/machinery/door/airlock/multi_tile/mainship/marine/alpha/smart
	name = "\improper Alpha Squad Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_ALPHA)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/bravo
	name = "\improper Bravo Squad Preparations"
	icon = 'icons/obj/doors/mainship/2x1prepdoor_bravo.dmi'
	req_one_access = list(ACCESS_MARINE_LOGISTICS,ACCESS_MARINE_BRAVO)

/obj/machinery/door/airlock/multi_tile/mainship/marine/bravo/sl
	name = "\improper Bravo Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_BRAVO)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/bravo/engineer
	name = "\improper Bravo Squad Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_BRAVO)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/bravo/medic
	name = "\improper Bravo Squad Medic Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_BRAVO)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/bravo/smart
	name = "\improper Bravo Squad Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_BRAVO)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/charlie
	name = "\improper Charlie Squad Preparations"
	icon = 'icons/obj/doors/mainship/2x1prepdoor_charlie.dmi'
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CHARLIE)

/obj/machinery/door/airlock/multi_tile/mainship/marine/charlie/sl
	name = "\improper Charlie Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_CHARLIE)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/charlie/engineer
	name = "\improper Charlie Squad Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_CHARLIE)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/charlie/medic
	name = "\improper Charlie Squad Medic Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_CHARLIE)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/charlie/smart
	name = "\improper Charlie Squad Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_CHARLIE)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/delta
	name = "\improper Delta Squad Preparations"
	icon = 'icons/obj/doors/mainship/2x1prepdoor_delta.dmi'
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_DELTA)

/obj/machinery/door/airlock/multi_tile/mainship/marine/delta/sl
	name = "\improper Delta Squad Leader Preparations"
	req_access = list(ACCESS_MARINE_LEADER, ACCESS_MARINE_DELTA)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/delta/engineer
	name = "\improper Delta Squad Engineer Preparations"
	req_access = list(ACCESS_MARINE_ENGPREP, ACCESS_MARINE_DELTA)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/delta/medic
	name = "\improper Delta Squad Medic Preparations"
	req_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_DELTA)
	req_one_access = null

/obj/machinery/door/airlock/multi_tile/mainship/marine/delta/smart
	name = "\improper Delta Squad Smartgunner Preparations"
	req_access = list(ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DELTA)
	req_one_access = null

//MEDICAL
/obj/machinery/door/airlock/multi_tile/mainship/generic/personal
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/2x1personaldoor.dmi'

/obj/machinery/door/airlock/multi_tile/mainship/medidoor
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/mainship/2x1medidoor.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/personalglass
	name = "\improper Large Airlock"
	icon = 'icons/obj/doors/mainship/2x1personaldoor_glass.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/medidoor/medbay
	name = "\improper Medical Bay"
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/machinery/door/airlock/multi_tile/mainship/medidoor/medbay/free_access
	req_access = null

/obj/machinery/door/airlock/multi_tile/mainship/research
	name = "\improper Research Airlock"
	icon = 'icons/obj/doors/mainship/2x1medidoor.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = list(ACCESS_MARINE_RESEARCH)

//MAINTENANCE
/obj/machinery/door/airlock/multi_tile/mainship/maint
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/mainship/2x1maintdoor.dmi'
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ENGINEERING)

/obj/machinery/door/airlock/multi_tile/mainship/maint/free_access
	req_one_access = null

//ENGINEERING

/obj/machinery/door/airlock/multi_tile/mainship/engineering
	name = "\improper Engineering Airlock"
	icon = 'icons/obj/doors/mainship/2x1engidoor.dmi'
	opacity = FALSE
	glass = FALSE
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ENGINEERING)

/obj/machinery/door/airlock/multi_tile/mainship/engineering/glass
	name = "\improper Engineering Glass Airlock"
	icon = 'icons/obj/doors/mainship/2x1engidoor_glass.dmi'
	glass = TRUE

//COMMAND
/obj/machinery/door/airlock/multi_tile/mainship/comdoor
	name = "\improper Command Airlock"
	icon = 'icons/obj/doors/mainship/2x1comdoor.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/airlock/multi_tile/mainship/comdoor/rebel
	req_access = list(ACCESS_MARINE_BRIDGE_REBEL)

/obj/machinery/door/airlock/multi_tile/mainship/comdoor/free_access
	req_access = null

/obj/machinery/door/airlock/multi_tile/mainship/comdoor/cargopads
	name = "\improper Cargo Pads"
	req_access = list(ACCESS_NT_CORPORATE)

/obj/machinery/door/airlock/multi_tile/mainship/secdoor
	name = "\improper Security Airlock"
	icon = 'icons/obj/doors/mainship/2x1secdoor.dmi'
	opacity = FALSE
	glass = FALSE
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/airlock/multi_tile/mainship/secdoor/glass
	name = "\improper Security Glass Airlock"
	icon = 'icons/obj/doors/mainship/2x1secdoor_glass.dmi'
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/handle_multidoor()
	if(!(width > 1)) return //Bubblewrap

	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			T.set_opacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			T.set_opacity(opacity)

	if(dir in list(NORTH, SOUTH))
		bound_height = world.icon_size * width
	else if(dir in list(EAST, WEST))
		bound_width = world.icon_size * width

//We have to find these again since these doors are used on shuttles a lot so the turfs changes
/obj/machinery/door/airlock/multi_tile/mainship/proc/update_filler_turfs()

	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			if(T) T.set_opacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			if(T) T.set_opacity(opacity)

/obj/machinery/door/airlock/multi_tile/mainship/proc/get_filler_turfs()
	var/list/filler_turfs = list()
	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			if(T) filler_turfs += T
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			if(T) filler_turfs += T
	return filler_turfs

/obj/machinery/door/airlock/multi_tile/mainship/open()
	. = ..()
	update_filler_turfs()

/obj/machinery/door/airlock/multi_tile/mainship/close()
	. = ..()
	update_filler_turfs()

//------Dropship Cargo Doors -----//

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear
	opacity = TRUE
	width = 3
	resistance_flags = RESIST_ALL
	no_panel = TRUE
	not_weldable = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/proc/lockdown()
	unlock()
	close()
	lock()

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/proc/release()
	unlock()

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/ex_act(severity)
	return

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/close(forced=0)
	if(forced)
		for(var/turf/T in get_filler_turfs())
			for(var/mob/living/L in T)
				step(L, pick(NORTH,SOUTH)) // bump them off the tile
		safe = FALSE // in case anyone tries to run into the closing door~
		..()
		safe = TRUE // without having to rewrite closing proc~spookydonut
	else
		..()

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/ds1
	name = "\improper Alamo cargo door"
	icon = 'icons/obj/doors/mainship/dropship1_cargo.dmi'

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/ds2
	name = "\improper Normandy cargo door"
	icon = 'icons/obj/doors/mainship/dropship2_cargo.dmi'


//nice colony colony entrance
/obj/machinery/door/airlock/multi_tile/ice
	name = "ice colony door"
	icon = 'icons/obj/doors/icecolony.dmi'
	icon_state = "door_closed"
	width = 4
	openspeed = 17
	no_panel = TRUE
	opacity = TRUE
