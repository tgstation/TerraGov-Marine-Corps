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

/area/rocinante_Base/ground/underground/caveNW
	name = "Northwestern Caves"
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
	name = "Admin"
	icon_state = "cave"
