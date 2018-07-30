/*
 * Areas for the Ice Colony map (nickname is "Shiva's Snowball")
 * Area inheritance logic :
 * Exterior Areas all use the same code, under /exterior branch. Those are NOT homogenous but used to give rough locations to area scanners. THIS INCLUDES UNDERGROUND UNBUILT AREAS
 * Exterior is divided into /surface and /underground for ease of navigation. BOTH PATHS MUST INHERIT EXTERIOR
 * Otherwise, all areas on the surface excluding external areas use /surface, no exceptions. All areas underground use /underground, no exceptions
 * Areas are grouped by building if possible, this excludes some repeating buildings like storage units
 * ELEVATORS AND SHUTTLES ARE SEGREGATED AT THE END OF THE FILE IF APPLICABLE
 */

//Base Instance
/area/ice_colony
	name = "\improper Ice Colony"
	icon_state = "ice_colony"
	icon_state = "cliff_blocked"

/*
 *  ----------------
 * | Exterior Areas |
 *  ----------------
 */

/area/ice_colony/exterior
	name = "\improper Ice Colony"
	icon_state = "cliff_blocked"
	requires_power = 1
	always_unpowered = 1
	lighting_use_dynamic = 1
	power_light = 0
	power_equip = 0
	power_environ = 0
	ambience = list('sound/ambience/ambispace.ogg')
	temperature = ICE_COLONY_TEMPERATURE

/*
 * Exterior - Surface
 */

//Rough color code for the surface exteriors
//Mountains : Deep Blue/Purple
//Valleys : Light Blue/Cyan
//Open Ground : Gray
//Buildings : Native Color. Command stays Blue, Clinic is Red

/area/ice_colony/exterior/surface
	name = "\improper Ice Colony - Exterior Surface"
	fake_zlevel = 1 // above ground

//Equivalent of space. None of this area should be accessible. If these are valleys, make separate areas
/area/ice_colony/exterior/surface/cliff
	name = "\improper Ice Cliffs"
	icon_state = "cliff_blocked"

//Landing Pad for the Rasp. THIS IS NOT THE SHUTTLE AREA
/area/ice_colony/exterior/surface/landing_pad
	name = "\improper Aerodrome Landing Pad"
	icon_state = "landing_pad"

//Landing Pad for the Vindi. THIS IS NOT THE SHUTTLE AREA
/area/ice_colony/exterior/surface/landing_pad2
	name = "\improper Emergency Landing Pad"
	icon_state = "landing_pad"


//Everything around the physical landing pad
/area/ice_colony/exterior/surface/landing_pad_external
	name = "\improper Aerodrome Landing Valley"
	icon_state = "landing_pad_ext"

//Aerodrome Container Yard
/area/ice_colony/exterior/surface/container_yard
	name = "\improper Aerodrome Container Yard"
	icon_state = "container_yard"

//
// Valleys
// This is for all the areas mostly surrounded by mountains
// As of current, notably includes Excavation, Research, Requesition Storage, the North and Telecommunications
//

/area/ice_colony/exterior/surface/valley
	name = "\improper Ice Cliffs Valley"
	icon_state = "valley"

/area/ice_colony/exterior/surface/valley/north
	name = "\improper Northern Valleys"
	icon_state = "valley_north"

/area/ice_colony/exterior/surface/valley/northeast
	name = "\improper North Eastern Valleys"
	icon_state = "valley_north_east"

/area/ice_colony/exterior/surface/valley/northwest
	name = "\improper North Western Valleys"
	icon_state = "valley_north_west"

/area/ice_colony/exterior/surface/valley/west
	name = "\improper Western Valleys"
	icon_state = "valley_west"

/area/ice_colony/exterior/surface/valley/south
	name = "\improper Southern Valleys"
	icon_state = "valley_south"

/area/ice_colony/exterior/surface/valley/south/excavation
	name = "\improper Southern Valleys - Excavation Site"
	icon_state = "valley_south_excv"
	ceiling = CEILING_UNDERGROUND

/area/ice_colony/exterior/surface/valley/southeast
	name = "\improper Eastern Valleys"
	icon_state = "valley_east"

/area/ice_colony/exterior/surface/valley/southwest
	name = "\improper South Western Valleys"
	icon_state = "valley_south_west"

//
// Clearing
// The Colony Center, so to speak
//

/area/ice_colony/exterior/surface/clearing
	name = "\improper Ice Colony Clearing"
	icon_state = "clear"

/area/ice_colony/exterior/surface/clearing/pass
	name = "\improper Colony Central Valley"
	icon_state = "clear_pass"

