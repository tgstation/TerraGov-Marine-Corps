//lv759 AREAS--------------------------------------//

/area/lv759
	name = "LV-759 Hybrisa Prospera"
	icon = 'icons/turf/hybrisareas.dmi'
	icon_state = "hybrisa"
	can_build_special = TRUE
	powernet_name = "ground"
	minimap_color = MINIMAP_AREA_COLONY

//parent types

/area/lv759/indoors
	name = "Hybrisa - Indoors"
	icon_state = "cliff_blocked"//because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_METAL
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
	ambience_exterior = AMBIENCE_HYBRISA_INTERIOR
/area/lv759/outdoors
	name = "Hybrisa - Outdoors"
	icon_state = "cliff_blocked"//because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_NONE
	soundscape_playlist = SCAPE_PL_LV759_OUTDOORS
	ambience_exterior = AMBIENCE_CITY
	soundscape_interval = 25
/area/lv759/oob
	name = "Out Of Bounds"
	icon_state = "oob"
	ceiling = CEILING_MAX
	is_resin_allowed = FALSE
	flags_area = AREA_NOTUNNEL

// Landing Zone 1
/area/lv759/outdoors/landing_zone_1
	name = "Nova Medica Hospital Complex - Emergency Response Landing Zone One"
	icon_state = "medical_lz1"
	is_resin_allowed =  FALSE
	is_landing_zone = TRUE
	minimap_color = MINIMAP_AREA_LZ
	ceiling = CEILING_NONE
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
	is_resin_allowed =  FALSE
	is_landing_zone = TRUE
	minimap_color = MINIMAP_AREA_LZ
	ceiling = CEILING_NONE
/area/lv759/indoors/landing_zone_2/kmcc_hub_flight_control_room
	name = "KMCC Interstellar Freight Hub - Flight Control Room"
	icon_state = "hybrisa"
/area/lv759/indoors/landing_zone_2/kmcc_hub_security
	name = "KMCC Interstellar Freight Hub - Security Checkpoint Office"
	icon_state = "security_checkpoint"
/area/lv759/indoors/landing_zone_2/kmcc_hub_lounge_north
	name = "KMCC Interstellar Freight Hub - Passenger Departures - Lounge North"
	icon_state = "hybrisa"
/area/lv759/indoors/landing_zone_2/kmcc_hub_fuel
	name = "KMCC Interstellar Freight Hub - Fuel Storage & Maintenance - North"
	icon_state = "hybrisa"
/area/lv759/indoors/landing_zone_2/kmcc_hub_lounge_south
	name = "KMCC Interstellar Freight Hub - Passenger Departures - Lounge South"
	icon_state = "hybrisa"
/area/lv759/indoors/landing_zone_2/kmcc_hub_lounge_hallway
	name = "KMCC Interstellar Freight Hub - Passenger Departures - Hallway"
	icon_state = "hybrisa"
/area/lv759/indoors/landing_zone_2/kmcc_hub_south_office
	name = "KMCC Interstellar Freight Hub - Passenger Departures - South Office"
	icon_state = "hybrisa"
/area/lv759/indoors/landing_zone_2/kmcc_hub_maintenance
	name = "KMCC Interstellar Freight Hub - Passenger Departures - Maintenance"
	icon_state = "hybrisa"
/area/lv759/indoors/landing_zone_2/kmcc_hub/lz2_console
	name = "KMCC Interstellar Freight Hub - Dropship Normandy Console"
	icon_state = "hybrisa"
	requires_power = FALSE
	ceiling = CEILING_METAL
/area/lv759/indoors/landing_zone_2/kmcc_hub_cargo
	name = "KMCC Interstellar Freight Hub - Cargo Processing Center"
	icon_state = "mining_cargo"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/landing_zone_2/kmcc_hub_maintenance_north
	name = "KMCC Interstellar Freight Hub - Cargo Processing Center - Maintenance"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY

// Derelict Ship
/area/lv759/indoors/derelict_ship
	name = "Derelict Ship"
	icon_state = "derelictship"
	ceiling = CEILING_MAX
	flags_area = AREA_NOTUNNEL
	ambience_exterior = AMBIENCE_DERELICT
	soundscape_playlist = SCAPE_PL_LV759_DERELICTSHIP

// Caves
/area/lv759/indoors/wy_research_complex_entrance
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - North Main Entrance"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES_ALARM
	soundscape_playlist = SCAPE_PL_LV759_DEEPCAVES
/area/lv759/indoors/west_caves
	name = "Caverns - West"
	icon_state = "caves_west"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_CAVES
/area/lv759/indoors/west_caves_alarm
	name = "Caverns - West"
	icon_state = "caves_west"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES_ALARM
	soundscape_playlist = SCAPE_PL_LV759_CAVES
/area/lv759/indoors/east_caves
	name = "Caverns - East"
	icon_state = "caves_east"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_DEEPCAVES
/area/lv759/indoors/south_caves
	name = "Caverns - South"
	icon_state = "caves_south"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_DEEPCAVES
/area/lv759/indoors/south_east_caves
	name = "Caverns - Southeast"
	icon_state = "caves_southeast"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_DEEPCAVES
/area/lv759/indoors/south_west_caves
	name = "Caverns - Southwest"
	icon_state = "caves_southwest"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_DEEPCAVES
/area/lv759/indoors/south_west_caves_alarm
	name = "Caverns - Southwest"
	icon_state = "caves_southwest"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES_ALARM
	soundscape_playlist = SCAPE_PL_LV759_DEEPCAVES
/area/lv759/indoors/north_west_caves
	name = "Caverns - Northwest"
	icon_state = "caves_northwest"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_DEEPCAVES
/area/lv759/outdoors/north_west_caves_outdoors
	name = "Caverns - Northwest"
	icon_state = "caves_northwest"
	ceiling = CEILING_NONE
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_CAVES
/area/lv759/indoors/north_east_caves
	name = "Caverns - Northeast"
	icon_state = "caves_northeast"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_CAVES
/area/lv759/indoors/north_caves
	name = "Caverns - North"
	icon_state = "caves_north"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_DEEPCAVES
/area/lv759/indoors/central_caves
	name = "Caverns - Central"
	icon_state = "caves_central"
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_CAVES


// Caves Central Plateau
/area/lv759/outdoors/caveplateau
	name = "Caverns - Plateau"
	icon_state = "caves_plateau"
	ceiling = CEILING_NONE
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_PLATEAU_OUTDOORS

// Colony Streets
/area/lv759/outdoors/colony_streets
	name = "Colony Streets"
	icon_state = "colonystreets_north"
	ceiling = CEILING_NONE
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
	name = "Colony Streets - Southwest - WY Checkpoint Passthrough"
	icon_state = "colonystreets_southwest"
	ceiling = CEILING_NONE
	ambience_exterior = AMBIENCE_HYBRISA_CAVES
	soundscape_playlist = SCAPE_PL_LV759_CAVES
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
/area/lv759/indoors/spaceport/hallway_northeast
	name = "Nanotrasen Celestia Gateway Space-Port - Hallway - Northeast"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/hallway_north
	name = "Nanotrasen Celestia Gateway Space-Port - Hallway - North"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/hallway_northwest
	name = "Nanotrasen Celestia Gateway Space-Port - Hallway - Northwest"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/hallway_east
	name = "Nanotrasen Celestia Gateway Space-Port - Hallway - East"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/heavyequip
	name = "Nanotrasen Celestia Gateway Space-Port - Heavy Equipment Storage"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/engineering
	name = "Nanotrasen Celestia Gateway Space-Port - Fuel Storage & Processing"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/janitor
	name = "Nanotrasen Celestia Gateway Space-Port - Janitorial Storage Room"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/maintenance_east
	name = "Nanotrasen Celestia Gateway Space-Port - Maintenance - East"
	icon_state = "WYSpaceport"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/communications_office
	name = "Nanotrasen Celestia Gateway Space-Port - Communications & Administration Office"
	icon_state = "WYSpaceportadmin"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/flight_control_room
	name = "Nanotrasen Celestia Gateway Space-Port - Flight Control Room"
	icon_state = "WYSpaceportadmin"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/security
	name = "Nanotrasen Celestia Gateway Space-Port - Security- Observation & Office"
	icon_state = "security_checkpoint"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/security_office
	name = "Nanotrasen Celestia Gateway Space-Port - Office"
	icon_state = "security_checkpoint"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/cargo
	name = "Nanotrasen Celestia Gateway Space-Port - Cargo"
	icon_state = "WYSpaceportcargo"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/cargo_maintenance
	name = "Nanotrasen Celestia Gateway Space-Port - Cargo - Maintenance"
	icon_state = "WYSpaceportcargo"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/baggagehandling
	name = "Nanotrasen Celestia Gateway Space-Port - Baggage Storage & Handling"
	icon_state = "WYSpaceportbaggage"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/cuppajoes
	name = "Nanotrasen Celestia Gateway Space-Port - Cuppa Joe's"
	icon_state = "cuppajoes"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/kitchen
	name = "Nanotrasen Celestia Gateway Space-Port - Kitchen"
	icon_state = "WYSpaceportblue"
	minimap_color = MINIMAP_AREA_LZ
/area/lv759/indoors/spaceport/docking_bay_2
	name = "Nanotrasen Celestia Gateway Space-Port - Docking Bay: 2 - Refueling and Maintenance"
	icon_state = "WYSpaceportblue"

/area/lv759/indoors/spaceport/docking_bay_1
	name = "Nanotrasen Celestia Gateway Space-Port - Docking Bay: 1"
	icon_state = "WYSpaceport"

/area/lv759/indoors/spaceport/starglider
	name = "WY-LWI StarGlider SG-200"
	icon_state = "wydropship"
	requires_power = FALSE
/area/lv759/indoors/spaceport/horizon_runner
	name = "WY-LWI Horizon Runner HR-150"
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
/area/lv759/indoors/meridian/meridian_foyer
	name = "Meridian - Foyer"
	icon_state = "meridian"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/meridian/meridian_showroom
	name = "Meridian - Showroom"
	icon_state = "meridian"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/meridian/meridian_office
	name = "Meridian - Office"
	icon_state = "meridian"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/meridian/meridian_managersoffice
	name = "Meridian - Manager's Office"
	icon_state = "meridian"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/meridian/meridian_factory
	name = "Meridian - Factory Floor"
	icon_state = "meridian_factory"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/meridian/meridian_restroom
	name = "Meridian - Restroom"
	icon_state = "meridian"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/meridian/meridian_maintenance_south
	name = "Meridian - Maintenance South"
	icon_state = "meridian"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/meridian/meridian_maintenance_east
	name = "Meridian - Factory Floor - Maintenance"
	icon_state = "meridian"
	minimap_color = MINIMAP_AREA_COLONY

// Apartments (Dorms)
/area/lv759/indoors/apartment/westfoyer
	name = "Westhaven Apartment Complex - West - Foyer"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/apartment/westhallway
	name = "Westhaven Apartment Complex - West - Hallway"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/westbedrooms
	name = "Westhaven Apartment Complex - West - Bedrooms"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/westshowers
	name = "Westhaven Apartment Complex - West - Showers"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/westrestroom
	name = "Westhaven Apartment Complex - West - Restrooms"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/westentertainment
	name = "Westhaven Apartment Complex - West - Recreation Hub"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY



/area/lv759/indoors/apartment/eastentrance
	name = "Westhaven Apartment Complex - East - Entrance Room"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/eastfoyer
	name = "Westhaven Apartment Complex - East - Foyer"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/eastrestroomsshower
	name = "Westhaven Apartment Complex - East - Restrooms & Showers"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/eastbedrooms
	name = "Westhaven Apartment Complex - East - Bedrooms"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/eastbedroomsstorage
	name = "Westhaven Apartment Complex - East - Bedrooms - Storage Room"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/apartment/northfoyer
	name = "Westhaven Apartment Complex - North - Foyer"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/northhallway
	name = "Westhaven Apartment Complex - North - Hallway"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/apartment/northapartments
	name = "Westhaven Apartment Complex - North - Luxury Apartments"
	icon_state = "apartments"
	minimap_color = MINIMAP_AREA_COLONY

// Nanotrasen Offices
/area/lv759/indoors/weyyu_office
	name = "Nanotrasen Offices - Reception Hallway"
	icon_state = "wyoffice"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lv759/indoors/weyyu_office/hallway
	name = "Nanotrasen Offices - West Foyer"
	icon_state = "wyoffice"

/area/lv759/indoors/weyyu_office/floor
	name = "Nanotrasen Offices - Main Office Floor"

/area/lv759/indoors/weyyu_office/breakroom
	name = "Nanotrasen Offices - Breakroom"

