/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = 0 				(defaults to 1)
	music = "music/music.ogg"		(defaults to "music/music.ogg")

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/



/area
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = 1

	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREAS_LAYER
	mouse_opacity = 0
	invisibility = INVISIBILITY_LIGHTING
	var/lightswitch = 1

	var/flags_alarm_state = NOFLAGS

	var/debug = 0
	var/powerupdate = 10		//We give everything 10 ticks to settle out it's power usage.
	var/requires_power = 1
	var/unlimited_power = 0
	var/always_unpowered = 0	//this gets overriden to 1 for space in area/New()

	var/power_equip = 1
	var/power_light = 1
	var/power_environ = 1
	var/music = null
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0

	var/has_gravity = 1
	var/list/apc = list()
	var/list/area_machines = list() // list of machines only for master areas
	var/no_air = null
	var/area/master				// master area used for power calcluations
								// (original area before splitting due to sd_DAL)
	var/list/related			// the other areas of the same type as this
//	var/list/lights				// list of all lights on this area
	var/list/all_doors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated = 0
	var/list/ambience = list('sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambigen14.ogg')

/*Adding a wizard area teleport list because motherfucking lag -- Urist*/
/*I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game*/
var/list/teleportlocs = list()

/hook/startup/proc/setupTeleportLocs()
	for(var/area/AR in all_areas)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station) || istype(AR, /area/wizard_station)) continue
		if(teleportlocs.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == 1 || picked.z == MAIN_SHIP_Z_LEVEL)
			teleportlocs += AR.name
			teleportlocs[AR.name] = AR

	teleportlocs = sortAssoc(teleportlocs)

	return 1

var/list/ghostteleportlocs = list()

/hook/startup/proc/setupGhostTeleportLocs()
	for(var/area/AR in all_areas)
		if(ghostteleportlocs.Find(AR.name)) continue
		if(istype(AR, /area/turret_protected/aisat) || istype(AR, /area/tdome) || istype(AR, /area/shuttle/specops/centcom))
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == 1 || picked.z == 3 || picked.z == 4 || picked.z == 5)
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR

	ghostteleportlocs = sortAssoc(ghostteleportlocs)

	return 1

/*-----------------------------------------------------------------------------*/
/area/space
	name = "\improper Space"
	requires_power = 1
	always_unpowered = 1
	lighting_use_dynamic = 1
	power_light = 0
	power_equip = 0
	power_environ = 0
	ambience = list('sound/ambience/ambispace.ogg')
	temperature = TCMB
	pressure = 0

/area/engine/
	ambience = list('sound/ambience/ambisin1.ogg','sound/ambience/ambisin2.ogg','sound/ambience/ambisin3.ogg','sound/ambience/ambisin4.ogg')
/area/turret_protected/

/area/arrival
	requires_power = 0

/area/arrival/start
	name = "\improper Arrival Area"
	icon_state = "start"

/area/admin
	name = "\improper Admin room"
	icon_state = "start"



//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle //DO NOT TURN THE lighting_use_dynamic STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = 0

/area/shuttle/arrival
	name = "\improper abandoned  Arrival Shuttle"

/area/shuttle/arrival/pre_game
	icon_state = "shuttle2"

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/escape
	name = "\improper abandoned  Emergency Shuttle"
	music = "music/escape.ogg"

/area/shuttle/escape/station
	name = "\improper abandoned  Emergency Shuttle Station"
	icon_state = "shuttle2"

/area/shuttle/escape/centcom
	name = "\improper abandoned  Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	name = "\improper abandoned  Emergency Shuttle Transit"
	icon_state = "shuttle"

/area/shuttle/escape_pod1
	name = "\improper Escape Pod One"
	music = "music/escape.ogg"

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod2
	name = "\improper Escape Pod Two"
	music = "music/escape.ogg"

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod3
	name = "\improper Escape Pod Three"
	music = "music/escape.ogg"

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "\improper Escape Pod Five"
	music = "music/escape.ogg"

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"

/area/shuttle/mining
	name = "\improper abandoned Mining Shuttle"
	music = "music/escape.ogg"

/area/shuttle/mining/station
	icon_state = "shuttle2"

/area/shuttle/mining/outpost
	icon_state = "shuttle"

/area/shuttle/transport1/centcom
	icon_state = "shuttle"
	name = "\improper abandoned  Transport Shuttle Centcom"

/area/shuttle/transport1/station
	icon_state = "shuttle"
	name = "\improper abandoned  Transport Shuttle"
/*
/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "\improper abandoned  Alien Shuttle Base"
	requires_power = 1
	luminosity = 0
	lighting_use_dynamic = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "\improper abandoned  Alien Shuttle Mine"
	requires_power = 1
	luminosity = 0
	lighting_use_dynamic = 1
*/


/area/shuttle/prison/
	name = "\improper abandoned  Prison Shuttle"

/area/shuttle/prison/station
	icon_state = "shuttle"

/area/shuttle/prison/prison
	icon_state = "shuttle2"

/area/shuttle/specops/centcom
	name = "\improper abandoned  Special Ops Shuttle"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "\improper abandoned  Special Ops Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/syndicate_elite/mothership
	name = "\improper abandoned  Syndicate Elite Shuttle"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "\improper abandoned  Syndicate Elite Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/administration/centcom
	name = "\improper abandoned  Administration Shuttle Centcom"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "\improper abandoned  Administration Shuttle"
	icon_state = "shuttlered2"

/area/shuttle/thunderdome
	name = "honk"

/area/shuttle/thunderdome/grnshuttle
	name = "\improper abandoned  Thunderdome GRN Shuttle"
	icon_state = "green"

/area/shuttle/thunderdome/grnshuttle/dome
	name = "\improper abandoned  GRN Shuttle"
	icon_state = "shuttlegrn"

/area/shuttle/thunderdome/grnshuttle/station
	name = "\improper abandoned  GRN Station"
	icon_state = "shuttlegrn2"

/area/shuttle/thunderdome/redshuttle
	name = "\improper abandoned  Thunderdome RED Shuttle"
	icon_state = "red"

/area/shuttle/thunderdome/redshuttle/dome
	name = "\improper abandoned  RED Shuttle"
	icon_state = "shuttlered"

/area/shuttle/thunderdome/redshuttle/station
	name = "\improper abandoned  RED Station"
	icon_state = "shuttlered2"
// === Trying to remove these areas:
/*
/area/shuttle/research
	name = "\improper abandoned  Research Shuttle"
	music = "music/escape.ogg"

/area/shuttle/research/station
	icon_state = "shuttle2"

/area/shuttle/research/outpost
	icon_state = "shuttle"
*/
/area/shuttle/vox/station
	name = "\improper abandoned  Vox Skipjack"
	icon_state = "yellow"
	requires_power = 0

/area/airtunnel1/      // referenced in airtunnel.dm:759

/area/dummy/           // Referenced in engine.dm:261

/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = 0
	has_gravity = 1

// === end remove
/*
/area/alien
	name = "\improper abandoned  Alien base"
	icon_state = "yellow"
	requires_power = 0
*/
// CENTCOM

/area/centcom
	name = "\improper abandoned  Centcom"
	icon_state = "centcom"
	requires_power = 0

/area/centcom/control
	name = "\improper abandoned  Centcom Control"

/area/centcom/evac
	name = "\improper abandoned  Centcom Emergency Shuttle"

/area/centcom/suppy
	name = "\improper abandoned  Centcom Supply Shuttle"

/area/centcom/ferry
	name = "\improper abandoned  Centcom Transport Shuttle"

/area/centcom/shuttle
	name = "\improper abandoned  Centcom Administration Shuttle"

/area/centcom/test
	name = "\improper abandoned  Centcom Testing Facility"

/area/centcom/living
	name = "\improper abandoned  Centcom Living Quarters"

/area/centcom/specops
	name = "\improper abandoned  Centcom Special Ops"

/area/centcom/creed
	name = "Creed's Office"

/area/centcom/holding
	name = "\improper abandoned  Holding Facility"

/area/centcom/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

//SYNDICATES

/area/syndicate_mothership
	name = "\improper abandoned  Syndicate Base"
	icon_state = "syndie-ship"
	requires_power = 0
	unlimited_power = 1

/area/syndicate_mothership/control
	name = "\improper abandoned  Syndicate Control Room"
	icon_state = "syndie-control"

/area/syndicate_mothership/elite_squad
	name = "\improper abandoned  Syndicate Elite Squad"
	icon_state = "syndie-elite"

//EXTRA

/area/asteroid					// -- TLE
	name = "\improper abandoned  Asteroid"
	icon_state = "asteroid"
	requires_power = 0

/area/asteroid/cave				// -- TLE
	name = "\improper abandoned  Asteroid - Underground"
	icon_state = "cave"
	requires_power = 0

/area/asteroid/artifactroom
	name = "\improper abandoned  Asteroid - Artifact"
	icon_state = "cave"














/*
/area/planet/clown
	name = "\improper abandoned  Clown Planet"
	icon_state = "honk"
	requires_power = 0
*/
/area/tdome
	name = "\improper abandoned  Thunderdome"
	icon_state = "thunder"
	requires_power = 0

/area/tdome/tdome1
	name = "\improper abandoned  Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "\improper abandoned  Thunderdome (Team 2)"
	icon_state = "yellow"

/area/tdome/tdomeadmin
	name = "\improper abandoned  Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "\improper abandoned  Thunderdome (Observer.)"
	icon_state = "purple"

//ENEMY

//names are used
/area/syndicate_station
	name = "\improper abandoned  Syndicate Station"
	icon_state = "yellow"
	requires_power = 0
	unlimited_power = 1

/area/syndicate_station/start
	name = "\improper abandoned  Syndicate Forward Operating Base"
	icon_state = "yellow"

/area/syndicate_station/southwest
	name = "\improper abandoned  south-west of SS13"
	icon_state = "southwest"

/area/syndicate_station/northwest
	name = "\improper abandoned  north-west of SS13"
	icon_state = "northwest"

/area/syndicate_station/northeast
	name = "\improper abandoned  north-east of SS13"
	icon_state = "northeast"

/area/syndicate_station/southeast
	name = "\improper abandoned  south-east of SS13"
	icon_state = "southeast"

/area/syndicate_station/north
	name = "\improper abandoned  north of SS13"
	icon_state = "north"

/area/syndicate_station/south
	name = "\improper abandoned  south of SS13"
	icon_state = "south"

