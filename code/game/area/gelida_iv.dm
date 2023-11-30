//gelida AREAS--------------------------------------//

/area/gelida
	icon_state = "lv-626"

//parent types

/area/gelida/indoors
	name = "Indoors"
	icon_state = "cliff_blocked" //because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_NONE
	outside = FALSE

/area/gelida/outdoors
	name = "Outdoors"
	icon_state = "cliff_blocked" //because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_NONE
	outside = TRUE
	always_unpowered = TRUE

/area/gelida/oob
	name = "gelida - Out Of Bounds"
	icon_state = "unknown"

//Landing Zone 1

/area/gelida/landing_zone_1
	name = "Landing Zone One"
	icon_state = "explored"
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/shuttle/drop1/gelida
	name = "Gelida IV - Dropship Alamo Landing Zone"
	icon_state = "away1"
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/gelida/landing_zone_1/lz1_console
	name = "Gelida IV - Dropship Alamo Console"
	icon_state = "tcomsatcham"
	requires_power = FALSE
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

//Landing Zone 2

/area/gelida/landing_zone_2
	name = "Gelida IV - Landing Zone Two"
	icon_state = "explored"
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/shuttle/drop2/gelida
	name = "Gelida IV - Dropship Normandy Landing Zone"
	icon_state = "away2"
	minimap_color = MINIMAP_AREA_LZ

/area/gelida/landing_zone_2/lz2_console
	name = "Gelida IV - Dropship Normandy Console"
	icon_state = "tcomsatcham"
	requires_power = FALSE
	minimap_color = MINIMAP_AREA_LZ

//Landing Zone 3 & 4

/area/gelida/landing_zone_forecon
	name = "Gelida IV - FORECON Shuttle"
	icon_state = "shuttle"
	ceiling = CEILING_METAL
	requires_power = FALSE

/area/gelida/landing_zone_forecon/landing_zone_3
	name = "Gelida IV - Landing Zone 3"
	icon_state = "blue"
	ceiling = CEILING_NONE

/area/gelida/landing_zone_forecon/landing_zone_4
	name = "Gelida IV - Landing Zone 4"
	icon_state = "blue"
	ceiling = CEILING_NONE

/area/gelida/landing_zone_forecon/UD6_Typhoon
	name = "Gelida IV - UD6 Typhoon"
	outside = FALSE
	ceiling = CEILING_METAL

/area/gelida/landing_zone_forecon/UD6_Tornado
	name = "Gelida IV - UD6 Tornado"
	outside = FALSE
	ceiling = CEILING_METAL

//Outdoors areas
/area/gelida/outdoors/colony_streets //WHY IS THIS A SUBTYPE OF BUILDINGS AAAARGGHGHHHH YOU DIDN'T EVEN USE OBJECT INHERITANCE FOR THE CIELINGS I HATE YOU BOBBY
	name = "Colony Streets"
	icon_state = "green"
	ceiling = CEILING_NONE

/area/gelida/outdoors/colony_streets/windbreaker
	name = "Colony Windbreakers"
	icon_state = "tcomsatcham"
	requires_power = FALSE
	ceiling = CEILING_NONE

/area/gelida/outdoors/colony_streets/windbreaker/observation
	name = "Colony Windbreakers - Observation"
	icon_state = "purple"
	requires_power = FALSE
	ceiling = CEILING_NONE

/area/gelida/outdoors/colony_streets/central_streets
	name = "Central Street - West"
	icon_state = "west"

/area/gelida/outdoors/colony_streets/east_central_street
	name = "Central Street - East"
	icon_state = "east"

/area/gelida/outdoors/colony_streets/south_street
	name = "Colony Streets - South"
	icon_state = "south"

/area/gelida/outdoors/colony_streets/south_east_street
	name = "Colony Streets - Southeast"
	icon_state = "southeast"

/area/gelida/outdoors/colony_streets/south_west_street
	name = "Colony Streets - Southwest"
	icon_state = "southwest"

/area/gelida/outdoors/colony_streets/north_west_street
	name = "Colony Streets - Northwest"
	icon_state = "northwest"

/area/gelida/outdoors/colony_streets/north_east_street
	name = "Colony Streets - Northeast"
	icon_state = "northeast"

/area/gelida/outdoors/colony_streets/north_street
	name = "Colony Streets - North"
	icon_state = "north"

/area/gelida/outdoors/colony_streets/winde
	name = "Colony Streets - Northwest"
	icon_state = "northwest"

//misc indoors areas

/area/gelida/indoors/lone_buildings
	name = "gelida - Lone buildings"
	icon_state = "green"

/area/gelida/indoors/lone_buildings/engineering
	name = "Emergency Engineering"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI

/area/gelida/indoors/lone_buildings/spaceport
	name = "North LZ1 - Spaceport"
	icon_state = "red"

/area/gelida/indoors/lone_buildings/outdoor_bot
	name = "East LZ1 - Outdoor Botony"
	icon_state = "yellow"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_LIVING

/area/gelida/indoors/lone_buildings/storage_blocks
	name = "Outdoor Storage"
	icon_state = "blue"
	minimap_color = MINIMAP_AREA_REQ

/area/gelida/indoors/lone_buildings/chunk
	name = "Chunk 'N Dump"
	icon_state = "blue"
	minimap_color = MINIMAP_AREA_LIVING

//A Block
/area/gelida/indoors/a_block
	name = "A-Block"
	icon_state = "blue"
	ceiling = CEILING_METAL

/area/gelida/indoors/a_block/admin
	name = "A-Block - Colony Operations Centre"
	icon_state = "mechbay"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_COMMAND

/area/gelida/indoors/a_block/dorms
	name = "A-Block - Western Dorms And Offices"
	icon_state = "fitness"
	minimap_color = MINIMAP_AREA_LIVING

/area/gelida/indoors/a_block/fitness
	name = "A-Block - Fitness Centre"
	icon_state = "fitness"
	minimap_color = MINIMAP_AREA_LIVING

/area/gelida/indoors/a_block/hallway
	name = "A-Block - South Operations Hallway"
	icon_state = "green"

/area/gelida/indoors/a_block/hallway/damage
	name = "A-Block - South Operations Hallway"
	icon_state = "green"
	ceiling = CEILING_NONE

/area/gelida/indoors/a_block/medical
	name = "A-Block - Medical"
	icon_state = "medbay"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_MEDBAY

/area/gelida/indoors/a_block/security
	name = "A-Block - Security"
	icon_state = "head_quarters"
	minimap_color = MINIMAP_AREA_SEC

/area/gelida/indoors/a_block/kitchen
	name = "A-Block - Kitchen And Dining"
	icon_state = "kitchen"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_LIVING

/area/gelida/indoors/a_block/executive
	name = "A-Block - Executive Suite"
	icon_state = "captain"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_COMMAND

/area/gelida/indoors/a_block/dorm_north
	name = "A-Block - Northen Shared Dorms"
	icon_state = "fitness"
	minimap_color = MINIMAP_AREA_LIVING

/area/gelida/indoors/a_block/bridges
	name = "A-Block - Western Dorms To Security Bridge"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS

/area/gelida/indoors/a_block/bridges/dorms_fitness
	name = "A-Block - Corporate To Fitness Bridge"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS

/area/gelida/indoors/a_block/bridges/corpo_fitness
	name = "A-Block - Western Dorms To Fitness"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS


/area/gelida/indoors/a_block/bridges/corpo
	name = "A-Block - Security To Corporate Bridge"
	icon_state = "hallC1"

/area/gelida/indoors/a_block/bridges/op_centre
	name = "A-Block - Security To Operations Centre Bridge"
	icon_state = "hallC1"

/area/gelida/indoors/a_block/bridges/garden_bridge
	name = "A-Block - Garden Bridge"
	icon_state = "hallC2"

/area/gelida/indoors/a_block/corpo
	name = "A-Block - Corporate Office"
	icon_state = "toxlab"

/area/gelida/indoors/a_block/garden
	name = "A-Block - West Operations Garden"
	icon_state = "green"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_LIVING
//B Block

/area/gelida/indoors/b_block
	name = "B-Block"
	icon_state = "red"
	ceiling = CEILING_METAL

/area/gelida/indoors/b_block/hydro
	name = "B-Block - Hydroponics"
	icon_state = "hydro"
	minimap_color = MINIMAP_AREA_LIVING

/area/gelida/indoors/b_block/bar
	name = "B-Block - Bar"
	icon_state = "cafeteria"
	minimap_color = MINIMAP_AREA_LIVING

/area/gelida/indoors/b_block/bridge
	name = "B-Block - Hydroponics Bridge Network"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS

//C Block

/area/gelida/indoors/c_block
	name = "C-Block"
	icon_state = "green"

/area/gelida/indoors/c_block/cargo
	name = "C-Block - Cargo"
	icon_state = "primarystorage"
	minimap_color = MINIMAP_AREA_REQ

/area/gelida/indoors/c_block/mining
	name = "C-Block - Mining"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_REQ

/area/gelida/indoors/c_block/garage
	name = "C-Block - Garage"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ

/area/gelida/indoors/c_block/casino
	name = "C-Block - Casino"
	icon_state = "purple"
	minimap_color = MINIMAP_AREA_LIVING

/area/gelida/indoors/c_block/bridge
	name = "C-Block - Cargo To Garage Bridge"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS

//Rockies

/area/gelida/outdoors/n_rockies
	name = "North Colony - Rockies"
	icon_state = "away"

/area/gelida/outdoors/nw_rockies
	name = "Northwest Colony - Rockies"
	icon_state = "away1"

/area/gelida/outdoors/w_rockies
	name = "West Colony - Rockies"
	icon_state = "away2"
	ceiling = CEILING_UNDERGROUND
	always_unpowered = TRUE

/area/gelida/outdoors/p_n_rockies
	name = "North Processor - Rockies"
	icon_state = "away"

/area/gelida/outdoors/p_nw_rockies
	name = "Northwest Processor - Rockies"
	icon_state = "away1"

/area/gelida/outdoors/p_w_rockies
	name = "West Processor - Rockies"
	icon_state = "away2"

/area/gelida/outdoors/p_e_rockies
	name = "East Processor - Rockies"
	icon_state = "away3"

/area/gelida/outdoors/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	outside = FALSE
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

//ATMOS
/area/gelida/atmos
	name = "Atmospheric Processor"
	icon_state = "engineering"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_ENGI

/area/gelida/atmos/outdoor
	name = "Atmospheric Processor - Outdoors"
	icon_state = "quart"
	ceiling = CEILING_NONE
	minimap_color = NONE

/area/gelida/atmos/east_reactor
	name = "Atmospheric Processor - Eastern Reactor"
	icon_state = "blue"

/area/gelida/atmos/east_reactor/north
	name = "Atmospheric Processor - Outer East Reactor - North"
	icon_state = "yellow"

/area/gelida/atmos/east_reactor/south
	name = "Atmospheric Processor - Outer East Reactor - south"
	icon_state = "red"

/area/gelida/atmos/east_reactor/east
	name = "Atmospheric Processor - Outer East Reactor - east"
	icon_state = "green"

/area/gelida/atmos/east_reactor/west
	name = "Atmospheric Processor - Outer East Reactor - west"
	icon_state = "purple"
/area/gelida/atmos/west_reactor
	name = "Atmospheric Processor - Western Reactor"
	icon_state = "blue"

/area/gelida/atmos/cargo_intake
	name = "Atmospheric Processor - Cargo Intake"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_REQ

/area/gelida/atmos/command_centre
	name = "Atmospheric Processor - Central Command"
	icon_state = "red"

/area/gelida/atmos/north_command_centre
	name = "Atmospheric Processor - North Command Centre Checkpoint"
	icon_state = "green"

/area/gelida/atmos/filt
	name = "Atmospheric Processor - Filtration System"
	icon_state = "mechbay"

/area/gelida/powergen
	name = "Underground Power Generation"
	icon_state = "ass_line"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	outside = FALSE

/area/gelida/powergen/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/gelida/cavestructuretwo
	name = "Underground Abandoned Structure"
	icon_state = "garage"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES
	outside = FALSE

/area/gelida/caves
	outside = FALSE
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/gelida/caves/west_caves
	name = "Western Caves"
	icon_state = "yellow"

/area/gelida/caves/west_caves/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/gelida/caves/central_caves
	name = "Central Caves"
	icon_state = "purple"

/area/gelida/caves/central_caves/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/gelida/caves/east_caves
	name = "Eastern Caves"
	icon_state = "blue-red"

/area/gelida/caves/east_caves/garbledradio
	ceiling = CEILING_UNDERGROUND