/area/lv759/indoors/weyyu_office/vip
	name = "Nanotrasen Offices - Conference Room"

/area/lv759/indoors/weyyu_office/pressroom
	name = "Nanotrasen Offices - Assembly Hall"
/area/lv759/indoors/weyyu_office/supervisor
	name = "Nanotrasen Offices - Colony Supervisors Office"

// Bar & Entertainment Complex
/area/lv759/indoors/bar
	name = "Bar"
	icon_state = "bar"
	minimap_color = MINIMAP_AREA_COLONY

/area/lv759/indoors/bar/entertainment
	name = "Bar - Entertainment Subsection"
/area/lv759/indoors/bar/bathroom
	name = "Bar - Restrooms"
/area/lv759/indoors/bar/maintenance
	name = "Bar - Maintenance"
/area/lv759/indoors/bar/kitchen
	name = "Bar - Kitchen"

//Botany
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
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/north
	name = "KMCC - Mining Outpost - North"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/north_maint
	name = "KMCC - Mining Outpost - North - Maintenance"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/northeast
	name = "KMCC - Mining Outpost - Northeast"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/south
	name = "KMCC - Mining Outpost - South"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/vehicledeployment
	name = "KMCC - Mining Vehicle Deployment South"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/processing
	name = "KMCC - Mining Processing & Storage"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/east
	name = "KMCC - Mining Outpost - East"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/east_dorms
	name = "KMCC - Mining Outpost - East Dorms"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/east_deploymentbay
	name = "KMCC - Mining Outpost - East - Deployment Bay"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/east_command
	name = "KMCC - Mining Outpost - East - Command Center"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/mining_outpost/cargo_maint
	name = "KMCC - Mining Outpost - East - Maintenance"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_COLONY
// Electrical Substations
/area/lv759/indoors/electical_systems/substation1
	name = "Electrical Systems - Substation One - Control Room"
	icon_state = "power0"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/electical_systems/substation2
	name = "Electrical Systems - Substation Two"
	icon_state = "power0"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/electical_systems/substation3
	name = "Electrical Systems - Substation Three"
	icon_state = "power0"
	minimap_color = MINIMAP_AREA_COLONY

// Power-Plant (Engineering)
/area/lv759/indoors/power_plant
	name = "Nanotrasen DynaGrid Nexus - Central Hallway"
	icon_state = "power0"
	minimap_color = MINIMAP_AREA_COLONY
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
	minimap_color = MINIMAP_AREA_COLONY

//Nanotrasen - Resource Recovery Facility
/area/lv759/indoors/recycling_plant
	name = "Nanotrasen - Resource Recovery Facility"
	icon_state = "recycling"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/recycling_plant/garage
	name = "Nanotrasen - Resource Recovery Facility - Garage"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/recycling_plant/synthetic_storage
	name = "Synthetic Storage"
	icon_state = "synthetic"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/recycling_plant_office
	name = "Nanotrasen - Resource Recovery Facility - Office"
	icon_state = "recycling"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/recycling_plant_waste_disposal_incinerator
	name = "Nanotrasen - Resource Recovery Facility - Waste Disposal Incinerating Room"
	icon_state = "recycling"
	minimap_color = MINIMAP_AREA_COLONY
// Restrooms
/area/lv759/indoors/south_public_restroom
	name = "Public Restroom - South"
	icon_state = "restroom"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/southwest_public_restroom
	name = "Public Restroom - Southwest"
	icon_state = "restroom"
	minimap_color = MINIMAP_AREA_COLONY

//Nightgold Casino
/area/lv759/indoors/casino
	name = "Night Gold Casino"
	icon_state = "nightgold"
	minimap_color = MINIMAP_AREA_ENGI
/area/lv759/indoors/casino/casino_office
	name = "Night Gold Casino - Managers Office"
	icon_state = "nightgold"
	minimap_color = MINIMAP_AREA_ENGI
/area/lv759/indoors/casino/casino_restroom
	name = "Night Gold Casino - Restroom"
	icon_state = "nightgold"
	minimap_color = MINIMAP_AREA_ENGI
/area/lv759/indoors/casino/casino_vault
	name = "Night Gold Casino - Vault"
	icon_state = "nightgold"
	minimap_color = MINIMAP_AREA_ENGI