/area/syndicate_station/commssat
	name = "\improper abandoned  south of the communication satellite"
	icon_state = "south"

/area/syndicate_station/mining
	name = "\improper abandoned  north east of the mining asteroid"
	icon_state = "north"

/area/syndicate_station/transit
	name = "\improper abandoned  hyperspace"
	icon_state = "shuttle"

/area/wizard_station
	name = "\improper abandoned  Wizard's Den"
	icon_state = "yellow"
	requires_power = 0

/area/vox_station/transit
	name = "\improper abandoned  hyperspace"
	icon_state = "shuttle"
	requires_power = 0

/area/vox_station/southwest_solars
	name = "\improper abandoned  aft port solars"
	icon_state = "southwest"
	requires_power = 0

/area/vox_station/northwest_solars
	name = "\improper abandoned  fore port solars"
	icon_state = "northwest"
	requires_power = 0

/area/vox_station/northeast_solars
	name = "\improper abandoned  fore starboard solars"
	icon_state = "northeast"
	requires_power = 0

/area/vox_station/southeast_solars
	name = "\improper abandoned  aft starboard solars"
	icon_state = "southeast"
	requires_power = 0

/area/vox_station/mining
	name = "\improper abandoned  nearby mining asteroid"
	icon_state = "north"
	requires_power = 0

//PRISON
/*
/area/prison
	name = "\improper abandoned  Prison Station"
	icon_state = "brig"

/area/prison/arrival_airlock
	name = "\improper abandoned  Prison Station Airlock"
	icon_state = "green"
	requires_power = 0

/area/prison/control
	name = "\improper abandoned  Prison Security Checkpoint"
	icon_state = "security"

/area/prison/crew_quarters
	name = "\improper abandoned  Prison Security Quarters"
	icon_state = "security"

/area/prison/rec_room
	name = "\improper abandoned  Prison Rec Room"
	icon_state = "green"

/area/prison/closet
	name = "\improper abandoned  Prison Supply Closet"
	icon_state = "dk_yellow"

/area/prison/hallway/fore
	name = "\improper abandoned  Prison Fore Hallway"
	icon_state = "yellow"

/area/prison/hallway/aft
	name = "\improper abandoned  Prison Aft Hallway"
	icon_state = "yellow"

/area/prison/hallway/port
	name = "\improper abandoned  Prison Port Hallway"
	icon_state = "yellow"

/area/prison/hallway/starboard
	name = "\improper abandoned  Prison Starboard Hallway"
	icon_state = "yellow"

/area/prison/morgue
	name = "\improper abandoned  Prison Morgue"
	icon_state = "morgue"

/area/prison/medical_research
	name = "\improper abandoned  Prison Genetic Research"
	icon_state = "medresearch"

/area/prison/medical
	name = "\improper abandoned  Prison Medbay"
	icon_state = "medbay"

/area/prison/solar
	name = "\improper abandoned  Prison Solar Array"
	icon_state = "storage"
	requires_power = 0

/area/prison/podbay
	name = "\improper abandoned  Prison Podbay"
	icon_state = "dk_yellow"

/area/prison/solar_control
	name = "\improper abandoned  Prison Solar Array Control"
	icon_state = "dk_yellow"

/area/prison/solitary
	name = "Solitary Confinement"
	icon_state = "brig"

/area/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brig"

/area/prison/cell_block/B
	name = "Prison Cell Block B"
	icon_state = "brig"

/area/prison/cell_block/C
	name = "Prison Cell Block C"
	icon_state = "brig"

//STATION13

/area/atmos
 	name = "Atmospherics"
 	icon_state = "atmos"
*/
//Maintenance

/area/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/port
	name = "Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/atmos_control
	name = "Atmospherics Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint
	name = "Fore Port Maintenance - 1"
	icon_state = "fpmaint"

/area/maintenance/fpmaint2
	name = "Fore Port Maintenance - 2"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Fore Starboard Maintenance - 1"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Fore Starboard Maintenance - 2"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/engi_shuttle
	name = "Engineering Shuttle Access"
	icon_state = "maint_e_shuttle"

/area/maintenance/engi_engine
	name = "Engine Maintenance"
	icon_state = "maint_engine"

/area/maintenance/asmaint2
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/maintenance/apmaint
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "maintcentral"

/area/maintenance/arrivals
	name = "Arrivals Maintenance"
	icon_state = "maint_arrivals"

/area/maintenance/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"

/area/maintenance/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/maintenance/engineering
	name = "Engineering Maintenance"
	icon_state = "maint_engineering"

/area/maintenance/evahallway
	name = "\improper abandoned  EVA Maintenance"
	icon_state = "maint_eva"

/area/maintenance/dormitory
	name = "Dormitory Maintenance"
	icon_state = "maint_dormitory"

/area/maintenance/incinerator
	name = "\improper abandoned  Incinerator"
	icon_state = "disposal"

/area/maintenance/locker
	name = "Locker Room Maintenance"
	icon_state = "maint_locker"

/area/maintenance/medbay
	name = "Medbay Maintenance"
	icon_state = "maint_medbay"

/area/maintenance/research_port
	name = "Port Research Maintenance"
	icon_state = "maint_research_port"

