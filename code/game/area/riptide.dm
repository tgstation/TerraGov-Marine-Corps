// Riptide Areas

//Caves
/area/riptide/caves
	name = "Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/riptide/caves/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	area_flags = CANNOT_NUKE

//DO NOT GO HERE!!!
/area/riptide/caves/sea
	name = "Enclosed Watery Area"
	icon_state = "blueold"
	area_flags = NO_DROPPOD

/area/riptide/caves/checkpoint
	name = "PMC Checkpoint"
	icon_state = "Warden"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	always_unpowered = FALSE

/area/riptide/caves/central
	name = "Central Caves"
	icon_state = "central"

/area/riptide/caves/central/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/riptide/caves/north
	name = "Northern Caves"
	icon_state = "north2"

/area/riptide/caves/north/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/riptide/caves/north2
	name = "Northern Outcrop"
	icon_state = "north2"

/area/riptide/caves/north2/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/riptide/caves/piratecove
	name = "Underground Boat"
	icon_state = "hangar"
	always_unpowered = FALSE

/area/riptide/caves/pmc
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	always_unpowered = FALSE

/area/riptide/caves/pmc/lobby
	name = "Underground Facility Foyer"
	icon_state = "sec_backroom"

/area/riptide/caves/pmc/prison
	name = "Underground Holding Cells"
	icon_state = "sec_backroom"

/area/riptide/caves/pmc/rnd
	name = "Underground Robotics"
	icon_state = "security_sub"

/area/riptide/caves/pmc/toxins
	name = "Underground Laboratory"
	icon_state = "security"

/area/riptide/caves/pmc/warehouse
	name = "Underground Warehouse"
	icon_state = "armory"

/area/riptide/caves/tram
	name = "Decommissioned Tram Line"
	icon_state = "substation"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	always_unpowered = FALSE

/area/riptide/caves/south
	name = "Southern Mineshaft"
	icon_state = "south2"

/area/riptide/caves/south/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/riptide/caves/syndicatemining
	name = "Abandoned Quarry"
	icon_state = "security_sub"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	always_unpowered = FALSE

//Outside Area
/area/riptide/outside
	name = "Colony Grounds"
	icon_state = "cliff_blocked"
	ceiling = CEILING_NONE
	outside = TRUE
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE

/area/riptide/outside/northislands
	name = "Northern Islands"
	icon_state = "hallF"

/area/riptide/outside/northbeach
	name = "North Beach"
	icon_state = "north"

/area/riptide/outside/westbeach
	name = "West Beach"
	icon_state = "west"

/area/riptide/outside/westislands
	name = "Western Islands"
	icon_state = "hallA"

/area/riptide/outside/southbeach
	name = "South Beach"
	icon_state = "south"

/area/riptide/outside/southislands
	name = "Southern Islands"
	icon_state = "hallS"

/area/riptide/outside/river
	name = "River"
	icon_state = "valley"

/area/riptide/outside/eastbeach
	name = "East Beach"
	icon_state = "east"

/area/riptide/outside/beachlzone
	name = "North West Beach"
	icon_state = "firingrange"

/area/riptide/outside/southjungle
	name = "South Jungle"
	icon_state = "away2"

/area/riptide/outside/northjungle
	name = "North Jungle"
	icon_state = "anospectro"

/area/riptide/outside/westjungle
	name = "West Jungle"
	icon_state = "maint_research_shuttle"

/area/riptide/outside/volcano
	name = "Erupted Volcano"
	icon_state = "prototype_engine"

//Inside area parent, not used.
/area/riptide/inside
	name = "Inside"
	icon_state = "red"
	ceiling = CEILING_METAL
	outside = FALSE

/area/riptide/inside/engineering
	name = "Engineering"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI

/area/riptide/inside/engineering/bridge
	name = "River Dam"
	icon_state = "genetics"
	ceiling = CEILING_NONE
	outside = TRUE

/area/riptide/inside/engineering/cave
	name = "Underground Engineering"
	icon_state = "engine"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/riptide/inside/beachbar
	name = "Beach Bar"
	icon_state = "bar"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/beachshop
	name = "Gift Shop"
	icon_state = "thunder"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/beachtoilet
	name = "Public Restroom"
	icon_state = "landing_pad_taxiway"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/beachden
	name = "Gambling Den"
	icon_state = "bar"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/beachdressing
	name = "Beach Dressing Room"
	icon_state = "locker"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/beachmotel
	name = "Beach Motel"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/luxurybar
	name = "Luxurious River Bar"
	icon_state = "bar"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/beachsushi
	name = "Sushi Shop"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/medical
	name = "Medical Foyer"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/riptide/inside/medical/surgery
	name = "Surgery"
	icon_state = "patients"

/area/riptide/inside/medical/offices
	name = "CMO Office"
	icon_state = "CMO"

/area/riptide/inside/chapel
	name = "Chapel"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/warehouse
	name = "Industrial Warehouse"
	icon_state = "auxstorage"
	minimap_color = MINIMAP_AREA_REQ

/area/riptide/inside/hydroponics
	name = "Hydroponics"
	icon_state = "garden"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/tikihut
	name = "Tiki Huts"
	icon_state = "observatory"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/arena
	name = "Gunfight Arena"
	icon_state = "courtroom"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/observatory
	name = "Arena Observation"
	icon_state = "eva"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/recroom
	name = "Recreational Room"
	icon_state = "HH_Crypt"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/luxurybaroverlook
	name = "Bar Overlook"
	icon_state = "tcomsatentrance"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/canteen
	name = "Public Canteen"
	icon_state = "apmaint"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/canteen/two
	name = "Northern Canteen"

/area/riptide/inside/abandonedsec
	name = "Abandoned Security Island"
	icon_state = "sec_prison"
	minimap_color = MINIMAP_AREA_CELL_MED

/area/riptide/inside/cargoboat
	name = "Cargo Boat"
	icon_state = "amaint"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/lighttower
	name = "Light Tower"
	icon_state = "observatory"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/lighttowermaint
	name = "Light Tower Maintenance"
	icon_state = "maint_engine"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/boatdock
	name = "Boat Dock"
	icon_state = "eva"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/abandonedcottage
	name = "Abandoned Cottage"
	icon_state = "purple"
	minimap_color = MINIMAP_AREA_LIVING
	always_unpowered = TRUE

/area/riptide/inside/breachedfob
	name = "Destroyed Base"
	icon_state = "janitor"
	minimap_color = MINIMAP_AREA_LIVING
	always_unpowered = TRUE

/area/riptide/inside/southtower
	name = "Southern Observatory"
	icon_state = "janitor"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/guardcheck
	name = "Southern Guard"
	icon_state = "janitor"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/riverblocker
	name = "Southern River Cross"
	icon_state = "janitor"
	minimap_color = MINIMAP_AREA_LIVING

/area/riptide/inside/syndicatecheckpoint
	name = "Ominous Base Checkpoint"
	icon_state = "checkpoint1"
	minimap_color = MINIMAP_AREA_SEC

/area/riptide/inside/syndicatefoyer
	name = "Ominous Base Foyer"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/riptide/inside/syndicateport
	name = "Ominous Base Port"
	icon_state = "checkpoint1"
	minimap_color = MINIMAP_AREA_SEC

/area/riptide/inside/syndicategen
	name = "Ominous Base Engine"
	icon_state = "security_sub"
	minimap_color = MINIMAP_AREA_SEC

/area/riptide/inside/syndicatehead
	name = "Ominous Base Command Room"
	icon_state = "sec_hos"
	minimap_color = MINIMAP_AREA_SEC

/area/riptide/inside/syndicatestarboard
	name = "Ominous Base Starboard"
	icon_state = "sec_prison"
	minimap_color = MINIMAP_AREA_SEC

/area/riptide/inside/telecomms
	name = "Telecomms"
	icon_state = "tcomsatcham"
	area_flags = NO_DROPPOD
	requires_power = FALSE

/area/riptide/inside/landingzoneone
	name = "Landing Zone One"
	icon_state = "landingzone1"
	area_flags = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ
