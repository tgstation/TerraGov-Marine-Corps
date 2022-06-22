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
	name = "Ice Colony"
	icon_state = "ice_colony"
	icon_state = "cliff_blocked"

/*
*  ----------------
* | Exterior Areas |
*  ----------------
*/

/area/ice_colony/exterior
	name = "Ice Colony"
	icon_state = "cliff_blocked"
	requires_power = TRUE
	always_unpowered = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	ambience = list('sound/ambience/ambispace.ogg')
	temperature = ICE_COLONY_TEMPERATURE
	minimap_color = MINIMAP_AREA_COLONY

/*
* Exterior - Surface
*/

//Rough color code for the surface exteriors
//Mountains : Deep Blue/Purple
//Valleys : Light Blue/Cyan
//Open Ground : Gray
//Buildings : Native Color. Command stays Blue, Clinic is Red

/area/ice_colony/exterior/surface
	name = "Ice Colony - Exterior Surface"


//Equivalent of space. None of this area should be accessible. If these are valleys, make separate areas
/area/ice_colony/exterior/surface/cliff
	name = "Ice Cliffs"
	icon_state = "cliff_blocked"

//Landing Pad for the Rasp. THIS IS NOT THE SHUTTLE AREA
/area/ice_colony/exterior/surface/landing_pad
	name = "Aerodrome Landing Pad"
	icon_state = "landing_pad"
	outside = FALSE
	always_unpowered = FALSE

//Landing Pad for the Vindi. THIS IS NOT THE SHUTTLE AREA
/area/ice_colony/exterior/surface/landing_pad2
	name = "Emergency Landing Pad"
	icon_state = "landing_pad"
	outside = FALSE
	always_unpowered = FALSE

//Everything around the physical landing pad
/area/ice_colony/exterior/surface/landing_pad_external
	name = "Aerodrome Landing Valley"
	icon_state = "landing_pad_ext"

//Aerodrome Container Yard
/area/ice_colony/exterior/surface/container_yard
	name = "Aerodrome Container Yard"
	icon_state = "container_yard"

//The FRONT of the aerodromes.
/area/ice_colony/exterior/surface/taxiway
	name = "Aerodrome Taxiway"
	icon_state = "landing_pad_taxiway"

//
// Valleys
// This is for all the areas mostly surrounded by mountains
// As of current, notably includes Excavation, Research, Requesition Storage, the North and Telecommunications
//

/area/ice_colony/exterior/surface/valley
	name = "Ice Cliffs Valley"
	icon_state = "valley"

/area/ice_colony/exterior/surface/valley/north
	name = "Northern Valleys"
	icon_state = "valley_north"

/area/ice_colony/exterior/surface/valley/northeast
	name = "North Eastern Valleys"
	icon_state = "valley_north_east"

/area/ice_colony/exterior/surface/valley/northwest
	name = "North Western Valleys"
	icon_state = "valley_north_west"

/area/ice_colony/exterior/surface/valley/west
	name = "Western Valleys"
	icon_state = "valley_west"

/area/ice_colony/exterior/surface/valley/south
	name = "Southern Valleys"
	icon_state = "valley_south"

/area/ice_colony/exterior/surface/valley/south/excavation
	name = "Southern Valleys - Excavation Site"
	icon_state = "valley_south_excv"
	ceiling = CEILING_UNDERGROUND

/area/ice_colony/exterior/surface/valley/southeast
	name = "Eastern Valleys"
	icon_state = "valley_east"

/area/ice_colony/exterior/surface/valley/southwest
	name = "South Western Valleys"
	icon_state = "valley_south_west"

//
// Clearing
// The Colony Center, so to speak
//

/area/ice_colony/exterior/surface/clearing
	name = "Ice Colony Clearing"
	icon_state = "clear"

/area/ice_colony/exterior/surface/clearing/pass
	name = "Colony Central Valley"
	icon_state = "clear_pass"

/area/ice_colony/exterior/surface/clearing/south
	name = "Colony Southern Clearing"
	icon_state = "clear_south"

/area/ice_colony/exterior/surface/clearing/north
	name = "Colony Northern Clearing"
	icon_state = "clear_north"

/*
* Exterior - Underground
*/

/area/ice_colony/exterior/underground
	name = "Ice Colony - Exterior Underground"
	icon_state = "cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES


//
// Caves
// Extremely simple, anything that is not built is a cave
// For style, we have two subtypes. Open, and dig site
// These do NOT have particular names
//

/area/ice_colony/exterior/underground/caves
	name = "Underground Caves"
	icon_state = "cave"

/area/ice_colony/exterior/underground/caves/ice_nw
	name = "North Western Ice Caves"
	icon_state = "icecave_nw"

/area/ice_colony/exterior/underground/caves/ice_se
	name = "South Eastern Ice Caves"
	icon_state = "icecave_se"

/area/ice_colony/exterior/underground/caves/ice_w
	name = "Western Ice Caves"
	icon_state = "icecave_w"

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
	name = "Ice Colony - Built Surface"
	icon_state = "clear"
	ceiling = CEILING_METAL
	outside = FALSE

/*
* Surface - Bar
*/


/area/ice_colony/surface/bar
	name = "Anti-Freeze"
	icon_state = "bar"

/area/ice_colony/surface/bar/bar
	name = "Anti-Freeze Bar"

/area/ice_colony/surface/bar/canteen
	name = "Anti-Freeze Canteen"
	icon_state = "kitchen"

/*
* Surface - Clinic
*/

/area/ice_colony/surface/clinic
	name = "Aurora Medical Clinic"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/ice_colony/surface/clinic/lobby
	name = "Aurora Medical Clinic Lobby"

/area/ice_colony/surface/clinic/treatment
	name = "Aurora Medical Clinic Treatment"
	icon_state = "medbay2"

/area/ice_colony/surface/clinic/storage
	name = "Aurora Medical Clinic Storage"
	icon_state = "medbay3"

/*
* Surface - Colony Administration
*/

/area/ice_colony/surface/command
	name = "Colony Administration"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_SEC

/area/ice_colony/surface/command/checkpoint
	name = "Colony Administration Security Checkpoint"
	icon_state = "security"

/area/ice_colony/surface/command/control
	name = "Colony Control Center"
	icon_state = "maintcentral"

/area/ice_colony/surface/command/control/office
	name = "Colony Control Central Office"
	icon_state = "bridge"

/area/ice_colony/surface/command/control/pv1
	name = "Colony Control Private Office"
	icon_state = "yellow"

/area/ice_colony/surface/command/control/pv2
	name = "Colony Control Private Office"
	icon_state = "green"

/area/ice_colony/surface/command/crisis
	name = "Colony Crisis Room"
	icon_state = "head_quarters"

/*
* Surface - Disposals
*/

/area/ice_colony/surface/disposals
	name = "Surface Disposals"
	icon_state = "disposal"

/*
* Surface - Dormitories
*/

/area/ice_colony/surface/dorms
	name = "Dormitories"
	icon_state = "Sleep"

/area/ice_colony/surface/dorms/canteen
	name = "Dormitories Canteen"
	icon_state = "kitchen"

/area/ice_colony/surface/dorms/lavatory
	name = "Dormitories Lavatory"
	icon_state = "janitor"

/area/ice_colony/surface/dorms/restroom_w
	name = "Dormitories West Restroom"
	icon_state = "toilet"

/area/ice_colony/surface/dorms/restroom_e
	name = "Dormitories East Restroom"
	icon_state = "toilet"

/*
* Surface - Engineering
*/

/area/ice_colony/surface/engineering
	name = "Engineering"
	icon_state = "engine_hallway"
	minimap_color = MINIMAP_AREA_ENGI

/area/ice_colony/surface/engineering/generator
	name = "Engineering Generator Room"
	icon_state = "engine"

/area/ice_colony/surface/engineering/electric
	name = "Engineering Electric Storage"
	icon_state = "engine_storage"

/area/ice_colony/surface/engineering/tool
	name = "Engineering Tool Storage"
	icon_state = "storage"

/*
* Surface - Excavation Preparation
*/

/area/ice_colony/surface/excavation
	name = "Excavation Outpost"
	icon_state = "mining_outpost"

/area/ice_colony/surface/excavationbarracks
	name = "Excavation Barracks"
	icon_state = "mining_outpost"

/area/ice_colony/surface/excavation/storage
	name = "Excavation Outpost External Storage"
	icon_state = "mining_storage"
	minimap_color = MINIMAP_AREA_ENGI

/*
* Surface - Garage
*/

/area/ice_colony/surface/garage
	name = "Garage"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_ENGI

/area/ice_colony/surface/garage/one
	name = "Garage Western Unit"
	icon_state = "garage_one"

/area/ice_colony/surface/garage/two
	name = "Garage Eastern Unit"
	icon_state = "garage_two"

/area/ice_colony/surface/garage/repair
	name = "Garage Repair Station"
	icon_state = "engine"

/*
* Surface - Hangar
*/

/area/ice_colony/surface/hangar
	name = "Aerodrome Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_SEC

/area/ice_colony/surface/hangar/hallway
	name = "Aerodrome Hangar Hallway"

/area/ice_colony/surface/hangar/alpha
	name = "Aerodrome Hangar 'Alpha'"
	icon_state = "hangar_alpha"

/area/ice_colony/surface/hangar/beta
	name = "Aerodrome Hangar 'Beta'"
	icon_state = "hangar_beta"

/area/ice_colony/surface/hangar/checkpoint
	name = "Aerodrome Hangar Security Checkpoint"
	icon_state = "security"

/*
* Surface - Hydroponics
*/

/area/ice_colony/surface/hydroponics
	name = "Ice Colony Hydroponics"
	icon_state = "hydro"
	ceiling = CEILING_GLASS

/area/ice_colony/surface/hydroponics/lobby
	name = "Hydroponics Relaxation Module"
	icon_state = "garden"

/area/ice_colony/surface/hydroponics/north
	name = "Hydroponics North Wing"
	icon_state = "hydro_north"

/area/ice_colony/surface/hydroponics/south
	name = "Hydroponics South Wing"
	icon_state = "hydro_south"

/*
* Surface - Mining
*/

/area/ice_colony/surface/mining
	name = "Mining Outpost"
	icon_state = "mining_production"

/*
* Surface - Power
*/

/area/ice_colony/surface/substation
	name = "Surface Power Substation"
	icon_state = "dk_yellow"

/area/ice_colony/surface/substation/smes
	name = "Surface Power Substation SMES"
	icon_state = "substation"

/*
* Surface - Requesitions
*/

/area/ice_colony/surface/requesitions
	name = "Surface Requesition Warehouse"
	icon_state = "quartstorage"
	minimap_color = MINIMAP_AREA_ENGI

/*
* Surface - Research
*/

/area/ice_colony/surface/research

	name = "Omicron Dome"
	icon_state = "toxlab"

/area/ice_colony/surface/research/tech_storage
	name = "Omicron Dome Technical Storage"
	icon_state = "primarystorage"

/area/ice_colony/surface/research/field_gear
	name = "Omicron Dome Field Gear Storage"
	icon_state = "eva"

/area/ice_colony/surface/research/temporary
	name = "Omicron Dome Temporary Storage"
	icon_state = "storage"

/*
* Surface - Storage Units
*/

/area/ice_colony/surface/storage_unit
	name = "Storage Unit"
	icon_state = "storage"

/area/ice_colony/surface/storage_unit/research
	name = "Storage Unit Research"
	icon_state = "storage"

/area/ice_colony/surface/storage_unit/telecomms
	name = "Storage Unit T-Comms"
	icon_state = "storage"

/area/ice_colony/surface/storage_unit/power
	name = "Storage Unit Power"
	icon_state = "storage"

/*
* Surface - Telecommunications
*/

/area/ice_colony/surface/tcomms
	name = "Colony Telecommunications"
	icon_state = "tcomsatcham"

/*
*  -------------------------
* | Built Underground Areas |
*  -------------------------
*/

/area/ice_colony/underground
	name = "Ice Colony - Built Underground"
	icon_state = "explored"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	outside = FALSE

/*
* Underground - Crew Areas
*/

/area/ice_colony/underground/crew
	name = "Underground Crew Area"
	icon_state = "crew_quarters"

/area/ice_colony/underground/crew/dorm_l
	name = "West Dormitory"
	icon_state = "Sleep"

/area/ice_colony/underground/crew/dorm_r
	name = "East Dormitory"
	icon_state = "Sleep"

/area/ice_colony/underground/crew/canteen
	name = "Underground Canteen"
	icon_state = "kitchen"

/area/ice_colony/underground/crew/disposals
	name = "Underground Disposals"
	icon_state = "disposal"

/area/ice_colony/underground/crew/lavatory
	name = "Underground Lavatory"
	icon_state = "janitor"

/area/ice_colony/underground/crew/leisure
	name = "Underground Leisure Area"

/area/ice_colony/underground/crew/bball
	name = "Underground Sports Center"

/area/ice_colony/underground/crew/chapel
	name = "Underground Chapel"

/area/ice_colony/underground/crew/library
	name = "Underground Library"
	icon_state = "library"

/area/ice_colony/underground/crew/morgue
	name = "Underground Morgue"
	icon_state = "morgue"

/*
* Underground - Colony Administration
*/

/area/ice_colony/underground/command
	name = "Underground Colonial Administration"
	icon_state = "bridge"

/area/ice_colony/underground/command/checkpoint
	name = "Underground Colonial Administration Lobby"
	icon_state = "security"

/area/ice_colony/underground/command/center
	name = "Underground Colonial Administration Command Center"
	icon_state = "head_quarters"

/area/ice_colony/underground/command/pv1
	name = "Underground Colonial Administration Private Office"
	icon_state = "yellow"

/area/ice_colony/underground/command/pv2
	name = "Underground Colonial Administration Private Office"
	icon_state = "green"

/*
* Underground - Engineering
*/

/area/ice_colony/underground/engineering
	name = "Underground Engineering"
	icon_state = "engine_hallway"

/area/ice_colony/underground/engineering/locker
	name = "Underground Engineering Locker Room"
	icon_state = "storage"


/area/ice_colony/underground/engineering/substation
	name = "Underground Power Substation"
	icon_state = "substation"

/*
* Underground - Hallways
*/

/area/ice_colony/underground/hallway
	name = "Underground Hallway"
	icon_state = "hallC1"

/area/ice_colony/underground/hallway/north_west
	name = "Underground Hallway NW"

/area/ice_colony/underground/hallway/south_east
	name = "Underground Hallway SE"
	icon_state = "hallF"

/*
* Underground - Maintenance
*/

/area/ice_colony/underground/maintenance
	name = "Underground Maintenance"
	icon_state = "maintcentral"

/area/ice_colony/underground/maintenance/central
	name = "Underground Central Maintenance"

/area/ice_colony/underground/maintenance/central/construction
	name = "Underground Central Maintenance Project"
	icon_state = "construction"

/area/ice_colony/underground/maintenance/security
	name = "Underground Security Maintenance"
	icon_state = "maint_security_port"

/area/ice_colony/underground/maintenance/engineering
	name = "Underground Engineering Maintenance"
	icon_state = "maint_engineering"

/area/ice_colony/underground/maintenance/research
	name = "Underground Research Maintenance"
	icon_state = "maint_research_port"

/area/ice_colony/underground/maintenance/east
	name = "Underground Eastern Maintenance"
	icon_state = "fmaint"

/area/ice_colony/underground/maintenance/south
	name = "Underground Southern Maintenance"
	icon_state = "asmaint"

/area/ice_colony/underground/maintenance/north
	name = "Underground Northern Maintenance"
	icon_state = "asmaint"

/*
* Underground - Medbay
*/

/area/ice_colony/underground/medical
	name = "Underground Medical Laboratory"
	icon_state = "medbay"

/area/ice_colony/underground/medical/lobby
	name = "Underground Medical Laboratory Lobby"

/area/ice_colony/underground/medical/hallway
	name = "Underground Medical Laboratory Hallway"
	icon_state = "medbay2"

/area/ice_colony/underground/medical/storage
	name = "Underground Medical Laboratory Storage"
	icon_state = "storage"

/area/ice_colony/underground/medical/treatment
	name = "Underground Medical Laboratory Treatment"
	icon_state = "medbay3"

/area/ice_colony/underground/medical/or
	name = "Underground Medical Laboratory Operating Room"
	icon_state = "surgery"

/*
* Underground - Reception
*/

/area/ice_colony/underground/reception
	name = "Underground Reception"
	icon_state = "showroom"

/area/ice_colony/underground/reception/checkpoint_north
	name = "Underground Reception Northern Security Checkpoint"
	icon_state = "security"

/area/ice_colony/underground/reception/checkpoint_south
	name = "Underground Reception Southern Security Checkpoint"
	icon_state = "security"

/area/ice_colony/underground/reception/toilet_men
	name = "Underground Reception Men's Restroom"
	icon_state = "toilet"

/area/ice_colony/underground/reception/toilet_women
	name = "Underground Reception Women's Restroom"
	icon_state = "toilet"

/*
* Underground - Requesition
*/

/area/ice_colony/underground/requesition
	name = "Underground Requesitions"
	icon_state = "quart"

/area/ice_colony/underground/requesition/lobby
	name = "Underground Requesitions Lobby"
	icon_state = "quartoffice"

/area/ice_colony/underground/requesition/storage
	name = "Underground Requesitions Storage"
	icon_state = "quartstorage"

/area/ice_colony/underground/requesition/sec_storage
	name = "Underground Requesitions Secure Storage"
	icon_state = "storage"

/*
* Underground - Research
*/

/area/ice_colony/underground/research
	name = "Theta-V Research Laboratory"
	icon_state = "anolab"

/area/ice_colony/underground/research/work
	name = "Theta-V Research Laboratory Work Station"
	icon_state = "toxmix"

/area/ice_colony/underground/research/storage
	name = "Theta-V Research Laboratory Storage"
	icon_state = "storage"

/area/ice_colony/underground/research/sample
	name = "Theta-V Research Laboratory Sample Isolation"
	icon_state = "anosample"

/*
* Underground - Security
*/

/area/ice_colony/underground/security
	name = "Underground Security Center"
	icon_state = "security"

/area/ice_colony/underground/security/marshal
	name = "Marshal's Office"
	icon_state = "sec_hos"

/area/ice_colony/underground/security/detective
	name = "Detective's Office"
	icon_state = "detective"

/area/ice_colony/underground/security/interrogation
	name = "Interrogation Office"
	icon_state = "interrogation"

/area/ice_colony/underground/security/backroom
	name = "Underground Security Center Custodial Closet"
	icon_state = "sec_backroom"

/area/ice_colony/underground/security/hallway
	name = "Underground Security Center Hallway"
	icon_state = "checkpoint1"

/area/ice_colony/underground/security/armory
	name = "Underground Security Center Armory"
	icon_state = "armory"

/area/ice_colony/underground/security/brig
	name = "Underground Security Center Brig"
	icon_state = "brig"

/*
* Underground - Hangar
*/

/area/ice_colony/underground/hangar
	name = "Underground Hangar"
	icon_state = "hangar"
	ceiling = CEILING_NONE

/area/ice_colony/underground/responsehangar
	name = "Colony Response Team Hangar"

/area/ice_colony/underground/westroadtunnel
	name = "West Road Tunnel"

/*
* Underground - Storage
*/

/area/ice_colony/underground/storage
	name = "Underground Technical Storage"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_ENGI

/area/ice_colony/underground/storage/highsec
	name = "Underground High Security Technical Storage"
	icon_state = "armory"
