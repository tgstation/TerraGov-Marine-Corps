//LV624 AREAS--------------------------------------//
/area/lv624
	icon_state = "lv-626"

/area/lv624/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = 1 //Will this mess things up? God only knows

//Jungle
/area/lv624/ground/jungle1
	name =" Southeast Jungle"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle2
	name =" Southern Jungle"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle3
	name =" Southwest Jungle"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle4
	name =" Western Jungle"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle5
	name =" Eastern Jungle"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle6
	name =" Northwest Jungle"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle7
	name =" Northern Jungle"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle8
	name =" Northeast Jungle"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle9
	name =" Central Jungle"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')

//Sand
/area/lv624/ground/sand1
	name = " Western Barrens"
	icon_state = "west"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand2
	name = " Central Barrens"
	icon_state = "red"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand3
	name = " Eastern Barrens"
	icon_state = "east"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand4
	name = " North Western Barrens"
	icon_state = "northwest"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand5
	name = " North Central Barrens"
	icon_state = "blue-red"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand6
	name = " North Eastern Barrens"
	icon_state = "northeast"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand7
	name = " South Western Barrens"
	icon_state = "southwest"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand8
	name = " South Central Barrens"
	icon_state = "away1"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand9
	name = " South Eastern Barrens"
	icon_state = "southeast"
//	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/river1
	name = " Western River"
	icon_state = "blueold"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/river2
	name = " Central River"
	icon_state = "purple"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/river3
	name = " Eastern River"
	icon_state = "bluenew"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/compound
	name = " Weyland-Yutani Compound"
	icon_state = "green"

/area/lv624/ground/compound/ne
	name = " Northeast W-Y Compound"
	icon_state = "northeast"

/area/lv624/ground/compound/n
	name = " Northern W-Y Compound"
	icon_state = "north"

/area/lv624/ground/compound/c
	name = " Central W-Y Compound"
	icon_state = "purple"

/area/lv624/ground/compound/se
	name = " Southeast W-Y Compound"
	icon_state = "southeast"

/area/lv624/ground/compound/sw
	name = " Southwest W-Y Compound"
	icon_state = "southwest"

//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/caves //Does not actually exist
	name =" Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND

//Caves
/area/lv624/ground/caves/west1
	name =" Western Caves"
	icon_state = "away1"

/area/lv624/ground/caves/east1
	name =" Eastern Caves"
	icon_state = "away"

/area/lv624/ground/caves/central1
	name =" Central Caves"
	icon_state = "away4" //meh

/area/lv624/ground/caves/west2
	name =" North Western Caves"
	icon_state = "cave"

/area/lv624/ground/caves/east2
	name =" North Eastern Caves"
	icon_state = "cave"

/area/lv624/ground/caves/central2
	name =" North Central Caves"
	icon_state = "away3" //meh

/area/lv624/ground/caves/central3
	name =" South Central Caves"
	icon_state = "away2" //meh

//Lazarus landing
/area/lv624/lazarus
	name = " Lazarus"
	icon_state = "green"
	ceiling = CEILING_METAL

/area/lv624/lazarus/atmos
	name = " Atmospherics"
	icon_state = "atmos"
	ceiling = CEILING_GLASS

/area/lv624/lazarus/atmos/outside
	name = " Atmospherics Area"
	icon_state = "purple"
	ceiling = CEILING_NONE

/area/lv624/lazarus/hallway_one
	name = " Hallway"
	icon_state = "green"
	can_hellhound_enter = 0

/area/lv624/lazarus/hallway_two
	name = " Hallway"
	icon_state = "purple"
	can_hellhound_enter = 0

/area/lv624/lazarus/medbay
	name = " Medbay"
	icon_state = "medbay"

/area/lv624/lazarus/armory
	name = " Armory"
	icon_state = "armory"

/area/lv624/lazarus/security
	name = " Security"
	icon_state = "security"
	can_hellhound_enter = 0

/area/lv624/lazarus/captain
	name = " Commandant's Quarters"
	icon_state = "captain"
	can_hellhound_enter = 0

/area/lv624/lazarus/hop
	name = " Head of Personnel's Office"
	icon_state = "head_quarters"
	can_hellhound_enter = 0

/area/lv624/lazarus/kitchen
	name = " Kitchen"
	icon_state = "kitchen"
	can_hellhound_enter = 0

/area/lv624/lazarus/canteen
	name = " Canteen"
	icon_state = "cafeteria"
	can_hellhound_enter = 0

/area/lv624/lazarus/main_hall
	name = " Main Hallway"
	icon_state = "hallC1"
	can_hellhound_enter = 0

/area/lv624/lazarus/main_hall
	name = " Main Hallway"
	icon_state = "hallC1"
	can_hellhound_enter = 0

/area/lv624/lazarus/toilet
	name = " Dormitory Toilet"
	icon_state = "toilet"
	can_hellhound_enter = 0

/area/lv624/lazarus/chapel
	name = " Chapel"
	icon_state = "chapel"
	ambience = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')
	can_hellhound_enter = 0

/area/lv624/lazarus/toilet
	name = " Dormitory Toilet"
	icon_state = "toilet"
	can_hellhound_enter = 0

/area/lv624/lazarus/sleep_male
	name = " Male Dorm"
	icon_state = "Sleep"
	can_hellhound_enter = 0

/area/lv624/lazarus/sleep_female
	name = " Female Dorm"
	icon_state = "Sleep"
	can_hellhound_enter = 0

/area/lv624/lazarus/quart
	name = " Quartermasters"
	icon_state = "quart"
	can_hellhound_enter = 0

/area/lv624/lazarus/quartstorage
	name = " Cargo Bay"
	icon_state = "quartstorage"
	can_hellhound_enter = 0

/area/lv624/lazarus/quartstorage/outdoors
	name = " Cargo Bay Area"
	icon_state = "purple"
	ceiling = CEILING_NONE

/area/lv624/lazarus/engineering
	name = " Engineering"
	icon_state = "engine_smes"

/area/lv624/lazarus/comms
	name = " Communications Relay"
	icon_state = "tcomsatcham"

/area/lv624/lazarus/secure_storage
	name = " Secure Storage"
	icon_state = "storage"

/area/lv624/lazarus/internal_affairs
	name = " Internal Affairs"
	icon_state = "law"

/area/lv624/lazarus/robotics
	name = " Robotics"
	icon_state = "ass_line"

/area/lv624/lazarus/research
	name = " Research Lab"
	icon_state = "toxlab"

/area/lv624/lazarus/fitness
	name = " Fitness Room"
	icon_state = "fitness"

/area/lv624/lazarus/hydroponics
	name = " Hydroponics"
	icon_state = "hydro"
	ceiling = CEILING_GLASS

/area/lv624/lazarus/relay
	name = " Secret Relay Room"
	icon_state = "tcomsatcham"

/area/lv624/lazarus/console
	name = " Shuttle Console"
	icon_state = "tcomsatcham"
