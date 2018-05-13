//LV624 AREAS--------------------------------------//
/area/lv624
	icon_state = "lv-626"

/area/lv624/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = 1 //Will this mess things up? God only knows

//Jungle
/area/lv624/ground/jungle1
	name ="\improper Southeast Jungle"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle2
	name ="\improper Southern Jungle"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle3
	name ="\improper Southwest Jungle"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle4
	name ="\improper Western Jungle"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle5
	name ="\improper Eastern Jungle"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle6
	name ="\improper Northwest Jungle"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle7
	name ="\improper Northern Jungle"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle8
	name ="\improper Northeast Jungle"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/jungle9
	name ="\improper Central Jungle"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')

//Sand
/area/lv624/ground/sand1
	name = "\improper Western Barrens"
	icon_state = "west"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand2
	name = "\improper Central Barrens"
	icon_state = "red"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand3
	name = "\improper Eastern Barrens"
	icon_state = "east"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

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

/area/lv624/ground/sand7
	name = "\improper South Western Barrens"
	icon_state = "southwest"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand8
	name = "\improper South Central Barrens"
	icon_state = "away1"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/sand9
	name = "\improper South Eastern Barrens"
	icon_state = "southeast"
//	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambisin4.ogg')

/area/lv624/ground/river1
	name = "\improper Western River"
	icon_state = "blueold"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/river2
	name = "\improper Central River"
	icon_state = "purple"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/river3
	name = "\improper Eastern River"
	icon_state = "bluenew"
//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/compound
	name = "\improper Weyland Yutani Compound"
	icon_state = "green"

/area/lv624/ground/compound/ne
	name = "\improper Northeast W-Y Compound"
	icon_state = "northeast"

/area/lv624/ground/compound/n
	name = "\improper Northern W-Y Compound"
	icon_state = "north"

/area/lv624/ground/compound/c
	name = "\improper Central W-Y Compound"
	icon_state = "purple"

/area/lv624/ground/compound/se
	name = "\improper Southeast W-Y Compound"
	icon_state = "southeast"

/area/lv624/ground/compound/sw
	name = "\improper Southwest W-Y Compound"
	icon_state = "southwest"

//	ambience = list('sound/ambience/jungle_amb1.ogg')

/area/lv624/ground/caves //Does not actually exist
	name ="\improper Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND

//Caves
/area/lv624/ground/caves/west1
	name ="\improper Western Caves"
	icon_state = "away1"

/area/lv624/ground/caves/east1
	name ="\improper Eastern Caves"
	icon_state = "away"

/area/lv624/ground/caves/central1
	name ="\improper Central Caves"
	icon_state = "away4" //meh

/area/lv624/ground/caves/west2
	name ="\improper North Western Caves"
	icon_state = "cave"

/area/lv624/ground/caves/east2
	name ="\improper North Eastern Caves"
	icon_state = "cave"

/area/lv624/ground/caves/central2
	name ="\improper North Central Caves"
	icon_state = "away3" //meh

/area/lv624/ground/caves/central3
	name ="\improper South Central Caves"
	icon_state = "away2" //meh

//Lazarus landing
/area/lv624/lazarus
	name = "\improper Lazarus"
	icon_state = "green"
	ceiling = CEILING_METAL

/area/lv624/lazarus/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"
	ceiling = CEILING_GLASS

/area/lv624/lazarus/atmos/outside
	name = "\improper Atmospherics Area"
	icon_state = "purple"
	ceiling = CEILING_NONE

/area/lv624/lazarus/hallway_one
	name = "\improper Hallway"
	icon_state = "green"
	can_hellhound_enter = 0

/area/lv624/lazarus/hallway_two
	name = "\improper Hallway"
	icon_state = "purple"
	can_hellhound_enter = 0

/area/lv624/lazarus/medbay
	name = "\improper Medbay"
	icon_state = "medbay"

/area/lv624/lazarus/armory
	name = "\improper Armory"
	icon_state = "armory"

/area/lv624/lazarus/security
	name = "\improper Security"
	icon_state = "security"
	can_hellhound_enter = 0

/area/lv624/lazarus/captain
	name = "\improper Commandant's Quarters"
	icon_state = "captain"
	can_hellhound_enter = 0

/area/lv624/lazarus/hop
	name = "\improper Head of Personnel's Office"
	icon_state = "head_quarters"
	can_hellhound_enter = 0

/area/lv624/lazarus/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"
	can_hellhound_enter = 0

/area/lv624/lazarus/canteen
	name = "\improper Canteen"
	icon_state = "cafeteria"
	can_hellhound_enter = 0

/area/lv624/lazarus/main_hall
	name = "\improper Main Hallway"
	icon_state = "hallC1"
	can_hellhound_enter = 0

/area/lv624/lazarus/main_hall
	name = "\improper Main Hallway"
	icon_state = "hallC1"
	can_hellhound_enter = 0

/area/lv624/lazarus/toilet
	name = "\improper Dormitory Toilet"
	icon_state = "toilet"
	can_hellhound_enter = 0

/area/lv624/lazarus/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	ambience = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')
	can_hellhound_enter = 0

/area/lv624/lazarus/toilet
	name = "\improper Dormitory Toilet"
	icon_state = "toilet"
	can_hellhound_enter = 0

/area/lv624/lazarus/sleep_male
	name = "\improper Male Dorm"
	icon_state = "Sleep"
	can_hellhound_enter = 0

/area/lv624/lazarus/sleep_female
	name = "\improper Female Dorm"
	icon_state = "Sleep"
	can_hellhound_enter = 0

/area/lv624/lazarus/quart
	name = "\improper Quartermasters"
	icon_state = "quart"
	can_hellhound_enter = 0

/area/lv624/lazarus/quartstorage
	name = "\improper Cargo Bay"
	icon_state = "quartstorage"
	can_hellhound_enter = 0

/area/lv624/lazarus/quartstorage/outdoors
	name = "\improper Cargo Bay Area"
	icon_state = "purple"
	ceiling = CEILING_NONE

/area/lv624/lazarus/engineering
	name = "\improper Engineering"
	icon_state = "engine_smes"

/area/lv624/lazarus/comms
	name = "\improper Communications Relay"
	icon_state = "tcomsatcham"

/area/lv624/lazarus/secure_storage
	name = "\improper Secure Storage"
	icon_state = "storage"

/area/lv624/lazarus/internal_affairs
	name = "\improper Internal Affairs"
	icon_state = "law"

/area/lv624/lazarus/robotics
	name = "\improper Robotics"
	icon_state = "ass_line"

/area/lv624/lazarus/research
	name = "\improper Research Lab"
	icon_state = "toxlab"

/area/lv624/lazarus/fitness
	name = "\improper Fitness Room"
	icon_state = "fitness"

/area/lv624/lazarus/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"
	ceiling = CEILING_GLASS

/area/lv624/lazarus/relay
	name = "\improper Secret Relay Room"
	icon_state = "tcomsatcham"

/area/lv624/lazarus/console
	name = "\improper Shuttle Console"
	icon_state = "tcomsatcham"