/area/maintenance/research_starboard
	name = "Starboard Research Maintenance"
	icon_state = "maint_research_starboard"

/area/maintenance/research_shuttle
	name = "Research Shuttle Dock Maintenance"
	icon_state = "maint_research_shuttle"

/area/maintenance/security_port
	name = "Port Security Maintenance"
	icon_state = "maint_security_port"

/area/maintenance/security_starboard
	name = "Starboard Security Maintenance"
	icon_state = "maint_security_starboard"

/area/maintenance/storage
	name = "Atmospherics"
	icon_state = "green"

// SUBSTATIONS (Subtype of maint, that should let them serve as shielded area during radstorm)


/area/maintenance/substation
	name = "Substation"
	icon_state = "substation"

/area/maintenance/substation/engineering // Probably will be connected to engineering SMES room, as wires cannot be crossed properly without them sharing powernets.
	name = "Engineering Substation"

/area/maintenance/substation/medical_science // Medbay and Science. Each has it's own separated machinery, but it originates from the same room.
	name = "Medical Research Substation"

/area/maintenance/substation/civilian_east // Bar, kitchen, dorms, ...
	name = "Civilian East Substation"

/area/maintenance/substation/civilian_west // Cargo, PTS, locker room, probably arrivals, ...)
	name = "Civilian West Substation"

/area/maintenance/substation/command // AI and central cluster. This one will be between HoP office and meeting room (probably).
	name = "Command Substation"

/area/maintenance/substation/security // Security, Brig, Permabrig, etc.
	name = "Security Substation"




//Hallway

/area/hallway/primary/fore
	name = "\improper abandoned  Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "\improper abandoned  Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/aft
	name = "\improper abandoned  Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/port
	name = "\improper abandoned  Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central_one
	name = "\improper abandoned  Central Primary Hallway"
	icon_state = "hallC1"
	ambience = list('sound/ambience/signal.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg')

/area/hallway/primary/central_two
	name = "\improper abandoned  Central Primary Hallway"
	icon_state = "hallC2"

/area/hallway/primary/central_three
	name = "\improper abandoned  Central Primary Hallway"
	icon_state = "hallC3"

/area/hallway/secondary/exit
	name = "\improper abandoned  Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/construction
	name = "\improper abandoned  Construction Area"
	icon_state = "construction"

/area/hallway/secondary/entry
	name = "\improper abandoned  Arrival Shuttle Hallway"
	icon_state = "entry"

//Command

/area/bridge
	name = "\improper abandoned  Bridge"
	icon_state = "bridge"
	music = "signal"

/area/bridge/meeting_room
	name = "\improper abandoned  Heads of Staff Meeting Room"
	icon_state = "bridge"
	music = null

/area/crew_quarters/captain
	name = "\improper abandoned  Captain's Office"
	icon_state = "captain"

/area/crew_quarters/heads/hop
	name = "\improper abandoned  Head of Personnel's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hor
	name = "\improper abandoned  Research Director's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/chief
	name = "\improper abandoned  Chief Engineer's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hos
	name = "\improper abandoned  Head of Security's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/cmo
	name = "\improper abandoned  Chief Medical Officer's Office"
	icon_state = "head_quarters"

/area/crew_quarters/courtroom
	name = "\improper abandoned  Courtroom"
	icon_state = "courtroom"

/area/mint
	name = "\improper abandoned  Mint"
	icon_state = "green"

/area/comms
	name = "\improper abandoned  Communications Relay"
	icon_state = "tcomsatcham"

/area/server
	name = "\improper abandoned  Messaging Server Room"
	icon_state = "server"

//Crew

/area/crew_quarters
	name = "\improper abandoned  Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/toilet
	name = "\improper abandoned  Dormitory Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep
	name = "\improper abandoned  Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep/engi
	name = "\improper abandoned  Engineering Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep/engi_wash
	name = "\improper abandoned  Engineering Washroom"
	icon_state = "toilet"

/area/crew_quarters/sleep/sec
	name = "\improper abandoned  Security Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep/bedrooms
	name = "\improper abandoned  Dormitory Bedroom"
	icon_state = "Sleep"

/area/crew_quarters/sleep/cryo
	name = "\improper abandoned  Cryogenic Storage"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male
	name = "\improper abandoned  Male Dorm"
	icon_state = "Sleep"
/*
/area/crew_quarters/sleep_male/toilet_male
	name = "\improper abandoned  Male Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep_female
	name = "\improper abandoned  Female Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_female/toilet_female
	name = "\improper abandoned  Female Toilets"
	icon_state = "toilet"
*/
/area/crew_quarters/locker
	name = "\improper abandoned  Locker Room"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "\improper abandoned  Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "\improper abandoned  Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/cafeteria
	name = "\improper abandoned  Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "\improper abandoned  Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "\improper abandoned  Bar"
	icon_state = "bar"

/area/crew_quarters/theatre
	name = "\improper abandoned  Theatre"
	icon_state = "Theatre"

/area/library
 	name = "\improper abandoned  Library"
 	icon_state = "library"

/area/chapel/main
	name = "\improper abandoned  Chapel"
	icon_state = "chapel"
	ambience = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')

/area/chapel/office
	name = "\improper abandoned  Chapel Office"
	icon_state = "chapeloffice"

/area/lawoffice
	name = "\improper abandoned  Internal Affairs"
	icon_state = "law"







/area/holodeck
	name = "\improper abandoned  Holodeck"
	icon_state = "Holodeck"
	luminosity = 1
	lighting_use_dynamic = 0

/area/holodeck/alphadeck
	name = "\improper abandoned  Holodeck Alpha"


/area/holodeck/source_plating
	name = "\improper abandoned  Holodeck - Off"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "\improper abandoned  Holodeck - Empty Court"

/area/holodeck/source_boxingcourt
	name = "\improper abandoned  Holodeck - Boxing Court"

/area/holodeck/source_basketball
	name = "\improper abandoned  Holodeck - Basketball Court"

/area/holodeck/source_thunderdomecourt
	name = "\improper abandoned  Holodeck - Thunderdome Court"

/area/holodeck/source_beach
	name = "\improper abandoned  Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/holodeck/source_burntest
	name = "\improper abandoned  Holodeck - Atmospheric Burn Test"

/area/holodeck/source_wildlife
	name = "\improper abandoned  Holodeck - Wildlife Simulation"

/area/holodeck/source_meetinghall
	name = "\improper abandoned  Holodeck - Meeting Hall"

/area/holodeck/source_theatre
	name = "\improper abandoned  Holodeck - Theatre"

/area/holodeck/source_picnicarea
	name = "\improper abandoned  Holodeck - Picnic Area"

/area/holodeck/source_snowfield
	name = "\improper abandoned  Holodeck - Snow Field"

/area/holodeck/source_desert
	name = "\improper abandoned  Holodeck - Desert"

/area/holodeck/source_space
	name = "\improper abandoned  Holodeck - Space"











//Engineering

/area/engine

	drone_fabrication
		name = "\improper abandoned  Drone Fabrication"
		icon_state = "engine"

	engine_smes
		name = "Engineering SMES"
		icon_state = "engine_smes"
//		requires_power = 0//This area only covers the batteries and they deal with their own power

	engine_room
		name = "\improper abandoned  Engine Room"
		icon_state = "engine"

	engine_airlock
		name = "\improper abandoned  Engine Room Airlock"
		icon_state = "engine"

	engine_monitoring
		name = "\improper abandoned  Engine Monitoring Room"
		icon_state = "engine_monitoring"

	engine_waste
		name = "\improper abandoned  Engine Waste Handling"
		icon_state = "engine_waste"

	engineering_monitoring
		name = "\improper abandoned  Engineering Monitoring Room"
		icon_state = "engine_monitoring"

	atmos_monitoring
		name = "\improper abandoned  Atmospherics Monitoring Room"
		icon_state = "engine_monitoring"

	engineering
		name = "Engineering"
		icon_state = "engine_smes"

	engineering_foyer
		name = "\improper abandoned  Engineering Foyer"
		icon_state = "engine"

	break_room
		name = "\improper abandoned  Engineering Break Room"
		icon_state = "engine"

	hallway
		name = "\improper abandoned  Engineering Hallway"
		icon_state = "engine_hallway"

	engine_hallway
		name = "\improper abandoned  Engine Room Hallway"
		icon_state = "engine_hallway"

	engine_eva
		name = "\improper abandoned  Engine EVA"
		icon_state = "engine_eva"

	engine_eva_maintenance
		name = "\improper abandoned  Engine EVA Maintenance"
		icon_state = "engine_eva"

	workshop
		name = "\improper abandoned  Engineering Workshop"
		icon_state = "engine_storage"

	locker_room
		name = "\improper abandoned  Engineering Locker Room"
		icon_state = "engine_storage"


//Solars

/area/solar
	requires_power = 1
	always_unpowered = 1
	luminosity = 1
	lighting_use_dynamic = 0

	auxport
		name = "\improper abandoned  Fore Port Solar Array"
		icon_state = "panelsA"

	auxstarboard
		name = "\improper abandoned  Fore Starboard Solar Array"
		icon_state = "panelsA"

	fore
		name = "\improper abandoned  Fore Solar Array"
		icon_state = "yellow"

	aft
		name = "\improper abandoned  Aft Solar Array"
		icon_state = "aft"

	starboard
		name = "\improper abandoned  Aft Starboard Solar Array"
		icon_state = "panelsS"

	port
		name = "\improper abandoned  Aft Port Solar Array"
		icon_state = "panelsP"

/area/maintenance/auxsolarport
	name = "Fore Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/starboardsolar
	name = "Aft Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/portsolar
	name = "Aft Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/auxsolarstarboard
	name = "Fore Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/foresolar
	name = "Fore Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/assembly/chargebay
	name = "\improper abandoned  Mech Bay"
	icon_state = "mechbay"

/area/assembly/showroom
	name = "\improper abandoned  Robotics Showroom"
	icon_state = "showroom"

/area/assembly/robotics
	name = "\improper abandoned  Robotics Lab"
	icon_state = "ass_line"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "\improper abandoned  Assembly Line"
	icon_state = "ass_line"
	power_equip = 0
	power_light = 0
	power_environ = 0

//Teleporter

/area/teleporter
	name = "\improper abandoned  Teleporter"
	icon_state = "teleporter"
	music = "signal"

/area/gateway
	name = "\improper abandoned  Gateway"
	icon_state = "teleporter"
	music = "signal"

