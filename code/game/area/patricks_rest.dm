//ORIONOUTPOST AREAS//
/area/patricks_rest
	name = "Patricks Rest"
	icon_state = "dark"

/area/patricks_rest/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE

/area/patricks_rest/surface
	name = "Surface"
	icon_state = "red"

/area/patricks_rest/surface/building
	name = "Orion Outpost Buildings"
	icon_state = "clear"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/patricks_rest/ground/underground
	name = "Orion Outpost Underground"
	icon_state = "cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

//LandingZone
/area/patricks_rest/surface/landing_pad
	name = "Landing Pad 1"
	icon_state = "landing_pad"
	flags_area = NO_DROPPOD
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/patricks_rest/surface/landing_pad_external
	name = "Landing Zone 1"
	icon_state = "landing_pad_ext"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/patricks_rest/surface/landing_pad_2
	name = "Landing Pad 2"
	icon_state = "landing_pad"
	flags_area = NO_DROPPOD
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

/area/patricks_rest/surface/landing_pad2_external
	name = "Landing Zone 2"
	icon_state = "landing_pad_ext"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_LZ

//River
/area/patricks_rest/ground/river/riverside_north
	name = "Northern Riverbed"
	icon_state = "bluenew"

/area/patricks_rest/ground/river/riverside_central
	name = "Central Riverbed"
	icon_state = "bluenew"

/area/patricks_rest/ground/river/riverside_south
	name = "Southern Riverbed"
	icon_state = "bluenew"

//OutpostGround
/area/patricks_rest/ground/outpostse
	name ="Southeast Outpost"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/outposts
	name ="Southern Outpost"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/outpostsw
	name ="Southwest Outpost"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/outpostw
	name ="Western Outpost"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/outposte
	name ="Eastern Outpost"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/outpostnw
	name ="Northwest Outpost"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/outpostn
	name ="Northern Outpost"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/outpostne
	name ="Northeast Outpost"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/outpostcent
	name ="Central Outpost"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

//OutpostCaves
/area/patricks_rest/ground/underground/cave
	name = "Underground Caves"
	icon_state = "cave"

/area/patricks_rest/ground/underground/caveN
	name = "Northern Caves"
	icon_state = "cave"

/area/patricks_rest/ground/underground/caveNW
	name = "Northwestern Caves"
	icon_state = "cave"

/area/patricks_rest/ground/underground/caveE
	name = "Eastern Caves"
	icon_state = "cave"

/area/patricks_rest/ground/underground/caveS
	name = "Southern Caves"
	icon_state = "cave"

/area/patricks_rest/ground/underground/caveW
	name = "Western Caves"
	icon_state = "cave"

//OutpostBuildings
/area/patricks_rest/surface/building/canteen
	name = "Canteen"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_LIVING

/area/patricks_rest/surface/building/barracks
	name = "Barracks"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/patricks_rest/surface/building/prep
	name = "Preperations"
	icon_state = "green"
	minimap_color = MINIMAP_AREA_PREP

/area/patricks_rest/surface/building/command
	name = "Command"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_COMMAND

/area/patricks_rest/surface/building/engineering
	name = "Engineering"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/patricks_rest/surface/building/cargo
	name = "Cargo Storage"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_REQ

/area/patricks_rest/surface/building/nebuilding
	name = "Northeast Building"
	icon_state = "dark160"

/area/patricks_rest/surface/building/medbay
	name = "Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/patricks_rest/surface/building/dorms
	name = "Dormitory"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/patricks_rest/surface/building/bunker
	name = "Bunkers"
	always_unpowered = TRUE
	icon_state = "dark128"

/area/patricks_rest/surface/building/crashedufo
	name = "Crashed UFO"
	icon_state = "blueold"

/area/patricks_rest/surface/building/tadpolepad
	name = "Tadpole Landing Pad"
	icon_state = "purple"

/area/patricks_rest/surface/building/armory
	name = "Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/patricks_rest/surface/building/brig
	name = "Brig"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/patricks_rest/surface/building/monitor
	name = "Monitoring Station"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/patricks_rest/surface/building/administration
	name = "Administration"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_COMMAND

/area/patricks_rest/surface/building/atc
	name = "Traffic Control"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_COMMAND

/area/patricks_rest/surface/building/ammodepot
	name = "Ammo Depot"
	icon_state = "dark"
	minimap_color = MINIMAP_AREA_SEC

/area/patricks_rest/surface/building/vehicledepot
	name = "Vehicle Depot"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_ENGI

/area/patricks_rest/surface/building/breakroom
	name = "Breakroom Building"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_LIVING
