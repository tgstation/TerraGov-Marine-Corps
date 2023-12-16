//Patricks Rest  AREAS//
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
	name = "Patricks Rest Colony Buildings"
	icon_state = "clear"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/patricks_rest/ground/underground
	name = "Patricks Rest Colony Underground"
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

//ColonyGround
/area/patricks_rest/ground/colonyse
	name ="Southeast Colony"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/colonys
	name ="Southern Colony"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/colonysw
	name ="Southwest Colony"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/colonyw
	name ="Western Colony"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/colonye
	name ="Eastern Colony"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/colonynw
	name ="Northwest Colony"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/colonyn
	name ="Northern Colony"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/colonyne
	name ="Northeast Colony"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/patricks_rest/ground/colonycent
	name ="Central Colony"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

//ColonyCaves
/area/patricks_rest/ground/underground/cave
	name = "Solomon Cavern"
	icon_state = "cave"

//ColonyBuildings
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

/area/patricks_rest/surface/building/hydro
	name = "Hydroelectric Power"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/patricks_rest/surface/building/offices
	name = "Offices"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_LIVING

/area/patricks_rest/surface/building/cargo_office
	name = "Cargo Offices"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_REQ

/area/patricks_rest/surface/building/medbay
	name = "Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/patricks_rest/surface/building/armory
	name = "Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/patricks_rest/surface/building/administration
	name = "Administration"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_COMMAND

/area/patricks_rest/surface/building/atc
	name = "Traffic Control"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_COMMAND

/area/patricks_rest/surface/building/residential_e
	name = "Residential East"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/patricks_rest/surface/building/residential_cent
	name = "Residential Central"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/patricks_rest/surface/building/residential_w
	name = "Residential West"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/patricks_rest/surface/building/residential_engi
	name = "Residential Engineering"
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/patricks_rest/surface/building/transformer_residential
	name = "Hydroelectric Power"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/patricks_rest/surface/building/transformer_barracks
	name = "Hydroelectric Power"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/patricks_rest/surface/building/transformer_offices
	name = "Hydroelectric Power"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/patricks_rest/surface/building/security_post_cargo
	name = "Cargo Security Post"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/patricks_rest/surface/building/security_post_residential
	name = "Residential Security Post"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/patricks_rest/surface/building/security_post_research
	name = "Research Security Post"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/patricks_rest/surface/building/storage_depot_south
	name = "South Storage Depot"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_REQ

/area/patricks_rest/surface/building/storage_depot_research
	name = "Research Storage Depot"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_REQ

/area/patricks_rest/surface/building/ore
	name = "Ore Processing"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_REQ

/area/patricks_rest/surface/building/ore_storage
	name = "Ore Storage"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_REQ

/area/patricks_rest/surface/building/baggage
	name = "Baggage Claim"
	icon_state = "dark160"
	minimap_color = MINIMAP_AREA_REQ

/area/patricks_rest/surface/building/science
	name = "Science Department"
	icon_state = "purple"
	minimap_color = MINIMAP_AREA_RESEARCH