/area/ice_colony/exterior/surface/clearing/south
	name = "\improper Colony Southern Clearing"
	icon_state = "clear_south"

/area/ice_colony/exterior/surface/clearing/north
	name = "\improper Colony Northern Clearing"
	icon_state = "clear_north"

/*
 * Exterior - Underground
 */

/area/ice_colony/exterior/underground
	name = "\improper Ice Colony - Exterior Underground"
	icon_state = "cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	fake_zlevel = 2 // underground

//
// Caves
// Extremely simple, anything that is not built is a cave
// For style, we have two subtypes. Open, and dig site
// These do NOT have particular names
//

/area/ice_colony/exterior/underground/caves
	name = "\improper Underground Caves"
	icon_state = "cave"

/area/ice_colony/exterior/underground/caves/open
	icon_state = "explored"

/area/ice_colony/exterior/underground/caves/dig
	icon_state = "mining_living"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL


/*
 *  ---------------------
 * | Built Surface Areas |
 *  ---------------------
 */

/area/ice_colony/surface
	name = "\improper Ice Colony - Built Surface"
	icon_state = "clear"
	ceiling = CEILING_METAL
	fake_zlevel = 1 // above ground

/*
 * Surface - Bar
 */


/area/ice_colony/surface/bar
	name = "\improper Anti-Freeze"
	icon_state = "bar"

/area/ice_colony/surface/bar/bar
	name = "\improper Anti-Freeze Bar"

/area/ice_colony/surface/bar/canteen
	name = "\improper Anti-Freeze Canteen"
	icon_state = "kitchen"

/*
 * Surface - Clinic
 */

/area/ice_colony/surface/clinic
	name = "\improper Aurora Medical Clinic"
	icon_state = "medbay"

/area/ice_colony/surface/clinic/lobby
	name = "\improper Aurora Medical Clinic Lobby"

/area/ice_colony/surface/clinic/treatment
	name = "\improper Aurora Medical Clinic Treatment"
	icon_state = "medbay2"

/area/ice_colony/surface/clinic/storage
	name = "\improper Aurora Medical Clinic Storage"
	icon_state = "medbay3"

/*
 * Surface - Colony Administration
 */

/area/ice_colony/surface/command
	name = "\improper Colony Administration"
	icon_state = "bridge"

/area/ice_colony/surface/command/checkpoint
	name = "\improper Colony Administration Security Checkpoint"
	icon_state = "security"

/area/ice_colony/surface/command/control
	name = "\improper Colony Control Center"
	icon_state = "maintcentral"

/area/ice_colony/surface/command/control/office
	name = "\improper Colony Control Central Office"
	icon_state = "bridge"

/area/ice_colony/surface/command/control/pv1
	name = "\improper Colony Control Private Office"
	icon_state = "yellow"

/area/ice_colony/surface/command/control/pv2
	name = "\improper Colony Control Private Office"
	icon_state = "green"

/area/ice_colony/surface/command/crisis
	name = "\improper Colony Crisis Room"
	icon_state = "head_quarters"

/*
 * Surface - Disposals
 */

/area/ice_colony/surface/disposals
	name = "\improper Surface Disposals"
	icon_state = "disposal"

/*
 * Surface - Dormitories
 */

/area/ice_colony/surface/dorms
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/ice_colony/surface/dorms/canteen
	name = "\improper Dormitories Canteen"
	icon_state = "kitchen"

/area/ice_colony/surface/dorms/lavatory
	name = "\improper Dormitories Lavatory"
	icon_state = "janitor"

/area/ice_colony/surface/dorms/restroom_w
	name = "\improper Dormitories West Restroom"
	icon_state = "toilet"

/area/ice_colony/surface/dorms/restroom_e
	name = "\improper Dormitories East Restroom"
	icon_state = "toilet"

/*
 * Surface - Engineering
 */

/area/ice_colony/surface/engineering
	name = "\improper Engineering"
	icon_state = "engine_hallway"

/area/ice_colony/surface/engineering/generator
	name = "\improper Engineering Generator Room"
	icon_state = "engine"

/area/ice_colony/surface/engineering/electric
	name = "\improper Engineering Electric Storage"
	icon_state = "engine_storage"

/area/ice_colony/surface/engineering/tool
	name = "\improper Engineering Tool Storage"
	icon_state = "storage"

/*
 * Surface - Excavation Preparation
 */

/area/ice_colony/surface/excavation
	name = "\improper Excavation Outpost"
	icon_state = "mining_outpost"

/area/ice_colony/surface/excavation/storage
	name = "\improper Excavation Outpost External Storage"
	icon_state = "mining_storage"

/*
 * Surface - Garage
 */

/area/ice_colony/surface/garage
	name = "\improper Garage"
	icon_state = "garage"

/area/ice_colony/surface/garage/one
	name = "\improper Garage Western Unit"
	icon_state = "garage_one"

/area/ice_colony/surface/garage/two
	name = "\improper Garage Eastern Unit"
	icon_state = "garage_two"

/area/ice_colony/surface/garage/repair
	name = "\improper Garage Repair Station"
	icon_state = "engine"

/*
 * Surface - Hangar
 */

/area/ice_colony/surface/hangar
	name = "\improper Aerodrome Hangar"
	icon_state = "hangar"

/area/ice_colony/surface/hangar/hallway
	name = "\improper Aerodrome Hangar Hallway"

/area/ice_colony/surface/hangar/alpha
	name = "\improper Aerodrome Hangar 'Alpha'"
	icon_state = "hangar_alpha"

/area/ice_colony/surface/hangar/beta
	name = "\improper Aerodrome Hangar 'Beta'"
	icon_state = "hangar_beta"

/area/ice_colony/surface/hangar/checkpoint
	name = "\improper Aerodrome Hangar Security Checkpoint"
	icon_state = "security"

/*
 * Surface - Hydroponics
 */

/area/ice_colony/surface/hydroponics
	name = "\improper Ice Colony Hydroponics"
	icon_state = "hydro"
	ceiling = CEILING_GLASS

/area/ice_colony/surface/hydroponics/lobby
	name = "\improper Hydroponics Relaxation Module"
	icon_state = "garden"

/area/ice_colony/surface/hydroponics/north
	name = "\improper Hydroponics North Wing"
	icon_state = "hydro_north"

/area/ice_colony/surface/hydroponics/south
	name = "\improper Hydroponics South Wing"
	icon_state = "hydro_south"

/*
 * Surface - Mining
 */

/area/ice_colony/surface/mining
	name = "\improper Mining Outpost"
	icon_state = "mining_production"

/*
 * Surface - Power
 */

/area/ice_colony/surface/substation
	name = "\improper Surface Power Substation"
	icon_state = "dk_yellow"

/area/ice_colony/surface/substation/smes
	name = "\improper Surface Power Substation SMES"
	icon_state = "substation"

/*
 * Surface - Requesitions
 */

/area/ice_colony/surface/requesitions
	name = "\improper Surface Requesition Warehouse"
	icon_state = "quartstorage"

/*
 * Surface - Research
 */

/area/ice_colony/surface/research

	name = "\improper Omicron Dome"
	icon_state = "toxlab"

/area/ice_colony/surface/research/tech_storage
	name = "\improper Omicron Dome Technical Storage"
	icon_state = "primarystorage"

/area/ice_colony/surface/research/field_gear
	name = "\improper Omicron Dome Field Gear Storage"
	icon_state = "eva"

/area/ice_colony/surface/research/temporary
	name = "\improper Omicron Dome Temporary Storage"
	icon_state = "storage"

/*
 * Surface - Storage Units
 */

/area/ice_colony/surface/storage_unit
	name = "\improper Storage Unit"
	icon_state = "storage"

/area/ice_colony/surface/storage_unit/research
	name = "\improper Storage Unit Research"
	icon_state = "storage"

/area/ice_colony/surface/storage_unit/telecomms
	name = "\improper Storage Unit T-Comms"
	icon_state = "storage"

/area/ice_colony/surface/storage_unit/power
	name = "\improper Storage Unit Power"
	icon_state = "storage"

/*
 * Surface - Telecommunications
 */

/area/ice_colony/surface/tcomms
	name = "\improper Colony Telecommunications"
	icon_state = "tcomsatcham"

/*
 *  -------------------------
 * | Built Underground Areas |
 *  -------------------------
 */

/area/ice_colony/underground
	name = "\improper Ice Colony - Built Underground"
	icon_state = "explored"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	fake_zlevel = 2 // underground

/*
 * Underground - Crew Areas
 */

/area/ice_colony/underground/crew
	name = "\improper Underground Crew Area"
	icon_state = "crew_quarters"

/area/ice_colony/underground/crew/dorm_l
	name = "\improper West Dormitory"
	icon_state = "Sleep"

/area/ice_colony/underground/crew/dorm_r
	name = "\improper East Dormitory"
	icon_state = "Sleep"

