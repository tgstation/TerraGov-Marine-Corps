//LV624 AREAS--------------------------------------//
/area/lv624
	icon_state = "lv-626"

/area/lv624/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE //Will this mess things up? God only knows

//Jungle
/area/lv624/ground/jungle1
	name = "Southeast Jungle"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle2
	name = "Southern Jungle"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle3
	name = "Southwest Jungle"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle4
	name = "Central Western Jungle"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle5
	name = "Eastern Jungle"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle6
	name = "Northwest Jungle"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle7
	name = "Northern Jungle"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle8
	name = "Northeast Jungle"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle9
	name = "Central Jungle"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/lv624/ground/jungle10
	name = "Western Jungle"
	icon_state = "west2"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

//Sand
/area/lv624/ground/sand1
	name = "\improper Western Barrens"
	icon_state = "west"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand2
	name = "\improper Central Barrens"
	icon_state = "red"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand2/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lv624/ground/sand3
	name = "\improper Eastern Barrens"
	icon_state = "east"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand3/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lv624/ground/sand4
	name = "\improper North Western Barrens"
	icon_state = "northwest"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand5
	name = "\improper North Central Barrens"
	icon_state = "blue-red"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand6
	name = "\improper North Eastern Barrens"
	icon_state = "northeast"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand6/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lv624/ground/sand7
	name = "\improper South Western Barrens"
	icon_state = "southwest"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand7/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lv624/ground/sand8
	name = "\improper South Central Barrens"
	icon_state = "away1"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand9
	name = "\improper South Eastern Barrens"
	icon_state = "southeast"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/tfort
	name = "\improper Table Fort"
	icon_state = "purple"
	outside = FALSE

/area/lv624/ground/river1
	name = "\improper Western River"
	icon_state = "blueold"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/river2
	name = "\improper Central River"
	icon_state = "purple"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/river3
	name = "\improper Eastern River"
	icon_state = "bluenew"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/filtration
	name = "\improper Filtration Plant"
	icon_state = "green"
	outside = FALSE
	minimap_color = MINIMAP_AREA_ENGI

/area/lv624/ground/compound
	name = "\improper Nanotrasen Compound"
	icon_state = "green"

/area/lv624/ground/compound/ne
	name = "\improper Northeast NT Compound"
	icon_state = "northeast"

/area/lv624/ground/compound/n
	name = "\improper Northern NT Compound"
	icon_state = "north"

/area/lv624/ground/compound/c
	name = "\improper Central NT Compound"
	icon_state = "purple"

/area/lv624/ground/compound/se
	name = "\improper Southeast NT Compound"
	icon_state = "southeast"

/area/lv624/ground/compound/sw
	name = "\improper Southwest NT Compound"
	icon_state = "southwest"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/shelter
	name = "\improper Rain shelter"
	icon_state = "blue"
	outside = FALSE

/area/lv624/ground/ruin
	name = "\improper Unknown structure"
	icon_state = "red"
	outside = FALSE

/area/lv624/ground/southcargo
	name = "\improper South Cargo Storage"
	icon_state = "storage"
	outside = FALSE

/area/lv624/ground/central2
	name = "North Central Caves"
	icon_state = "away3"

/area/lv624/ground/caves //Does not actually exist
	name = "Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

//Caves
/area/lv624/ground/caves/rock //catchall for closed turfs we want immune to rain/easily visible to map editing tools
	name = "Enclosed Area"
	icon_state = "transparent"
	minimap_color = null

/area/lv624/ground/caves/west1
	name = "Western Caves"
	icon_state = "away1"

/area/lv624/ground/caves/east1
	name = "Eastern Caves"
	icon_state = "away"

/area/lv624/ground/caves/east1/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lv624/ground/caves/central1
	name = "Central Caves"
	icon_state = "away4" //meh

/area/lv624/ground/caves/central1/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lv624/ground/caves/central2
	name = "Central Caves"
	icon_state = "away3"

/area/lv624/ground/caves/west2
	name = "North Western Caves"
	icon_state = "cave"

/area/lv624/ground/caves/east2
	name = "North Eastern Caves"
	icon_state = "cave"

/area/lv624/ground/caves/central3
	name = "South Central Caves"
	icon_state = "away2"

/area/lv624/ground/caves/central3/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lv624/ground/caves/central5
	name = "South Western Central Caves"
	icon_state = "purple"

/area/lv624/ground/caves/central5/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/lv624/ground/caves/central4
	name = "South Western Caves"
	icon_state = "yellow"

/area/lv624/ground/caves/central4/garbledradio
	ceiling = CEILING_UNDERGROUND

//Lazarus landing
/area/lv624/lazarus
	name = "\improper Lazarus"
	icon_state = "green"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/lv624/lazarus/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_ENGI

/area/lv624/lazarus/atmos/outside
	name = "\improper Atmospherics Area"
	icon_state = "purple"
	ceiling = CEILING_NONE

