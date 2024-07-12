
//areas for new prison (I want to leave the legacy ones intact yo)

/area/fiorina
	name = "Fiorina Orbital Penitentiary - Science Annex"
	icon = 'icons/turf/area_prison_v3_fiorina.dmi'
	//ambience = list('figuresomethingout.ogg')
	icon_state = "fiorina"
	can_build_special = TRUE //T-Comms structure
	temperature = T20C
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_COLONY

/area/fiorina/oob
	name = "Fiorina - Out Of Bounds"
	icon_state = "oob"
	ceiling = CEILING_MAX
	is_resin_allowed = FALSE
	flags_area = AREA_NOTUNNEL

/area/fiorina/maintenance
	name = "Fiorina - Maintenance"
	ceiling = CEILING_METAL
	icon_state = "maints"

//tumor / hive areas aka the place that is CAS immune
/area/fiorina/tumor
	name = "Fiorina - Resin Tumor"
	icon_state = "tumor0"
	temperature = 309.15 //its uh, gettin' kinda warm in here SL...
	ceiling = CEILING_UNDERGROUND_METAL_BLOCK_CAS
/area/fiorina/tumor/deep
	icon_state = "tumor0-deep"

/area/fiorina/tumor/fiberbush
	name = "Fiorina - Fiberbush Infestation"
	icon_state = "tumor-fiberbush"

/area/fiorina/tumor/ship
	name = "Fiorina - Scavenger Ship 'NSV Renault'"
	icon_state = "tumor1"
	requires_power = 0
	minimap_color = MINIMAP_AREA_SHIP

/area/fiorina/tumor/civres
	name = "Fiorina - Green Block Residences"
	icon_state = "tumor0"

/area/fiorina/tumor/aux_engi
	name = "Fiorina - Engineering Sector"
	icon_state = "tumor2"
	minimap_color = MINIMAP_AREA_ENGI

/area/fiorina/tumor/servers
	name = "Fiorina - Research Servers"
	icon_state = "tumor2"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/fiorina/tumor/ice_lab
	name = "Fiorina - Cryogenic Research Labs"
	icon_state = "tumor3"
	minimap_color = MINIMAP_AREA_RESEARCH



//LZ CODE
/area/fiorina/lz
	icon_state = "lz"
	ceiling = CEILING_GLASS
	name = "Fiorina - LZ"
	is_landing_zone = TRUE
	minimap_color = MINIMAP_AREA_LZ
	is_resin_allowed = FALSE

/area/fiorina/lz/near_lzI
	name = "Fiorina - LZ1 Aux Port"

/area/fiorina/lz/near_lzII
	name = "Fiorina - LZ2 Prison Port"

/area/fiorina/lz/console_I
	name = "Fiorina - LZ1 Control Console"
	icon_state = "lz1"
	requires_power = 0

/area/fiorina/lz/console_II
	name = "Fiorina - LZ2 Control Console"
	icon_state = "lz2"
	requires_power = 0

/area/shuttle/drop1/prison_v3
	name = "Fiorina - Dropship Alamo Landing Zone"
	icon_state = "shuttle"
	is_resin_allowed = FALSE

/area/shuttle/drop2/prison_v3
	name = "Fiorina - Normandy Landing Zone"
	icon_state = "shuttle2"
	is_resin_allowed = FALSE

//STATION AREAS AAAA
/area/fiorina/station
	name = "Fiorina - Station Interior"
	icon_state = "station0"
	ceiling = CEILING_GLASS

/area/fiorina/station/lowsec
	name = "Fiorina - Low Security Cells"
	icon_state = "station1"

/area/fiorina/station/power_ring
	name = "Fiorina - Engineering Ring"
	icon_state = "power0"
	minimap_color = MINIMAP_AREA_ENGI

/area/fiorina/station/disco
	name = "Fiorina - Disco Storage"
	icon_state = "disco"

/area/fiorina/station/flight_deck
	name = "Fiorina - Flight Deck"
	icon_state = "police_line"

/area/fiorina/station/security
	name = "Fiorina - Security Hub"
	icon_state = "security_hub"
	minimap_color = MINIMAP_AREA_SEC

/area/fiorina/station/security/wardens
	name = "Fiorina - Warden's Office"
	icon_state = "wardens"
	minimap_color = MINIMAP_AREA_SEC

/area/fiorina/station/botany
	name = "Fiorina - Botany Growtrays"
	icon_state = "botany"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/fiorina/station/park
	name = "Fiorina - Park"
	icon_state = "station0"

/area/fiorina/station/transit_hub
	name = "Fiorina - Transit Hub"
	icon_state = "station1"

/area/fiorina/station/central_ring
	name = "Fiorina - Central Ring"
	icon_state = "station2"

/area/fiorina/station/chapel
	name = "Fiorina - Chapel"
	icon_state = "station3"

/area/fiorina/station/civres_blue
	name = "Fiorina - Blue Block Residences"
	icon_state = "station1"

/area/fiorina/station/medbay
	name = "Fiorina - Medical Bay"
	icon_state = "station4"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/fiorina/station/research_cells
	name = "Fiorina - Research Cellblock"
	icon_state = "station0"
	minimap_color = MINIMAP_AREA_RESEARCH


//telecomms areas
/area/fiorina/station/telecomm
	name = "Fiorina - Communications Relay"
	icon_state = "ass_line"
	is_resin_allowed = FALSE
	ceiling_muffle = FALSE
	base_muffle = MUFFLE_LOW

/area/fiorina/station/telecomm/lz1_cargo
	name = "Fiorina - LZ1 Cargo Communications Relay"

/area/fiorina/station/telecomm/lz1_containers
	name = "Fiorina - LZ1 Containers Communications Relay"

/area/fiorina/station/telecomm/lz1_tram
	name = "Fiorina - LZ1 Aux Port Communications Relay"
	is_landing_zone = TRUE

/area/fiorina/station/telecomm/lz1_engineering
	name = "Fiorina - Engineering Primary Communications Relay"

/area/fiorina/station/telecomm/lz2_engineering
	name = "Fiorina - Engineering Secondary Communications Relay"

/area/fiorina/station/telecomm/lz2_north
	name = "Fiorina - LZ2 North Communications Relay"

/area/fiorina/station/telecomm/lz2_maint
	name = "Fiorina - Backup Communications Relay"