/area/ice_colony/underground/crew/canteen
	name = "\improper Underground Canteen"
	icon_state = "kitchen"

/area/ice_colony/underground/crew/disposals
	name = "\improper Underground Disposals"
	icon_state = "disposal"

/area/ice_colony/underground/crew/lavatory
	name = "\improper Underground Lavatory"
	icon_state = "janitor"

/area/ice_colony/underground/crew/leisure
	name = "\improper Underground Leisure Area"

/area/ice_colony/underground/crew/bball
	name = "\improper Underground Sports Center"

/area/ice_colony/underground/crew/chapel
	name = "\improper Underground Chapel"

/area/ice_colony/underground/crew/library
	name = "\improper Underground Library"
	icon_state = "library"

/area/ice_colony/underground/crew/morgue
	name = "\improper Underground Morgue"
	icon_state = "morgue"

/*
 * Underground - Colony Administration
 */

/area/ice_colony/underground/command
	name = "\improper Underground Colonial Administration"
	icon_state = "bridge"

/area/ice_colony/underground/command/checkpoint
	name = "\improper Underground Colonial Administration Lobby"
	icon_state = "security"

/area/ice_colony/underground/command/center
	name = "\improper Underground Colonial Administration Command Center"
	icon_state = "head_quarters"

/area/ice_colony/underground/command/pv1
	name = "\improper Underground Colonial Administration Private Office"
	icon_state = "yellow"

/area/ice_colony/underground/command/pv2
	name = "\improper Underground Colonial Administration Private Office"
	icon_state = "green"

/*
 * Underground - Engineering
 */

/area/ice_colony/underground/engineering
	name = "\improper Underground Engineering"
	icon_state = "engine_hallway"

/area/ice_colony/underground/engineering/locker
	name = "\improper Underground Engineering Locker Room"
	icon_state = "storage"


/area/ice_colony/underground/engineering/substation
	name = "\improper Underground Power Substation"
	icon_state = "substation"

/*
 * Underground - Hallways
 */

/area/ice_colony/underground/hallway
	name = "\improper Underground Hallway"
	icon_state = "hallC1"

/area/ice_colony/underground/hallway/north_west
	name = "\improper Underground Hallway NW"

/area/ice_colony/underground/hallway/south_east
	name = "\improper Underground Hallway SE"
	icon_state = "hallF"

/*
 * Underground - Maintenance
 */

/area/ice_colony/underground/maintenance
	name = "\improper Underground Maintenance"
	icon_state = "maintcentral"

/area/ice_colony/underground/maintenance/central
	name = "\improper Underground Central Maintenance"

/area/ice_colony/underground/maintenance/central/construction
	name = "\improper Underground Central Maintenance Project"
	icon_state = "construction"

/area/ice_colony/underground/maintenance/security
	name = "\improper Underground Security Maintenance"
	icon_state = "maint_security_port"

/area/ice_colony/underground/maintenance/engineering
	name = "\improper Underground Engineering Maintenance"
	icon_state = "maint_engineering"

/area/ice_colony/underground/maintenance/research
	name = "\improper Underground Research Maintenance"
	icon_state = "maint_research_port"

/area/ice_colony/underground/maintenance/east
	name = "\improper Underground Eastern Maintenance"
	icon_state = "fmaint"

/area/ice_colony/underground/maintenance/south
	name = "\improper Underground Southern Maintenance"
	icon_state = "asmaint"

/area/ice_colony/underground/maintenance/north
	name = "\improper Underground Northern Maintenance"
	icon_state = "asmaint"

/*
 * Underground - Medbay
 */

/area/ice_colony/underground/medical
	name = "\improper Underground Medical Laboratory"
	icon_state = "medbay"

/area/ice_colony/underground/medical/lobby
	name = "\improper Underground Medical Laboratory Lobby"

/area/ice_colony/underground/medical/hallway
	name = "\improper Underground Medical Laboratory Hallway"
	icon_state = "medbay2"

/area/ice_colony/underground/medical/storage
	name = "\improper Underground Medical Laboratory Storage"
	icon_state = "storage"

/area/ice_colony/underground/medical/treatment
	name = "\improper Underground Medical Laboratory Treatment"
	icon_state = "medbay3"

/area/ice_colony/underground/medical/or
	name = "\improper Underground Medical Laboratory Operating Room"
	icon_state = "surgery"

/*
 * Underground - Reception
 */

/area/ice_colony/underground/reception
	name = "\improper Underground Reception"
	icon_state = "showroom"