/area/AIsattele
	name = "\improper abandoned  AI Satellite Teleporter Room"
	icon_state = "teleporter"
	music = "signal"
	ambience = list('sound/ambience/ambimalf.ogg')

//MedBay

/area/medical/medbay
	name = "\improper abandoned  Medbay"
	icon_state = "medbay"
	music = 'sound/ambience/signal.ogg'

//Medbay is a large area, these additional areas help level out APC load.
/area/medical/medbay2
	name = "\improper abandoned  Medbay"
	icon_state = "medbay2"
	music = 'sound/ambience/signal.ogg'

/area/medical/medbay3
	name = "\improper abandoned  Medbay"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/biostorage
	name = "\improper abandoned  Secondary Storage"
	icon_state = "medbay2"
	music = 'sound/ambience/signal.ogg'

/area/medical/reception
	name = "\improper abandoned  Medbay Reception"
	icon_state = "medbay"
	music = 'sound/ambience/signal.ogg'

/area/medical/psych
	name = "\improper abandoned  Psych Room"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/crew_quarters/medbreak
	name = "\improper abandoned  Break Room"
	icon_state = "medbay3"
	music = 'sound/ambience/signal.ogg'

/area/medical/patients_rooms
	name = "\improper abandoned  Patient's Rooms"
	icon_state = "patients"

/area/medical/ward
	name = "\improper abandoned  Recovery Ward"
	icon_state = "patients"

/area/medical/patient_a
	name = "\improper abandoned  Isolation A"
	icon_state = "patients"

/area/medical/patient_b
	name = "\improper abandoned  Isolation B"
	icon_state = "patients"

/area/medical/patient_c
	name = "\improper abandoned  Isolation C"
	icon_state = "patients"

/area/medical/patient_wing
	name = "\improper abandoned  Patient Wing"
	icon_state = "patients"

/area/medical/cmostore
	name = "\improper abandoned  Secure Storage"
	icon_state = "CMO"

/area/medical/robotics
	name = "\improper abandoned  Robotics"
	icon_state = "medresearch"

/area/medical/virology
	name = "\improper abandoned  Virology"
	icon_state = "virology"

/area/medical/virologyaccess
	name = "\improper abandoned  Virology Access"
	icon_state = "virology"

/area/medical/morgue
	name = "\improper abandoned  Morgue"
	icon_state = "morgue"
	ambience = list('sound/ambience/ambimo1.ogg','sound/ambience/ambimo2.ogg')

/area/medical/chemistry
	name = "\improper abandoned  Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "\improper abandoned  Operating Theatre 1"
	icon_state = "surgery"

/area/medical/surgery2
	name = "\improper abandoned  Operating Theatre 2"
	icon_state = "surgery"

/area/medical/surgeryobs
	name = "\improper abandoned  Operation Observation Room"
	icon_state = "surgery"

/area/medical/surgeryprep
	name = "\improper abandoned  Pre-Op Prep Room"
	icon_state = "surgery"

/area/medical/cryo
	name = "\improper abandoned  Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "\improper abandoned  Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "\improper abandoned  Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics_cloning
	name = "\improper abandoned  Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "\improper abandoned  Emergency Treatment Centre"
	icon_state = "exam_room"

//Security

/area/security/main
	name = "\improper abandoned  Security Office"
	icon_state = "security"

/area/security/lobby
	name = "\improper abandoned  Security lobby"
	icon_state = "security"

/area/security/brig
	name = "\improper abandoned  Brig"
	icon_state = "brig"

/area/security/prison
	name = "\improper abandoned  Prison Wing"
	icon_state = "sec_prison"


/area/security/warden
	name = "\improper abandoned  Warden"
	icon_state = "Warden"

/area/security/armoury
	name = "\improper abandoned  Armory"
	icon_state = "Warden"

/area/security/detectives_office
	name = "\improper abandoned  Detective's Office"
	icon_state = "detective"

/area/security/range
	name = "\improper abandoned  Firing Range"
	icon_state = "firingrange"

/area/security/tactical
	name = "\improper abandoned  Tactical Equipment"
	icon_state = "Tactical"

/*
	New()
		..()

		spawn(10) //let objects set up first
			for(var/turf/turfToGrayscale in src)
				if(turfToGrayscale.icon)
					var/icon/newIcon = icon(turfToGrayscale.icon)
					newIcon.GrayScale()
					turfToGrayscale.icon = newIcon
				for(var/obj/objectToGrayscale in turfToGrayscale) //1 level deep, means tables, apcs, locker, etc, but not locker contents
					if(objectToGrayscale.icon)
						var/icon/newIcon = icon(objectToGrayscale.icon)
						newIcon.GrayScale()
						objectToGrayscale.icon = newIcon
*/

/area/security/nuke_storage
	name = "\improper abandoned  Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "\improper abandoned  Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "\improper abandoned  Security Checkpoint"
	icon_state = "security"

/area/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint1"

/area/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint1"

/area/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint1"

/area/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint1"

/area/security/vacantoffice
	name = "\improper abandoned  Vacant Office"
	icon_state = "security"

/area/security/vacantoffice2
	name = "\improper abandoned  Vacant Office"
	icon_state = "security"

/area/quartermaster
	name = "\improper abandoned  Quartermasters"
	icon_state = "quart"

