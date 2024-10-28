//Bluesummers Wreck Site Areas

//Caves
/area/bluesummers/caves
	name = "Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/bluesummers/caves/rock
	name = "Enclosed Area"
	icon_state = "transparent"

/area/bluesummers/caves/northwest
	name = "Northwestern Caves"
	icon_state = "northwest2"

/area/bluesummers/caves/northwest/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/bluesummers/caves/northwest/garbledradio/indoor
	name = "Lower Northwest Caves Wreckage"
	always_unpowered = FALSE
	ceiling = CEILING_UNDERGROUND_METAL

/area/bluesummers/caves/northwest/indoor
	name = "Northwest Caves Wreckage"
	always_unpowered = FALSE
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/bluesummers/caves/north
	name = "Northern Caves"
	icon_state = "north2"

/area/bluesummers/caves/north/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/bluesummers/caves/mining
	name = "North Terraforming Wing"
	icon_state = "nuke_storage"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_REQ
	always_unpowered = FALSE

/area/bluesummers/caves/mining/drill
	name = "Stampede Terraforming Drill"
	icon_state = "mining_eva"

/area/bluesummers/caves/mining/south
	name = "South Terraforming Wing"
	icon_state = "mining_storage"

/area/bluesummers/caves/cryostorage
	name = "Cryogenics Storage Wing"
	icon_state = "research"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_MEDBAY_CAVE
	always_unpowered = FALSE

/area/bluesummers/caves/cryostorage/north
	name = "Cryogenics Storage Wing North"
	icon_state = "anospectro"

/area/bluesummers/caves/cryostorage/south
	name = "Cryogenics Storage Wing South"
	icon_state = "anolab"
	ceiling = CEILING_UNDERGROUND_METAL

/area/bluesummers/caves/cryostorage/bridge
	name = "HMS Bluesummers Bridge"
	icon_state = "bridge"

/area/bluesummers/caves/cryostorage/gravity
	name = "Gravity Generator Room"
	icon_state = "anomaly"

/area/bluesummers/caves/cryostorage/tcomms
	name = "Telecommunications Control Room"
	icon_state = "tcomsatcomp"

/area/bluesummers/caves/cloning
	name = "Restricted Cloning Wing"
	icon_state = "cloning"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	always_unpowered = FALSE

/area/bluesummers/caves/dorms
	name = "Crew Sleeping Quarters"
	icon_state = "crew_quarters"
	ceiling = CEILING_UNDERGROUND
	minimap_color = MINIMAP_AREA_LIVING_CAVE
	always_unpowered = FALSE

/area/bluesummers/caves/martian
	name = "Punisher-Class Boarding Ship"
	icon_state = "shuttlered"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE
	always_unpowered = FALSE

/area/bluesummers/caves/northeast
	name = "Northeastern Caves"
	icon_state = "northeast2"

/area/bluesummers/caves/northeast/indoor
	name = "Northeast Caves Wreckage"
	always_unpowered = FALSE
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/bluesummers/caves/northeast/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/bluesummers/caves/northeast/garbledradio/indoor
	name = "Lower Northeast Caves Wreckage"
	always_unpowered = FALSE
	ceiling = CEILING_UNDERGROUND_METAL

/area/bluesummers/caves/southwest
	name = "Southwestern Caves"
	icon_state = "southwest2"
	ceiling = CEILING_UNDERGROUND

/area/bluesummers/caves/east
	name = "Eastern Tunnel"
	icon_state = "east2"
	ceiling = CEILING_UNDERGROUND

/area/bluesummers/caves/southeast
	name = "Southeast Caves"
	icon_state = "southeast2"
	ceiling = CEILING_UNDERGROUND

/area/bluesummers/caves/west
	name = "West Tunnel"
	icon_state = "west2"
	ceiling = CEILING_UNDERGROUND

/area/bluesummers/caves/south
	name = "Southern Caves"
	icon_state = "south2"
	ceiling = CEILING_UNDERGROUND

//Outside Area
/area/bluesummers/outside
	name = "Desert Grounds"
	icon_state = "cliff_blocked"
	ceiling = CEILING_NONE
	outside = TRUE
	always_unpowered = TRUE
	ambience = list('sound/effects/wind/wind_2_1.ogg' = 1, 'sound/effects/wind/wind_2_2.ogg' = 1, 'sound/effects/wind/wind_3_1.ogg' = 1, 'sound/effects/wind/wind_4_1.ogg' = 1, 'sound/effects/wind/wind_4_2.ogg' = 1, 'sound/effects/wind/wind_5_1.ogg' = 1)
	min_ambience_cooldown = 10 SECONDS
	max_ambience_cooldown = 12 SECONDS

/area/bluesummers/outside/southeast
	name = "Southeastern Desert"
	icon_state = "southeast"

/area/bluesummers/outside/southeast/roofed
	ceiling = CEILING_METAL
	outside = FALSE

/area/bluesummers/outside/south
	name = "Southern Desert"
	icon_state = "south"

/area/bluesummers/outside/south/roofed
	ceiling = CEILING_METAL
	outside = FALSE

/area/bluesummers/outside/southwest
	name = "Southwestern Desert"
	icon_state = "southwest"

/area/bluesummers/outside/southwest/roofed
	ceiling = CEILING_METAL
	outside = FALSE

/area/bluesummers/outside/northeast
	name = "Northeastern Desert"
	icon_state = "northeast"

/area/bluesummers/outside/northeast/roofed
	ceiling = CEILING_METAL
	outside = FALSE

/area/bluesummers/outside/north
	name = "Northern Desert"
	icon_state = "north"

/area/bluesummers/outside/north/roofed
	ceiling = CEILING_METAL
	outside = FALSE

/area/bluesummers/outside/northwest
	name = "Northwestern Desert"
	icon_state = "northwest"

/area/bluesummers/outside/northwest/roofed
	ceiling = CEILING_METAL
	outside = FALSE

//Indoor Areas
/area/bluesummers/inside
	name = "Inside"
	icon_state = "red"
	ceiling = CEILING_METAL
	outside = FALSE
	min_ambience_cooldown = 1 SECONDS
	max_ambience_cooldown = 1 SECONDS
	ambience = list('sound/ambience/ambienthum.ogg' = 1)

/area/bluesummers/inside/space_port
	name = "Space Port"
	icon_state = "landingzone1"
	ceiling = NONE
	area_flags = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/bluesummers/inside/telecomms
	name = "Telecomms"
	icon_state = "tcomsatcham"
	area_flags = NO_DROPPOD
	requires_power = FALSE

/area/bluesummers/inside/garage
	name = "Vehicle Storage Wing"
	icon_state = "garage"

/area/bluesummers/inside/hydroponics
	name = "Hydroponics Wing North"
	icon_state = "hydro_north"
	minimap_color = MINIMAP_AREA_LIVING

/area/bluesummers/inside/hydroponics/south
	name = "Hydroponics Wing South"
	icon_state = "hydro_south"

/area/bluesummers/inside/biodome
	name = "Biological Environment Dome"
	icon_state = "garden"
	minimap_color = MINIMAP_AREA_LIVING

/area/bluesummers/inside/engineering
	name = "Engineering Wing"
	icon_state = "engine_storage"
	minimap_color = MINIMAP_AREA_ENGI

/area/bluesummers/inside/engineering/office
	name = "Engineering Wing Office"
	icon_state = "engine_monitoring"

/area/bluesummers/inside/engineering/plant
	name = "Electrical Wing Plant"
	icon_state = "engine"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/bluesummers/inside/engineering/plant/control
	name = "Electrical Wing Control"
	icon_state = "engine_control"

/area/bluesummers/inside/chapel
	name = "Religious Wing Chapel"
	icon_state = "chapel"
	minimap_color = MINIMAP_AREA_LIVING

/area/bluesummers/inside/chapel/office
	name = "Religious Wing Office"
	icon_state = "chapeloffice"

/area/bluesummers/inside/recreation
	name = "Recreation Wing"
	icon_state = "courtroom"
	minimap_color = MINIMAP_AREA_LIVING

/area/bluesummers/inside/industrial
	name = "Industrial Wing"
	icon_state = "construction"
	minimap_color = MINIMAP_AREA_REQ

/area/bluesummers/inside/robotics
	name = "Robotics Wing"
	icon_state = "toxlab"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/bluesummers/inside/captains_office
	name = "Captain's Office"
	icon_state = "captain"
	minimap_color = MINIMAP_AREA_COMMAND

/area/bluesummers/inside/observation_deck
	name = "Observation Deck"
	icon_state = "tcomsatcham"

/area/bluesummers/inside/food_processing
	name = "Western Food Processing Wing"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_PREP

/area/bluesummers/inside/food_processing/east
	name = "Eastern Food Processing Wing"

/area/bluesummers/inside/eva
	name = "EVA Operations Wing"
	icon_state = "eva"

/area/bluesummers/inside/holodeck
	name = "Holodeck Entertainment Wing"
	icon_state = "Holodeck"

/area/bluesummers/inside/luxury
	name = "Luxury Cabin Wing"
	icon_state = "Theatre"
	minimap_color = MINIMAP_AREA_LIVING

/area/bluesummers/inside/data_processing
	name = "Data Processing Wing"
	icon_state = "HH_MOFFICE"
