// Metnal Mining Base areas

//Caves
/area/metnal/caves
	name = "Caves"
	icon_state = "cave"
	ambience = list('sound/ambience/ambimine.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambisin4.ogg')
	ceiling = CEILING_DEEP_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/metnal/caves/rock
	name = "Enclosed Area"
	icon_state = "transparent"

/area/metnal/caves/northwest
	name = "Northwestern Caves"
	icon_state = "northwest2"

/area/metnal/caves/northwest/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/north
	name = "Northern Caves"
	icon_state = "north2"
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/north/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/nukestorage
	name = "Nuclear Storage"
	icon_state = "nuke_storage"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
	always_unpowered = FALSE

/area/metnal/caves/research
	name = "Biohazard Research Facility"
	icon_state = "research"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	always_unpowered = FALSE

/area/metnal/caves/northeast
	name = "Northeastern Caves"
	icon_state = "northeast2"

/area/metnal/caves/northeast/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/southwest
	name = "Southwestern Caves"
	icon_state = "southwest2"

/area/metnal/caves/southwest/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/south
	name = "Southern Tunnel"
	icon_state = "south2"
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/east
	name = "Eastern Tunnel"
	icon_state = "east2"

//Outside Area
/area/metnal/outside
	name = "Colony Grounds"
	icon_state = "cliff_blocked"
	ceiling = CEILING_NONE
	outside = TRUE
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE
	temperature = T22C

/area/metnal/outside/caldera
	name = "The Caldera"
	icon_state = "red"
	temperature = T40C

/area/metnal/outside/southeast
	name = "Southeastern Colony"
	icon_state = "southeast"

/area/metnal/outside/south
	name = "Southern Colony"
	icon_state = "south"

/area/metnal/outside/southwest
	name = "Southwestern Colony"
	icon_state = "southeast"

/area/metnal/outside/east
	name = "Eastern Grounds"
	icon_state = "east"

/area/metnal/outside/northeast
	name = "Northeastern Grounds"
	icon_state = "northeast"

/area/metnal/outside/north
	name = "Northern Grounds"
	icon_state = "north"

//Inside area parent, not used.
/area/metnal/inside
	name = "Inside"
	icon_state = "red"
	ceiling = CEILING_METAL
	outside = FALSE

/area/metnal/inside/engineering
	name = "Engineering"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI

/area/metnal/inside/colonydorms
	name = "Colony Dorms"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/bar
	name = "Maars Bar"
	icon_state = "bar"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/cargo
	name = "Colony Cargo"
	icon_state = "primarystorage"
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/colonyauxstorage
	name = "Colony Auxillary Storage"
	icon_state = "storage"
	always_unpowered = TRUE
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/bunker
	name = "Landing Zone Monitoring"
	icon_state = "shuttlered"
	minimap_color = MINIMAP_AREA_SEC

/area/metnal/inside/bunker/west
	name = "Western Bunker"

/area/metnal/inside/bunker/center
	name = "Central Bunker"

/area/metnal/inside/bunker/east
	name = "Eastern Bunker"

/area/metnal/inside/prisonshower
	name = "Prison Showers"
	icon_state = "decontamination"
	minimap_color = MINIMAP_AREA_CELL_MED

/area/metnal/inside/habitationnorth
	name = "Prison Habitation"
	icon_state = "cells_med_n"
	minimap_color = MINIMAP_AREA_CELL_MED


/area/metnal/inside/studyroom
	name = "Study Room"
	icon_state = "library"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/mining
	name = "Mineral Processing"
	icon_state = "mining"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_CELL_MED

/area/metnal/inside/westernbooth
	name = "Western Security Booth"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/metnal/inside/westcomputerlab
	name = "Western Computer Lab"
	icon_state = "server"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/substation
	name = "Geothermal Substation"
	icon_state = "substation"
	minimap_color = MINIMAP_AREA_ENGI

/area/metnal/inside/prisongarden
	name = "Garden"
	icon_state = "garden"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/centralhalls
	name = "Central Halls"
	icon_state = "hallC1"

/area/metnal/inside/laundromat
	name = "Laundromat"
	icon_state = "LP"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/laundromat/collapsedroof
	outside = TRUE
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/metnal/inside/mechanicshop
	name = "Mechanical Shop"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI

/area/metnal/inside/staffrestroom
	name = "Staff Restroom"
	icon_state = "toilet"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/auxstorage
	name = "Auxillary Storage"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/staffbreakroom
	name = "Staff Breakroom"
	icon_state = "Holodeck"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/northclass
	name = "Northern Classroom"
	icon_state = "law"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/metnal/inside/centralbooth
	name = "Central Security Room"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/metnal/inside/recreation
	name = "Prison Recreation"
	icon_state = "showroom"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/janitorial
	name = "Janitorial Room"
	icon_state = "janitor"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/metnal/inside/freezer
	name = "Kitchen Freezer"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/sportstorage
	name = "Sports Storage"
	icon_state = "auxstorage"
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/northmeetingroom
	name = "Meeting Room"
	icon_state = "conference"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/library
	name = "Library"
	icon_state = "library"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/execution
	name = "Maximum Security Rooms"
	icon_state = "sec_backroom"
	minimap_color = MINIMAP_AREA_SEC

/area/metnal/inside/basketball
	name = "Basketball Court"
	icon_state = "anog"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/lobby
	name = "Security Lobby"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_SEC

/area/metnal/inside/corporateoffice
	name = "Liason Office"
	icon_state = "blueold"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/southmeetingroom
	name = "Corporate Meeting Room"
	icon_state = "party"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/garage
	name = "Garage"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/gym
	name = "Gym"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/chapel
	name = "Chapel"
	icon_state = "chapel"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/security
	name = "Security"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/metnal/inside/security/secbreakroom
	name = "Security Break Room"

/area/metnal/inside/security/cameras
	name = "Camera Center"

/area/metnal/inside/security/warden
	name = "Warden Office"

/area/metnal/inside/security/office
	name = "Security Office"

/area/metnal/inside/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"

/area/metnal/inside/meddesk
	name = "Medbay Clerk's Desk"
	ceiling = CEILING_OBSTRUCTED

/area/metnal/inside/medical
	name = "Infirmary"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY
	ceiling = CEILING_OBSTRUCTED

/area/metnal/inside/eastward
	name = "East Ward"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY
	ceiling = CEILING_OBSTRUCTED

/area/metnal/inside/medical/chemistry
	name = "Chemistry"

/area/metnal/inside/medical/treatment
	name = "Infirmary Treatment"

/area/metnal/inside/garden
	name = "Hydroponics Garden"
	icon_state = "garden"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/hydroponics
	name = "Hydroponics"
	icon_state = "hydro"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/hydroponicstesting
	name = "Hydroponics Testing"
	icon_state = "hydro_north"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/seccheckpoint
	name = "Security Checkpoint"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/metnal/inside/secoffices
	name = "Security Checkpoint Offices"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/metnal/inside/pmcdropship
	name = "Crashed PMC Dropship"
	icon_state = "shuttle"
	minimap_color = MINIMAP_AREA_COLONY
	always_unpowered = TRUE

/area/metnal/inside/landingzoneone
	name = "Landing Zone One"
	icon_state = "landingzone1"
	flags_area = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/metnal/inside/telecomms
	name = "Telecomms"
	icon_state = "tcomsatcham"
	flags_area = NO_DROPPOD
	requires_power = FALSE