// Pizza
/area/lv759/indoors/pizzaria
	name = "Pizza Galaxy - Outpost Zeta"
	icon_state = "pizza"
	minimap_color = MINIMAP_AREA_ENGI

//T-comms
/area/lv759/indoors/tcomms_northwest
	name = "Telecommunications Substation - Northwest"
	icon_state = "comms_1"
	minimap_color = MINIMAP_AREA_ENGI

// Weymart
/area/lv759/indoors/weymart
	name = "Weymart"
	icon_state = "weymart"
	minimap_color = MINIMAP_AREA_COMMAND
	ambience_exterior = AMBIENCE_WEYMART
/area/lv759/indoors/weymart/backrooms
	name = "Weymart - Backrooms"
	icon_state = "weymartbackrooms"
	minimap_color = MINIMAP_AREA_COMMAND
/area/lv759/indoors/weymart/maintenance
	name = "Weymart - Maintenance"
	icon_state = "weymartbackrooms"
	minimap_color = MINIMAP_AREA_COMMAND

// WY Security Checkpoints
/area/lv759/indoors/wy_security/checkpoint_northeast
	name = "Nanotrasen Security Checkpoint - North East"
	icon_state = "security_checkpoint_northeast"
	minimap_color = MINIMAP_AREA_COLONY
/area/lv759/indoors/wy_security/checkpoint_east
	name = "Nanotrasen Security Checkpoint - East"
	icon_state = "security_checkpoint_east"
/area/lv759/indoors/wy_security/checkpoint_central
	name = "Nanotrasen Security Checkpoint - Central"
	icon_state = "security_checkpoint_central"
/area/lv759/indoors/wy_security/checkpoint_west
	name = "Nanotrasen Security Checkpoint - West"
	icon_state = "security_checkpoint_west"
/area/lv759/indoors/wy_security/checkpoint_northwest
	name = "Nanotrasen Security Checkpoint - North West"
	icon_state = "security_checkpoint_northwest"

// Misc
/area/lv759/indoors/hobosecret
	name = "Hidden Hobo Haven"
	icon_state = "hobo"
	ceiling = CEILING_REINFORCED_METAL
	is_resin_allowed = FALSE
	flags_area = AREA_NOTUNNEL

// Nanotrasen Advanced Bio-Genomic Research Complex

/area/lv759/indoors/wy_research_complex
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex"
	icon_state = "wylab"
	minimap_color = MINIMAP_AREA_COMMAND
/area/lv759/indoors/wy_research_complex/medical_annex
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Medical Annex Building"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/reception
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Reception & Administration"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/cargo
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Requisitions & Cargo"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/researchanddevelopment
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Technology Research & Development Lab"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/mainlabs
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Advanced Chemical Testing & Research Lab"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/xenobiology
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Advanced Xenobiology Lab"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_2
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/weaponresearchlab
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Advanced Weapon Research Lab"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/weaponresearchlabtesting
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Advanced Weapon Research Lab - Weapons Testing Range"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/xenoarcheology
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Xenoarcheology Research Lab"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/vehicledeploymentbay
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Vehicle Deployment & Maintenance Bay"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/janitor
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Janitorial Supplies Storage"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/cafeteria
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Cafeteria"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/cafeteriakitchen
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Cafeteria - Kitchen"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/dormsfoyer
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Dorms Foyer"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/dormsbedroom
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Dorms"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/securitycommand
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Security Command Center & Deployment"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/securityarmory
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Armory"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/hangarbay
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Hangar Bay"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/hangarbayshuttle
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Hangar Bay - Nanotrasen PMC ERT Shuttle"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/hallwaynorth
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Technology Research & Development Lab"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/hallwaynorthexit
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - North Hallway - Personnel Exit East"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/hallwayeast
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Hallway East"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/hallwaycentral
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Central Hallway"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/hallwaysouthwest
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - South West Hallway"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/hallwaysoutheast
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - South East Hallway"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/southeastexit
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - South East Maintenace & Emergency Exit"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB_HALLWAY
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
/area/lv759/indoors/wy_research_complex/changingroom
	name = "Nanotrasen - Advanced Bio-Genomic Research Complex - Locker Room"
	icon_state = "wylab"
	ambience_exterior = AMBIENCE_LAB
	soundscape_playlist = SCAPE_PL_LV759_INDOORS
