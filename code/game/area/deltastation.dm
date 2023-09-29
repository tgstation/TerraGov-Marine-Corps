// Station areas and shuttles

/area/deltastation/
	name = "Station Areas"
	icon = 'icons/turf/areas_station.dmi'
	icon_state = "station"

//Maintenance

/area/deltastation/maintenance
	name = "Generic Maintenance"
	minimap_color = MINIMAP_AREA_COLONY

//Maintenance - Departmental

/area/deltastation/maintenance/department/chapel
	name = "Chapel Maintenance"
	icon_state = "maint_chapel"

/area/deltastation/maintenance/department/chapel/monastery
	name = "Monastery Maintenance"
	icon_state = "maint_monastery"

/area/deltastation/maintenance/department/crew_quarters/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"

/area/deltastation/maintenance/department/crew_quarters/dorms
	name = "Dormitory Maintenance"
	icon_state = "maint_dorms"

/area/deltastation/maintenance/department/eva
	name = "EVA Maintenance"
	icon_state = "maint_eva"

/area/deltastation/maintenance/department/eva/abandoned
	name = "Abandoned EVA Storage"

/area/deltastation/maintenance/department/electrical
	name = "Electrical Maintenance"
	icon_state = "maint_electrical"
	minimap_color = MINIMAP_AREA_ENGI

/area/deltastation/maintenance/department/engine/atmos
	name = "Atmospherics Maintenance"
	icon_state = "maint_atmos"

/area/deltastation/maintenance/department/security
	name = "Security Maintenance"
	icon_state = "maint_sec"

/area/deltastation/maintenance/department/security/upper
	name = "Upper Security Maintenance"

/area/deltastation/maintenance/department/security/brig
	name = "Brig Maintenance"
	icon_state = "maint_brig"

/area/deltastation/maintenance/department/medical
	name = "Medbay Maintenance"
	icon_state = "medbay_maint"

/area/deltastation/maintenance/department/medical/central
	name = "Central Medbay Maintenance"
	icon_state = "medbay_maint_central"

/area/deltastation/maintenance/department/medical/morgue
	name = "Morgue Maintenance"
	icon_state = "morgue_maint"

/area/deltastation/maintenance/department/science
	name = "Science Maintenance"
	icon_state = "maint_sci"

/area/deltastation/maintenance/department/science/central
	name = "Central Science Maintenance"
	icon_state = "maint_sci_central"

/area/deltastation/maintenance/department/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/deltastation/maintenance/department/bridge
	name = "Bridge Maintenance"
	icon_state = "maint_bridge"

/area/deltastation/maintenance/department/engine
	name = "Engineering Maintenance"
	icon_state = "maint_engi"

/area/deltastation/maintenance/department/science/xenobiology
	name = "Xenobiology Maintenance"
	icon_state = "xenomaint"

//Maintenance - Generic Tunnels

/area/deltastation/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "aftmaint"

/area/deltastation/maintenance/aft/upper
	name = "Upper Aft Maintenance"
	icon_state = "upperaftmaint"

/area/deltastation/maintenance/aft/greater //use greater variants of area definitions for when the station has two different sections of maintenance on the same z-level. Can stand alone without "lesser". This one means that this goes more fore/north than the "lesser" maintenance area.
	name = "Greater Aft Maintenance"
	icon_state = "greateraftmaint"

/area/deltastation/maintenance/aft/lesser //use lesser variants of area definitions for when the station has two different sections of maintenance on the same z-level in conjunction with "greater" (just because it follows better). This one means that this goes more aft/south than the "greater" maintenance area.
	name = "Lesser Aft Maintenance"
	icon_state = "lesseraftmaint"

/area/deltastation/maintenance/central
	name = "Central Maintenance"
	icon_state = "centralmaint"

/area/deltastation/maintenance/central/greater
	name = "Greater Central Maintenance"
	icon_state = "greatercentralmaint"

/area/deltastation/maintenance/central/lesser
	name = "Lesser Central Maintenance"
	icon_state = "lessercentralmaint"

/area/deltastation/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "foremaint"

/area/deltastation/maintenance/fore/upper
	name = "Upper Fore Maintenance"
	icon_state = "upperforemaint"

/area/deltastation/maintenance/fore/greater
	name = "Greater Fore Maintenance"
	icon_state = "greaterforemaint"

/area/deltastation/maintenance/fore/lesser
	name = "Lesser Fore Maintenance"
	icon_state = "lesserforemaint"

/area/deltastation/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "starboardmaint"

/area/deltastation/maintenance/starboard/upper
	name = "Upper Starboard Maintenance"
	icon_state = "upperstarboardmaint"

/area/deltastation/maintenance/starboard/central
	name = "Central Starboard Maintenance"
	icon_state = "centralstarboardmaint"

/area/deltastation/maintenance/starboard/greater
	name = "Greater Starboard Maintenance"
	icon_state = "greaterstarboardmaint"

