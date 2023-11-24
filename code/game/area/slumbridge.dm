// Slumbridge Area Code

/area/slumbridge/caves
	name = "Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/slumbridge/caves/rock
	name = "Enclosed Area"
	icon_state = "transparent"

/area/slumbridge/caves/rock/nearlz
	icon_state = "blue"

/area/slumbridge/caves/northeastcaves
	name = "\improper Northeast Caves"
	icon_state = "northeast2"

/area/slumbridge/caves/northeastcaves/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/caves/southwestcaves
	name = "\improper Southwest Caves"
	icon_state = "southwest2"

/area/slumbridge/caves/southeastcaves
	name = "\improper Southeast Caves"
	icon_state = "southeast2"

/area/slumbridge/caves/southeastcaves/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/caves/northwestcaves
	name = "\improper Northwest Caves"
	icon_state = "northwest2"

/area/slumbridge/caves/mining
	name = "\improper Asteroids"
	icon_state = "mining"
	always_unpowered = FALSE

/area/slumbridge/caves/mining/dropship
	name = "\improper Unknown Dropship"
	icon_state = "blue"
	ceiling = CEILING_METAL
	always_unpowered = FALSE

/area/slumbridge/caves/minedrock
	name = "\improper Mined Rock"
	icon_state = "mining_production"
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/outside
	name = "Colony Grounds"
	icon_state = "green"
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/slumbridge/outside/northeast
	name = "\improper Northeast Grasslands"
	icon_state = "away"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/slumbridge/outside/northeast/bridges
	icon_state = "away"
	outside = FALSE
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/outside/northwest
	name = "\improper Northwest Desert"
	icon_state = "away4"
	minimap_color = MINIMAP_AREA_COLONY

/area/slumbridge/outside/northwest/nearlz

/area/slumbridge/outside/southwest
	name = "\improper Southwest Snowlands"
	icon_state = "away1"
	minimap_color = MINIMAP_AREA_PREP
	ambience = list('sound/ambience/ambispace.ogg')
	temperature = ICE_COLONY_TEMPERATURE

/area/slumbridge/outside/southwest/nearlz

/area/slumbridge/outside/southeast
	name = "\improper Southeast Jungle"
	icon_state = "away2"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/slumbridge/inside
	name = "Colony Building"
	icon_state = "red"
	ceiling = CEILING_METAL
	outside = FALSE

/area/slumbridge/inside/sombase
	name = "SOM Base"
	ceiling = CEILING_UNDERGROUND
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/slumbridge/inside/sombase/east
	name = "\improper SOM Base Starboard"
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "syndie-ship"

/area/slumbridge/inside/sombase/west
	name = "\improper SOM Base Port"
	icon_state = "syndie-control"

/area/slumbridge/inside/sombase/hangar
	name = "\improper SOM Base Hangar"
	icon_state = "syndie-elite"

/area/slumbridge/inside/houses
	name = "Grasslands Housing"
	minimap_color = MINIMAP_AREA_COLONY

/area/slumbridge/inside/houses/nwcargo
	name = "Cargo Storage"
	icon_state = "primarystorage"

/area/slumbridge/inside/houses/swcargo
	name = "Cargo Checkpoint"
	icon_state = "quart"

/area/slumbridge/inside/houses/recreational
	name = "Recreational Plaza"
	icon_state = "crew_quarters"

/area/slumbridge/inside/houses/dorms
	name = "Dorms"
	icon_state = "Sleep"

/area/slumbridge/inside/houses/surgery
	name = "Dorms Medical"
	icon_state = "medbay3"

/area/slumbridge/inside/houses/surgery/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/slumbridge/inside/houses/car
	name = "Heavy Equipment Depo"
	icon_state = "garage"

/area/slumbridge/inside/zeta
	name = "Research Lab"
	icon_state = "blue"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/slumbridge/inside/zeta/north
	ceiling = CEILING_DEEP_UNDERGROUND
	icon_state = "toxlab"

/area/slumbridge/inside/zeta/south
	ceiling = CEILING_UNDERGROUND
	name = "Research Lab Foyer"
	icon_state = "xeno_lab"

/area/slumbridge/inside/zeta/entrance
	name = "Research Lab Entrance"
	icon_state = "engine"

/area/slumbridge/inside/engi
	name = "Engineering"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_ENGI

/area/slumbridge/inside/engi/engineroom
	name = "Engineering Head Room"
	icon_state = "substation"

/area/slumbridge/inside/engi/south
	name = "Engineering Stern"
	icon_state = "hallC2"

/area/slumbridge/inside/engi/central
	name = "Engineer Central"
	icon_state = "hallC1"

/area/slumbridge/inside/engi/west
	name = "Engineering Port"
	icon_state = "hallP"

/area/slumbridge/inside/engi/engine
	name = "Engineering Dam"
	icon_state = "hallS"
	outside = TRUE
	ceiling = CEILING_NONE

/area/slumbridge/inside/hydrotreatment
	name = "\improper Water Treatment Plant"
	icon_state = "decontamination"

/area/slumbridge/inside/prison
	name = "\improper High Security Prison"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/slumbridge/inside/prison/innerring
	name = "\improper High Security Interior"
	icon_state = "brig"

/area/slumbridge/inside/prison/outerringnorth
	name = "\improper High Security Northern Exterior"
	icon_state = "sec_hos"

/area/slumbridge/inside/prison/outerringsouth
	name = "\improper High Security Southern Exterior"
	icon_state = "sec_prison"

/area/slumbridge/inside/prison/outside
	icon_state = "security_sub"
	outside = TRUE
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/slumbridge/inside/hydrotreatment/mining
	name = "\improper Mining Outpost"
	icon_state = "mining_living"

/area/slumbridge/inside/colony
	name = "Colony Building"
	icon_state = "away1"
	minimap_color = MINIMAP_AREA_LIVING

/area/slumbridge/inside/colony/pharmacy
	name = "Colony Pharmacy"
	icon_state = "blue2"

/area/slumbridge/inside/colony/construction
	name = "Colony Construction"
	icon_state = "LP"

/area/slumbridge/inside/colony/hydro
	name = "Colony Hydroponics"
	icon_state = "hydro"

/area/slumbridge/inside/colony/dorms
	name = "Colony Dormitory"
	icon_state = "crew_quarters"

/area/slumbridge/inside/colony/kitchen
	name = "Colony Kitchen"
	icon_state = "kitchen"

/area/slumbridge/inside/colony/bar
	name = "Colony Bar"
	icon_state = "bar"

/area/slumbridge/inside/colony/vault
	name = "Colony Vault"
	icon_state = "observatory"

/area/slumbridge/inside/colony/oreprocess
	name = "Colony Ore Processing"
	icon_state = "unexplored"

/area/slumbridge/inside/colony/headoffice
	name = "Colony Director Office"
	icon_state = "conference"

/area/slumbridge/inside/colony/orestorage
	name = "Colony Storage"
	icon_state = "storage"

/area/slumbridge/inside/medical
	name = "\improper Medical Facility"
	icon_state = "medbay3"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/slumbridge/inside/medical/foyer
	name = "\improper Medical Foyer"
	icon_state = "medbay2"

/area/slumbridge/inside/medical/storage
	name = "\improper Medicine Storage"
	icon_state = "locker"

/area/slumbridge/inside/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"

/area/slumbridge/inside/medical/cmo
	name = "\improper Chief Medical Office"
	icon_state = "CMO"

/area/slumbridge/inside/medical/surgery
	name = "\improper Surgery Room"
	icon_state = "surgery"

/area/slumbridge/inside/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/slumbridge/inside/medical/southern
	name = "\improper Medical Lounge"
	icon_state = "LPS"

/area/slumbridge/inside/colony/southerndome
	name = "\improper Research Dome"
	icon_state = "toxmisc"

/area/slumbridge/inside/colony/northerndome
	name = "\improper Toxins Dome"
	icon_state = "toxtest"

/area/slumbridge/inside/pmcdome
	name = "\improper PMC Dome"
	icon_state = "Tactical"
	minimap_color = MINIMAP_AREA_MEDBAY_CAVE

/area/slumbridge/inside/pmcdome/nukevault
	name = "\improper PMC Nuke Vault"
	icon_state = "nuke_storage"
	always_unpowered = FALSE

/area/slumbridge/inside/pmcdome/weaponvault
	name = "\improper PMC Weapon Vault"
	icon_state = "armory"

/area/slumbridge/inside/pmcdome/dorms
	name = "\improper PMC Dormitory"
	icon_state = "Sleep"

/area/slumbridge/landingzoneone
	name = "Landing Zone One"
	icon_state = "landingzone1"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/slumbridge/landingzonetwo
	name = "Landing Zone Two"
	icon_state = "landingzone2"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/slumbridge/console
	name = "\improper Shuttle Console"
	icon_state = "tcomsatcham"
	flags_area = NO_DROPPOD
	requires_power = FALSE
