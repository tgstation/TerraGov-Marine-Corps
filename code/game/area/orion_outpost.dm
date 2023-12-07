//ORIONOUTPOST AREAS//
/area/orion_outpost
	name = "Orion Military Outpost"
	icon_state = "dark"

/area/orion_outpost/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE

/area/orion_outpost/surface
	name = "Surface"
	icon_state = "red"

/area/orion_outpost/surface/building
	name = "Orion Outpost Buildings"
	icon_state = "clear"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/orion_outpost/ground/underground
	name = "Orion Outpost Underground"
	icon_state = "cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

//LandingZone
/area/orion_outpost/surface/landing_pad
	name = "Landing Pad 1"
	icon_state = "landing_pad"
	flags_area = NO_DROPPOD
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ
	always_unpowered = TRUE

/area/orion_outpost/surface/landing_pad_external
	name = "Landing Zone 1"
	icon_state = "landing_pad_ext"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/orion_outpost/surface/landing_pad_2
	name = "Landing Pad 2"
	icon_state = "landing_pad"
	flags_area = NO_DROPPOD
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ
	always_unpowered = TRUE

/area/orion_outpost/surface/landing_pad2_external
	name = "Landing Zone 2"
	icon_state = "landing_pad_ext"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/orion_outpost/surface/train_yard
	name = "train yard"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_LZ

//River
/area/orion_outpost/ground/river/riverside_north
	name = "Northern Riverbed"
	icon_state = "bluenew"

/area/orion_outpost/ground/river/riverside_central
	name = "Central Riverbed"
	icon_state = "bluenew"

/area/orion_outpost/ground/river/riverside_south
	name = "Southern Riverbed"
	icon_state = "bluenew"

//OutpostGround
/area/orion_outpost/ground/outpostse
	name ="Southeast Outpost"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/orion_outpost/ground/outposts
	name ="Southern Outpost"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/orion_outpost/ground/outpostsw
	name ="Southwest Outpost"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/orion_outpost/ground/outpostw
	name ="Western Outpost"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/orion_outpost/ground/outposte
	name ="Eastern Outpost"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/orion_outpost/ground/outpostnw
	name ="Northwest Outpost"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/orion_outpost/ground/outpostn
	name ="Northern Outpost"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/orion_outpost/ground/outpostne
	name ="Northeast Outpost"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/orion_outpost/ground/outpostcent
	name ="Central Outpost"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

//OutpostCaves
/area/orion_outpost/ground/underground/cave
	name = "Underground Caves"
	icon_state = "cave"

/area/orion_outpost/ground/underground/caveN
	name = "Northern Caves"
	icon_state = "cave"

/area/orion_outpost/ground/underground/caveN/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/orion_outpost/ground/underground/caveNW
	name = "Northwestern Caves"
	icon_state = "cave"

/area/orion_outpost/ground/underground/caveE
	name = "Eastern Caves"
	icon_state = "cave"

/area/orion_outpost/ground/underground/caveE/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/orion_outpost/ground/underground/caveS
	name = "Southern Caves"
	icon_state = "cave"

/area/orion_outpost/ground/underground/caveS/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/orion_outpost/ground/underground/caveW
	name = "Western Caves"
	icon_state = "cave"

//OutpostBuildings
/area/orion_outpost/surface/building/canteen
	name = "Canteen"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_LIVING

/area/orion_outpost/surface/building/barracks
	name = "Barracks"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/orion_outpost/surface/building/prep
	name = "Preperations"
	icon_state = "green"
	minimap_color = MINIMAP_AREA_PREP

/area/orion_outpost/surface/building/command
	name = "Command"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_COMMAND

/area/orion_outpost/surface/building/engineering
	name = "Engineering"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/orion_outpost/surface/building/cargo
	name = "Cargo Storage"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_REQ

/area/orion_outpost/surface/building/nebuilding
	name = "Northeast Building"
	icon_state = "dark160"

/area/orion_outpost/surface/building/medbay
	name = "Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/orion_outpost/surface/building/dorms
	name = "Dormitory"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/orion_outpost/surface/building/bunker
	name = "Bunkers"
	always_unpowered = TRUE
	icon_state = "dark128"

/area/orion_outpost/surface/building/crashedufo
	name = "Crashed UFO"
	icon_state = "blueold"
	always_unpowered = TRUE

/area/orion_outpost/surface/building/tadpolepad
	name = "Tadpole Landing Pad"
	icon_state = "purple"

/area/orion_outpost/surface/building/armory
	name = "Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/orion_outpost/surface/building/brig
	name = "Brig"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/orion_outpost/surface/building/monitor
	name = "Monitoring Station"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/orion_outpost/surface/building/administration
	name = "Administration"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_COMMAND

/area/orion_outpost/surface/building/atc
	name = "Traffic Control"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_COMMAND

/area/orion_outpost/surface/building/ammodepot
	name = "Ammo Depot"
	icon_state = "dark"
	minimap_color = MINIMAP_AREA_SEC

/area/orion_outpost/surface/building/vehicledepot
	name = "Vehicle Depot"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_ENGI

/area/orion_outpost/surface/building/breakroom
	name = "Breakroom Building"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_LIVING
