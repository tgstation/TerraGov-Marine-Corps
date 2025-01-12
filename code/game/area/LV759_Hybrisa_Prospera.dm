#define AMBIENT_LV759_OUTDOORS list('sound/effects/urban/outdoors/wind4.ogg','sound/effects/urban/outdoors/wind5.ogg','sound/effects/urban/outdoors/wind6.ogg','sound/effects/urban/outdoors/wind7.ogg','sound/effects/urban/outdoors/wind8.ogg','sound/effects/urban/outdoors/wind9.ogg','sound/effects/urban/outdoors/wind10.ogg','sound/effects/urban/outdoors/wind11.ogg','sound/effects/urban/outdoors/wind12.ogg','sound/effects/urban/outdoors/wind13.ogg','sound/effects/urban/outdoors/wind14.ogg','sound/effects/urban/outdoors/wind15.ogg','sound/effects/urban/outdoors/wind16.ogg','sound/effects/urban/outdoors/wind17.ogg','sound/effects/urban/outdoors/wind18.ogg','sound/effects/urban/outdoors/wind19.ogg','sound/effects/urban/outdoors/wind20.ogg','sound/effects/urban/outdoors/wind21.ogg','sound/effects/urban/outdoors/wind22.ogg','sound/effects/urban/outdoors/wind23.ogg','sound/effects/urban/outdoors/wind24.ogg','sound/effects/urban/outdoors/wind25.ogg','sound/effects/urban/outdoors/wind26.ogg','sound/effects/urban/outdoors/wind27.ogg','sound/effects/urban/outdoors/wind28.ogg',)
#define AMBIENT_LV759_INDOORS list('sound/effects/urban/indoors/indoor_wind.ogg','sound/effects/urban/indoors/indoor_wind2.ogg','sound/effects/urban/indoors/vent_1.ogg','sound/effects/urban/indoors/vent_2.ogg','sound/effects/urban/indoors/vent_3.ogg','sound/effects/urban/indoors/vent_4.ogg','sound/effects/urban/indoors/vent_5.ogg','sound/effects/urban/indoors/vent_6.ogg','sound/effects/urban/indoors/vent_7.ogg','sound/effects/urban/indoors/vent_6.ogg','sound/effects/urban/indoors/distant_sounds_1.ogg','sound/effects/urban/indoors/distant_sounds_2.ogg','sound/effects/urban/indoors/distant_sounds_3.ogg','sound/effects/urban/indoors/distant_sounds_4.ogg','sound/effects/urban/indoors/distant_sounds_5.ogg','sound/effects/urban/indoors/distant_sounds_6.ogg','sound/effects/urban/indoors/distant_sounds_7.ogg','sound/effects/urban/indoors/distant_sounds_8.ogg','sound/effects/urban/indoors/distant_sounds_9.ogg','sound/effects/urban/indoors/distant_sounds_10.ogg','sound/effects/engamb1.ogg','sound/effects/engamb2.ogg','sound/effects/engamb3.ogg','sound/effects/engamb4.ogg','sound/effects/engamb5.ogg','sound/effects/engamb6.ogg','sound/effects/engamb7.ogg',)
#define AMBIENT_LV759_DERELICTSHIP list('sound/effects/urban/indoors/derelict1.ogg','sound/effects/urban/indoors/derelict_ambience.ogg','sound/effects/urban/indoors/urban_interior.ogg','sound/effects/urban/indoors/derelict2.ogg','sound/effects/urban/indoors/derelict3.ogg','sound/effects/urban/indoors/derelict4.ogg','sound/effects/urban/indoors/derelict5.ogg','sound/effects/urban/indoors/derelict6.ogg','sound/effects/urban/indoors/derelict7.ogg','sound/effects/urban/indoors/derelict8.ogg')

//lv759 AREAS--------------------------------------//

/area/lv759
	name = "LV-759 Hybrisa Prospera"
	icon = 'icons/turf/hybrisareas.dmi'
	icon_state = "hybrisa"

//parent types

/area/lv759/indoors
	name = "Hybrisa - Indoors"
	icon_state = "cliff_blocked"//because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_METAL
	outside = FALSE
	always_unpowered = FALSE
	minimap_color = MINIMAP_AREA_LIVING
	ambience = AMBIENT_LV759_INDOORS

/area/lv759/outdoors
	name = "Hybrisa - Outdoors"
	icon_state = "cliff_blocked"//because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_NONE
	always_unpowered = TRUE
	ambience = AMBIENT_LV759_OUTDOORS

/area/lv759/oob
	name = "Out Of Bounds"
	icon_state = "oob"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	always_unpowered = TRUE

// Landing Zone 1
/area/lv759/outdoors/landing_zone_1
	name = "Nova Medica Hospital Complex - Emergency Response Landing Zone One"
	icon_state = "medical_lz1"
	minimap_color = MINIMAP_AREA_LZ
	ceiling = CEILING_NONE
	always_unpowered = FALSE

/area/lv759/indoors/landing_zone_1/flight_control_room
	name = "Nova Medica Hospital Complex - Emergency Response Landing Zone One - Flight Control Room"
	icon_state = "hybrisa"
	ceiling = CEILING_METAL

/area/lv759/indoors/landing_zone_1/lz1_console
	name = "Nova Medica Hospital Complex - Emergency Response Landing Zone One - Dropship Alamo Console"
	icon_state = "hybrisa"
	requires_power = FALSE
	ceiling = CEILING_METAL

// Landing Zone 2
/area/lv759/outdoors/landing_zone_2
	name = "KMCC Interstellar Freight Hub - Landing Zone Two"
	icon_state = "mining_lz2"
	minimap_color = MINIMAP_AREA_LZ
	ceiling = CEILING_NONE
	area_flavor = AREA_FLAVOR_URBAN

/area/lv759/indoors/landing_zone_2
	icon_state = "hybrisa"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/lv759/indoors/landing_zone_2/kmcc_hub_flight_control_room
	name = "KMCC Interstellar Freight Hub - Flight Control Room"

/area/lv759/indoors/landing_zone_2/kmcc_hub_security
	name = "KMCC Interstellar Freight Hub - Security Checkpoint Office"
	icon_state = "security_checkpoint"

/area/lv759/indoors/landing_zone_2/kmcc_hub_lounge_north
	name = "KMCC Interstellar Freight Hub - Passenger Departures - Lounge North"

/area/lv759/indoors/landing_zone_2/kmcc_hub_fuel
	name = "KMCC Interstellar Freight Hub - Fuel Storage & Maintenance - North"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/landing_zone_2/kmcc_hub_lounge_south
	name = "KMCC Interstellar Freight Hub - Passenger Departures - Lounge South"

/area/lv759/indoors/landing_zone_2/kmcc_hub_lounge_hallway
	name = "KMCC Interstellar Freight Hub - Passenger Departures - Hallway"

/area/lv759/indoors/landing_zone_2/kmcc_hub_south_office
	name = "KMCC Interstellar Freight Hub - Passenger Departures - South Office"

/area/lv759/indoors/landing_zone_2/kmcc_hub_maintenance
	name = "KMCC Interstellar Freight Hub - Passenger Departures - Maintenance"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/landing_zone_2/kmcc_hub/lz2_console
	name = "KMCC Interstellar Freight Hub - Dropship Normandy Console"
	requires_power = FALSE

/area/lv759/indoors/landing_zone_2/kmcc_hub_cargo
	name = "KMCC Interstellar Freight Hub - Cargo Processing Center"
	icon_state = "mining_cargo"
	minimap_color = MINIMAP_AREA_REQ

/area/lv759/indoors/landing_zone_2/kmcc_hub_maintenance_north
	name = "KMCC Interstellar Freight Hub - Cargo Processing Center - Maintenance"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_ENGI

// Derelict Ship
/area/lv759/indoors/derelict_ship
	name = "Derelict Ship"
	icon_state = "derelictship"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_SEC_CAVE
	ambience = AMBIENT_LV759_DERELICTSHIP

// Caves
/area/lv759/indoors/nt_research_complex_entrance
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - North Main Entrance"
	ceiling = CEILING_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES

/area/lv759/indoors/caves
	name = "LV759 - Caverns"
	icon_state = "caves_west"
	always_unpowered = TRUE
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES
	ambience = list('sound/effects/urban/outdoors/windy_caverns_1.ogg',
	'sound/effects/urban/outdoors/windy_caverns_2.ogg',
	'sound/effects/urban/outdoors/windy_caverns_3.ogg',
	'sound/effects/urban/outdoors/deepcave1.ogg',
	'sound/effects/urban/outdoors/deepcave2.ogg',
	)

/area/lv759/indoors/caves/west_caves
	name = "Caverns - West"

/area/lv759/indoors/caves/west_caves_alarm
	name = "Caverns - West"
	icon_state = "caves_west"

/area/lv759/indoors/caves/east_caves
	name = "Caverns - East"
	icon_state = "caves_east"

/area/lv759/indoors/caves/south_caves
	name = "Caverns - South"
	icon_state = "caves_south"

/area/lv759/indoors/caves/south_east_caves
	name = "Caverns - Southeast"
	icon_state = "caves_southeast"

/area/lv759/indoors/caves/south_west_caves
	name = "Caverns - Southwest"
	icon_state = "caves_southwest"

/area/lv759/indoors/caves/south_west_caves_alarm
	name = "Caverns - Southwest"
	icon_state = "caves_southwest"

/area/lv759/indoors/caves/north_west_caves
	name = "Caverns - Northwest"
	icon_state = "caves_northwest"
	ceiling = CEILING_UNDERGROUND
	always_unpowered = FALSE

/area/lv759/outdoors/north_west_caves_outdoors
	name = "Caverns - Northwest"
	icon_state = "caves_northwest"
	ceiling = CEILING_UNDERGROUND