/area/deltastation/maintenance/starboard/lesser
	name = "Lesser Starboard Maintenance"
	icon_state = "lesserstarboardmaint"

/area/deltastation/maintenance/starboard/aft
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/deltastation/maintenance/starboard/fore
	name = "Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/deltastation/maintenance/port
	name = "Port Maintenance"
	icon_state = "portmaint"

/area/deltastation/maintenance/port/central
	name = "Central Port Maintenance"
	icon_state = "centralportmaint"

/area/deltastation/maintenance/port/greater
	name = "Greater Port Maintenance"
	icon_state = "greaterportmaint"

/area/deltastation/maintenance/port/lesser
	name = "Lesser Port Maintenance"
	icon_state = "lesserportmaint"

/area/deltastation/maintenance/port/aft
	name = "Aft Port Maintenance"
	icon_state = "apmaint"

/area/deltastation/maintenance/port/fore
	name = "Fore Port Maintenance"
	icon_state = "fpmaint"

/area/deltastation/maintenance/tram
	name = "Primary Tram Maintenance"

/area/deltastation/maintenance/tram/left
	name = "\improper Port Tram Underpass"
	icon_state = "mainttramL"

/area/deltastation/maintenance/tram/mid
	name = "\improper Central Tram Underpass"
	icon_state = "mainttramM"

/area/deltastation/maintenance/tram/right
	name = "\improper Starboard Tram Underpass"
	icon_state = "mainttramR"

//Maintenance - Discrete Areas
/area/deltastation/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/deltastation/maintenance/disposal/incinerator
	name = "\improper Incinerator"
	icon_state = "incinerator"

/area/deltastation/maintenance/space_hut
	name = "\improper Space Hut"
	icon_state = "spacehut"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES
	outside = FALSE
	requires_power = FALSE

/area/deltastation/maintenance/space_hut/cabin
	name = "Abandoned Cabin"

/area/deltastation/maintenance/space_hut/plasmaman
	name = "\improper Abandoned Plasmaman Friendly Startup"

/area/deltastation/maintenance/space_hut/observatory
	name = "\improper Space Observatory"

//Radation storm shelter
/area/deltastation/maintenance/radshelter
	name = "\improper Radstorm Shelter"
	icon_state = "radstorm_shelter"

/area/deltastation/maintenance/radshelter/medical
	name = "\improper Medical Radstorm Shelter"

/area/deltastation/maintenance/radshelter/sec
	name = "\improper Security Radstorm Shelter"

/area/deltastation/maintenance/radshelter/service
	name = "\improper Service Radstorm Shelter"

/area/deltastation/maintenance/radshelter/civil
	name = "\improper Civilian Radstorm Shelter"

/area/deltastation/maintenance/radshelter/sci
	name = "\improper Science Radstorm Shelter"

/area/deltastation/maintenance/radshelter/cargo
	name = "\improper Cargo Radstorm Shelter"


//Hallway

/area/deltastation/hallway
	icon_state = "hall"

/area/deltastation/hallway/primary
	name = "\improper Primary Hallway"
	icon_state = "primaryhall"

/area/deltastation/hallway/primary/aft
	name = "\improper Aft Primary Hallway"
	icon_state = "afthall"

/area/deltastation/hallway/primary/fore
	name = "\improper Fore Primary Hallway"
	icon_state = "forehall"

/area/deltastation/hallway/primary/starboard
	name = "\improper Starboard Primary Hallway"
	icon_state = "starboardhall"

/area/deltastation/hallway/primary/port
	name = "\improper Port Primary Hallway"
	icon_state = "porthall"

/area/deltastation/hallway/primary/central
	name = "\improper Central Primary Hallway"
	icon_state = "centralhall"

/area/deltastation/hallway/primary/central/fore
	name = "\improper Fore Central Primary Hallway"
	icon_state = "hallCF"

/area/deltastation/hallway/primary/central/aft
	name = "\improper Aft Central Primary Hallway"
	icon_state = "hallCA"

/area/deltastation/hallway/primary/upper
	name = "\improper Upper Central Primary Hallway"
	icon_state = "centralhall"

/area/deltastation/hallway/primary/tram
	name = "\improper Primary Tram"

/area/deltastation/hallway/primary/tram/left
	name = "\improper Port Tram Dock"
	icon_state = "halltramL"

/area/deltastation/hallway/primary/tram/center
	name = "\improper Central Tram Dock"
	icon_state = "halltramM"

/area/deltastation/hallway/primary/tram/right
	name = "\improper Starboard Tram Dock"
	icon_state = "halltramR"

/area/deltastation/hallway/secondary // This shouldn't be used, but it gives an icon for the enviornment tree in the map editor
	icon_state = "secondaryhall"

/area/deltastation/hallway/secondary/command
	name = "\improper Command Hallway"
	icon_state = "bridge_hallway"

/area/deltastation/hallway/secondary/construction
	name = "\improper Construction Area"
	icon_state = "construction"

/area/deltastation/hallway/secondary/construction/engineering
	name = "\improper Engineering Hallway"

/area/deltastation/hallway/secondary/exit
	name = "\improper Escape Shuttle Hallway"
	icon_state = "escape"

/area/deltastation/hallway/secondary/exit/departure_lounge
	name = "\improper Departure Lounge"
	icon_state = "escape_lounge"

/area/deltastation/hallway/secondary/entry
	name = "\improper Arrival Shuttle Hallway"
	icon_state = "entry"

/area/deltastation/hallway/secondary/service
	name = "\improper Service Hallway"
	icon_state = "hall_service"

//Command

/area/deltastation/command
	name = "Command"
	icon_state = "command"
	minimap_color = MINIMAP_AREA_COMMAND

/area/deltastation/command/bridge
	name = "\improper Bridge"
	icon_state = "bridge"

/area/deltastation/command/meeting_room
	name = "\improper Heads of Staff Meeting Room"
	icon_state = "meeting"

/area/deltastation/command/meeting_room/council
	name = "\improper Council Chamber"
	icon_state = "meeting"

/area/deltastation/command/corporate_showroom
	name = "\improper Corporate Showroom"
	icon_state = "showroom"

/area/deltastation/command/heads_quarters
	icon_state = "heads_quarters"

/area/deltastation/command/heads_quarters/captain
	name = "\improper Captain's Office"
	icon_state = "captain"

/area/deltastation/command/heads_quarters/captain/private
	name = "\improper Captain's Quarters"
	icon_state = "captain_private"

/area/deltastation/command/heads_quarters/ce
	name = "\improper Chief Engineer's Office"
	icon_state = "ce_office"

/area/deltastation/command/heads_quarters/cmo
	name = "\improper Chief Medical Officer's Office"
	icon_state = "cmo_office"

/area/deltastation/command/heads_quarters/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "hop_office"

/area/deltastation/command/heads_quarters/hos
	name = "\improper Head of Security's Office"
	icon_state = "hos_office"

/area/deltastation/command/heads_quarters/rd
	name = "\improper Research Director's Office"
	icon_state = "rd_office"

/area/deltastation/command/heads_quarters/qm
	name = "\improper Quartermaster's Office"
	icon_state = "qm_office"

//Command - Teleporters

/area/deltastation/command/teleporter
	name = "\improper Teleporter Room"
	icon_state = "teleporter"

/area/deltastation/command/gateway
	name = "\improper Gateway"
	icon_state = "gateway"

//Commons

/area/deltastation/commons
	name = "\improper Crew Facilities"
	icon_state = "commons"
	minimap_color = MINIMAP_AREA_LIVING

/area/deltastation/commons/dorms
	name = "\improper Dormitories"
	icon_state = "dorms"

/area/deltastation/commons/dorms/barracks
	name = "\improper Sleep Barracks"

/area/deltastation/commons/dorms/barracks/male
	name = "\improper Male Sleep Barracks"
	icon_state = "dorms_male"

/area/deltastation/commons/dorms/barracks/female
	name = "\improper Female Sleep Barracks"
	icon_state = "dorms_female"

/area/deltastation/commons/dorms/laundry
	name = "\improper Laundry Room"
	icon_state = "laundry_room"

/area/deltastation/commons/toilet
	name = "\improper Dormitory Toilets"
	icon_state = "toilet"

/area/deltastation/commons/toilet/auxiliary
	name = "\improper Auxiliary Restrooms"
	icon_state = "toilet"

/area/deltastation/commons/toilet/locker
	name = "\improper Locker Toilets"
	icon_state = "toilet"

/area/deltastation/commons/toilet/restrooms
	name = "\improper Restrooms"
	icon_state = "toilet"

/area/deltastation/commons/locker
	name = "\improper Locker Room"
	icon_state = "locker"

/area/deltastation/commons/lounge
	name = "\improper Bar Lounge"
	icon_state = "lounge"

/area/deltastation/commons/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"
	minimap_color = MINIMAP_AREA_LIVING

/area/deltastation/commons/fitness/locker_room
	name = "\improper Unisex Locker Room"
	icon_state = "locker"

/area/deltastation/commons/fitness/locker_room/male
	name = "\improper Male Locker Room"
	icon_state = "locker_male"

/area/deltastation/commons/fitness/locker_room/female
	name = "\improper Female Locker Room"
	icon_state = "locker_female"

/area/deltastation/commons/fitness/recreation
	name = "\improper Recreation Area"
	icon_state = "rec"

/area/deltastation/commons/fitness/recreation/entertainment
	name = "\improper Entertainment Center"
	icon_state = "entertainment"

// Commons - Vacant Rooms
/area/deltastation/commons/vacant_room
	name = "\improper Vacant Room"
	icon_state = "vacant_room"

/area/deltastation/commons/vacant_room/office
	name = "\improper Vacant Office"
	icon_state = "vacant_office"

/area/deltastation/commons/vacant_room/commissary
	name = "\improper Vacant Commissary"
	icon_state = "vacant_commissary"

//Commons - Storage
/area/deltastation/commons/storage

/area/deltastation/commons/storage/tools
	name = "\improper Auxiliary Tool Storage"
	icon_state = "tool_storage"

/area/deltastation/commons/storage/primary
	name = "\improper Primary Tool Storage"
	icon_state = "primary_storage"

/area/deltastation/commons/storage/art
	name = "\improper Art Supply Storage"
	icon_state = "art_storage"

/area/deltastation/commons/storage/emergency/starboard
	name = "\improper Starboard Emergency Storage"
	icon_state = "emergency_storage"

/area/deltastation/commons/storage/emergency/port
	name = "\improper Port Emergency Storage"
	icon_state = "emergency_storage"

/area/deltastation/commons/storage/mining
	name = "\improper Public Mining Storage"
	icon_state = "mining_storage"

//Service

/area/deltastation/service
	minimap_color = MINIMAP_AREA_LIVING

/area/deltastation/service/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/deltastation/service/barber
	name = "\improper Barber"
	icon_state = "barber"

/area/deltastation/service/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/deltastation/service/kitchen/coldroom
	name = "\improper Kitchen Cold Room"
	icon_state = "kitchen_cold"

/area/deltastation/service/kitchen/diner
	name = "\improper Diner"
	icon_state = "diner"

/area/deltastation/service/kitchen/abandoned
	name = "\improper Abandoned Kitchen"
	icon_state = "abandoned_kitchen"

/area/deltastation/service/bar
	name = "\improper Bar"
	icon_state = "bar"

/area/deltastation/service/bar/atrium
	name = "\improper Atrium"
	icon_state = "bar"

/area/deltastation/service/bar/backroom
	name = "\improper Bar Backroom"
	icon_state = "bar_backroom"

/area/deltastation/service/electronic_marketing_den
	name = "\improper Electronic Marketing Den"
	icon_state = "abandoned_marketing_den"

/area/deltastation/service/abandoned_gambling_den
	name = "\improper Abandoned Gambling Den"
	icon_state = "abandoned_gambling_den"

/area/deltastation/service/abandoned_gambling_den/gaming
	name = "\improper Abandoned Gaming Den"
	icon_state = "abandoned_gaming_den"

/area/deltastation/service/theater
	name = "\improper Theater"
	icon_state = "theatre"

/area/deltastation/service/theater/abandoned
	name = "\improper Abandoned Theater"
	icon_state = "abandoned_theatre"

/area/deltastation/service/library
	name = "\improper Library"
	icon_state = "library"

/area/deltastation/service/library/lounge
	name = "\improper Library Lounge"
	icon_state = "library_lounge"

/area/deltastation/service/library/artgallery
	name = "\improper Art Gallery"
	icon_state = "library_gallery"

/area/deltastation/service/library/private
	name = "\improper Library Private Study"
	icon_state = "library_gallery_private"

/area/deltastation/service/library/upper
	name = "\improper Library Upper Floor"
	icon_state = "library"

/area/deltastation/service/library/printer
	name = "\improper Library Printer Room"
	icon_state = "library"

/area/deltastation/service/library/abandoned
	name = "\improper Abandoned Library"
	icon_state = "abandoned_library"

/area/deltastation/service/chapel
	name = "\improper Chapel"
	icon_state = "chapel"

/area/deltastation/service/chapel/monastery
	name = "\improper Monastery"

/area/deltastation/service/chapel/office
	name = "\improper Chapel Office"
	icon_state = "chapeloffice"

/area/deltastation/service/chapel/asteroid
	name = "\improper Chapel Asteroid"
	icon_state = "explored"

/area/deltastation/service/chapel/asteroid/monastery
	name = "\improper Monastery Asteroid"

/area/deltastation/service/chapel/dock
	name = "\improper Chapel Dock"
	icon_state = "construction"

/area/deltastation/service/chapel/storage
	name = "\improper Chapel Storage"
	icon_state = "chapelstorage"

/area/deltastation/service/chapel/funeral
	name = "\improper Chapel Funeral Room"
	icon_state = "chapelfuneral"

/area/deltastation/service/lawoffice
	name = "\improper Law Office"
	icon_state = "law"

/area/deltastation/service/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/deltastation/service/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"

/area/deltastation/service/hydroponics/upper
	name = "Upper Hydroponics"
	icon_state = "hydro"

/area/deltastation/service/hydroponics/garden
	name = "Garden"
	icon_state = "garden"

/area/deltastation/service/hydroponics/garden/abandoned
	name = "\improper Abandoned Garden"
	icon_state = "abandoned_garden"

/area/deltastation/service/hydroponics/garden/monastery
	name = "\improper Monastery Garden"
	icon_state = "hydro"

//Engineering

/area/deltastation/engineering
	icon_state = "engie"
	minimap_color = MINIMAP_AREA_ENGI

/area/deltastation/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"

/area/deltastation/engineering/main
	name = "Engineering"
	icon_state = "engine"

/area/deltastation/engineering/hallway
	name = "Engineering Hallway"
	icon_state = "engine_hallway"

/area/deltastation/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/deltastation/engineering/atmos/upper
	name = "Upper Atmospherics"

/area/deltastation/engineering/atmos/project
	name = "\improper Atmospherics Project Room"
	icon_state = "atmos_projectroom"

/area/deltastation/engineering/atmos/pumproom
	name = "\improper Atmospherics Pumping Room"
	icon_state = "atmos_pump_room"

/area/deltastation/engineering/atmos/mix
	name = "\improper Atmospherics Mixing Room"
	icon_state = "atmos_mix"

/area/deltastation/engineering/atmos/storage
	name = "\improper Atmospherics Storage Room"
	icon_state = "atmos_storage"

/area/deltastation/engineering/atmos/storage/gas
	name = "\improper Atmospherics Gas Storage"
	icon_state = "atmos_storage_gas"

/area/deltastation/engineering/atmos/office
	name = "\improper Atmospherics Office"
	icon_state = "atmos_office"

/area/deltastation/engineering/atmos/hfr_room
	name = "\improper Atmospherics HFR Room"
	icon_state = "atmos_HFR"

/area/deltastation/engineering/atmospherics_engine
	name = "\improper Atmospherics Engine"
	icon_state = "atmos_engine"

/area/deltastation/engineering/lobby
	name = "\improper Engineering Lobby"
	icon_state = "engi_lobby"

/area/deltastation/engineering/supermatter
	name = "\improper Supermatter Engine"
	icon_state = "engine_sm"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	outside = FALSE
	requires_power = FALSE

/area/deltastation/engineering/supermatter/room
	name = "\improper Supermatter Engine Room"
	icon_state = "engine_sm_room"
	requires_power = TRUE

/area/deltastation/engineering/break_room
	name = "\improper Engineering Foyer"
	icon_state = "engine_break"

/area/deltastation/engineering/gravity_generator
	name = "\improper Gravity Generator Room"
	icon_state = "grav_gen"

/area/deltastation/engineering/storage
	name = "Engineering Storage"
	icon_state = "engine_storage"

/area/deltastation/engineering/storage_shared
	name = "Shared Engineering Storage"
	icon_state = "engine_storage_shared"

/area/deltastation/engineering/transit_tube
	name = "\improper Transit Tube"
	icon_state = "transit_tube"

/area/deltastation/engineering/storage/tech
	name = "Technical Storage"
	icon_state = "tech_storage"

/area/deltastation/engineering/storage/tcomms
	name = "Telecomms Storage"
	icon_state = "tcom_storage"

//Engineering - Construction

/area/deltastation/construction
	name = "\improper Construction Area"
	icon_state = "construction"
	minimap_color = MINIMAP_AREA_ENGI

/area/deltastation/construction/mining/aux_base
	name = "Auxiliary Base Construction"
	icon_state = "aux_base_construction"

/area/deltastation/construction/storage_wing
	name = "\improper Storage Wing"
	icon_state = "storage_wing"

//Solars

/area/deltastation/solars
	icon_state = "panels"
	requires_power = FALSE
	minimap_color = MINIMAP_AREA_ENGI

/area/deltastation/solars/fore
	name = "\improper Fore Solar Array"
	icon_state = "panelsF"

/area/deltastation/solars/aft
	name = "\improper Aft Solar Array"
	icon_state = "panelsAF"

/area/deltastation/solars/aux/port
	name = "\improper Port Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/deltastation/solars/aux/starboard
	name = "\improper Starboard Bow Auxiliary Solar Array"
	icon_state = "panelsA"

/area/deltastation/solars/starboard
	name = "\improper Starboard Solar Array"
	icon_state = "panelsS"

/area/deltastation/solars/starboard/aft
	name = "\improper Starboard Quarter Solar Array"
	icon_state = "panelsAS"

/area/deltastation/solars/starboard/fore
	name = "\improper Starboard Bow Solar Array"
	icon_state = "panelsFS"

/area/deltastation/solars/port
	name = "\improper Port Solar Array"
	icon_state = "panelsP"

/area/deltastation/solars/port/aft
	name = "\improper Port Quarter Solar Array"
	icon_state = "panelsAP"

/area/deltastation/solars/port/fore
	name = "\improper Port Bow Solar Array"
	icon_state = "panelsFP"

/area/deltastation/solars/aisat
	name = "\improper AI Satellite Solars"
	icon_state = "panelsAI"


//Solar Maint

/area/deltastation/maintenance/solars
	name = "Solar Maintenance"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_ENGI

/area/deltastation/maintenance/solars/port
	name = "Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/deltastation/maintenance/solars/port/aft
	name = "Port Quarter Solar Maintenance"
	icon_state = "SolarcontrolAP"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	outside = FALSE

