//MOUNTAIN PASS AREAS//

// exterior areas

/area/mountain_pass/exterior
	name = "Z-level 1: Central Base Grounds"
	icon_state = "central"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_JUNGLE
	always_unpowered = TRUE

/area/space/mountain_pass/midair
	debuff_type = /datum/status_effect/spacefreeze/light/high_altitude
	ambience = list('sound/ambience/windambient.ogg')
	icon_state = "runway"

/area/mountain_pass/exterior/landingzone
	name = "Z-Level 1: Landing Zone"
	icon = 'icons/turf/area_kutjevo.dmi'
	icon_state = "lz_pad"

/area/mountain_pass/exterior/s
	name = "Z-Level 1: Southern Base Grounds"
	icon_state = "south"

/area/mountain_pass/exterior/e
	name = "Z-Level 1: Eastern Base Grounds"
	icon_state = "east"

/area/mountain_pass/exterior/w
	name = "Z-Level 1: Western Base Grounds"
	icon_state = "west"

/area/mountain_pass/exterior/se
	name = "Z-Level 1: Southeastern Base Grounds"
	icon_state = "southeast"

/area/mountain_pass/exterior/beach
	name = "Z-Level 1: Beach"
	icon_state = "yellow"
	minimap_color = MINIMAP_DIRT

/area/mountain_pass/exterior/ocean
	name = "Z-Level 1: Ocean"
	icon_state = "blue2"
	minimap_color = MINIMAP_WATER

/area/mountain_pass/exterior/zlevel2
	name = "Z-Level 2: Western Road"
	icon_state = "west"

/area/mountain_pass/exterior/zlevel2/eastroad
	name = "Z-Level 2: Eastern Road"
	icon_state = "east2"

/area/mountain_pass/exterior/zlevel2/central
	name = "Z-Level 2: Central Base Grounds"
	icon_state = "central"

/area/mountain_pass/exterior/zlevel3
	name = "Z-Level 3: Western Road"
	icon_state = "west"

/area/mountain_pass/exterior/zlevel3/northwesternroad
	name = "Z-Level 3: Northwestern Road"
	icon_state = "northwest"

/area/mountain_pass/exterior/zlevel3/centralroad
	name = "Z-Level 3: Central Road"
	icon_state = "central"

/area/mountain_pass/exterior/zlevel3/easterncliff
	name = "Z-Level 3: Eastern Cliff"
	icon_state = "east"

/area/mountain_pass/exterior/zlevel3/northeasterncliff
	name = "Z-Level 3: Northeastern Cliff"
	icon_state = "northeast"

// Interior Areas

/area/mountain_pass/interior
	name = "Z-level 1: Medbay"
	icon_state = "medbay3"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_MEDBAY
	always_unpowered = TRUE

/area/mountain_pass/interior/barracks
	name = "Z-level 1: Infantry Barracks"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/mountain_pass/interior/guard_barracks
	name = "Z-level 1: Guardsman Barracks"
	icon_state = "locker"
	minimap_color = MINIMAP_AREA_LIVING

/area/mountain_pass/interior/armorer_workshop
	name = "Z-level 1: Armorer Workshop"
	icon_state = "dk_yellow"
	minimap_color = MINIMAP_AREA_ENGI

/area/mountain_pass/interior/coastal_bunker
	name = "Z-level 1: Coastal Bunker"
	icon_state = "blue-red"
	minimap_color = MINIMAP_AREA_SEC

/area/mountain_pass/interior/coastal_gun
	name = "Z-level 1: Coastal Gun"
	icon_state = "blue"
	minimap_color = MINIMAP_AREA_SEC

/area/mountain_pass/interior/cafeteria
	name = "Z-level 1: Cafeteria"
	icon_state = "HH_Diner"
	minimap_color = MINIMAP_AREA_LIVING

/area/mountain_pass/interior/kitchen
	name = "Z-level 1: Kitchen"
	icon_state = "HH_Kitchen"
	minimap_color = MINIMAP_AREA_LIVING

/area/mountain_pass/interior/cargo
	name = "Z-level 1: Cargo"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ

/area/mountain_pass/interior/lz_offices
	name = "Z-level 1: Landing Zone Offices"
	icon_state = "dark128"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/mountain_pass/interior/artillery_ammunition_storage
	name = "Z-level 1: Artillery Ammunition Storage"
	icon_state = "firingrange"
	minimap_color = MINIMAP_AREA_SEC

/area/mountain_pass/interior/construction
	name = "Z-level 1: Construction Site"
	icon_state = "construction"
	minimap_color = MINIMAP_AREA_COLONY

/area/mountain_pass/interior/zlevel2
	name = "Z-level 2: Defensive Bunker"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

// Underground Buildings
/area/mountain_pass/cave
	name = "Z-level 1: Underground Brig"
	icon_state = "brig"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE
	always_unpowered = TRUE

/area/mountain_pass/cave/armory
	name = "Z-level 1: Underground Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_REQ_CAVE
	always_unpowered = FALSE

/area/mountain_pass/cave/panic_bunker
	name = "Z-level 1: Underground Panic Bunker"
	icon_state = "nuke_storage"
	minimap_color = MINIMAP_AREA_COMMAND_CAVE

/area/mountain_pass/cave/zlevel2
	name = "Z-level 2: Underground Power Substation"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	ceiling = CEILING_UNDERGROUND_METAL

/area/mountain_pass/cave/zlevel2/engi_generators
	name = "Z-level 2: Underground Engineering - Generators"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/mountain_pass/cave/zlevel2/engi_offices
	name = "Z-level 2: Underground Engineering - Offices"
	icon_state = "engine_monitoring"
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/mountain_pass/cave/zlevel2/coastal_gauss
	name = "Z-level 2: Underground Gauss Cannon"
	icon_state = "security_sub"
	minimap_color = MINIMAP_AREA_SEC_CAVE
	ceiling = CEILING_UNDERGROUND_METAL

/area/mountain_pass/cave/zlevel3
	name = "Z-level 3: CIC Bunker - Security Checkpoint"
	icon_state = "checkpoint1"
	minimap_color = MINIMAP_AREA_SEC_CAVE
	ceiling = CEILING_UNDERGROUND_METAL

/area/mountain_pass/cave/zlevel3/cic_bunker_front
	name = "Z-level 3: CIC Bunker - Gate"
	icon_state = "purple"
	minimap_color = MINIMAP_AREA_COMMAND_CAVE

/area/mountain_pass/cave/zlevel3/cic_bunker
	name = "Z-level 3: CIC Bunker - Interior"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND_CAVE
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

// Cave areas

/area/mountain_pass/cave/passages
	name = "Z-level 1: Southern Caves"
	icon_state = "caves_south"
	icon = 'icons/turf/hybrisareas.dmi'
	minimap_color = MINIMAP_SHALE
	ceiling = CEILING_UNDERGROUND

/area/mountain_pass/cave/passages/east
	name = "Z-level 1: Eastern Caves"
	icon_state = "caves_east"

/area/mountain_pass/cave/passages/north
	name = "Z-level 1: Northern Caves"
	icon_state = "caves_north"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/mountain_pass/cave/passages/west
	name = "Z-level 1: Western Caves"
	icon_state = "caves_west"

/area/mountain_pass/cave/passages/northwest
	name = "Z-level 1: Northwestern Caves"
	icon_state = "caves_northwest"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/mountain_pass/cave/passages/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	area_flags = CANNOT_NUKE

/area/mountain_pass/cave/passages/zlevel2
	name = "Z-level 2: Southern Caves"

/area/mountain_pass/cave/passages/zlevel2/northeast
	name = "Z-level 2: Northeastern Caves"
	icon_state = "caves_northeast"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/mountain_pass/cave/passages/zlevel2/north
	name = "Z-level 2: Northern Caves"
	icon_state = "caves_north"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/mountain_pass/cave/passages/zlevel2/northwest
	name = "Z-level 2: Northwestern Caves"
	icon_state = "caves_northwest"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/mountain_pass/cave/passages/zlevel2/east
	name = "Z-level 2: Eastern Caves"
	icon_state = "caves_east"

/area/mountain_pass/cave/passages/zlevel2/southeast
	name = "Z-level 2: Southeastern Caves"
	icon_state = "caves_southeast"

/area/mountain_pass/cave/passages/zlevel2/southwest
	name = "Z-level 2: Southwestern Caves"
	icon_state = "caves_southwest"

/area/mountain_pass/cave/passages/zlevel2/west
	name = "Z-level 2: Western Caves"
	icon_state = "caves_west"
	ceiling = CEILING_DEEP_UNDERGROUND