///////////WORK IN PROGRESS//////////

/area/quartermaster/sorting
	name = "\improper abandoned  Delivery Office"
	icon_state = "quartstorage"

////////////WORK IN PROGRESS//////////

/area/quartermaster/office
	name = "\improper abandoned  Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "\improper abandoned  Cargo Bay"
	icon_state = "quartstorage"

/area/quartermaster/qm
	name = "\improper abandoned  Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "\improper abandoned  Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "\improper abandoned  Mining Storage"
	icon_state = "green"

/area/quartermaster/mechbay
	name = "\improper abandoned  Mech Bay"
	icon_state = "yellow"

/area/janitor/
	name = "\improper abandoned  Custodial Closet"
	icon_state = "janitor"

/area/hydroponics
	name = "\improper abandoned  Hydroponics"
	icon_state = "hydro"

/area/hydroponics/garden
	name = "\improper abandoned  Garden"
	icon_state = "garden"

//rnd (Research and Development

/area/rnd/research
	name = "\improper abandoned  Research and Development"
	icon_state = "research"

/area/rnd/docking
	name = "\improper abandoned  Research Dock"
	icon_state = "research_dock"

/area/rnd/lab
	name = "\improper abandoned  Research Lab"
	icon_state = "toxlab"

/area/rnd/rdoffice
	name = "\improper abandoned  Research Director's Office"
	icon_state = "head_quarters"

/area/rnd/supermatter
	name = "\improper abandoned  Supermatter Lab"
	icon_state = "toxlab"

/area/rnd/xenobiology
	name = "\improper abandoned  Xenobiology Lab"
	icon_state = "xeno_lab"

/area/rnd/xenobiology/xenoflora_storage
	name = "\improper abandoned  Xenoflora Storage"
	icon_state = "xeno_f_store"

/area/rnd/xenobiology/xenoflora
	name = "\improper abandoned  Xenoflora Lab"
	icon_state = "xeno_f_lab"

/area/rnd/storage
	name = "\improper abandoned  Toxins Storage"
	icon_state = "toxstorage"

/area/rnd/test_area
	name = "\improper abandoned  Toxins Test Area"
	icon_state = "toxtest"

/area/rnd/mixing
	name = "\improper abandoned  Toxins Mixing Room"
	icon_state = "toxmix"

/area/rnd/misc_lab
	name = "\improper abandoned  Miscellaneous Research"
	icon_state = "toxmisc"

/area/toxins/server
	name = "\improper abandoned  Server Room"
	icon_state = "server"

//Storage

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/storage/auxillary
	name = "Auxillary Storage"
	icon_state = "auxstorage"

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency3
	name = "Central Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/testroom
	requires_power = 0
	name = "\improper abandoned  Test Room"
	icon_state = "storage"

//DJSTATION

/area/djstation
	name = "\improper abandoned  Listening Post"
	icon_state = "LP"

/area/djstation/solars
	name = "\improper abandoned  Listening Post Solars"
	icon_state = "LPS"

//DERELICT
/*
/area/derelict
	name = "\improper abandoned  Derelict Station"
	icon_state = "storage"

/area/derelict/hallway/primary
	name = "\improper abandoned  Derelict Primary Hallway"
	icon_state = "hallP"

/area/derelict/hallway/secondary
	name = "\improper abandoned  Derelict Secondary Hallway"
	icon_state = "hallS"

/area/derelict/arrival
	name = "\improper abandoned  Derelict Arrival Centre"
	icon_state = "yellow"

/area/derelict/storage/equipment
	name = "Derelict Equipment Storage"

/area/derelict/storage/storage_access
	name = "Derelict Storage Access"

/area/derelict/storage/engine_storage
	name = "Derelict Engine Storage"
	icon_state = "green"

/area/derelict/bridge
	name = "\improper abandoned  Derelict Control Room"
	icon_state = "bridge"

/area/derelict/secret
	name = "\improper abandoned  Derelict Secret Room"
	icon_state = "library"

/area/derelict/bridge/access
	name = "Derelict Control Room Access"
	icon_state = "auxstorage"

/area/derelict/bridge/ai_upload
	name = "\improper abandoned  Derelict Computer Core"
	icon_state = "ai"

/area/derelict/solar_control
	name = "\improper abandoned  Derelict Solar Control"
	icon_state = "engine"

/area/derelict/crew_quarters
	name = "\improper abandoned  Derelict Crew Quarters"
	icon_state = "fitness"

/area/derelict/medical
	name = "Derelict Medbay"
	icon_state = "medbay"

/area/derelict/medical/morgue
	name = "\improper abandoned  Derelict Morgue"
	icon_state = "morgue"

/area/derelict/medical/chapel
	name = "\improper abandoned  Derelict Chapel"
	icon_state = "chapel"

/area/derelict/teleporter
	name = "\improper abandoned  Derelict Teleporter"
	icon_state = "teleporter"

/area/derelict/eva
	name = "Derelict EVA Storage"
	icon_state = "eva"

/area/derelict/ship
	name = "\improper abandoned  Abandoned Ship"
	icon_state = "yellow"

/area/solar/derelict_starboard
	name = "\improper abandoned  Derelict Starboard Solar Array"
	icon_state = "panelsS"

/area/solar/derelict_aft
	name = "\improper abandoned  Derelict Aft Solar Array"
	icon_state = "aft"

/area/derelict/singularity_engine
	name = "\improper abandoned  Derelict Singularity Engine"
	icon_state = "engine"
*/
//HALF-BUILT STATION (REPLACES DERELICT IN BAYCODE, ABOVE IS LEFT FOR DOWNSTREAM)
/*
/area/shuttle/constructionsite
	name = "\improper abandoned  Construction Site Shuttle"
	icon_state = "yellow"

/area/shuttle/constructionsite/station
	name = "\improper abandoned  Construction Site Shuttle"

/area/shuttle/constructionsite/site
	name = "\improper abandoned  Construction Site Shuttle"

/area/constructionsite
	name = "\improper abandoned  Construction Site"
	icon_state = "storage"

/area/constructionsite/storage
	name = "\improper abandoned  Construction Site Storage Area"

/area/constructionsite/science
	name = "\improper abandoned  Construction Site Research"

/area/constructionsite/bridge
	name = "\improper abandoned  Construction Site Bridge"
	icon_state = "bridge"

/area/constructionsite/maintenance
	name = "\improper abandoned  Construction Site Maintenance"
	icon_state = "yellow"

/area/constructionsite/hallway/aft
	name = "\improper abandoned  Construction Site Aft Hallway"
	icon_state = "hallP"

/area/constructionsite/hallway/fore
	name = "\improper abandoned  Construction Site Fore Hallway"
	icon_state = "hallS"

/area/constructionsite/atmospherics
	name = "\improper abandoned  Construction Site Atmospherics"
	icon_state = "green"

/area/constructionsite/medical
	name = "\improper abandoned  Construction Site Medbay"
	icon_state = "medbay"

/area/constructionsite/ai
	name = "\improper abandoned  Construction Computer Core"
	icon_state = "ai"

/area/constructionsite/engineering
	name = "\improper abandoned  Construction Site Engine Bay"
	icon_state = "engine"

/area/solar/constructionsite
	name = "\improper abandoned  Construction Site Solars"
	icon_state = "aft"

//area/constructionsite
//	name = "\improper abandoned  Construction Site Shuttle"

//area/constructionsite
//	name = "\improper abandoned  Construction Site Shuttle"

*/
//Construction

/area/construction
	name = "\improper abandoned  Construction Area"
	icon_state = "yellow"

/area/construction/supplyshuttle
	name = "\improper abandoned  Supply Shuttle"
	icon_state = "yellow"

/area/construction/quarters
	name = "\improper abandoned  Engineer's Quarters"
	icon_state = "yellow"

/area/construction/qmaint
	name = "Maintenance"
	icon_state = "yellow"

/area/construction/hallway
	name = "\improper abandoned  Hallway"
	icon_state = "yellow"

/area/construction/solars
	name = "\improper abandoned  Solar Panels"
	icon_state = "yellow"

/area/construction/solarscontrol
	name = "\improper abandoned  Solar Panel Control"
	icon_state = "yellow"

/area/construction/Storage
	name = "Construction Site Storage"
	icon_state = "yellow"

//AI

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"

/area/turret_protected/ai_upload
	name = "\improper abandoned  AI Upload Chamber"
	icon_state = "ai_upload"
	ambience = list('sound/ambience/ambimalf.ogg')

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"
	ambience = list('sound/ambience/ambimalf.ogg')

/area/turret_protected/ai_server_room
	name = "AI Server Room"
	icon_state = "ai_server"

/area/turret_protected/ai
	name = "\improper abandoned  AI Chamber"
	icon_state = "ai_chamber"
	ambience = list('sound/ambience/ambimalf.ogg')

/area/turret_protected/ai_cyborg_station
	name = "\improper abandoned  Cyborg Station"
	icon_state = "ai_cyborg"

/area/turret_protected/aisat
	name = "\improper abandoned  AI Satellite"
	icon_state = "ai"


/////////////////////////////////////////////////////////////////////
/*
 Lists of areas to be used with is_type_in_list.
 Used in gamemodes code at the moment. --rastaf0
*/

// CENTCOM
var/list/centcom_areas = list (
	/area/centcom,
	/area/shuttle/escape/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod5/centcom,
	/area/shuttle/transport1/centcom,
	/area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
)

//SPACE STATION 13
var/list/the_station_areas = list (
	/area/shuttle/arrival,						//To be removed
	/area/shuttle/escape/station,				//To be removed
	/area/shuttle/escape_pod1/station,			//To be removed
	/area/shuttle/escape_pod2/station,			//To be removed
	/area/shuttle/escape_pod3/station,			//To be removed
	/area/shuttle/escape_pod5/station,			//To be removed
	/area/shuttle/mining/station,				//To be removed
	/area/shuttle/transport1/station,			//To be removed
//	/area/shuttle/transport2/station,
//	/area/shuttle/prison/station,				//To be removed
	/area/shuttle/administration/station,		//To be removed
	/area/shuttle/specops/station,				//To be removed
	/area/holodeck,								//To be removed
	/area/sulaco/cafeteria,
	/area/sulaco/cargo,
	/area/sulaco/engineering/storage,
	/area/sulaco/morgue,
	/area/sulaco/disposal,
	/area/sulaco/medbay/storage
)