/area/deltastation/maintenance/solars/port/fore
	name = "Port Bow Solar Maintenance"
	icon_state = "SolarcontrolFP"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	outside = FALSE

/area/deltastation/maintenance/solars/starboard
	name = "Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/deltastation/maintenance/solars/starboard/aft
	name = "Starboard Quarter Solar Maintenance"
	icon_state = "SolarcontrolAS"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	outside = FALSE

/area/deltastation/maintenance/solars/starboard/fore
	name = "Starboard Bow Solar Maintenance"
	icon_state = "SolarcontrolFS"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	outside = FALSE

//MedBay

/area/deltastation/medical
	name = "Medical"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/deltastation/medical/abandoned
	name = "\improper Abandoned Medbay"
	icon_state = "abandoned_medbay"
/area/deltastation/medical/medbay/central
	name = "Medbay Central"
	icon_state = "med_central"

/area/deltastation/medical/medbay/lobby
	name = "\improper Medbay Lobby"
	icon_state = "med_lobby"

//Medbay is a large area, these additional areas help level out APC load.

/area/deltastation/medical/medbay/aft
	name = "Medbay Aft"
	icon_state = "med_aft"

/area/deltastation/medical/storage
	name = "Medbay Storage"
	icon_state = "med_storage"

/area/deltastation/medical/paramedic
	name = "Paramedic Dispatch"
	icon_state = "paramedic"

/area/deltastation/medical/office
	name = "\improper Medical Office"
	icon_state = "med_office"

/area/deltastation/medical/break_room
	name = "\improper Medical Break Room"
	icon_state = "med_break"

/area/deltastation/medical/coldroom
	name = "\improper Medical Cold Room"
	icon_state = "kitchen_cold"

/area/deltastation/medical/patients_rooms
	name = "\improper Patients' Rooms"
	icon_state = "patients"

/area/deltastation/medical/patients_rooms/room_a
	name = "Patient Room A"
	icon_state = "patients"

/area/deltastation/medical/patients_rooms/room_b
	name = "Patient Room B"
	icon_state = "patients"

/area/deltastation/medical/virology
	name = "Virology"
	icon_state = "virology"

/area/deltastation/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"

/area/deltastation/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/deltastation/medical/pharmacy
	name = "\improper Pharmacy"
	icon_state = "pharmacy"

/area/deltastation/medical/surgery
	name = "\improper Operating Room"
	icon_state = "surgery"

/area/deltastation/medical/surgery/fore
	name = "\improper Fore Operating Room"
	icon_state = "foresurgery"

/area/deltastation/medical/surgery/aft
	name = "\improper Aft Operating Room"
	icon_state = "aftsurgery"

/area/deltastation/medical/surgery/theatre
	name = "\improper Grand Surgery Theatre"
	icon_state = "surgerytheatre"
/area/deltastation/medical/cryo
	name = "Cryogenics"
	icon_state = "cryo"

/area/deltastation/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/deltastation/medical/treatment_center
	name = "\improper Medbay Treatment Center"
	icon_state = "exam_room"

/area/deltastation/medical/psychology
	name = "\improper Psychology Office"
	icon_state = "psychology"

//Security

/area/deltastation/security
	name = "Security"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/deltastation/security/office
	name = "\improper Security Office"
	icon_state = "security"

/area/deltastation/security/lockers
	name = "\improper Security Locker Room"
	icon_state = "securitylockerroom"

/area/deltastation/security/brig
	name = "\improper Brig"
	icon_state = "brig"

/area/deltastation/security/holding_cell
	name = "\improper Holding Cell"
	icon_state = "holding_cell"

/area/deltastation/security/medical
	name = "\improper Security Medical"
	icon_state = "security_medical"

/area/deltastation/security/brig/upper
	name = "\improper Brig Overlook"
	icon_state = "upperbrig"

/area/deltastation/security/courtroom
	name = "\improper Courtroom"
	icon_state = "courtroom"

/area/deltastation/security/prison
	name = "\improper Prison Wing"
	icon_state = "sec_prison"

//Rad proof
/area/deltastation/security/prison/toilet
	name = "\improper Prison Toilet"
	icon_state = "sec_prison_safe"

// Rad proof
/area/deltastation/security/prison/safe
	name = "\improper Prison Wing Cells"
	icon_state = "sec_prison_safe"

/area/deltastation/security/prison/upper
	name = "\improper Upper Prison Wing"
	icon_state = "prison_upper"

/area/deltastation/security/prison/visit
	name = "\improper Prison Visitation Area"
	icon_state = "prison_visit"

/area/deltastation/security/prison/rec
	name = "\improper Prison Rec Room"
	icon_state = "prison_rec"

/area/deltastation/security/prison/mess
	name = "\improper Prison Mess Hall"
	icon_state = "prison_mess"

/area/deltastation/security/prison/work
	name = "\improper Prison Work Room"
	icon_state = "prison_work"

/area/deltastation/security/prison/shower
	name = "\improper Prison Shower"
	icon_state = "prison_shower"

/area/deltastation/security/prison/workout
	name = "\improper Prison Gym"
	icon_state = "prison_workout"

/area/deltastation/security/prison/garden
	name = "\improper Prison Garden"
	icon_state = "prison_garden"

/area/deltastation/security/processing
	name = "\improper Labor Shuttle Dock"
	icon_state = "sec_labor_processing"

/area/deltastation/security/processing/cremation
	name = "\improper Security Crematorium"
	icon_state = "sec_cremation"

/area/deltastation/security/interrogation
	name = "\improper Interrogation Room"
	icon_state = "interrogation"

/area/deltastation/security/warden
	name = "Brig Control"
	icon_state = "warden"

/area/deltastation/security/detectives_office
	name = "\improper Detective's Office"
	icon_state = "detective"

/area/deltastation/security/detectives_office/private_investigators_office
	name = "\improper Private Investigator's Office"
	icon_state = "investigate_office"

/area/deltastation/security/range
	name = "\improper Firing Range"
	icon_state = "firingrange"

/area/deltastation/security/execution
	icon_state = "execution_room"

/area/deltastation/security/execution/transfer
	name = "\improper Transfer Centre"
	icon_state = "sec_processing"

/area/deltastation/security/execution/education
	name = "\improper Prisoner Education Chamber"

/area/deltastation/security/checkpoint
	name = "\improper Security Checkpoint"
	icon_state = "checkpoint"

/area/deltastation/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

/area/deltastation/security/checkpoint/escape
	icon_state = "checkpoint_esc"

/area/deltastation/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint_supp"

/area/deltastation/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint_engi"

/area/deltastation/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint_med"

/area/deltastation/security/checkpoint/medical/medsci
	name = "Security Post - Medsci"

/area/deltastation/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint_sci"

/area/deltastation/security/checkpoint/science/research
	name = "Security Post - Research Division"
	icon_state = "checkpoint_res"

/area/deltastation/security/checkpoint/customs
	name = "Customs"
	icon_state = "customs_point"

/area/deltastation/security/checkpoint/customs/auxiliary
	name = "Auxiliary Customs"
	icon_state = "customs_point_aux"

/area/deltastation/security/checkpoint/customs/fore
	name = "Fore Customs"
	icon_state = "customs_point_fore"

/area/deltastation/security/checkpoint/customs/aft
	name = "Aft Customs"
	icon_state = "customs_point_aft"

//Cargo

/area/deltastation/cargo
	name = "Quartermasters"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_CELL_HIGH

/area/deltastation/cargo/sorting
	name = "\improper Delivery Office"
	icon_state = "cargo_delivery"

/area/deltastation/cargo/warehouse
	name = "\improper Warehouse"
	icon_state = "cargo_warehouse"

/area/deltastation/cargo/drone_bay
	name = "\improper Drone Bay"
	icon_state = "cargo_drone"

/area/deltastation/cargo/warehouse/upper
	name = "\improper Upper Warehouse"

/area/deltastation/cargo/office
	name = "\improper Cargo Office"
	icon_state = "cargo_office"

/area/deltastation/cargo/storage
	name = "\improper Cargo Bay"
	icon_state = "cargo_bay"

/area/deltastation/cargo/lobby
	name = "\improper Cargo Lobby"
	icon_state = "cargo_lobby"

/area/deltastation/cargo/miningdock
	name = "\improper Mining Dock"
	icon_state = "mining_dock"

/area/deltastation/cargo/miningdock/cafeteria
	name = "\improper Mining Cafeteria"
	icon_state = "mining_cafe"

/area/deltastation/cargo/miningdock/oresilo
	name = "\improper Mining Ore Silo Storage"
	icon_state = "mining_silo"

/area/deltastation/cargo/miningoffice
	name = "\improper Mining Office"
	icon_state = "mining"

//Science

/area/deltastation/science
	name = "\improper Science Division"
	icon_state = "science"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/deltastation/science/lobby
	name = "\improper Science Lobby"
	icon_state = "science_lobby"

/area/deltastation/science/lower
	name = "\improper Lower Science Division"
	icon_state = "lower_science"

/area/deltastation/science/breakroom
	name = "\improper Science Break Room"
	icon_state = "science_breakroom"

/area/deltastation/science/lab
	name = "Research and Development"
	icon_state = "research"

/area/deltastation/science/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xenobio"

/area/deltastation/science/xenobiology/hallway
	name = "\improper Xenobiology Hallway"
	icon_state = "xenobio_hall"

/area/deltastation/science/cytology
	name = "\improper Cytology Lab"
	icon_state = "cytology"

// Use this for the main lab. If test equipment, storage, etc is also present use this one too.
/area/deltastation/science/ordnance
	name = "\improper Ordnance Lab"
	icon_state = "ord_main"

/area/deltastation/science/ordnance/office
	name = "\improper Ordnance Office"
	icon_state = "ord_office"

/area/deltastation/science/ordnance/storage
	name = "\improper Ordnance Storage"
	icon_state = "ord_storage"

/area/deltastation/science/ordnance/burnchamber
	name = "\improper Ordnance Burn Chamber"
	icon_state = "ord_burn"
	requires_power = FALSE

/area/deltastation/science/ordnance/freezerchamber
	name = "\improper Ordnance Freezer Chamber"
	icon_state = "ord_freeze"
	requires_power = FALSE

// Room for equipments and such
/area/deltastation/science/ordnance/testlab
	name = "\improper Ordnance Testing Lab"
	icon_state = "ord_test"

/area/deltastation/science/ordnance/bomb
	name = "\improper Ordnance Bomb Site"
	icon_state = "ord_boom"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	outside = FALSE
	always_unpowered = TRUE

/area/deltastation/science/genetics
	name = "\improper Genetics Lab"
	icon_state = "geneticssci"

/area/deltastation/science/server
	name = "\improper Research Division Server Room"
	icon_state = "server"

/area/deltastation/science/circuits
	name = "\improper Circuit Lab"
	icon_state = "cir_lab"

/area/deltastation/science/explab
	name = "\improper Experimentation Lab"
	icon_state = "exp_lab"

// Useless room
/area/deltastation/science/auxlab
	name = "\improper Auxiliary Lab"
	icon_state = "aux_lab"

/area/deltastation/science/auxlab/firing_range
	name = "\improper Research Firing Range"

/area/deltastation/science/robotics
	name = "Robotics"
	icon_state = "robotics"

/area/deltastation/science/robotics/mechbay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/deltastation/science/robotics/lab
	name = "\improper Robotics Lab"
	icon_state = "ass_line"

/area/deltastation/science/research
	name = "\improper Research Division"
	icon_state = "science"

/area/deltastation/science/research/abandoned
	name = "\improper Abandoned Research Lab"
	icon_state = "abandoned_sci"

// Telecommunications Satellite

/area/deltastation/tcommsat
	icon_state = "tcomsatcham"
	minimap_color = MINIMAP_AREA_COMMAND

/area/deltastation/tcommsat/computer
	name = "\improper Telecomms Control Room"
	icon_state = "tcomsatcomp"

/area/deltastation/tcommsat/server
	name = "\improper Telecomms Server Room"
	icon_state = "tcomsatcham"

/area/deltastation/tcommsat/server/upper
	name = "\improper Upper Telecomms Server Room"

//Telecommunications - On Station

/area/deltastation/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"

/area/deltastation/server
	name = "\improper Messaging Server Room"
	icon_state = "server"

//External Hull Access
/area/deltastation/maintenance/external
	name = "\improper External Hull Access"
	icon_state = "amaint"

/area/deltastation/maintenance/external/aft
	name = "\improper Aft External Hull Access"

/area/deltastation/maintenance/external/port
	name = "\improper Port External Hull Access"

/area/deltastation/maintenance/external/port/bow
	name = "\improper Port Bow External Hull Access"

/area/deltastation/external/landingzone
	name = "\improper Delta Station landing zone"
	icon_state = "ship"
	minimap_color = MINIMAP_AREA_LZ

/area/deltastation/asteroidcaves
	name = "Unknown Area"
	icon_state = "asteroid"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	ambience = list('sound/ambience/ambicave.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava2.ogg', 'sound/ambience/ambilava3.ogg')
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE


/area/deltastation/asteroidcaves/rock
	name = "Enclosed Area"
	icon_state = "transparent"

/area/deltastation/asteroidcaves/northcaves

/area/deltastation/asteroidcaves/northcaves/garbledradio

/area/deltastation/asteroidcaves/northeastcaves

/area/deltastation/asteroidcaves/westerncaves

/area/deltastation/asteroidcaves/westerncaves/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/deltastation/asteroidcaves/easterntunnel
	ceiling = CEILING_UNDERGROUND

/area/deltastation/asteroidcaves/securitycaves
	ceiling = CEILING_UNDERGROUND

/area/deltastation/asteroidcaves/southtunnel
	ceiling = CEILING_UNDERGROUND

/area/deltastation/asteroidcaves/exteriorasteroids
	icon_state = "asteroidexterior"

/area/deltastation/asteroidcaves/ship
	name = "Abandoned Ship"
	icon_state = "ship"
	always_unpowered = FALSE
	minimap_color = MINIMAP_AREA_SHIP

/area/deltastation/asteroidcaves/ship/two

/area/deltastation/asteroidcaves/derelictnortheast
	icon_state = "derelict"
	always_unpowered = FALSE

/area/deltastation/asteroidcaves/derelictwest
	icon_state = "derelict"
	always_unpowered = FALSE
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/deltastation/asteroidcaves/derelictsatellite

/area/deltastation/asteroidcaves/southlz
	ceiling = CEILING_NONE
	requires_power = FALSE
	outside = TRUE
