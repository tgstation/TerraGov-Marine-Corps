/area/tinyblue/outside
	name = "Colony Grounds"
	icon_state = "blue"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE

/area/tinyblue/outside/c
	name = "Central Colony Grounds"
	icon_state = "central"

/area/tinyblue/outside/n
	name = "Northern Colony Grounds"
	icon_state = "north"

/area/tinyblue/outside/w
	name = "Western Colony Grounds"
	icon_state = "west"

/area/tinyblue/outside/e
	name = "Eastern Colony Grounds"
	icon_state = "east"

/area/tinyblue/outside/s
	name = "Southern Colony Grounds"
	icon_state = "south"

/area/tinyblue/outside/se
	name = "Southeastern Colony Grounds"
	icon_state = "southeast"

/area/tinyblue/outside/ne
	name = "Northeastern Colony Grounds"
	icon_state = "northeast"

/area/tinyblue/caves
	name = "Unknown Area"
	icon_state = "bluenew"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	ambience = list('sound/ambience/ambicave.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava2.ogg', 'sound/ambience/ambilava3.ogg')
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/tinyblue/caves/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	area_flags = CANNOT_NUKE

/area/tinyblue/caves/w
	name = "Western Caverns"
	icon_state = "west"
	ceiling = CEILING_UNDERGROUND

/area/tinyblue/caves/sw
	name = "Southwestern Caverns"
	icon_state = "southwest"

/area/tinyblue/caves/s
	name = "Southern Caverns"
	icon_state = "south"

/area/tinyblue/caves/s/shallow
	ceiling = CEILING_UNDERGROUND

/area/tinyblue/caves/se
	name = "Southeastern Caverns"
	icon_state = "southeast"

/area/tinyblue/caves/e
	name = "Eastern Caverns"
	icon_state = "east"

/area/tinyblue/caves/e/shallow
	ceiling = CEILING_UNDERGROUND

/area/tinyblue/caves/ne
	name = "Northeastern Caverns"
	icon_state = "northeast"

/area/tinyblue/caves/n
	name = "Northern Caverns"
	icon_state = "north"

/area/tinyblue/caves/facility
	name = "Unknown Area"
	icon_state = "blue"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	always_unpowered = FALSE
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/tinyblue/caves/facility/engi
	name = "Main Powerplant"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/tinyblue/caves/facility/omicron
	name = "Omicron Research Facility"
	icon_state = "anomaly"
	area_flags = CANNOT_NUKE

/area/tinyblue/caves/facility/eta
	name = "Eta Research Facility - Entrance"
	icon_state = "anog"

/area/tinyblue/caves/facility/eta/e
	name = "Eta Research Facility - Offices"

/area/tinyblue/caves/facility/eta/xeno
	name = "Eta Research Facility - Xenomorph Cells"
	icon_state = "xeno_lab"

/area/tinyblue/caves/facility/lambda
	name = "Lambda Research Facility - Center"
	icon_state = "research"

/area/tinyblue/caves/facility/lambda/n
	name = "Lambda Research Facility - North"

/area/tinyblue/caves/facility/lambda/s
	name = "Lambda Research Facility - South"

/area/tinyblue/caves/facility/lambda/sec
	name = "Lambda Research Facility - Security Checkpoint"
	minimap_color = MINIMAP_AREA_SEC

/area/tinyblue/outside/building
	name = "Unknown Area"
	icon_state = "blue"
	ceiling = CEILING_METAL
	outside = FALSE
	always_unpowered = FALSE

/area/tinyblue/outside/building/lz
	name = "Space Port"
	icon_state = "shuttle"
	minimap_color = MINIMAP_AREA_LZ
	ceiling = CEILING_NONE

/area/tinyblue/outside/building/marshal
	name = "Marshals Office"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/tinyblue/outside/building/marshal/court
	name = "Courtroom"

/area/tinyblue/outside/building/med
	name = "Medical Clinic"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/tinyblue/outside/building/med/icu
	name = "Medical Clinic Intensive Care Unit"
	icon_state = "medbay2"

/area/tinyblue/outside/building/cargo
	name = "Cargo Bay"
	icon_state = "ass_line"
	minimap_color = MINIMAP_AREA_REQ

/area/tinyblue/outside/building/cargo/outpost
	name = "Cargo Storage"

/area/tinyblue/outside/building/cargo/shop
	name = "General Store"
	icon_state = "yellow"

/area/tinyblue/outside/building/virology
	name = "Virology Laboratory"
	icon_state = "toxlab"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/tinyblue/outside/building/engi
	name = "Electrical Substation"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI

/area/tinyblue/outside/building/engi/filt
	name = "Filtration Plant"
	icon_state = "engine_waste"

/area/tinyblue/outside/building/admin
	name = "Colony Administration Offices"
	icon_state = "blue2"
	minimap_color = MINIMAP_AREA_COMMAND

/area/tinyblue/outside/building/dorms
	name = "Colony Dormitories"
	icon_state = "restrooms"
	minimap_color = MINIMAP_AREA_LIVING

/area/tinyblue/outside/building/dorms/rec
	name = "Arcade"
	icon_state = "green"

/area/tinyblue/outside/building/dorms/bar
	name = "Bar"
	icon_state = "sensor"

/area/tinyblue/outside/building/dorms/eat
	name = "Cafeteria"
	icon_state = "lava_civ_cargo"

/area/tinyblue/outside/building/dorms/plant
	name = "Hydroponics Bay"
	icon_state = "hydro"
	ceiling = CEILING_GLASS

/area/tinyblue/outside/building/dorms/chapel
	name = "Chapel"
	icon_state = "library"

/area/tinyblue/outside/building/mining
	name = "Excavation Center"
	icon_state = "mining_outpost"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/tinyblue/outside/building/toolshed
	name = "Tool Storage"
	icon_state = "auxstorage"
	minimap_color = MINIMAP_AREA_REQ_CAVE
