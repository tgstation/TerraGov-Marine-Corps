//thonus AREAS--------------------------------------//

/area/thonus
	icon_state = "lv-626"

//parent types

/area/thonus/indoors
	name = "Indoors"
	icon_state = "cliff_blocked" //because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_NONE
	outside = FALSE

/area/thonus/outdoors
	name = "Outdoors"
	icon_state = "cliff_blocked" //because this is a PARENT TYPE and you should not be using it and should also be changing the icon!!!
	ceiling = CEILING_NONE
	outside = TRUE

/area/thonus/oob
	name = "thonus - Out Of Bounds"
	icon_state = "unknown"

//Landing Zone 1

/area/thonus/landing_zone_1
	name = "Landing Zone One"
	icon_state = "explored"
	outside = FALSE

/area/shuttle/drop1/thonus
	name = "Thonus IV - Dropship Alamo Landing Zone"
	icon_state = "away1"
	outside = FALSE

/area/thonus/landing_zone_1/lz1_console
	name = "Thonus IV - Dropship Alamo Console"
	icon_state = "tcomsatcham"
	requires_power = FALSE
	outside = FALSE

//Landing Zone 2

/area/thonus/landing_zone_2
	name = "Thonus IV - Landing Zone Two"
	icon_state = "explored"
	outside = FALSE

/area/shuttle/drop2/thonus
	name = "Thonus IV - Dropship Normandy Landing Zone"
	icon_state = "away2"

/area/thonus/landing_zone_2/lz2_console
	name = "Thonus IV - Dropship Normandy Console"
	icon_state = "tcomsatcham"
	requires_power = FALSE

//Landing Zone 3 & 4

/area/thonus/landing_zone_forecon
	name = "Thonus IV - FORECON Shuttle"
	icon_state = "shuttle"
	ceiling =  CEILING_METAL
	requires_power = FALSE

/area/thonus/landing_zone_forecon/landing_zone_3
	name = "Thonus IV - Landing Zone 3"
	icon_state = "blue"
	ceiling = CEILING_NONE

/area/thonus/landing_zone_forecon/landing_zone_4
	name = "Thonus IV - Landing Zone 4"
	icon_state = "blue"
	ceiling = CEILING_NONE

/area/thonus/landing_zone_forecon/UD6_Typhoon
	name = "Thonus IV - UD6 Typhoon"

/area/thonus/landing_zone_forecon/UD6_Tornado
	name = "Thonus IV - UD6 Tornado"

//Outdoors areas
/area/thonus/outdoors/colony_streets //WHY IS THIS A SUBTYPE OF BUILDINGS AAAARGGHGHHHH YOU DIDN'T EVEN USE OBJECT INHERITANCE FOR THE CIELINGS I HATE YOU BOBBY
	name = "Colony Streets"
	icon_state = "green"
	ceiling = CEILING_NONE

/area/thonus/outdoors/colony_streets/windbreaker
	name = "Colony Windbreakers"
	icon_state = "tcomsatcham"
	requires_power = FALSE
	ceiling = CEILING_NONE

/area/thonus/outdoors/colony_streets/windbreaker/observation
	name = "Colony Windbreakers - Observation"
	icon_state = "purple"
	requires_power = FALSE
	ceiling = CEILING_NONE

/area/thonus/outdoors/colony_streets/central_streets
	name = "Central Street - West"
	icon_state = "west"

/area/thonus/outdoors/colony_streets/east_central_street
	name = "Central Street - East"
	icon_state = "east"

/area/thonus/outdoors/colony_streets/south_street
	name = "Colony Streets - South"
	icon_state = "south"

/area/thonus/outdoors/colony_streets/south_east_street
	name = "Colony Streets - Southeast"
	icon_state = "southeast"

/area/thonus/outdoors/colony_streets/south_west_street
	name = "Colony Streets - Southwest"
	icon_state = "southwest"

/area/thonus/outdoors/colony_streets/north_west_street
	name = "Colony Streets - Northwest"
	icon_state = "northwest"

/area/thonus/outdoors/colony_streets/north_east_street
	name = "Colony Streets - Northeast"
	icon_state = "northeast"

/area/thonus/outdoors/colony_streets/north_street
	name = "Colony Streets - North"
	icon_state = "north"

/area/thonus/outdoors/colony_streets/winde
	name = "Colony Streets - Northwest"
	icon_state = "northwest"

//misc indoors areas

/area/thonus/indoors/lone_buildings
	name = "thonus - Lone buildings"
	icon_state = "green"

/area/thonus/indoors/lone_buildings/engineering
	name = "Emergency Engineering"
	icon_state = "engine_smes"

/area/thonus/indoors/lone_buildings/spaceport
	name = "North LZ1 - Spaceport"
	icon_state = "red"

/area/thonus/indoors/lone_buildings/outdoor_bot
	name = "East LZ1 - Outdoor Botony"
	icon_state = "yellow"
	ceiling = CEILING_GLASS

/area/thonus/indoors/lone_buildings/storage_blocks
	name = "Outdoor Storage"
	icon_state = "blue"

/area/thonus/indoors/lone_buildings/chunk
	name = "Chunk 'N Dump"
	icon_state = "blue"

//A Block
/area/thonus/indoors/a_block
	name = "A-Block"
	icon_state = "blue"
	ceiling = CEILING_METAL

/area/thonus/indoors/a_block/admin
	name = "A-Block - Colony Operations Centre"
	icon_state = "mechbay"
	ceiling = CEILING_GLASS

/area/thonus/indoors/a_block/dorms
	name = "A-Block - Western Dorms And Offices"
	icon_state = "fitness"

/area/thonus/indoors/a_block/fitness
	name = "A-Block - Fitness Centre"
	icon_state = "fitness"

/area/thonus/indoors/a_block/hallway
	name = "A-Block - South Operations Hallway"
	icon_state = "green"

/area/thonus/indoors/a_block/hallway/damage
	name = "A-Block - South Operations Hallway"
	icon_state = "green"
	ceiling = CEILING_NONE

/area/thonus/indoors/a_block/medical
	name = "A-Block - Medical"
	icon_state = "medbay"
	ceiling =  CEILING_GLASS

/area/thonus/indoors/a_block/security
	name = "A-Block - Security"
	icon_state = "head_quarters"

/area/thonus/indoors/a_block/kitchen
	name = "A-Block - Kitchen And Dining"
	icon_state = "kitchen"
	ceiling = CEILING_GLASS

/area/thonus/indoors/a_block/executive
	name = "A-Block - Executive Suite"
	icon_state = "captain"
	ceiling = CEILING_GLASS

/area/thonus/indoors/a_block/dorm_north
	name = "A-Block - Northen Shared Dorms"
	icon_state = "fitness"

/area/thonus/indoors/a_block/bridges
	name = "A-Block - Western Dorms To Security Bridge"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS

/area/thonus/indoors/a_block/bridges/dorms_fitness
	name = "A-Block - Corporate To Fitness Bridge"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS

/area/thonus/indoors/a_block/bridges/corpo_fitness
	name = "A-Block - Western Dorms To Fitness"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS


/area/thonus/indoors/a_block/bridges/corpo
	name = "A-Block - Security To Corporate Bridge"
	icon_state = "hallC1"

/area/thonus/indoors/a_block/bridges/op_centre
	name = "A-Block - Security To Operations Centre Bridge"
	icon_state = "hallC1"

/area/thonus/indoors/a_block/bridges/garden_bridge
	name = "A-Block - Garden Bridge"
	icon_state = "hallC2"

/area/thonus/indoors/a_block/corpo
	name = "A-Block - Corporate Office"
	icon_state = "toxlab"

/area/thonus/indoors/a_block/garden
	name = "A-Block - West Operations Garden"
	icon_state = "green"
	ceiling = CEILING_GLASS
//B Block

/area/thonus/indoors/b_block
	name = "B-Block"
	icon_state = "red"
	ceiling =  CEILING_METAL

/area/thonus/indoors/b_block/hydro
	name = "B-Block - Hydroponics"
	icon_state = "hydro"

/area/thonus/indoors/b_block/bar
	name = "B-Block - Bar"
	icon_state = "cafeteria"

/area/thonus/indoors/b_block/bridge
	name = "B-Block - Hydroponics Bridge Network"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS

//C Block

/area/thonus/indoors/c_block
	name = "C-Block"
	icon_state = "green"

/area/thonus/indoors/c_block/cargo
	name = "C-Block - Cargo"
	icon_state = "primarystorage"

/area/thonus/indoors/c_block/mining
	name = "C-Block - Mining"
	icon_state = "yellow"

/area/thonus/indoors/c_block/garage
	name = "C-Block - Garage"
	icon_state = "storage"

/area/thonus/indoors/c_block/casino
	name = "C-Block - Casino"
	icon_state = "purple"

/area/thonus/indoors/c_block/bridge
	name = "C-Block - Cargo To Garage Bridge"
	icon_state = "hallC1"
	ceiling = CEILING_GLASS

//Rockies

/area/thonus/outdoors/n_rockies
	name = "North Colony - Rockies"
	icon_state = "away"

/area/thonus/outdoors/nw_rockies
	name = "Northwest Colony - Rockies"
	icon_state = "away1"

/area/thonus/outdoors/w_rockies
	name = "West Colony - Rockies"
	icon_state = "away2"

/area/thonus/outdoors/p_n_rockies
	name = "North Processor - Rockies"
	icon_state = "away"

/area/thonus/outdoors/p_nw_rockies
	name = "Northwest Processor - Rockies"
	icon_state = "away1"

/area/thonus/outdoors/p_w_rockies
	name = "West Processor - Rockies"
	icon_state = "away2"

/area/thonus/outdoors/p_e_rockies
	name = "East Processor - Rockies"
	icon_state = "away3"

/area/thonus/outdoors/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	outside = FALSE
	ceiling = CEILING_DEEP_UNDERGROUND

//ATMOS
/area/thonus/atmos
	name = "Atmospheric Processor"
	icon_state = "engineering"
	ceiling = CEILING_METAL

/area/thonus/atmos/outdoor
	name = "Atmospheric Processor - Outdoors"
	icon_state = "quart"
	ceiling = CEILING_NONE

/area/thonus/atmos/east_reactor
	name = "Atmospheric Processor - Eastern Reactor"
	icon_state = "blue"

/area/thonus/atmos/east_reactor/north
	name = "Atmospheric Processor - Outer East Reactor - North"
	icon_state = "yellow"

/area/thonus/atmos/east_reactor/south
	name = "Atmospheric Processor - Outer East Reactor - south"
	icon_state = "red"

/area/thonus/atmos/east_reactor/east
	name = "Atmospheric Processor - Outer East Reactor - east"
	icon_state = "green"

/area/thonus/atmos/east_reactor/west
	name = "Atmospheric Processor - Outer East Reactor - west"
	icon_state = "purple"
/area/thonus/atmos/west_reactor
	name = "Atmospheric Processor - Western Reactor"
	icon_state = "blue"

/area/thonus/atmos/cargo_intake
	name = "Atmospheric Processor - Cargo Intake"
	icon_state = "yellow"

/area/thonus/atmos/command_centre
	name = "Atmospheric Processor - Central Command"
	icon_state = "red"

/area/thonus/atmos/north_command_centre
	name = "Atmospheric Processor - North Command Centre Checkpoint"
	icon_state = "green"

/area/thonus/atmos/filt
	name = "Atmospheric Processor - Filtration System"
	icon_state = "mechbay"

/area/thonus/caves
	outside = FALSE
	ceiling = CEILING_DEEP_UNDERGROUND
/area/thonus/caves/west_caves
	name = "Western Caves"
	icon_state = "yellow"

/area/thonus/caves/central_caves
	name = "Central Caves"
	icon_state = "purple"

/area/thonus/caves/east_caves
	name = "Eastern Caves"
	icon_state = "blue-red"
