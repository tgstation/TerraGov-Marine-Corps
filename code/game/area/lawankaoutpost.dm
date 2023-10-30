// Lawanka Outpost Areas

/area/lawankaoutpost/caves
	name = "Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/lawankaoutpost/caves/rock
	name = "Enclosed Area"
	icon_state = "transparent"

/area/lawankaoutpost/caves/northwest
	name = "Northwestern Caves"
	icon_state = "northwest"

/area/lawankaoutpost/caves/northwest/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lawankaoutpost/caves/west
	name = "Western Caves"
	icon_state = "west"

/area/lawankaoutpost/caves/west/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lawankaoutpost/caves/nukestorage
	name = "Nuclear Storage"
	icon_state = "nuke_storage"
	always_unpowered = FALSE

/area/lawankaoutpost/caves/southwest
	name = "Southwestern Caves"
	icon_state = "southwest"

/area/lawankaoutpost/caves/south
	name = "Southern Caves"
	icon_state = "south"
	ceiling = CEILING_UNDERGROUND

/area/lawankaoutpost/caves/east
	name = "Eastern Caves"
	icon_state = "east"
	ceiling = CEILING_UNDERGROUND

/area/lawankaoutpost/caves/nanotrasen_lab
	name = "ETA Research Lab"
	icon_state = "research"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	always_unpowered = FALSE

/area/lawankaoutpost/outside
	name = "Colony Grounds"
	icon_state = "green"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_JUNGLE
	always_unpowered = TRUE

/area/lawankaoutpost/outside/northwest
	name = "Northwestern Colony"
	icon_state = "northwest"

/area/lawankaoutpost/outside/north
	name = "Northern Colony"
	icon_state = "north"

/area/lawankaoutpost/outside/northeast
	name = "Northeastern Colony"
	icon_state = "northeast"

/area/lawankaoutpost/outside/west
	name = "Western Colony"
	icon_state = "west"

/area/lawankaoutpost/outside/central
	name = "Central Colony"
	icon_state = "central"

/area/lawankaoutpost/outside/east
	name = "Eastern Colony"
	icon_state = "east"

/area/lawankaoutpost/outside/southwest
	name = "Southwestern Colony"
	icon_state = "southwest"

/area/lawankaoutpost/outside/south
	name = "Southern Colony"
	icon_state = "south"

/area/lawankaoutpost/outside/southeast
	name = "Southeastern Colony"
	icon_state = "southeast"

/area/lawankaoutpost/colony
	name = "Colony Building"
	icon_state = "red"
	ceiling = CEILING_METAL
	outside = FALSE

/area/lawankaoutpost/colony/biologics
	name = "Biological Research Facility"
	icon_state = "xeno_lab"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/lawankaoutpost/colony/biologics_storage
	name = "Biological Storage"
	icon_state = "xeno_f_lab"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/lawankaoutpost/colony/cargo
	name = "Cargo"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_REQ

/area/lawankaoutpost/colony/mining
	name = "Mineral Processing"
	icon_state = "mining"
	minimap_color = MINIMAP_AREA_REQ

/area/lawankaoutpost/colony/medbay
	name = "Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/lawankaoutpost/colony/robotics
	name = "Robotics"
	icon_state = "ass_line"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/lawankaoutpost/colony/atmos
	name = "Atmospherics"
	icon_state = "atmos"
	minimap_color = MINIMAP_AREA_ENGI

/area/lawankaoutpost/colony/northdorms
	name = "Northern Dormitories"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/lawankaoutpost/colony/recdorms
	name = "Dormitories Recreation"
	icon_state = "showroom"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/lawankaoutpost/colony/bar
	name = "Bar"
	icon_state = "bar"
	minimap_color = MINIMAP_AREA_LIVING

/area/lawankaoutpost/colony/operations_administration
	name = "Operations Administration"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lawankaoutpost/colony/operations_hall
	name = "Operations Main Hallway"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_COMMAND

/area/lawankaoutpost/colony/operations_kitchen
	name = "Operations Kitchen"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lawankaoutpost/colony/operations_meeting
	name = "Operations Meeting Rooms"
	icon_state = "conference"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lawankaoutpost/colony/operations_storage
	name = "Operations Tool Storage"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lawankaoutpost/colony/southdorms
	name = "Southern Dormitories"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/lawankaoutpost/colony/engineering
	name = "Engineering"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI
	ceiling = CEILING_OBSTRUCTED

/area/lawankaoutpost/colony/chapel
	name = "Chapel"
	icon_state = "chapel"
	minimap_color = MINIMAP_AREA_LIVING

/area/lawankaoutpost/colony/marshalls
	name = "Marshall Offices"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/lawankaoutpost/colony/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	minimap_color = MINIMAP_AREA_LIVING

/area/lawankaoutpost/colony/cabin
	name = "South Cabin"
	icon_state = "crew_quarters"

/area/lawankaoutpost/colony/landingzoneone
	name = "Landing Zone One"
	icon_state = "landingzone1"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/lawankaoutpost/colony/landingzonetwo
	name = "Landing Zone Two"
	icon_state = "landingzone2"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ
