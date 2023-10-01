//rocinanteBase AREAS//
/area/rocinante_Base
	name = "rocinante Polar Base"
	icon_state = "dark"

/area/rocinante_Base/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE
	minimap_color = MINIMAP_AREA_COLONY
	ambience = list('sound/ambience/snow_ambience.ogg')

/area/rocinante_Base/surface
	name = "Surface"
	icon_state = "red"

/area/rocinante_Base/surface/building
	name = "Rocinante Interior"
	icon_state = "clear"
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY
	ambience = list('sound/ambience/ambiencetemp.ogg', 'sound/ambience/ambiencepizzaday.ogg', 'sound/ambience/ambiencemeeting.ogg', 'sound/ambience/ambiencereport.ogg', 'sound/ambience/ambienceengi.ogg', 'sound/ambience/ambiencesec.ogg')

/area/rocinante_Base/surface/building/building_underground
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/rocinante_Base/ground/underground
	name = "rocinante Base Underground"
	icon_state = "cave"
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

//landingZone
/area/rocinante_Base/surface/landing
	ambience = list('sound/ambience/ambiencetemp.ogg', 'sound/ambience/ambiencepizzaday.ogg', 'sound/ambience/ambiencemeeting.ogg', 'sound/ambience/ambiencereport.ogg', 'sound/ambience/ambienceengi.ogg', 'sound/ambience/ambiencesec.ogg')

/area/rocinante_Base/surface/landing/landing_pad_one
	name = "Landing Pad 1"
	icon_state = "landing_pad"
	minimap_color = MINIMAP_AREA_LZ

/area/rocinante_Base/surface/landing/landing_pad_one_external
	name = "Landing Zone 1"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_LZ

/area/rocinante_Base/surface/landing/landing_pad_two
	name = "Landing Pad 2"
	icon_state = "landing_pad"
	minimap_color = MINIMAP_AREA_LZ

/area/rocinante_Base/surface/landing/landing_pad_two_external
	name = "Landing Zone 2"
	icon_state = "landing_pad_ext"
	minimap_color = MINIMAP_AREA_LZ

//BaseGround
/area/rocinante_Base/ground/base_se
	name ="Southeast Base"
	icon_state = "southeast"

/area/rocinante_Base/ground/base_s
	name ="Southern Base"
	icon_state = "south"

/area/rocinante_Base/ground/base_sw
	name ="Southwest Base"
	icon_state = "southwest"

/area/rocinante_Base/ground/base_w
	name ="Western Base"
	icon_state = "west"

/area/rocinante_Base/ground/base_e
	name ="Eastern Base"
	icon_state = "east"

/area/rocinante_Base/ground/base_nw
	name ="Northwest Base"
	icon_state = "northwest"

/area/rocinante_Base/ground/base_n
	name ="Northern Base"
	icon_state = "north"

/area/rocinante_Base/ground/base_ne
	name ="Northeast Base"
	icon_state = "northeast"

/area/rocinante_Base/ground/base_cent
	name ="Central Base"
	icon_state = "central"

//BaseCaves
/area/rocinante_Base/ground/underground/cave
	name = "Underground Caves"
	icon_state = "cave"

/area/rocinante_Base/ground/underground/caveN
	name = "Northern Caves"
	icon_state = "cave"

/area/rocinante_Base/ground/underground/caveCent
	name = "Central Caves"
	icon_state = "cave"

/area/rocinante_Base/ground/underground/caveE
	name = "Eastern Caves"
	icon_state = "cave"

/area/rocinante_Base/ground/underground/caveS
	name = "Southern Caves"
	icon_state = "cave"

/area/rocinante_Base/ground/underground/caveW
	name = "Western Caves"
	icon_state = "cave"

//BaseBuildings
/area/rocinante_Base/surface/building/administration
	name = "Administration"
	icon_state = "cave"

/area/rocinante_Base/surface/building/adminbreakroom
	name = "Administration Break Room"
	icon_state = "cave"

/area/rocinante_Base/surface/building/laundromat
	name = "Laundromat"
	icon_state = "cave"

/area/rocinante_Base/surface/building/tramstation_nw
	name = "Northwestern Tram Station"
	icon_state = "cave"

/area/rocinante_Base/surface/building/tramstation_cent
	name = "Central Tram Station"
	icon_state = "cave"

/area/rocinante_Base/surface/building/tramstation_e
	name = "Eastern Tram Station"
	icon_state = "cave"

/area/rocinante_Base/surface/building/office_n
	name = "Northern Office Building"
	icon_state = "cave"

/area/rocinante_Base/surface/building/chapel_ne
	name = "Northeastern Chapel"
	icon_state = "cave"

/area/rocinante_Base/surface/building/complex_hall
	name = "Western Research Complex Hallway"
	icon_state = "cave"

/area/rocinante_Base/surface/building/complex_hall_e
	name = "Eastern Research Complex Hallway"
	icon_state = "cave"

/area/rocinante_Base/surface/building/complex_sec
	name = "Research Complex Security Post"
	icon_state = "cave"

/area/rocinante_Base/surface/building/research_lab
	name = "Central Research Labs"
	icon_state = "cave"

/area/rocinante_Base/surface/building/crystal_lab
	name = "Crystal Research Labs"
	icon_state = "cave"

/area/rocinante_Base/surface/building/tele_lab
	name = "Teleportation Research Labs"
	icon_state = "cave"

/area/rocinante_Base/surface/building/bio_lab
	name = "Biological Research Labs"
	icon_state = "cave"

/area/rocinante_Base/surface/building/command
	name = "Command"
	icon_state = "cave"

/area/rocinante_Base/surface/building/vehicle_garage
	name = "Vehicle Garage"
	icon_state = "cave"

/area/rocinante_Base/surface/building/garage_sec
	name = "Vehicle Garage Security Post"
	icon_state = "cave"
