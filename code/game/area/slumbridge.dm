// Slumbridge Area Code

/area/slumbridge/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	always_unpowered = TRUE

/area/slumbridge/rock/nearlz
	icon_state = "blue"

/area/slumbridge/northeastcaves
	name = "\improper Northeast Caves"
	icon_state = "northeast2"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/slumbridge/northeastcaves/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/mining
	name = "\improper Asteroids"
	icon_state = "mining"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE

/area/slumbridge/mining/dropship
	name = "\improper Unknown Dropship"
	icon_state = "blue"
	outside = FALSE
	ceiling = CEILING_METAL

/area/slumbridge/sombase
	name = "SOM Base"
	ceiling = CEILING_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/slumbridge/sombase/east
	name = "\improper SOM Base Starboard"
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "syndie-ship"

/area/slumbridge/sombase/west
	name = "\improper SOM Base Port"
	icon_state = "syndie-control"

/area/slumbridge/sombase/hangar
	name = "\improper SOM Base Hangar"
	icon_state = "syndie-elite"

/area/slumbridge/outside1
	name = "\improper Northeast Grasslands"
	icon_state = "away"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE
	always_unpowered = TRUE

/area/slumbridge/outside1/bridges
	icon_state = "away"
	outside = FALSE
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/houses
	name = "Grasslands Housing"
	outside = FALSE
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_COLONY

/area/slumbridge/houses/nwcargo
	name = "Cargo Storage"
	icon_state = "primarystorage"

/area/slumbridge/houses/swcargo
	name = "Cargo Checkpoint"
	icon_state = "quart"

/area/slumbridge/houses/recreational
	name = "Recreational Plaza"
	icon_state = "crew_quarters"

/area/slumbridge/houses/dorms
	name = "Dorms"
	icon_state = "Sleep"

/area/slumbridge/houses/surgery
	name = "Dorms Medical"
	icon_state = "medbay3"

/area/slumbridge/houses/surgery/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/houses/car
	name = "Heavy Equipment Depo"
	icon_state = "garage"

/area/slumbridge/zeta
	name = "Research Lab"
	outside = FALSE
	ceiling = CEILING_METAL
	icon_state = "blue"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/slumbridge/zeta/north
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "toxlab"

/area/slumbridge/zeta/south
	ceiling = CEILING_UNDERGROUND
	name = "Research Lab Foyer"
	icon_state = "xeno_lab"

/area/slumbridge/zeta/entrance
	name = "Research Lab Entrance"
	icon_state = "engine"

/area/slumbridge/engi
	name = "Engineering"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_ENGI
	outside = FALSE
	ceiling = CEILING_METAL

/area/slumbridge/engi/engineroom
	name = "Engineering Head Room"
	icon_state = "substation"

/area/slumbridge/engi/south
	name = "Engineering Stern"
	icon_state = "hallC2"

/area/slumbridge/engi/central
	name = "Engineer Central"
	icon_state = "hallC1"

/area/slumbridge/engi/west
	name = "Engineering Port"
	icon_state = "hallP"

/area/slumbridge/engi/engine
	name = "Engineering Dam"
	icon_state = "hallS"
	outside = TRUE
	ceiling = CEILING_NONE

/area/slumbridge/outside2
	name = "\improper Northwest Desert"
	icon_state = "away4"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE

/area/slumbridge/outside2/nearlz

/area/slumbridge/hydrotreatment
	name = "\improper Water Treatment Plant"
	icon_state = "decontamination"
	outside = FALSE
	ceiling = CEILING_METAL

/area/slumbridge/hydrotreatment/rock
	name = "\improper Mined Rock"
	icon_state = "mining_production"
	ceiling = CEILING_UNDERGROUND
	always_unpowered = TRUE
	outside = FALSE

/area/slumbridge/prison
	name = "\improper High Security Prison"
	icon_state = "red"
	outside = FALSE
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_SEC

/area/slumbridge/prison/innerring
	name = "\improper High Security Interior"
	icon_state = "brig"

/area/slumbridge/prison/outerringnorth
	name = "\improper High Security Northern Exterior"
	icon_state = "sec_hos"

