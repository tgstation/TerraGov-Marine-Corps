//Base Instance
/area/desert_dam
	name = "Desert Dam"
	icon_state = "cliff_blocked"

//INTERIOR
// areas under rock
/area/desert_dam/interior
	ceiling = CEILING_METAL
	outside = FALSE
//NorthEastern Lab Section
/area/desert_dam/interior/lab_northeast
	ceiling = CEILING_DEEP_UNDERGROUND
/area/desert_dam/interior/lab_northeast
	name = "Northeastern Lab"
	icon_state = "purple"
/area/desert_dam/interior/lab_northeast/east_lab_lobby
	name = "East Lab Lobby"
	icon_state = "green"
/area/desert_dam/interior/lab_northeast/east_lab_west_hallway
	name = "East Lab Western Hallway"
	icon_state = "blue"
/area/desert_dam/interior/lab_northeast/east_lab_central_hallway
	name = "East Lab Central Hallway"
	icon_state = "green"
/area/desert_dam/interior/lab_northeast/east_lab_east_hallway
	name = "East Lab East Hallway"
	icon_state = "yellow"
/area/desert_dam/interior/lab_northeast/east_lab_workshop
	name = "East Lab Workshop"
	icon_state = "ass_line"
/area/desert_dam/interior/lab_northeast/east_lab_storage
	name = "East Lab Storage "
	icon_state = "storage"
/area/desert_dam/interior/lab_northeast/east_lab_RD_office
	name = "East Lab Research Director's Office"
	icon_state = "yellow"
/area/desert_dam/interior/lab_northeast/east_lab_maintenence
	name = "East Lab Maintenence"
	icon_state = "maintcentral"
/area/desert_dam/interior/lab_northeast/east_lab_containment
	name = "East Lab Containment"
	icon_state = "purple"
/area/desert_dam/interior/lab_northeast/east_lab_RND
	name = "East Lab Research and Development"
	icon_state = "purple"
/area/desert_dam/interior/lab_northeast/east_lab_biology
	name = "East Lab Biology"
	icon_state = "purple"
/area/desert_dam/interior/lab_northeast/east_lab_surgery
	name = "East Lab Surgery"
	icon_state = "red"
/area/desert_dam/interior/lab_northeast/east_lab_excavation
	name = "East Lab Excavation Prep"
	icon_state = "blue"
/area/desert_dam/interior/lab_northeast/east_lab_west_entrance
	name = "East Lab West Entrance"
	icon_state = "purple"
/area/desert_dam/interior/lab_northeast/east_lab_east_entrance
	name = "East Lab Entrance"
	icon_state = "purple"
/area/desert_dam/interior/lab_northeast/east_lab_security_checkpoint
	name = "East Lab Security Checkpoint"
	icon_state = "purple"
/area/desert_dam/interior/lab_northeast/east_lab_security_office
	name = "East Lab Security Office"
	icon_state = "security"
/area/desert_dam/interior/lab_northeast/east_lab_security_armory
	name = "East Lab Armory"
	icon_state = "armory"
/area/desert_dam/interior/lab_northeast/east_lab_xenobiology
	name = "East Lab Xenobiology"
	icon_state = "red"

//Dam Interior
/area/desert_dam/interior/dam_interior
	minimap_color = MINIMAP_AREA_ENGI
	outside = FALSE
/area/desert_dam/interior/dam_interior/engine_room
	name = "Engineering Generator Room"
	icon_state = "yellow"
/area/desert_dam/interior/dam_interior/control_room
	name = "Engineering Control Room"
	icon_state = "red"
/area/desert_dam/interior/dam_interior/smes_main
	name = "Engineering Main Substation"
	icon_state = "purple"
/area/desert_dam/interior/dam_interior/smes_backup
	name = "Engineering Secondary Backup Substation"
	icon_state = "green"
/area/desert_dam/interior/dam_interior/engine_east_wing
	name = "Engineering East Engine Wing"
	icon_state = "blue-red"
/area/desert_dam/interior/dam_interior/engine_west_wing
	name = "Engineering West Engine Wing"
	icon_state = "yellow"
/area/desert_dam/interior/dam_interior/lobby
	name = "Engineering Lobby"
	icon_state = "purple"
/area/desert_dam/interior/dam_interior/atmos_storage
	name = "Engineering Atmospheric Storage"
	icon_state = "purple"
/area/desert_dam/interior/dam_interior/northwestern_tunnel
	name = "Engineering Northwestern Tunnel"
	icon_state = "green"
/area/desert_dam/interior/dam_interior/north_tunnel
	name = "Engineering Northern Tunnel"
	icon_state = "blue-red"
	minimap_color = MINIMAP_AREA_COLONY
/area/desert_dam/interior/dam_interior/west_tunnel
	name = "Engineering Western Tunnel"
	icon_state = "yellow"
/area/desert_dam/interior/dam_interior/central_tunnel
	name = "Engineering Central Tunnel"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_COLONY
/area/desert_dam/interior/dam_interior/south_tunnel
	name = "Engineering Southern Tunnel"
	icon_state = "purple"
	minimap_color = MINIMAP_AREA_ENGI
/area/desert_dam/interior/dam_interior/northeastern_tunnel
	name = "Engineering Northeastern Tunnel"
	icon_state = "green"
	minimap_color = MINIMAP_AREA_COLONY
/area/desert_dam/interior/dam_interior/CE_office
	name = "Engineering Chief Engineer's Office"
	icon_state = "yellow"
/area/desert_dam/interior/dam_interior/workshop
	name = "Engineering Workshop"
	icon_state = "purple"
/area/desert_dam/interior/dam_interior/hanger
	name = "Engineering Hangar"
	icon_state = "hangar"
/area/desert_dam/interior/dam_interior/hangar_storage
	name = "Engineering Hangar Storage"
	icon_state = "storage"
/area/desert_dam/interior/dam_interior/auxilary_tool_storage
	name = "Engineering Auxiliary Tool Storage"
	icon_state = "red"
/area/desert_dam/interior/dam_interior/primary_tool_storage
	name = "Engineering Primary Tool Storage"
	icon_state = "blue"
/area/desert_dam/interior/dam_interior/tech_storage
	name = "Engineering Secure Tech Storage"
	icon_state = "dark"
/area/desert_dam/interior/dam_interior/break_room
	name = "Engineering Breakroom"
	icon_state = "yellow"
/area/desert_dam/interior/dam_interior/disposals
	name = "Engineering Disposals"
	icon_state = "disposal"
/area/desert_dam/interior/dam_interior/western_dam_cave
	name = "Engineering West Entrance"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_CAVES
/area/desert_dam/interior/dam_interior/office
	name = "Engineering Office"
	icon_state = "red"
/area/desert_dam/interior/dam_interior
	name = "Engineering"
	icon_state = ""

/area/desert_dam/interior/east_engineering
	name = "Eastern Engineering"
	icon_state = "yellow"

/area/desert_dam/interior/dam_interior/north_tunnel_entrance
	name = "Engineering North Tunnel Entrance"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_SEC
/area/desert_dam/interior/dam_interior/east_tunnel_entrance
	name = "Engineering East Tunnel Entrance"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_SEC
/area/desert_dam/interior/dam_interior/south_tunnel_entrance
	name = "Engineering South Tunnel Entrance"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/desert_dam/interior/caves
	name = "Caves"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	icon_state = "red"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	minimap_color = MINIMAP_AREA_CAVES

/area/desert_dam/interior/caves/northern_caves
	name = "Northern Caves"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_CAVES
/area/desert_dam/interior/caves/east_caves
	name = "Eastern Caves"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_CAVES

/area/desert_dam/interior/caves/central_caves
	name = "Central Caves"
	icon_state = "yellow"
/area/desert_dam/interior/caves/central_caves/entrances/east_tunnel_entrance
	name = "Eastern Central Tunnel Entrance"
	icon_state = "red"
/area/desert_dam/interior/caves/central_caves/entrances/south_tunnel_entrance
	name = "Southern Central Tunnel Entrance"
	icon_state = "red"
/area/desert_dam/interior/caves/central_caves/entrances/west_tunnel_entrance
	name = "Western Central Tunnel Entrance"
	icon_state = "red"

/area/desert_dam/interior/caves/temple
	name = "Sand Temple"
	icon_state = "green"

//BUILDING
//areas not under rock
// ceiling = CEILING_METAL
/area/desert_dam/building
	ceiling = CEILING_METAL
	outside = FALSE
//Substations
/area/desert_dam/building/substation
	name = "Substation"
	icon = 'icons/turf/dam_areas.dmi'
	minimap_color = MINIMAP_AREA_ENGI

/area/desert_dam/building/substation/northwest
	name = "Command Substation"
	icon_state = "northewestern_ss"
/area/desert_dam/building/substation/northeast
	name = "Command Substation"
	icon_state = "northeastern_ss"
/area/desert_dam/building/substation/east
	name = "Command Substation"
	icon_state = "eastern_ss"
/area/desert_dam/building/substation/southeast
	name = "Command Substation"
	icon_state = "southeastern_ss"
/area/desert_dam/building/substation/central
	name = "Command Substation"
	icon_state = "central_ss"
/area/desert_dam/building/substation/southwest
	name = "Command Substation"
	icon_state = "southwestern_ss"
/area/desert_dam/building/substation/west
	name = "Command Substation"
	icon_state = "western_ss"

//Administration
/area/desert_dam/building/administration/control_room
	name = "Administration Landing Control Room"
	icon_state = "yellow"
/area/desert_dam/building/administration/lobby
	name = "Administration Lobby"
	icon_state = "green"
/area/desert_dam/building/administration/hallway
	name = "Administration Hallway"
	icon_state = "purple"
/area/desert_dam/building/administration/office
	name = "Administration Office"
	icon_state = "blue-red"
/area/desert_dam/building/administration/overseer_office
	name = "Administration Overseer's Office"
	icon_state = "red"
/area/desert_dam/building/administration/meetingrooom
	name = "Administration Meeting Room"
	icon_state = "yellow"
/area/desert_dam/building/administration/archives
	name = "Administration Archives"
	icon_state = "green"


//Bar
/area/desert_dam/building/bar/bar
	name = "Bar"
	icon_state = "yellow"
/area/desert_dam/building/bar/backroom
	name = "Bar Backroom"
	icon_state = "green"
/area/desert_dam/building/bar/bar_restroom
	name = "Bar Restroom"
	icon_state = "purple"


//Cafe
/area/desert_dam/building/cafeteria/cafeteria
	name = "Cafeteria"
	icon_state = "yellow"
/area/desert_dam/building/cafeteria/backroom
	name = "Cafeteria Backroom"
	icon_state = "green"
/area/desert_dam/building/cafeteria/restroom
	name = "Cafeteria Restroom"
	icon_state = "purple"
/area/desert_dam/building/cafeteria/loading
	name = "Cafeteria Loading Room"
	icon_state = "blue-red"
/area/desert_dam/building/cafeteria/cold_room
	name = "Cafeteria Coldroom"
	icon_state = "red"


//Dorms
/area/desert_dam/building/dorms/hallway_northwing
	name = "Dormitory North Wing"
	icon_state = "yellow"
/area/desert_dam/building/dorms/hallway_westwing
	name = "Dormitory West Wing"
	icon_state = "green"
/area/desert_dam/building/dorms/hallway_eastwing
	name = "Dormitory East Wing"
	icon_state = "purple"
/area/desert_dam/building/dorms/restroom
	name = "Dormitory Showers"
	icon_state = "blue-red"
/area/desert_dam/building/dorms/pool
	name = "Dormitory Pool Room"
	icon_state = "red"


//Medical
/area/desert_dam/building/medical
	minimap_color = MINIMAP_AREA_MEDBAY
/area/desert_dam/building/medical/garage
	name = "Medical Garage"
	icon_state = "garage"
/area/desert_dam/building/medical/emergency_room
	name = "Medical Emergency Room"
	icon_state = "medbay"
/area/desert_dam/building/medical/treatment_room
	name = "Medical Treatment Room"
	icon_state = "medbay2"
/area/desert_dam/building/medical/lobby
	name = "Medical Lobby"
	icon_state = "medbay3"
/area/desert_dam/building/medical/chemistry
	name = "Medical Pharmacy"
	icon_state = "medbay"
/area/desert_dam/building/medical/west_wing_hallway
	name = "Medical West Wing "
	icon_state = "medbay2"
/area/desert_dam/building/medical/north_wing_hallway
	name = "Medical North Wing"
	icon_state = "medbay3"
/area/desert_dam/building/medical/east_wing_hallway
	name = "Medical East Wing"
	icon_state = "medbay"
/area/desert_dam/building/medical/primary_storage
	name = "Medical Primary Storage"
	icon_state = "red"
/area/desert_dam/building/medical/surgery_room_one
	name = "Medical Surgery Room One"
	icon_state = "yellow"
/area/desert_dam/building/medical/surgery_room_two
	name = "Medical Surgery Room Two"
	icon_state = "purple"
/area/desert_dam/building/medical/surgery_observation
	name = "Medical Surgery Observation"
	icon_state = "medbay2"
/area/desert_dam/building/medical/morgue
	name = "Medical Morgue"
	icon_state = "blue"
/area/desert_dam/building/medical/break_room
	name = "Medical Breakroom"
	icon_state = "medbay"
/area/desert_dam/building/medical/CMO
	name = "Medical CMO's Office"
	icon_state = "CMO"
/area/desert_dam/building/medical/office1
	name = "Medical Office One"
	icon_state = "red"
/area/desert_dam/building/medical/office2
	name = "Medical Office Two"
	icon_state = "blue"
/area/desert_dam/building/medical/patient_wing
	name = "Medical Patient Wing"
	icon_state = "medbay2"
/area/desert_dam/building/medical/virology_wing
	name = "Medical Virology Wing"
	icon_state = "medbay3"
/area/desert_dam/building/medical/virology_isolation
	name = "Medical Virology Isolation"
	icon_state = "medbay"
/area/desert_dam/building/medical/medsecure
	name = "Medical Virology Isolation"
	icon_state = "red"
/area/desert_dam/building/medical
	name = "Medical"
	icon_state = "medbay2"


//Warehouse
/area/desert_dam/building/warehouse/warehouse
	name = "Warehouse"
	icon_state = "yellow"
/area/desert_dam/building/warehouse/loading
	name = "Warehouse Loading Room"
	icon_state = "red"
/area/desert_dam/building/warehouse/breakroom
	name = "Warehouse Breakroom"
	icon_state = "green"


//Hydroponics
/area/desert_dam/building/hydroponics/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
/area/desert_dam/building/hydroponics/hydroponics_storage
	name = "Hydroponics Storage"
	icon_state = "green"
/area/desert_dam/building/hydroponics/hydroponics_loading
	name = "Hydroponics Loading Room"
	icon_state = "garage"
/area/desert_dam/building/hydroponics/hydroponics_breakroom
	name = "Hydroponics Breakroom"
	icon_state = "red"


//Telecoms
/area/desert_dam/building/telecommunication
	name = "Telecommunications"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_ENGI

//Water Treatment Plant 1
/area/desert_dam/building/water_treatment_one
	name = "Water Treatment One"
	icon_state = "yellow"
//Water Treatment Plant 1
/area/desert_dam/building/water_treatment_one/lobby
	name = "Water Treatment One Lobby"
	icon_state = "red"
/area/desert_dam/building/water_treatment_one/breakroom
	name = "Water Treatment One Breakroom"
	icon_state = "green"
/area/desert_dam/building/water_treatment_one/garage
	name = "Water Treatment One Garage"
	icon_state = "garage"
/area/desert_dam/building/water_treatment_one/sedimentation
	name = "Water Treatment One Sedimentation"
	icon_state = "blue"
/area/desert_dam/building/water_treatment_one/equipment
	name = "Water Treatment One Equipment Room"
	icon_state = "red"
/area/desert_dam/building/water_treatment_one/hallway
	name = "Water Treatment One Hallway"
	icon_state = "purple"
/area/desert_dam/building/water_treatment_one/control_room
	name = "Water Treatment One Control Room"
	icon_state = "yellow"
/area/desert_dam/building/water_treatment_one/purification
	name = "Water Treatment One Purification"
	icon_state = "green"
/area/desert_dam/building/water_treatment_one/floodgate_control
	name = "Water Treatment One Floodgate Control"
	icon_state = "green"

/area/desert_dam/building/water_treatment_one/floodgate_control/central
	name = "Central Floodgate Control"
	icon_state = "green"

/area/desert_dam/building/water_treatment_one/floodgate_control/central2
	name = "Central Floodgate Control Storage"
	icon_state = "green"

//Water Treatment Plant 2
/area/desert_dam/building/water_treatment_two
	name = "Water Treatment Two"
	icon_state = "yellow"
/area/desert_dam/building/water_treatment_two/lobby
	name = "Water Treatment Two Lobby"
	icon_state = "red"
/area/desert_dam/building/water_treatment_two/breakroom
	name = "Water Treatment Two Breakroom"
	icon_state = "green"
/area/desert_dam/building/water_treatment_two/garage
	name = "Water Treatment Two Garage"
	icon_state = "garage"
/area/desert_dam/building/water_treatment_two/sedimentation
	name = "Water Treatment Two Sedimentation"
	icon_state = "blue"
/area/desert_dam/building/water_treatment_two/equipment
	name = "Water Treatment Two Equipment"
	icon_state = "red"
/area/desert_dam/building/water_treatment_two/hallway
	name = "Water Treatment Two Hallway"
	icon_state = "purple"
/area/desert_dam/building/water_treatment_two/control_room
	name = "Water Treatment Two Control Room"
	icon_state = "yellow"
/area/desert_dam/building/water_treatment_two/purification
	name = "Water Treatment Two Purification"
	icon_state = "green"
/area/desert_dam/building/water_treatment_two/floodgate_control
	name = "Water Treatment Two Floodgate Control"
	icon_state = "green"


//Library UNUSED
/*
/area/desert_dam/building/library/library
	name = "Library"
	icon_state = "library"
/area/desert_dam/building/library/restroom
	name = "Library Restroom"
	icon_state = "green"
/area/desert_dam/building/library/studyroom
	name = "Library Study Room"
	icon_state = "purple"
*/

//Security
/area/desert_dam/building/security
	minimap_color = MINIMAP_AREA_SEC
/area/desert_dam/building/security/prison
	name = "Security Prison"
	icon_state = "sec_prison"
/area/desert_dam/building/security/marshals_office
	name = "Security Marshal's Office"
	icon_state = "sec_hos"
/area/desert_dam/building/security/armory
	name = "Security Armory"
	icon_state = "armory"
/area/desert_dam/building/security/warden
	name = "Security Warden's Office"
	icon_state = "Warden"
/area/desert_dam/building/security/interrogation
	name = "Security Interrogation"
	icon_state = "interrogation"
/area/desert_dam/building/security/backroom
	name = "Security Interrogation"
	icon_state = "sec_backroom"
/area/desert_dam/building/security/observation
	name = "Security Observation"
	icon_state = "observatory"
/area/desert_dam/building/security/detective
	name = "Security Detective's Office"
	icon_state = "detective"
/area/desert_dam/building/security/office
	name = "Security Office"
	icon_state = "yellow"
/area/desert_dam/building/security/lobby
	name = "Security Lobby"
	icon_state = "green"
/area/desert_dam/building/security/northern_hallway
	name = "Security North Hallway"
	icon_state = "purple"
/area/desert_dam/building/security/courtroom
	name = "Security Courtroom"
	icon_state = "courtroom"
/area/desert_dam/building/security/evidence
	name = "Security Evidence"
	icon_state = "red"
/area/desert_dam/building/security/holding
	name = "Security Holding Room"
	icon_state = "yellow"
/area/desert_dam/building/security/southern_hallway
	name = "Security South Hallway"
	icon_state = "green"
/area/desert_dam/building/security/deathrow
	name = "Security Death Row"
	icon_state = "cells_max_n"
/area/desert_dam/building/security/execution_chamber
	name = "Security Execution Chamber"
	icon_state = "red"
/area/desert_dam/building/security/staffroom
	name = "Security Staffroom"
	icon_state = "security"

//Church
/area/desert_dam/building/church
	name = "Church"
	icon_state = "courtroom"

//Mining area
/area/desert_dam/building/mining
	minimap_color = MINIMAP_AREA_ENGI
/area/desert_dam/building/mining/workshop
	name = "Mining Workshop"
	icon_state = "yellow"
/area/desert_dam/building/mining/workshop_foyer
	name = "Mining Workshop Foyer"
	icon_state = "purple"
//Legacy Areas for mining
	/*
/area/desert_dam/building/mining/garage
	name = "Mining Garage"
	icon_state = "garage"
/area/desert_dam/building/mining/boxing_room
	name = "Mining Boxing Room"
	icon_state = "red"
/area/desert_dam/building/mining/loading_room
	name = "Mining Loading Bay"
	icon_state = "yellow"
/area/desert_dam/building/mining/break_room
	name = "Mining Breakroom"
	icon_state = "purple"
/area/desert_dam/building/mining/locker_room
	name = "Mining Locker Room"
	icon_state = "green"
/area/desert_dam/building/mining/lobby
	name = "Mining Lobby"
	icon_state = "red"
/area/desert_dam/building/mining/front_desk
	name = "Mining Front Desk"
	icon_state = "green"
/area/desert_dam/building/mining/foremans_office
	name = "Mining Foreman's Office"
	icon_state = "yellow"
/area/desert_dam/building/mining/maintenance_north
	name = "Mining Maintenance North"
	icon_state = "dark160"
/area/desert_dam/building/mining/maintenance_east
	name = "Mining Maintenance East"
	icon_state = "dark128"
/area/desert_dam/building/mining/bunkhouse
	name = "Mining Bunkhouse"
	icon_state = "red"
/area/desert_dam/building/mining/construction_site
	name = "Construction Site"
	icon_state = "yellow"
*/


//NorthWest Lab Buildings
/area/desert_dam/building/lab_northwest/west_lab_robotics
	name = "West Lab Robotics"
	icon_state = "ass_line"
/area/desert_dam/building/lab_northwest/west_lab_robotics_mechbay
	name = "West Lab Mechbay"
	icon_state = "purple"
/area/desert_dam/building/lab_northwest/west_lab_east_hallway
	name = "West Lab Hallway"
	icon_state = "red"
/area/desert_dam/building/lab_northwest/west_lab_west_hallway
	name = "West Lab Hallway"
	icon_state = "red"
/area/desert_dam/building/lab_northwest/west_lab_maintenance
	name = "West Lab Maintenance"
	icon_state = "purple"
/area/desert_dam/building/lab_northwest/west_lab_chemistry
	name = "West Lab Chemistry"
	icon_state = "yellow"
/area/desert_dam/building/lab_northwest/west_lab_cafeteria
	name = "West Lab Cafeteria"
	icon_state = "blue"
/area/desert_dam/building/lab_northwest/west_lab_kitchen
	name = "West Lab Kitchen"
	icon_state = "kitchen"
/area/desert_dam/building/lab_northwest/west_lab_dormitory
	name = "West Lab Dormitory"
	icon_state = "red"
/area/desert_dam/building/lab_northwest/west_lab_meeting_room
	name = "West Lab Meeting Room"
	icon_state = "purple"
/area/desert_dam/building/lab_northwest/west_lab_xenoflora
	name = "West Lab Xenoflora"
	icon_state = "purple"
/area/desert_dam/building/lab_northeast/checkpoint
	name = "East Lab Checkpoint"
	icon_state = "red"
/area/desert_dam/building/lab_northeast/garage
	name = "East Lab Garage"
	icon_state = "garage"


//EXTERIOR
//under open sky
/area/desert_dam/exterior
	always_unpowered = TRUE

/area/desert_dam/exterior/rock
	name = "Rock"
	icon_state = "cave"

/area/desert_dam/exterior/landing
	always_unpowered = FALSE

//Landing Pad for the Alamo. THIS IS NOT THE SHUTTLE AREA
/area/desert_dam/exterior/landing/landing_pad_one
	name = "Airstrip Landing Pad"
	icon_state = "landing_pad"
	minimap_color = MINIMAP_AREA_LZ
/area/desert_dam/exterior/landing/landing_pad_one_external
	name = "Airstrip Landing Valley"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_COLONY


//Landing Pad for the Normandy. THIS IS NOT THE SHUTTLE AREA
/area/desert_dam/exterior/landing/landing_pad_two
	name = "Eastern Aerodrome Landing Pad"
	icon_state = "landing_pad"
	minimap_color = MINIMAP_AREA_LZ
/area/desert_dam/exterior/landing/landing_pad_two_external
	name = "Eastern Landing Valley"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_COLONY

//Landing Pad for the abandoned tradeship, not used for transit. THIS IS NOT THE SHUTTLE AREA
/area/desert_dam/exterior/landing/landing_pad_three
	name = "Aerodrome Landing Pad"
	icon_state = "landing_pad"
	minimap_color = MINIMAP_AREA_LZ
/area/desert_dam/exterior/landing/landing_pad_three_external
	name = "Aerodrome Landing Valley"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_COLONY

//Valleys
//Near LZ
//TODO: incorporate valleys and substrations for floodlight coverage

/area/desert_dam/exterior/valley
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = FALSE

/area/desert_dam/exterior/valley/valley_northwest
	name = "Northwest Valley"
	icon_state = "valley_north_west"
/area/desert_dam/exterior/valley/valley_cargo
	name = "Shipping Valley"
	icon_state = "valley_south_west"
/area/desert_dam/exterior/valley/valley_telecoms
	name = "Telecomms Valley"
	icon_state = "valley_west"
/area/desert_dam/exterior/valley/tradeship
	name = "NTT Jerry-Cabot"
	icon_state = "dark160"
	requires_power = FALSE

//Away from LZ

/area/desert_dam/exterior/valley/valley_labs
	name = "Lab Valley"
	icon_state = "valley_north"
/area/desert_dam/exterior/valley/valley_mining
	name = "Mining Valley"
	icon_state = "valley_east"
/area/desert_dam/exterior/valley/valley_civilian
	name = "Civilian Valley"
	icon_state = "valley_south_excv"
/area/desert_dam/exterior/valley/valley_medical
	name = "Medical Valley"
	icon_state = "valley"
/area/desert_dam/exterior/valley/valley_medical_south
	name = "Southern Medical Valley"
	icon_state = "valley"
/area/desert_dam/exterior/valley/valley_hydro
	name = "Hydro Valley"
	icon_state = "valley"
/area/desert_dam/exterior/valley/valley_crashsite
	name = "Crash Site Valley"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_CAVES
/area/desert_dam/exterior/valley/north_valley_dam
	name = "North Dam Valley"
	icon_state = "valley"
/area/desert_dam/exterior/valley/south_valley_dam
	name = "South Dam Valley"
	icon_state = "valley"
/area/desert_dam/exterior/valley/bar_valley_dam
	name = "Bar Valley"
	icon_state = "yellow"
/area/desert_dam/exterior/valley/valley_wilderness
	name = "Wilderness Valley"
	icon_state = "central"


//End of the river areas, no Next
/area/desert_dam/exterior/river/riverside_northwest
	name = "Northwestern Riverbed"
	icon_state = "bluenew"
/area/desert_dam/exterior/river/riverside_central_north
	name = "Northern Central Riverbed"
	icon_state = "purple"
/area/desert_dam/exterior/river/riverside_central_south
	name = "Southern Central Riverbed"
	icon_state = "purple"
/area/desert_dam/exterior/river/riverside_south
	name = "Southern Riverbed"
	icon_state = "bluenew"
/area/desert_dam/exterior/river/riverside_east
	name = "Eastern Riverbed"
	icon_state = "bluenew"
/area/desert_dam/exterior/river/riverside_northeast
	name = "Northeastern Riverbed"
	icon_state = "bluenew"
//The filtration plants - This area isn't for the WHOLE plant, but the areas that have water in them, so the water changes color as well.

/area/desert_dam/exterior/river/filtration_a
	name = "Filtration Plant A"

/area/desert_dam/exterior/river/filtration_b
	name = "Filtration Plant B"

//Areas that are rivers, but will not change because they're before the floodgates
/area/desert_dam/exterior/river_mouth/southern
	name = "Southern River Mouth"
	icon_state = "purple"

/area/desert_dam/exterior/river_mouth/eastern
	name = "Eastern River Mouth"
	icon_state = "purple"

/area/desert_dam/landing/console
	name = "LZ1 'Admin'"
	icon_state = "tcomsatcham"
	requires_power = 0
	flags_area = NO_DROPPOD

/area/desert_dam/landing/console2
	name = "LZ2 'Supply'"
	icon_state = "tcomsatcham"
	requires_power = 0
	flags_area = NO_DROPPOD

//Transit Shuttle
/area/shuttle/tri_trans1/alpha
	icon_state = "shuttle"
/area/shuttle/tri_trans1/away
	icon_state = "away1"

/area/shuttle/tri_trans2/alpha
	icon_state = "shuttlered"
/area/shuttle/tri_trans2/away
	icon_state = "away2"
/area/shuttle/tri_trans2/omega
	icon_state = "shuttle2"

