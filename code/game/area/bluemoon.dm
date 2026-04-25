/area/bluemoon/outside
	name = "Colony Grounds"
	icon_state = "blue"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE

/area/bluemoon/outside/c
	name = "Central Colony Grounds"
	icon_state = "central"

/area/bluemoon/outside/n
	name = "Northern Colony Grounds"
	icon_state = "north"

/area/bluemoon/outside/w
	name = "Western Colony Grounds"
	icon_state = "west"

/area/bluemoon/outside/e
	name = "Eastern Colony Grounds"
	icon_state = "east"

/area/bluemoon/outside/s
	name = "Southern Colony Grounds"
	icon_state = "south"

/area/bluemoon/outside/se
	name = "Southeastern Colony Grounds"
	icon_state = "southeast"

/area/bluemoon/outside/ne
	name = "Northeastern Colony Grounds"
	icon_state = "northeast"

/area/bluemoon/caves
	name = "Caverns"
	icon_state = "bluenew"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	ambience = list('sound/ambience/ambicave.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava2.ogg', 'sound/ambience/ambilava3.ogg')
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/bluemoon/caves/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	area_flags = CANNOT_NUKE

/area/bluemoon/caves/w
	name = "Western Caverns"
	icon_state = "west"
	ceiling = CEILING_UNDERGROUND

/area/bluemoon/caves/sw
	name = "Southwestern Caverns"
	icon_state = "southwest"

/area/bluemoon/caves/sw/shallow
	ceiling = CEILING_UNDERGROUND

/area/bluemoon/caves/s
	name = "Southern Caverns"
	icon_state = "south"

/area/bluemoon/caves/s/shallow
	ceiling = CEILING_UNDERGROUND

/area/bluemoon/caves/se
	name = "Southeastern Caverns"
	icon_state = "southeast"
	area_flags = CANNOT_NUKE

/area/bluemoon/caves/e
	name = "Eastern Caverns"
	icon_state = "east"

/area/bluemoon/caves/e/shallow
	ceiling = CEILING_UNDERGROUND

/area/bluemoon/caves/ne
	name = "Northeastern Caverns"
	icon_state = "northeast"

/area/bluemoon/caves/ne/shallow
	ceiling = CEILING_UNDERGROUND

/area/bluemoon/caves/n
	name = "Northern Caverns"
	icon_state = "north"
	ceiling = CEILING_UNDERGROUND

/area/bluemoon/caves/facility
	name = "Unknown Area"
	icon_state = "blue"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	always_unpowered = FALSE
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/bluemoon/caves/facility/bunker
	name = "Emergency Bunker"
	minimap_color = MINIMAP_AREA_LIVING_CAVE

/area/bluemoon/caves/facility/omicron
	name = "Omicron Research Facility"
	icon_state = "anomaly"
	area_flags = CANNOT_NUKE

/area/bluemoon/caves/facility/eta
	name = "Eta Research Facility"
	icon_state = "anog"
	area_flags = CANNOT_NUKE

/area/bluemoon/caves/facility/eta/e
	name = "Eta Research Facility - Offices"

/area/bluemoon/caves/facility/eta/xeno
	name = "Eta Research Facility - Xenomorph Cells"
	icon_state = "xeno_lab"

/area/bluemoon/caves/facility/lambda
	name = "Lambda Research Facility"
	icon_state = "research"

/area/bluemoon/caves/facility/lambda/n
	name = "Lambda Research Facility - North"

/area/bluemoon/caves/facility/lambda/s
	name = "Lambda Research Facility - South"

/area/bluemoon/caves/facility/lambda/sec
	name = "Lambda Research Facility - Security Checkpoint"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_SEC

/area/bluemoon/outside/building
	name = "Unknown Area"
	icon_state = "blue"
	ceiling = CEILING_METAL
	outside = FALSE
	always_unpowered = FALSE

/area/bluemoon/outside/building/lz
	name = "Space Port"
	icon_state = "shuttle"
	minimap_color = MINIMAP_AREA_LZ
	ceiling = CEILING_NONE
	area_flags = NEAR_FOB

/area/bluemoon/outside/building/marshal
	name = "Marshals Office"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/bluemoon/outside/building/marshal/court
	name = "Courtroom"

/area/bluemoon/outside/building/med
	name = "Medical Clinic"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/bluemoon/outside/building/med/icu
	name = "Medical Clinic Intensive Care Unit"
	icon_state = "medbay2"

/area/bluemoon/outside/building/cargo
	name = "Cargo Bay"
	icon_state = "ass_line"
	minimap_color = MINIMAP_AREA_REQ

/area/bluemoon/outside/building/cargo/outpost
	name = "Cargo Storage"

/area/bluemoon/outside/building/cargo/shop
	name = "General Store"
	icon_state = "yellow"

/area/bluemoon/outside/building/virology
	name = "Virology Laboratory"
	icon_state = "toxlab"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/bluemoon/outside/building/engi
	name = "Electrical Substation"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI

/area/bluemoon/outside/building/engi/filt
	name = "Filtration Plant"
	icon_state = "engine_waste"

/area/bluemoon/outside/building/admin
	name = "Colony Administration Offices"
	icon_state = "blue2"
	minimap_color = MINIMAP_AREA_COMMAND

/area/bluemoon/outside/building/dorms
	name = "Colony Dormitories"
	icon_state = "restrooms"
	minimap_color = MINIMAP_AREA_LIVING

/area/bluemoon/outside/building/dorms/rec
	name = "Arcade"
	icon_state = "green"

/area/bluemoon/outside/building/dorms/bar
	name = "Bar"
	icon_state = "sensor"

/area/bluemoon/outside/building/dorms/eat
	name = "Cafeteria"
	icon_state = "lava_civ_cargo"

/area/bluemoon/outside/building/dorms/plant
	name = "Hydroponics Bay"
	icon_state = "hydro"
	ceiling = CEILING_GLASS

/area/bluemoon/outside/building/dorms/chapel
	name = "Chapel"
	icon_state = "library"

/area/bluemoon/outside/building/mining
	name = "Excavation Center"
	icon_state = "mining_outpost"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/bluemoon/outside/building/toolshed
	name = "Tool Storage"
	icon_state = "auxstorage"
	minimap_color = MINIMAP_AREA_REQ_CAVE