/area/slumbridge/prison/outerringsouth
	name = "\improper High Security Southern Exterior"
	icon_state = "sec_prison"

/area/slumbridge/prison/outside
	icon_state = "security_sub"
	outside = TRUE
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/slumbridge/landingzoneone
	name = "Landing Zone One"
	icon_state = "landingzone1"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/slumbridge/northwestcaves
	name = "\improper Northwest Caves"
	icon_state = "northwest2"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/slumbridge/hydrotreatment/mining
	name = "\improper Mining Outpost"
	icon_state = "mining_living"

/area/slumbridge/console
	name = "\improper Shuttle Console"
	icon_state = "tcomsatcham"
	flags_area = NO_DROPPOD
	requires_power = FALSE

/area/slumbridge/southwestcaves
	name = "\improper Southwest Caves"
	icon_state = "southwest2"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/slumbridge/outside3
	name = "\improper Southwest Snowlands"
	icon_state = "away1"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_PREP
	always_unpowered = TRUE
	ambience = list('sound/ambience/ambispace.ogg')
	temperature = ICE_COLONY_TEMPERATURE

/area/slumbridge/outside3/nearlz

/area/slumbridge/landingzonetwo
	name = "Landing Zone Two"
	icon_state = "landingzone2"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/slumbridge/colony
	name = "Colony Building"
	icon_state = "away1"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LIVING

/area/slumbridge/colony/pharmacy
	name = "Colony Pharmacy"
	icon_state = "blue2"

/area/slumbridge/colony/construction
	name = "Colony Construction"
	icon_state = "LP"

/area/slumbridge/colony/hydro
	name = "Colony Hydroponics"
	icon_state = "hydro"

/area/slumbridge/colony/dorms
	name = "Colony Dormitory"
	icon_state = "crew_quarters"

/area/slumbridge/colony/kitchen
	name = "Colony Kitchen"
	icon_state = "kitchen"

/area/slumbridge/colony/bar
	name = "Colony Bar"
	icon_state = "bar"

/area/slumbridge/colony/vault
	name = "Colony Vault"
	icon_state = "observatory"

/area/slumbridge/colony/oreprocess
	name = "Colony Ore Processing"
	icon_state = "unexplored"

/area/slumbridge/colony/headoffice
	name = "Colony Director Office"
	icon_state = "conference"

/area/slumbridge/colony/orestorage
	name = "Colony Storage"
	icon_state = "storage"

/area/slumbridge/southeastcaves
	name = "\improper Southeast Caves"
	icon_state = "southeast2"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/slumbridge/southeastcaves/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/outside4
	name = "\improper Southeast Jungle"
	icon_state = "away2"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_JUNGLE
	always_unpowered = TRUE

/area/slumbridge/medical
	name = "\improper Medical Facility"
	icon_state = "medbay3"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_MEDBAY

/area/slumbridge/medical/foyer
	name = "\improper Medical Foyer"
	icon_state = "medbay2"

/area/slumbridge/medical/storage
	name = "\improper Medicine Storage"
	icon_state = "locker"

/area/slumbridge/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"

/area/slumbridge/medical/CMO
	name = "\improper Chief Medical Office"
	icon_state = "CMO"

/area/slumbridge/medical/surgery
	name = "\improper Surgery Room"
	icon_state = "surgery"

/area/slumbridge/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/slumbridge/medical/southern
	name = "\improper Medical Lounge"
	icon_state = "LPS"

/area/slumbridge/colony/southerndome
	name = "\improper Research Dome"
	icon_state = "toxmisc"

/area/slumbridge/colony/northerndome
	name = "\improper Toxins Dome"
	icon_state = "toxtest"

/area/slumbridge/pmcdome
	name = "\improper PMC Dome"
	icon_state = "Tactical"
	outside = FALSE
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_MEDBAY_CAVE

/area/slumbridge/pmcdome/nukevault
	name = "\improper PMC Nuke Vault"
	icon_state = "nuke_storage"
	always_unpowered = FALSE

/area/slumbridge/pmcdome/weaponvault
	name = "\improper PMC Weapon Vault"
	icon_state = "armory"

/area/slumbridge/pmcdome/dorms
	name = "\improper PMC Dormitory"
	icon_state = "Sleep"