/area/lv624/lazarus/hallway_one
	name = "\improper Hallway"
	icon_state = "green"

/area/lv624/lazarus/hallway_two
	name = "\improper Hallway"
	icon_state = "purple"

/area/lv624/lazarus/medbay
	name = "\improper Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/lv624/lazarus/armory
	name = "\improper Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/lv624/lazarus/security
	name = "\improper Security"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/lv624/lazarus/captain
	name = "\improper Commandant's Quarters"
	icon_state = "captain"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lv624/lazarus/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "head_quarters"
	minimap_color = MINIMAP_AREA_COMMAND

/area/lv624/lazarus/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv624/lazarus/canteen
	name = "\improper Canteen"
	icon_state = "cafeteria"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv624/lazarus/main_hall
	name = "\improper Main Hallway"
	icon_state = "hallC1"

/area/lv624/lazarus/main_hall
	name = "\improper Main Hallway"
	icon_state = "hallC1"

/area/lv624/lazarus/toilet
	name = "\improper Dormitory Toilet"
	icon_state = "toilet"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv624/lazarus/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	minimap_color = MINIMAP_AREA_LIVING
	ambience = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')

/area/lv624/lazarus/toilet
	name = "\improper Dormitory Toilet"
	icon_state = "toilet"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv624/lazarus/sleep_male
	name = "\improper Male Dorm"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv624/lazarus/sleep_female
	name = "\improper Female Dorm"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv624/lazarus/quart
	name = "\improper Quartermasters"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_REQ

/area/lv624/lazarus/quartstorage
	name = "\improper Cargo Bay"
	icon_state = "quartstorage"
	minimap_color = MINIMAP_AREA_REQ

/area/lv624/lazarus/quartstorage/dome

/area/lv624/lazarus/quartstorage/two

/area/lv624/lazarus/quartstorage/outdoors
	name = "\improper Cargo Bay Area"
	icon_state = "purple"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE

/area/lv624/lazarus/engineering
	name = "\improper Engineering"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv624/lazarus/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"

/area/lv624/lazarus/secure_storage
	name = "\improper Secure Storage"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_SEC

/area/lv624/lazarus/internal_affairs
	name = "\improper Internal Affairs"
	icon_state = "law"

/area/lv624/lazarus/corporate_affairs
	name = "\improper Corporate Affairs"
	icon_state = "law"

/area/lv624/lazarus/robotics
	name = "\improper Robotics"
	icon_state = "ass_line"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv624/lazarus/research
	name = "\improper Research Lab"
	icon_state = "toxlab"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/lv624/lazarus/research/caves
	ceiling = CEILING_DEEP_UNDERGROUND

/area/lv624/lazarus/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"
	minimap_color = MINIMAP_AREA_LIVING

/area/lv624/lazarus/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_LIVING

/area/lv624/lazarus/hydroponics/aux
	name = "\improper Auxillary Hydroponics"

/area/lv624/lazarus/bar
	name = "\improper Bar"
	icon_state = "kitchen"
	ceiling = CEILING_GLASS

/area/lv624/lazarus/overgrown
	name = "\improper Overgrown Dome"
	icon_state = "construction"
	ceiling = CEILING_NONE
	outside = TRUE

/area/lv624/lazarus/sandtemple
	name = "\improper Mysterious Temple"
	icon_state = "sandtemple"
	ceiling = CEILING_DEEP_UNDERGROUND
	always_unpowered = TRUE

/area/lv624/lazarus/sandtemple/garbledradio
	ceiling = CEILING_UNDERGROUND
	always_unpowered = FALSE

/area/lv624/lazarus/sandtemple/sideroom //needed to allow nuke generator within temple to function
	name = "\improper Mysterious Temple"
	icon_state = "purple"
	requires_power = FALSE

/area/lv624/lazarus/tablefort
	name = "\improper Table Fort"
	icon_state = "tablefort"
	always_unpowered = TRUE
	outside = FALSE

/area/lv624/lazarus/crashed_ship
	name = "\improper Crashed Ship"
	icon_state = "shuttlered"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	always_unpowered = TRUE
	minimap_color = MINIMAP_AREA_SHIP

/area/lv624/lazarus/crashed_ship/desparity
	always_unpowered = FALSE

/area/lv624/lazarus/relay
	name = "\improper Secret Relay Room"
	icon_state = "tcomsatcham"
	minimap_color = MINIMAP_AREA_ENGI

/area/lv624/lazarus/console
	name = "\improper Shuttle Console"
	icon_state = "tcomsatcham"
	flags_area = NO_DROPPOD
	requires_power = FALSE

/area/lv624/lazarus/spaceport
	name = "\improper Eastern Space Port"
	icon_state = "landingzone1"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/lv624/lazarus/spaceport2
	name = "\improper Western Space Port"
	icon_state = "landingzone2"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ
