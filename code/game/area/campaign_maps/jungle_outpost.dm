//Jungle outpost areas
/area/campaign/jungle_outpost
	icon_state = "lv-626"

/area/campaign/jungle_outpost/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE
	ambience = list('sound/ambience/jungle_amb1.ogg')

//Jungle
/area/campaign/jungle_outpost/ground/jungle
	name = "Central Jungle"
	icon_state = "central"
	minimap_color = MINIMAP_AREA_JUNGLE

/area/campaign/jungle_outpost/ground/jungle/south_west
	name = "Southwestern Jungle"
	icon_state = "southwest"

/area/campaign/jungle_outpost/ground/jungle/south_east
	name = "Southeastern Jungle"
	icon_state = "southeast"

/area/campaign/jungle_outpost/ground/jungle/north_west
	name = "Northwestern Jungle"
	icon_state = "northwest"

/area/campaign/jungle_outpost/ground/jungle/north_east
	name = "Northeastern Jungle"
	icon_state = "northeast"

/area/campaign/jungle_outpost/ground/jungle/west
	name = "Western Jungle"
	icon_state = "west"

/area/campaign/jungle_outpost/ground/jungle/south
	name = "Southern Jungle"
	icon_state = "south"

/area/campaign/jungle_outpost/ground/jungle/east
	name = "Eastern Jungle"
	icon_state = "east"

/area/campaign/jungle_outpost/ground/jungle/north
	name = "Northern Jungle"
	icon_state = "north"

//river
/area/campaign/jungle_outpost/ground/river
	name = "\improper Southern River"
	icon_state = "blueold"

/area/campaign/jungle_outpost/ground/river/north
	name = "\improper Northern River"

/area/campaign/jungle_outpost/ground/river/west
	name = "\improper Western River"

/area/campaign/jungle_outpost/ground/river/east
	name = "\improper Eastern River"

/area/campaign/jungle_outpost/ground/river/lake
	name = "\improper Southern Lake"

//outpost
/area/campaign/jungle_outpost/outpost
	name = "\improper Outpost"
	icon_state = "green"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/campaign/jungle_outpost/outpost/medbay
	name = "\improper Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/campaign/jungle_outpost/outpost/medbay/lobby
	name = "\improper Medbay Lobby"
	icon_state = "medbay2"

/area/campaign/jungle_outpost/outpost/medbay/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/campaign/jungle_outpost/outpost/security
	name = "\improper Security Station"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/campaign/jungle_outpost/outpost/security/vault
	name = "\improper Vault"
	icon_state = "security"

/area/campaign/jungle_outpost/outpost/command
	name = "\improper Operations"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/campaign/jungle_outpost/outpost/command/captain
	name = "\improper Executive Office"
	icon_state = "captain"

/area/campaign/jungle_outpost/outpost/engineering
	name = "\improper Engineering"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI

/area/campaign/jungle_outpost/outpost/living
	name = "\improper Living Quarters"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING

/area/campaign/jungle_outpost/outpost/living/bathroom
	name = "\improper Bathrooms"
	icon_state = "restrooms"

/area/campaign/jungle_outpost/outpost/living/canteen
	name = "\improper Canteen"
	icon_state = "cafeteria"

/area/campaign/jungle_outpost/outpost/living/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/campaign/jungle_outpost/outpost/living/hydro
	name = "\improper Hydroponics Dome"
	icon_state = "hydro"

/area/campaign/jungle_outpost/outpost/req
	name = "\improper Cargo Bay"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_REQ

/area/campaign/jungle_outpost/outpost/req/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quartoffice"

/area/campaign/jungle_outpost/outpost/req/depot
	name = "\improper Cargo Depot"
	icon_state = "quartstorage"

/area/campaign/jungle_outpost/outpost/req/containers
	name = "\improper Container storage"
	icon_state = "container_yard"
	outside = TRUE
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/campaign/jungle_outpost/outpost/science
	name = "\improper Research Lab"
	icon_state = "toxlab"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/campaign/jungle_outpost/outpost/science/south
	name = "\improper Southern Research Lab"
	icon_state = "toxlab"

/area/campaign/jungle_outpost/outpost/science/office
	name = "\improper Science Director's office"
	icon_state = "toxlab"

/area/campaign/jungle_outpost/outpost/landing
	name = "\improper Landing pad"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_LZ
	outside = TRUE
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/campaign/jungle_outpost/outpost/landing/storage
	name = "\improper Landing pad storage"
	icon_state = "landing_pad"

/area/campaign/jungle_outpost/outpost/outer/southwest
	name = "\improper Southwestern dome"
	icon_state = "green"

/area/campaign/jungle_outpost/outpost/outer/west
	name = "\improper Western dome"
	icon_state = "green"

/area/campaign/jungle_outpost/outpost/outer/hermit
	name = "\improper Hermit's home"
	icon_state = "green"
	always_unpowered = TRUE
