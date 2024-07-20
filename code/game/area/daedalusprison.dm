// Daedalus Prison Areas

//Caves
/area/daedalusprison/caves
	name = "Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/daedalusprison/caves/rock
	name = "Enclosed Area"
	icon_state = "transparent"
	area_flags = CANNOT_NUKE

/area/daedalusprison/caves/northwest
	name = "Northwestern Caves"
	icon_state = "northwest2"

/area/daedalusprison/caves/northwest/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/daedalusprison/caves/north
	name = "Northern Caves"
	icon_state = "north2"

/area/daedalusprison/caves/north/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/daedalusprison/caves/nukestorage
	name = "Nuclear Storage"
	icon_state = "nuke_storage"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	always_unpowered = FALSE

/area/daedalusprison/caves/research
	name = "Biologcal Research Facility"
	icon_state = "research"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	always_unpowered = FALSE

/area/daedalusprison/caves/northeast
	name = "Northeastern Caves"
	icon_state = "northeast2"

/area/daedalusprison/caves/northeast/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/daedalusprison/caves/southwest
	name = "Southwestern Caves"
	icon_state = "southwest2"

/area/daedalusprison/caves/southwest/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/daedalusprison/caves/south
	name = "Southern Tunnel"
	icon_state = "south2"
	ceiling = CEILING_UNDERGROUND

/area/daedalusprison/caves/east
	name = "Eastern Tunnel"
	icon_state = "east2"

//Outside Area
/area/daedalusprison/outside
	name = "Colony Grounds"
	icon_state = "cliff_blocked"
	ceiling = CEILING_NONE
	outside = TRUE
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE
	temperature = ICE_COLONY_TEMPERATURE

/area/daedalusprison/outside/southeast
	name = "Southeastern Colony"
	icon_state = "southeast"

/area/daedalusprison/outside/south
	name = "Southern Colony"
	icon_state = "south"

/area/daedalusprison/outside/southwest
	name = "Southwestern Colony"
	icon_state = "southeast"

/area/daedalusprison/outside/east
	name = "Eastern Grounds"
	icon_state = "east"

/area/daedalusprison/outside/northeast
	name = "Northeastern Grounds"
	icon_state = "northeast"

/area/daedalusprison/outside/north
	name = "Northern Grounds"
	icon_state = "north"

//Inside area parent, not used.
/area/daedalusprison/inside
	name = "Inside"
	icon_state = "red"
	ceiling = CEILING_GLASS
	outside = FALSE

/area/daedalusprison/inside/engineering
	name = "Engineering"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI
	ceiling = CEILING_METAL

/area/daedalusprison/inside/colonydorms
	name = "Colony Dorms"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING
	ceiling = CEILING_METAL

/area/daedalusprison/inside/bar
	name = "Colony Bar"
	icon_state = "bar"
	minimap_color = MINIMAP_AREA_LIVING
	ceiling = CEILING_METAL

/area/daedalusprison/inside/cargo
	name = "Colony Cargo"
	icon_state = "primarystorage"
	minimap_color = MINIMAP_AREA_REQ
	ceiling = CEILING_METAL

/area/daedalusprison/inside/colonyauxstorage
	name = "Colony Auxillary Storage"
	icon_state = "storage"
	always_unpowered = TRUE
	minimap_color = MINIMAP_AREA_REQ
	ceiling = CEILING_METAL

/area/daedalusprison/inside/bunker
	name = "Landing Zone Bunker"
	icon_state = "shuttlered"
	minimap_color = MINIMAP_AREA_SEC
	ceiling = CEILING_METAL

/area/daedalusprison/inside/bunker/west
	name = "Western Bunker"

/area/daedalusprison/inside/bunker/center
	name = "Central Bunker"

/area/daedalusprison/inside/bunker/east
	name = "Eastern Bunker"

/area/daedalusprison/inside/prisonshower
	name = "Prison Showers"
	icon_state = "decontamination"
	minimap_color = MINIMAP_AREA_CELL_MED

/area/daedalusprison/inside/habitationnorth
	name = "Prison North Habitation"
	icon_state = "cells_med_n"
	minimap_color = MINIMAP_AREA_CELL_MED

/area/daedalusprison/inside/habitationsouth
	name = "Prison South Habitation"
	icon_state = "cells_med_s"
	minimap_color = MINIMAP_AREA_CELL_MED

/area/daedalusprison/inside/studyroom
	name = "Prison Study Room"
	icon_state = "library"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/mining
	name = "Prison Mineral Processing"
	icon_state = "mining"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_CELL_MED

/area/daedalusprison/inside/westernbooth
	name = "Prison Western Security Booth"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/daedalusprison/inside/westcomputerlab
	name = "Prison Western Computer Lab"
	icon_state = "server"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/substation
	name = "Prison Substation"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/daedalusprison/inside/prisongarden
	name = "Prison Garden"
	icon_state = "garden"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/centralhalls
	name = "Prison Central Halls"
	icon_state = "hallC1"

/area/daedalusprison/inside/laundromat
	name = "Prison Laundromat"
	icon_state = "LP"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/laundromat/collapsedroof
	outside = TRUE
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/daedalusprison/inside/mechanicshop
	name = "Prison Mechanical Shop"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI

/area/daedalusprison/inside/staffrestroom
	name = "Prison Staff Restroom"
	icon_state = "toilet"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/auxstorage
	name = "Prison Auxillary Storage"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ

/area/daedalusprison/inside/staffbreakroom
	name = "Prison Staff Breakroom"
	icon_state = "Holodeck"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/northclass
	name = "Prison Northern Classroom"
	icon_state = "law"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/daedalusprison/inside/southclass
	name = "Prison Southern Classroom"
	icon_state = "law"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/daedalusprison/inside/centralbooth
	name = "Prison Central Security Booth"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/daedalusprison/inside/recreation
	name = "Prison Recreation"
	icon_state = "showroom"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/janitorial
	name = "Prison Janitorial Room"
	icon_state = "janitor"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/daedalusprison/inside/freezer
	name = "Prison Freezer"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/daedalusprison/inside/kitchen
	name = "Prison Kitchen"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/daedalusprison/inside/cafeteria
	name = "Prison Cafeteria"
	icon_state = "cafeteria"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/daedalusprison/inside/sportstorage
	name = "Prison Sports Storage"
	icon_state = "auxstorage"
	minimap_color = MINIMAP_AREA_REQ

/area/daedalusprison/inside/northmeetingroom
	name = "Prison Meeting Room"
	icon_state = "conference"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/daedalusprison/inside/library
	name = "Prison Library"
	icon_state = "library"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/execution
	name = "Prison Execution"
	icon_state = "sec_backroom"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/basketball
	name = "Prison Basketball Court"
	icon_state = "anog"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/daedalusprison/inside/lobby
	name = "Prison Lobby"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/corporateoffice
	name = "Liason Office"
	icon_state = "blueold"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/daedalusprison/inside/southmeetingroom
	name = "Corporate Meeting Room"
	icon_state = "party"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/daedalusprison/inside/garage
	name = "Prison Garage"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_REQ

/area/daedalusprison/inside/easternhalls
	name = "Prison Eastern Hallways"
	icon_state = "hallS"

/area/daedalusprison/inside/gym
	name = "Prison Gym"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/daedalusprison/inside/chapel
	name = "Prison Chapel"
	icon_state = "chapel"
	minimap_color = MINIMAP_AREA_LIVING

/area/daedalusprison/inside/security
	name = "Security"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/daedalusprison/inside/security/easternbooth
	name = "Prison Eastern Security Booth"

/area/daedalusprison/inside/security/secbreakroom
	name = "Prison Security Break Room"

/area/daedalusprison/inside/security/cameras
	name = "Prison Camera Center"

/area/daedalusprison/inside/security/warden
	name = "Prison Warden Office"

/area/daedalusprison/inside/security/office
	name = "Prison Security Office"

/area/daedalusprison/inside/security/interrogation
	name = "Prison Interrogation"
	icon_state = "interrogation"

/area/daedalusprison/inside/security/medsec
	name = "Prison Medbay Security"
	ceiling = CEILING_METAL

/area/daedalusprison/inside/medical
	name = "Prison Infirmary"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY
	ceiling = CEILING_METAL

/area/daedalusprison/inside/medical/chemistry
	name = "Prison Chemistry"

/area/daedalusprison/inside/medical/treatment
	name = "Prison Infirmary Treatment"

/area/daedalusprison/inside/barracks
	name = "Prison Security Barracks"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/daedalusprison/inside/garden
	name = "Hydroponics Garden"
	icon_state = "garden"
	minimap_color = MINIMAP_AREA_LIVING
	ceiling = CEILING_METAL

/area/daedalusprison/inside/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	minimap_color = MINIMAP_AREA_LIVING
	ceiling = CEILING_METAL

/area/daedalusprison/inside/hydroponicstesting
	name = "Hydroponics Testing"
	icon_state = "hydro_north"
	minimap_color = MINIMAP_AREA_LIVING
	ceiling = CEILING_METAL

/area/daedalusprison/inside/seccheckpoint
	name = "Security Checkpoint"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/daedalusprison/inside/secoffices
	name = "Security Checkpoint Offices"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/daedalusprison/inside/pmcdropship
	name = "Crashed PMC Dropship"
	icon_state = "shuttle"
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE

/area/daedalusprison/inside/landingzoneone
	name = "Landing Zone One"
	icon_state = "landingzone1"
	area_flags = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/daedalusprison/inside/telecomms
	name = "Telecomms"
	icon_state = "tcomsatcham"
	area_flags = NO_DROPPOD
	requires_power = FALSE
