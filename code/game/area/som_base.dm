//ROCICANTECOLONY AREAS//
/area/rocicante_colony
	name = "Rocicante Polar Colony"
	icon_state = "dark"

/area/rocicante_colony/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE

/area/rocicante_colony/surface
	name = "Surface"
	icon_state = "red"

/area/rocicante_colony/surface/building
	name = "Rocicante Colony Buildings"
	icon_state = "clear"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/rocicante_colony/ground/underground
	name = "Rocicante Colony Underground"
	icon_state = "cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

//LandingZone
/area/rocicante_colony/surface/landing_pad
	name = "Landing Pad 1"
	icon_state = "landing_pad"
	flags_area = NO_DROPPOD
	ceiling = CEILING_METAL
	outside = FALSE

/area/rocicante_colony/surface/landing_pad/2
	name = "Landing Pad 2"

/area/rocicante_colony/surface/landing_pad_external
	name = "LZ1"
	icon_state = "landing_pad_ext"
	ceiling = CEILING_METAL

/area/rocicante_colony/surface/landing_pad_external/2
	name = "LZ2"

//colonyGround
/area/rocicante_colony/ground/colonyse
	name ="Southeast colony"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocicante_colony/ground/colonys
	name ="Southern colony"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocicante_colony/ground/colonysw
	name ="Southwest colony"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocicante_colony/ground/colonyw
	name ="Western colony"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocicante_colony/ground/colonye
	name ="Eastern colony"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocicante_colony/ground/colonynw
	name ="Northwest colony"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocicante_colony/ground/colonyn
	name ="Northern colony"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocicante_colony/ground/colonyne
	name ="Northeast colony"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocicante_colony/ground/colonycent
	name ="Central colony"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

//colonyCaves
/area/rocicante_colony/ground/underground/cave
	name = "Underground Caves"
	icon_state = "cave"

/area/rocicante_colony/ground/underground/caveN
	name = "Northern Caves"
	icon_state = "cave"

/area/rocicante_colony/ground/underground/caveNW
	name = "Northwestern Caves"
	icon_state = "cave"

/area/rocicante_colony/ground/underground/caveE
	name = "Eastern Caves"
	icon_state = "cave"

/area/rocicante_colony/ground/underground/caveS
	name = "Southern Caves"
	icon_state = "cave"

/area/rocicante_colony/ground/underground/caveW
	name = "Western Caves"
	icon_state = "cave"

//colonyBuildings
/area/rocicante_colony/surface/building/canteen
	name = "Canteen"
	icon_state = "yellow"

/area/rocicante_colony/surface/building/barracks
	name = "Barracks"
	icon_state = "crew_quarters"

/area/rocicante_colony/surface/building/residential
	name = "Residential Apartment North"
	icon_state = "crew_quarters"

/area/rocicante_colony/surface/building/residential/res2
	name = "Residential Apartment South"
	icon_state = "crew_quarters"

/area/rocicante_colony/surface/building/showers
	name = "Showers"
	icon_state = "restrooms"

/area/rocicante_colony/surface/building/command
	name = "Command"
	icon_state = "bluenew"

/area/rocicante_colony/surface/building/engineering
	name = "Engineering"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/rocicante_colony/surface/building/medbay
	name = "Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/rocicante_colony/surface/building/bunker
	name = "Bunkers"
	icon_state = "dark128"

/area/rocicante_colony/surface/building/research
	name = "Research"
	icon_state = "purple"

/area/rocicante_colony/surface/building/armory
	name = "Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC
