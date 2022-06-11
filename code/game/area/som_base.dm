//rocinanteCOLONY AREAS//
/area/rocinante_colony
	name = "rocinante Polar Colony"
	icon_state = "dark"

/area/rocinante_colony/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE

/area/rocinante_colony/surface
	name = "Surface"
	icon_state = "red"

/area/rocinante_colony/surface/building
	name = "Rocinante Interior"
	icon_state = "clear"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY
	ambience = list('sound/ambience/ambiencetemp.ogg', 'sound/ambience/ambiencepizzaday.ogg', 'sound/ambience/ambiencemeeting.ogg', 'sound/ambience/ambienceagent.ogg', 'sound/ambience/ambienceengi.ogg', 'sound/ambience/ambiencesec.ogg')


/area/rocinante_colony/ground/underground
	name = "rocinante Colony Underground"
	icon_state = "cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

//landingZone
/area/rocinante_colony/surface/landing
	ambience = list('sound/ambience/ambiencetemp.ogg', 'sound/ambience/ambiencecontraband.ogg')

/area/rocinante_colony/surface/landing/landing_pad_one
	name = "Landing Pad 1"
	icon_state = "landing_pad"
	minimap_color = MINIMAP_AREA_LZ

/area/rocinante_colony/surface/landing/landing_pad_one_external
	name = "Landing Zone 1"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_COLONY

/area/rocinante_colony/surface/landing/landing_pad_two
	name = "Landing Pad 2"
	icon_state = "landing_pad"
	minimap_color = MINIMAP_AREA_LZ

/area/rocinante_colony/surface/landing/landing_pad_two_external
	name = "Landing Zone 2"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_COLONY

//river
/area/rocinante_colony/ground/river
	name = "Southwestern Riverbed"
	icon_state = "bluenew"

/area/rocinante_colony/ground/river/river_north
	name = "Northwestern Riverbed"
	icon_state = "bluenew"

//colonyGround
/area/rocinante_colony/ground/colonyse
	name ="Southeast colony"
	icon_state = "southeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocinante_colony/ground/colonys
	name ="Southern colony"
	icon_state = "south"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocinante_colony/ground/colonysw
	name ="Southwest colony"
	icon_state = "southwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocinante_colony/ground/colonyw
	name ="Western colony"
	icon_state = "west"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocinante_colony/ground/colonye
	name ="Eastern colony"
	icon_state = "east"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocinante_colony/ground/colonynw
	name ="Northwest colony"
	icon_state = "northwest"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocinante_colony/ground/colonyn
	name ="Northern colony"
	icon_state = "north"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocinante_colony/ground/colonyne
	name ="Northeast colony"
	icon_state = "northeast"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

/area/rocinante_colony/ground/colonycent
	name ="Central colony"
	icon_state = "central"
	ambience = list('sound/ambience/jungle_amb1.ogg')
	minimap_color = MINIMAP_AREA_JUNGLE

//colonyCaves
/area/rocinante_colony/ground/underground/cave
	name = "Underground Caves"
	icon_state = "cave"

/area/rocinante_colony/ground/underground/caveN
	name = "Northern Caves"
	icon_state = "cave"

/area/rocinante_colony/ground/underground/caveNW
	name = "Northwestern Caves"
	icon_state = "cave"

/area/rocinante_colony/ground/underground/caveE
	name = "Eastern Caves"
	icon_state = "cave"

/area/rocinante_colony/ground/underground/caveS
	name = "Southern Caves"
	icon_state = "cave"

/area/rocinante_colony/ground/underground/caveW
	name = "Western Caves"
	icon_state = "cave"

//colonyBuildings
/area/rocinante_colony/surface/building/canteen
	name = "Canteen"
	icon_state = "yellow"

/area/rocinante_colony/surface/building/barracks
	name = "Barracks"
	icon_state = "crew_quarters"

/area/rocinante_colony/surface/building/residential
	name = "Residential Apartment North"
	icon_state = "crew_quarters"

/area/rocinante_colony/surface/building/residential/res2
	name = "Residential Apartment South"
	icon_state = "crew_quarters"

/area/rocinante_colony/surface/building/administrationsom
	name = "Administration"
	icon_state = "red"

/area/rocinante_colony/surface/building/administrationoffices
	name = "Administration Offices"
	icon_state = "blue-red"

/area/rocinante_colony/surface/building/space_hangar
	name = "Spaceship Hangar"
	icon_state = "dark"

/area/rocinante_colony/surface/building/cas_hangar
	name = "CAS Hangar"
	icon_state = "dark160"

/area/rocinante_colony/surface/building/dropship_hangar
	name = "Dropship Hangar"
	icon_state = "dark160"

/area/rocinante_colony/surface/building/vehicle_garage
	name = "Vehicle Garage"
	icon_state = "dark128"

/area/rocinante_colony/surface/building/tadpole_hangar
	name = "Tadpole Hangar"
	icon_state = "dark128"

/area/rocinante_colony/surface/building/storage_depot
	name = "Storage Depot"
	icon_state = "dark128"

/area/rocinante_colony/surface/building/naval_dorm
	name = "Naval Crew Dorms"
	icon_state = "crew_quarters"

/area/rocinante_colony/surface/building/cargo_office
	name = "Cargo Office"
	icon_state = "yellow"

/area/rocinante_colony/surface/building/commercial_n
	name = "Commercial Area North"
	icon_state = "green"

/area/rocinante_colony/surface/building/monitorion_s
	name = "Security Monitoring South"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/rocinante_colony/surface/building/convenience_store
	name = "Convenience Store"
	icon_state = "green"

/area/rocinante_colony/surface/building/showers
	name = "Showers"
	icon_state = "restrooms"

/area/rocinante_colony/surface/building/command
	name = "Command"
	icon_state = "bluenew"

/area/rocinante_colony/surface/building/engineering
	name = "Engineering"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/rocinante_colony/surface/building/medbay
	name = "Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/rocinante_colony/surface/building/bunker
	name = "Bunkers"
	icon_state = "dark128"

/area/rocinante_colony/surface/building/research
	name = "Research"
	icon_state = "purple"

/area/rocinante_colony/surface/building/armory
	name = "Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/rocinante_colony/surface/building/glass_ash
	name = "Glass Ashtray Factory"
	icon_state = "dk_yellow"

/area/rocinante_colony/surface/building/ammo_factory
	name = "Ammo Factory"
	icon_state = "dk_yellow"

/area/rocinante_colony/surface/building/refinery
	name = "Mining Refinery"
	icon_state = "dk_yellow"

/area/rocinante_colony/surface/building/secpostn
	name = "Security Post North"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/rocinante_colony/surface/building/secposts
	name = "Security Post South"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/rocinante_colony/surface/building/commanddorms
	name = "Command Dorms"
	icon_state = "crew_quarters"

/area/rocinante_colony/surface/building/industryrest
	name = "Industry Rest Area"
	icon_state = "dk_yellow"

/area/rocinante_colony/surface/building/canterbury
	name = "Canterbury"
	icon_state = "dark128"

/area/rocinante_colony/surface/building/bunker
	name = "Bunker"
	icon_state = "dark128"
	always_unpowered = TRUE

/area/rocinante_colony/surface/building/medbay
	name = "Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/rocinante_colony/surface/building/office
	name = "Office South"
	icon_state = "dark128"