/area/lv759/indoors/caves/north_east_caves
	name = "Caverns - Northeast"
	icon_state = "caves_northeast"
	ceiling = CEILING_UNDERGROUND
	always_unpowered = FALSE

/area/lv759/indoors/caves/north_caves
	name = "Caverns - North"
	icon_state = "caves_north"
	always_unpowered = TRUE
	ceiling = CEILING_UNDERGROUND

/area/lv759/indoors/caves/central_caves
	name = "Caverns - Central"
	icon_state = "caves_central"

// Caves Central Plateau
/area/lv759/outdoors/caveplateau
	name = "Caverns - Plateau"
	icon_state = "caves_plateau"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	ambience = list('sound/effects/urban/outdoors/derelict_plateau_1.ogg',
	'sound/effects/urban/outdoors/derelict_plateau_2.ogg',
	)

// Colony Streets
/area/lv759/outdoors/colony_streets
	name = "Colony Streets"
	icon_state = "colonystreets_north"
	ceiling = CEILING_NONE
	always_unpowered = FALSE
	area_flavor = AREA_FLAVOR_URBAN
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/outdoors/colony_streets/central_streets
	name = "Central Street - West"
	icon_state = "colonystreets_west"

/area/lv759/outdoors/colony_streets/east_central_street
	name = "Central Street - East"
	icon_state = "colonystreets_east"

/area/lv759/outdoors/colony_streets/south_street
	name = "Colony Streets - South"
	icon_state = "colonystreets_south"

/area/lv759/outdoors/colony_streets/south_east_street
	name = "Colony Streets - Southeast"
	icon_state = "colonystreets_southeast"

/area/lv759/outdoors/colony_streets/south_west_street
	name = "Colony Streets - Southwest - NT Checkpoint Passthrough"
	icon_state = "colonystreets_southwest"
	ceiling = CEILING_UNDERGROUND

/area/lv759/outdoors/colony_streets/north_west_street
	name = "Colony Streets - Northwest"
	icon_state = "colonystreets_northwest"

/area/lv759/outdoors/colony_streets/north_east_street
	name = "Colony Streets - Northeast"
	icon_state = "colonystreets_northeast"

/area/lv759/outdoors/colony_streets/north_street
	name = "Colony Streets - North"
	icon_state = "colonystreets_north"

//Spaceport Indoors
/area/lv759/indoors/spaceport
	minimap_color = MINIMAP_AREA_ESCAPE

/area/lv759/indoors/spaceport/hallway_northeast
	name = "Nanotrasen Celestia Gateway Space-Port - Hallway - Northeast"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/spaceport/hallway_north
	name = "Nanotrasen Celestia Gateway Space-Port - Hallway - North"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/spaceport/hallway_northwest
	name = "Nanotrasen Celestia Gateway Space-Port - Hallway - Northwest"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/spaceport/hallway_east
	name = "Nanotrasen Celestia Gateway Space-Port - Hallway - East"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/spaceport/heavyequip
	name = "Nanotrasen Celestia Gateway Space-Port - Heavy Equipment Storage"
	icon_state = "WYSpaceport"

/area/lv759/indoors/spaceport/engineering
	name = "Nanotrasen Celestia Gateway Space-Port - Fuel Storage & Processing"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/spaceport/janitor
	name = "Nanotrasen Celestia Gateway Space-Port - Janitorial Storage Room"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/spaceport/maintenance_east
	name = "Nanotrasen Celestia Gateway Space-Port - Maintenance - East"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/spaceport/communications_office
	name = "Nanotrasen Celestia Gateway Space-Port - Communications & Administration Office"
	icon_state = "WYSpaceportadmin"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lv759/indoors/spaceport/flight_control_room
	name = "Nanotrasen Celestia Gateway Space-Port - Flight Control Room"
	icon_state = "WYSpaceportadmin"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lv759/indoors/spaceport/security
	name = "Nanotrasen Celestia Gateway Space-Port - Security- Observation & Office"
	icon_state = "security_checkpoint"
	minimap_color = MINIMAP_AREA_SEC

/area/lv759/indoors/spaceport/security_office
	name = "Nanotrasen Celestia Gateway Space-Port - Office"
	icon_state = "security_checkpoint"
	minimap_color = MINIMAP_AREA_SEC

/area/lv759/indoors/spaceport/cargo
	name = "Nanotrasen Celestia Gateway Space-Port - Cargo"
	icon_state = "WYSpaceportcargo"
	minimap_color = MINIMAP_AREA_REQ

/area/lv759/indoors/spaceport/cargo_maintenance
	name = "Nanotrasen Celestia Gateway Space-Port - Cargo - Maintenance"
	icon_state = "WYSpaceportcargo"
	minimap_color = MINIMAP_AREA_REQ

/area/lv759/indoors/spaceport/baggagehandling
	name = "Nanotrasen Celestia Gateway Space-Port - Baggage Storage & Handling"
	icon_state = "WYSpaceportbaggage"

/area/lv759/indoors/spaceport/cuppajoes
	name = "Nanotrasen Celestia Gateway Space-Port - Cuppa Joe's"
	icon_state = "cuppajoes"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv759/indoors/spaceport/kitchen
	name = "Nanotrasen Celestia Gateway Space-Port - Kitchen"
	icon_state = "WYSpaceportblue"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv759/indoors/spaceport/docking_bay_2
	name = "Nanotrasen Celestia Gateway Space-Port - Docking Bay: 2 - Refueling and Maintenance"
	icon_state = "WYSpaceportblue"

/area/lv759/indoors/spaceport/docking_bay_1
	name = "Nanotrasen Celestia Gateway Space-Port - Docking Bay: 1"
	icon_state = "WYSpaceport"

/area/lv759/indoors/spaceport/starglider
	name = "NT-LWI StarGlider SG-200"
	icon_state = "wydropship"
	requires_power = FALSE

/area/lv759/indoors/spaceport/horizon_runner
	name = "NT-LWI Horizon Runner HR-150"
	icon_state = "wydropship"
	requires_power = FALSE

// Garage

/area/lv759/indoors/garage_reception
	name = "Garage - Reception"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/garage_restroom
	name = "Garage - Restroom"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/garage_workshop
	name = "Garage - Workshop"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/garage_workshop_storage
	name = "Garage - Workshop - Storage Room"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/garage_managersoffice
	name = "Garage - Managers Office"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_ENGI

// Meridian Offices & Factory Floor
/area/lv759/indoors/meridian
	icon_state = "meridian"
	minimap_color = MINIMAP_AREA_REQ

/area/lv759/indoors/meridian/meridian_foyer
	name = "Meridian - Foyer"

/area/lv759/indoors/meridian/meridian_showroom
	name = "Meridian - Showroom"

/area/lv759/indoors/meridian/meridian_office
	name = "Meridian - Office"

/area/lv759/indoors/meridian/meridian_managersoffice
	name = "Meridian - Manager's Office"

/area/lv759/indoors/meridian/meridian_factory
	name = "Meridian - Factory Floor"
	icon_state = "meridian_factory"

/area/lv759/indoors/meridian/meridian_restroom
	name = "Meridian - Restroom"

/area/lv759/indoors/meridian/meridian_maintenance_south
	name = "Meridian - Maintenance South"

/area/lv759/indoors/meridian/meridian_maintenance_east
	name = "Meridian - Factory Floor - Maintenance"

// Apartments (Dorms)
/area/lv759/indoors/apartment
	minimap_color = MINIMAP_AREA_LIVING

/area/lv759/indoors/apartment/westfoyer
	name = "Westhaven Apartment Complex - West - Foyer"
	icon_state = "apartments"

/area/lv759/indoors/apartment/westhallway
	name = "Westhaven Apartment Complex - West - Hallway"
	icon_state = "apartments"

/area/lv759/indoors/apartment/westbedrooms
	name = "Westhaven Apartment Complex - West - Bedrooms"
	icon_state = "apartments"

/area/lv759/indoors/apartment/westshowers
	name = "Westhaven Apartment Complex - West - Showers"
	icon_state = "apartments"

/area/lv759/indoors/apartment/westrestroom
	name = "Westhaven Apartment Complex - West - Restrooms"
	icon_state = "apartments"

/area/lv759/indoors/apartment/westentertainment
	name = "Westhaven Apartment Complex - West - Recreation Hub"
	icon_state = "apartments"

/area/lv759/indoors/apartment/eastentrance
	name = "Westhaven Apartment Complex - East - Entrance Room"
	icon_state = "apartments"

/area/lv759/indoors/apartment/eastfoyer
	name = "Westhaven Apartment Complex - East - Foyer"
	icon_state = "apartments"

/area/lv759/indoors/apartment/eastrestroomsshower
	name = "Westhaven Apartment Complex - East - Restrooms & Showers"
	icon_state = "apartments"

/area/lv759/indoors/apartment/eastbedrooms
	name = "Westhaven Apartment Complex - East - Bedrooms"
	icon_state = "apartments"

/area/lv759/indoors/apartment/eastbedroomsstorage
	name = "Westhaven Apartment Complex - East - Bedrooms - Storage Room"
	icon_state = "apartments"

/area/lv759/indoors/apartment/northfoyer
	name = "Westhaven Apartment Complex - North - Foyer"
	icon_state = "apartments"

/area/lv759/indoors/apartment/northhallway
	name = "Westhaven Apartment Complex - North - Hallway"
	icon_state = "apartments"

/area/lv759/indoors/apartment/northapartments
	name = "Westhaven Apartment Complex - North - Luxury Apartments"
	icon_state = "apartments"

// Nanotrasen Offices
/area/lv759/indoors/nt_office
	name = "Nanotrasen Offices - Reception Hallway"
	icon_state = "wyoffice"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lv759/indoors/nt_office/hallway
	name = "Nanotrasen Offices - West Foyer"
	icon_state = "wyoffice"

/area/lv759/indoors/nt_office/floor
	name = "Nanotrasen Offices - Main Office Floor"

/area/lv759/indoors/nt_office/breakroom
	name = "Nanotrasen Offices - Breakroom"

/area/lv759/indoors/nt_office/vip
	name = "Nanotrasen Offices - Conference Room"

/area/lv759/indoors/nt_office/pressroom
	name = "Nanotrasen Offices - Assembly Hall"

/area/lv759/indoors/nt_office/supervisor
	name = "Nanotrasen Offices - Colony Supervisors Office"

// Bar & Entertainment Complex
/area/lv759/indoors/bar
	name = "Bar"
	icon_state = "bar"

/area/lv759/indoors/bar/entertainment
	name = "Bar - Entertainment Subsection"

/area/lv759/indoors/bar/bathroom
	name = "Bar - Restrooms"

/area/lv759/indoors/bar/maintenance
	name = "Bar - Maintenance"

/area/lv759/indoors/bar/kitchen
	name = "Bar - Kitchen"

//Botany

/area/lv759/indoors/botany
	minimap_color = MINIMAP_AREA_LIVING_CAVE

/area/lv759/indoors/botany/botany_greenhouse
	name = "Botany - Greenhouse"
	icon_state = "botany"

/area/lv759/indoors/botany/botany_hallway
	name = "Botany - Hallway"
	icon_state = "botany"

/area/lv759/indoors/botany/botany_maintenance
	name = "Botany - Maintenance"
	icon_state = "botany"

/area/lv759/indoors/botany/botany_mainroom
	name = "Botany - Main Room"
	icon_state = "botany"

// Hosptial
/area/lv759/indoors/hospital
	icon_state = "medical"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/lv759/indoors/hospital/paramedics_garage
	name = "Nova Medica Hospital Complex - Paramedic's Garage"

/area/lv759/indoors/hospital/cryo_room
	name = "Nova Medica Hospital Complex - Cryo Ward"

/area/lv759/indoors/hospital/emergency_room
	name = "Nova Medica Hospital Complex - Emergency Room"

/area/lv759/indoors/hospital/reception
	name = "Nova Medica Hospital Complex - Reception"

/area/lv759/indoors/hospital/cmo_office
	name = "Nova Medica Hospital Complex - Chief Medical Officer's Office"

/area/lv759/indoors/hospital/maintenance
	name = "Nova Medica Hospital Complex - Subspace Communications & Electrical Systems"

/area/lv759/indoors/hospital/pharmacy
	name = "Nova Medica Hospital Complex - Pharmacy & Outgoing Foyer"

/area/lv759/indoors/hospital/outgoing
	name = "Nova Medica Hospital Complex - Outgoing Ward"

/area/lv759/indoors/hospital/central_hallway
	name = "Nova Medica Hospital Complex - Central Hallway"

/area/lv759/indoors/hospital/east_hallway
	name = "Nova Medica Hospital Complex - East Hallway"

/area/lv759/indoors/hospital/medical_storage
	name = "Nova Medica Hospital Complex - Medical Storage"

/area/lv759/indoors/hospital/operation
	name = "Nova Medica Hospital Complex - Operation Theatres & Observation"

/area/lv759/indoors/hospital/patient_ward
	name = "Nova Medica Hospital Complex - Patient Ward"

/area/lv759/indoors/hospital/virology
	name = "Nova Medica Hospital Complex - Virology"

/area/lv759/indoors/hospital/morgue
	name = "Nova Medica Hospital Complex - Morgue"

/area/lv759/indoors/hospital/icu
	name = "Nova Medica Hospital Complex - Intensive Care Ward"

/area/lv759/indoors/hospital/storage
	name = "Nova Medica Hospital Complex - Storage Room"

/area/lv759/indoors/hospital/maintenance_north
	name = "Nova Medica Hospital Complex - Maintenance North"

/area/lv759/indoors/hospital/maintenance_south
	name = "Nova Medica Hospital Complex - Maintenance South"

/area/lv759/indoors/hospital/janitor
	name = "Nova Medica Hospital Complex - Janitors Closet"

// Mining

/area/lv759/indoors/mining_outpost
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_REQ

/area/lv759/indoors/mining_outpost/north
	name = "KMCC - Mining Outpost - North"

/area/lv759/indoors/mining_outpost/north_maint
	name = "KMCC - Mining Outpost - North - Maintenance"

/area/lv759/indoors/mining_outpost/northeast
	name = "KMCC - Mining Outpost - Northeast"

/area/lv759/indoors/mining_outpost/south
	name = "KMCC - Mining Outpost - South"

/area/lv759/indoors/mining_outpost/vehicledeployment
	name = "KMCC - Mining Vehicle Deployment South"

/area/lv759/indoors/mining_outpost/processing
	name = "KMCC - Mining Processing & Storage"

/area/lv759/indoors/mining_outpost/east
	name = "KMCC - Mining Outpost - East"

/area/lv759/indoors/mining_outpost/east_dorms
	name = "KMCC - Mining Outpost - East Dorms"

/area/lv759/indoors/mining_outpost/east_deploymentbay
	name = "KMCC - Mining Outpost - East - Deployment Bay"

/area/lv759/indoors/mining_outpost/east_command
	name = "KMCC - Mining Outpost - East - Command Center"

/area/lv759/indoors/mining_outpost/cargo_maint
	name = "KMCC - Mining Outpost - East - Maintenance"

// Electrical Substations
/area/lv759/indoors/electical_systems
	icon_state = "power0"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/electical_systems/substation1
	name = "Electrical Systems - Substation One - Control Room"

/area/lv759/indoors/electical_systems/substation2
	name = "Electrical Systems - Substation Two"

/area/lv759/indoors/electical_systems/substation3
	name = "Electrical Systems - Substation Three"

// Power-Plant (Engineering)
/area/lv759/indoors/power_plant
	name = "Nanotrasen DynaGrid Nexus - Central Hallway"
	icon_state = "power0"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv759/indoors/power_plant/south_hallway
	name = "Nanotrasen DynaGrid Nexus - South Hallway"

/area/lv759/indoors/power_plant/geothermal_generators
	name = "Nanotrasen DynaGrid Nexus - Geothermal Generators Room"

/area/lv759/indoors/power_plant/power_storage
	name = "Nanotrasen DynaGrid Nexus - Power Storage Room"

/area/lv759/indoors/power_plant/transformers_north
	name = "Nanotrasen DynaGrid Nexus - Transformers - North"

/area/lv759/indoors/power_plant/transformers_south
	name = "Nanotrasen DynaGrid Nexus - Transformers - South"

/area/lv759/indoors/power_plant/gas_generators
	name = "Nanotrasen DynaGrid Nexus - Gas Mixing & Storage "

/area/lv759/indoors/power_plant/fusion_generators
	name = "Nanotrasen DynaGrid Nexus - Control Center"

/area/lv759/indoors/power_plant/telecomms
	icon_state = "comms_1"
	name = "Nanotrasen DynaGrid Nexus - Telecommunications"

/area/lv759/indoors/power_plant/workers_canteen
	name = "Nanotrasen DynaGrid Nexus - Worker's Canteen"

/area/lv759/indoors/power_plant/workers_canteen_kitchen
	name = "Nanotrasen DynaGrid Nexus - Worker's Canteen - Kitchen"

/area/lv759/indoors/power_plant/equipment_east
	name = "Nanotrasen DynaGrid Nexus - Equipment Storage Room - East"

/area/lv759/indoors/power_plant/equipment_west
	name = "Nanotrasen DynaGrid Nexus - Equipment Storage Room - West"

// Marshalls
/area/lv759/indoors/colonial_marshals
	name = "CMB - Sentinel Outpost"
	icon_state = "security_hub"
	minimap_color = MINIMAP_AREA_SEC

/area/lv759/indoors/colonial_marshals/prisoners_cells
	name = "CMB - Sentinel Outpost - Maximum Security Ward - Cells"

/area/lv759/indoors/colonial_marshals/prisoners_foyer
	name = "CMB - Sentinel Outpost - Maximum Security Ward - Foyer"

/area/lv759/indoors/colonial_marshals/prisoners_recreation_area
	name = "CMB - Sentinel Outpost - Maximum Security Ward - Recreation Area & Shower Room"

/area/lv759/indoors/colonial_marshals/garage
	name = "CMB - Sentinel Outpost - Vehicle Deployment & Maintenace"

/area/lv759/indoors/colonial_marshals/armory_foyer
	name = "CMB - Sentinel Outpost - Armory Foyer"

/area/lv759/indoors/colonial_marshals/armory
	name = "CMB - Sentinel Outpost - Armory"

/area/lv759/indoors/colonial_marshals/armory_firingrange
	name = "CMB - Sentinel Outpost - Firing Range"

/area/lv759/indoors/colonial_marshals/armory_evidenceroom
	name = "CMB - Sentinel Outpost - Evidence Room"

/area/lv759/indoors/colonial_marshals/office
	name = "CMB - Sentinel Outpost - Office"

/area/lv759/indoors/colonial_marshals/reception
	name = "CMB - Sentinel Outpost - Reception Office"

/area/lv759/indoors/colonial_marshals/hallway_central
	name = "CMB - Sentinel Outpost - Central Hallway"

/area/lv759/indoors/colonial_marshals/hallway_south
	name = "CMB - Sentinel Outpost - South Hallway"

/area/lv759/indoors/colonial_marshals/hallway_reception
	name = "CMB - Sentinel Outpost - Reception Hallway"

/area/lv759/indoors/colonial_marshals/hallway_north
	name = "CMB - Sentinel Outpost - North Hallway"

/area/lv759/indoors/colonial_marshals/hallway_north_locker
	name = "CMB - Sentinel Outpost - North Hallway - Locker Room"

/area/lv759/indoors/colonial_marshals/holding_cells
	name = "CMB - Sentinel Outpost - Holding Cells"

/area/lv759/indoors/colonial_marshals/head_office
	name = "CMB - Sentinel Outpost - Forensics Office"

/area/lv759/indoors/colonial_marshals/north_office
	name = "CMB - Sentinel Outpost - North Office"

/area/lv759/indoors/colonial_marshals/wardens_office
	name = "CMB - Sentinel Outpost - Wardens Office"

/area/lv759/indoors/colonial_marshals/interrogation
	name = "CMB - Sentinel Outpost - Interrogation"

/area/lv759/indoors/colonial_marshals/press_room
	name = "CMB - Sentinel Outpost - Court Room"

/area/lv759/indoors/colonial_marshals/changing_room
	name = "CMB - Sentinel Outpost - Changing Room"

/area/lv759/indoors/colonial_marshals/restroom
	name = "CMB - Sentinel Outpost - Restroom & Showers"

/area/lv759/indoors/colonial_marshals/south_maintenance
	name = "CMB - Sentinel Outpost - Maintenance - South"

/area/lv759/indoors/colonial_marshals/north_maintenance
	name = "CMB - Sentinel Outpost - Maintenance - North"

/area/lv759/indoors/colonial_marshals/southwest_maintenance
	name = "CMB - Sentinel Outpost - Maintenance - Southwest"


// Jack's Surplus
/area/lv759/indoors/jacks_surplus
	name = "Jack's Military Surplus"
	icon_state = "jacks"

//Nanotrasen - Resource Recovery Facility
/area/lv759/indoors/recycling_plant
	name = "Nanotrasen - Resource Recovery Facility"
	icon_state = "recycling"

/area/lv759/indoors/recycling_plant/garage
	name = "Nanotrasen - Resource Recovery Facility - Garage"
/area/lv759/indoors/recycling_plant/synthetic_storage
	name = "Synthetic Storage"
	icon_state = "synthetic"

/area/lv759/indoors/recycling_plant_office
	name = "Nanotrasen - Resource Recovery Facility - Office"
	icon_state = "recycling"

/area/lv759/indoors/recycling_plant_waste_disposal_incinerator
	name = "Nanotrasen - Resource Recovery Facility - Waste Disposal Incinerating Room"
	icon_state = "recycling"

// Restrooms
/area/lv759/indoors/south_public_restroom
	name = "Public Restroom - South"
	icon_state = "restroom"

/area/lv759/indoors/southwest_public_restroom
	name = "Public Restroom - Southwest"
	icon_state = "restroom"

//Nightgold Casino
/area/lv759/indoors/casino
	name = "Night Gold Casino"
	icon_state = "nightgold"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv759/indoors/casino/casino_office
	name = "Night Gold Casino - Managers Office"
	icon_state = "nightgold"

/area/lv759/indoors/casino/casino_restroom
	name = "Night Gold Casino - Restroom"
	icon_state = "nightgold"

/area/lv759/indoors/casino/casino_vault
	name = "Night Gold Casino - Vault"
	icon_state = "nightgold"

// Pizza
/area/lv759/indoors/pizzaria
	name = "Pizza Galaxy - Outpost Zeta"
	icon_state = "pizza"
	minimap_color = MINIMAP_AREA_CELL_MED

//T-comms
/area/lv759/indoors/tcomms_northwest
	name = "Telecommunications Substation - Northwest"
	icon_state = "comms_1"
	minimap_color = MINIMAP_AREA_ENGI

// NTmart
/area/lv759/indoors/NTmart
	name = "NTmart"
	icon_state = "NTmart"
	minimap_color = MINIMAP_AREA_CELL_MED
	ambience = list('sound/effects/urban/indoors/weymart1.ogg',
	'sound/effects/urban/indoors/weymart2.ogg',
	'sound/effects/urban/indoors/weymart3.ogg',
	'sound/effects/urban/indoors/weymart4.ogg'
	)

/area/lv759/indoors/NTmart/backrooms
	name = "NTmart - Backrooms"
	icon_state = "NTmartbackrooms"

/area/lv759/indoors/NTmart/maintenance
	name = "NTmart - Maintenance"
	icon_state = "NTmartbackrooms"

// NT Security Checkpoints
/area/lv759/indoors/nt_security
	minimap_color = MINIMAP_AREA_SEC

/area/lv759/indoors/nt_security/checkpoint_northeast
	name = "Nanotrasen Security Checkpoint - North East"
	icon_state = "security_checkpoint_northeast"

/area/lv759/indoors/nt_security/checkpoint_east
	name = "Nanotrasen Security Checkpoint - East"
	icon_state = "security_checkpoint_east"

/area/lv759/indoors/nt_security/checkpoint_central
	name = "Nanotrasen Security Checkpoint - Central"
	icon_state = "security_checkpoint_central"

/area/lv759/indoors/nt_security/checkpoint_west
	name = "Nanotrasen Security Checkpoint - West"
	icon_state = "security_checkpoint_west"

/area/lv759/indoors/nt_security/checkpoint_northwest
	name = "Nanotrasen Security Checkpoint - North West"
	icon_state = "security_checkpoint_northwest"

// Misc
/area/lv759/indoors/hobosecret
	name = "Hidden Hobo Haven"
	icon_state = "hobo"
	ceiling = CEILING_METAL
	always_unpowered = TRUE

// Nanotrasen Advanced Bio-Genomic Research Complex

/area/lv759/indoors/nt_research_complex
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex"
	icon_state = "wylab"
	minimap_color = MINIMAP_AREA_CAVES
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	ambience = list('sound/effects/urban/indoors/lab_ambience.ogg')

/area/lv759/indoors/nt_research_complex/medical_annex
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Medical Annex Building"
	minimap_color = MINIMAP_AREA_MEDBAY_CAVE

/area/lv759/indoors/nt_research_complex/reception
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Reception & Administration"

/area/lv759/indoors/nt_research_complex/cargo
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Requisitions & Cargo"
	minimap_color = MINIMAP_AREA_REQ_CAVE

/area/lv759/indoors/nt_research_complex/researchanddevelopment
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Technology Research & Development Lab"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/lv759/indoors/nt_research_complex/mainlabs
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Advanced Chemical Testing & Research Lab"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/lv759/indoors/nt_research_complex/xenobiology
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Advanced Xenobiology Lab"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	ambience = list('sound/effects/urban/indoors/lab_ambience_2.ogg')

/area/lv759/indoors/nt_research_complex/weaponresearchlab
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Advanced Weapon Research Lab"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/lv759/indoors/nt_research_complex/weaponresearchlabtesting
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Advanced Weapon Research Lab - Weapons Testing Range"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/lv759/indoors/nt_research_complex/xenoarcheology
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Xenoarcheology Research Lab"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/lv759/indoors/nt_research_complex/vehicledeploymentbay
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Vehicle Deployment & Maintenance Bay"
	minimap_color = MINIMAP_AREA_REQ_CAVE

/area/lv759/indoors/nt_research_complex/janitor
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Janitorial Supplies Storage"
	minimap_color = MINIMAP_AREA_LIVING_CAVE

/area/lv759/indoors/nt_research_complex/cafeteria
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Cafeteria"
	minimap_color = MINIMAP_AREA_LIVING_CAVE

/area/lv759/indoors/nt_research_complex/cafeteriakitchen
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Cafeteria - Kitchen"
	minimap_color = MINIMAP_AREA_LIVING_CAVE

/area/lv759/indoors/nt_research_complex/dormsfoyer
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Dorms Foyer"
	minimap_color = MINIMAP_AREA_LIVING_CAVE

/area/lv759/indoors/nt_research_complex/dormsbedroom
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Dorms"
	minimap_color = MINIMAP_AREA_LIVING_CAVE

/area/lv759/indoors/nt_research_complex/securitycommand
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Security Command Center & Deployment"
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/lv759/indoors/nt_research_complex/securityarmory
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Armory"
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/lv759/indoors/nt_research_complex/hangarbay
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Hangar Bay"
	minimap_color = MINIMAP_AREA_ESCAPE_CAVE
	ambience = list('sound/effects/urban/indoors/lab_ambience_hallway.ogg')

/area/lv759/indoors/nt_research_complex/hangarbayshuttle
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Hangar Bay - Nanotrasen PMC ERT Shuttle"
	minimap_color = MINIMAP_AREA_ESCAPE_CAVE
	ambience = list('sound/effects/urban/indoors/lab_ambience_hallway.ogg')

/area/lv759/indoors/nt_research_complex/hallwaynorth
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Technology Research & Development Lab"
	ambience = list('sound/effects/urban/indoors/lab_ambience_hallway.ogg')

/area/lv759/indoors/nt_research_complex/hallwaynorthexit
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - North Hallway - Personnel Exit East"
	ambience = list('sound/effects/urban/indoors/lab_ambience_hallway.ogg')

/area/lv759/indoors/nt_research_complex/hallwayeast
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Hallway East"
	ambience = list('sound/effects/urban/indoors/lab_ambience_hallway.ogg')

/area/lv759/indoors/nt_research_complex/hallwaycentral
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Central Hallway"
	ambience = list('sound/effects/urban/indoors/lab_ambience_hallway.ogg')

/area/lv759/indoors/nt_research_complex/hallwaysouthwest
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - South West Hallway"
	ambience = list('sound/effects/urban/indoors/lab_ambience_hallway.ogg')

/area/lv759/indoors/nt_research_complex/hallwaysoutheast
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - South East Hallway"
	ambience = list('sound/effects/urban/indoors/lab_ambience_hallway.ogg')

/area/lv759/indoors/nt_research_complex/southeastexit
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - South East Maintenace & Emergency Exit"

/area/lv759/indoors/nt_research_complex/changingroom
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Locker Room"
	minimap_color = MINIMAP_AREA_LIVING_CAVE