/area/ice_colony/underground/reception/checkpoint_north
	name = "\improper Underground Reception Northern Security Checkpoint"
	icon_state = "security"

/area/ice_colony/underground/reception/checkpoint_south
	name = "\improper Underground Reception Southern Security Checkpoint"
	icon_state = "security"

/area/ice_colony/underground/reception/toilet_men
	name = "\improper Underground Reception Men's Restroom"
	icon_state = "toilet"

/area/ice_colony/underground/reception/toilet_women
	name = "\improper Underground Reception Women's Restroom"
	icon_state = "toilet"

/*
 * Underground - Requesition
 */

/area/ice_colony/underground/requesition
	name = "\improper Underground Requesitions"
	icon_state = "quart"

/area/ice_colony/underground/requesition/lobby
	name = "\improper Underground Requesitions Lobby"
	icon_state = "quartoffice"

/area/ice_colony/underground/requesition/storage
	name = "\improper Underground Requesitions Storage"
	icon_state = "quartstorage"

/area/ice_colony/underground/requesition/sec_storage
	name = "\improper Underground Requesitions Secure Storage"
	icon_state = "storage"

/*
 * Underground - Research
 */

/area/ice_colony/underground/research
	name = "\improper Theta-V Research Laboratory"
	icon_state = "anolab"

/area/ice_colony/underground/research/work
	name = "\improper Theta-V Research Laboratory Work Station"
	icon_state = "toxmix"

/area/ice_colony/underground/research/storage
	name = "\improper Theta-V Research Laboratory Storage"
	icon_state = "storage"

/area/ice_colony/underground/research/sample
	name = "\improper Theta-V Research Laboratory Sample Isolation"
	icon_state = "anosample"

/*
 * Underground - Security
 */

/area/ice_colony/underground/security
	name = "\improper Underground Security Center"
	icon_state = "security"

/area/ice_colony/underground/security/marshal
	name = "\improper Marshal's Office"
	icon_state = "sec_hos"

/area/ice_colony/underground/security/detective
	name = "\improper Detective's Office"
	icon_state = "detective"

/area/ice_colony/underground/security/interrogation
	name = "\improper Interrogation Office"
	icon_state = "interrogation"

/area/ice_colony/underground/security/backroom
	name = "\improper Underground Security Center Custodial Closet"
	icon_state = "sec_backroom"

/area/ice_colony/underground/security/hallway
	name = "\improper Underground Security Center Hallway"
	icon_state = "checkpoint1"

/area/ice_colony/underground/security/armory
	name = "\improper Underground Security Center Armory"
	icon_state = "armory"

/area/ice_colony/underground/security/brig
	name = "\improper Underground Security Center Brig"
	icon_state = "brig"

/*
 * Underground - Hangar
 */

/area/ice_colony/underground/hangar
	name = "\improper Underground Hangar"
	icon_state = "hangar"
	ceiling = CEILING_NONE

/*
 * Underground - Storage
 */

/area/ice_colony/underground/storage
	name = "\improper Underground Technical Storage"
	icon_state = "storage"

/area/ice_colony/underground/storage/highsec
	name = "\improper Underground High Security Technical Storage"
	icon_state = "armory"

//Elevator-------
/area/shuttle/elevator1/ground
	name = "\improper Elevator I"
	icon_state = "shuttlered"

/area/shuttle/elevator1/underground
	name = "\improper Elevator I"
	icon_state = "shuttle"

/area/shuttle/elevator1/transit
	name = "\improper Elevator I"
	icon_state = "shuttle2"

/area/shuttle/elevator2/ground
	name = "\improper Elevator II"
	icon_state = "shuttle"

/area/shuttle/elevator2/underground
	name = "\improper Elevator II"
	icon_state = "shuttle2"

/area/shuttle/elevator2/transit
	name = "\improper Elevator II"
	icon_state = "shuttlered"

/area/shuttle/elevator3/ground
	name = "\improper Elevator III"
	icon_state = "shuttle"

/area/shuttle/elevator3/underground
	name = "\improper Elevator III"
	icon_state = "shuttle2"

/area/shuttle/elevator3/transit
	name = "\improper Elevator III"
	icon_state = "shuttlered"

/area/shuttle/elevator4/ground
	name = "\improper Elevator IV"
	icon_state = "shuttlered"

/area/shuttle/elevator4/underground
	name = "\improper Elevator IV"
	icon_state = "shuttle"

/area/shuttle/elevator4/transit
	name = "\improper Elevator IV"
	icon_state = "shuttle2"
