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
	area_flags = CANNOT_NUKE

/area/metnal/caves/northwest
	name = "Northwestern Caves"
	icon_state = "northwest2"

/area/metnal/caves/northwest/garbledradio
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/north
	name = "Northern Caves"
	icon_state = "north2"

/area/metnal/caves/nukestorage
	name = "Nuclear Storage"
	icon_state = "nuke_storage"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_ENGI_CAVE
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
	name = "Southern Caves"
	icon_state = "south2"

/area/metnal/caves/south/garbledradio
	name = "Southern Caves"
	icon_state = "south2"
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/southeast
	name = "Southeastern Caves"
	icon_state = "east2"

/area/metnal/caves/southeast/garbledradio
	name = "Southeastern Caves"
	icon_state = "southeast2"

/area/metnal/caves/west
	name = "Western Caves"
	icon_state = "west2"
	ceiling = CEILING_UNDERGROUND

/area/metnal/caves/west/garbledradio
	name = "Western Caves"
	icon_state = "west2"
	ceiling = CEILING_UNDERGROUND

//Outside Area
/area/metnal/outside
	name = "Colony Grounds"
	icon_state = "cliff_blocked"
	ceiling = CEILING_NONE
	outside = TRUE
	minimap_color = MINIMAP_AREA_CELL_MAX
	always_unpowered = TRUE
	temperature = T22C

/area/metnal/outside/pathways/secondary
	name = "Landing Zone Primary Pathways"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/outside/pathways //looks less awful on tacmap
	name = "Primary Pathways"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/outside/central
	name = "Central Colony Grounds"
	icon_state = "green"

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

/area/metnal/outside/northwest
	name = "Northwestern Grounds"
	icon_state = "northwest"

/area/metnal/outside/west
	name = "Western Grounds"
	icon_state = "west"

//Inside area parent, not used.
/area/metnal/inside
	name = "Inside"
	icon_state = "red"
	ceiling = CEILING_METAL
	outside = FALSE

// dorm areas
/area/metnal/inside/colonydorms
	name = "Colony Dorms"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/laundromat
	name = "Laundromat"
	icon_state = "LP"
	minimap_color = MINIMAP_AREA_LIVING


// research areas
/area/metnal/inside/research
	name = "Research Labs"
	icon_state = "research"
	minimap_color = MINIMAP_AREA_RESEARCH
	ceiling = CEILING_UNDERGROUND_METAL

/area/metnal/inside/experimentation
	name = "Experimentation Area"
	icon_state = "research"
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE
	ceiling = CEILING_DEEP_UNDERGROUND

// engineering areas
/area/metnal/inside/engineering
	name = "Engineering"
	icon_state = "engine"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_ENGI

/area/metnal/inside/substation
	name = "Geothermal Substation"
	icon_state = "substation"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_ENGI

/area/metnal/inside/garage
	name = "Garage"
	icon_state = "garage"
	minimap_color = MINIMAP_AREA_REQ

// cargo areas
/area/metnal/inside/cargo
	name = "Colony Cargo"
	icon_state = "primarystorage"
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/mining
	name = "Mineral Processing"
	icon_state = "mining"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_CELL_MED

/area/metnal/inside/auxstorage
	name = "Auxillary Storage"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/mineralextraction
	name = "Mineral Extraction Zone"
	icon_state = "mining"
	ceiling = CEILING_UNDERGROUND
	minimap_color = MINIMAP_AREA_REQ_CAVE

/area/metnal/inside/emergencystorage
	name = "Secondary Emergency Storage"
	icon_state = "storage"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/emergencyequip
	name = "Emergency Equipement Storage"
	icon_state = "storage"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/centralminingequip
	name = "Central Mining Equipement Storage"
	icon_state = "storage"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_REQ

// cafeteria areas
/area/metnal/inside/bar
	name = "Maars Bar"
	icon_state = "bar"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"
	minimap_color = MINIMAP_AREA_ESCAPE

// Headquarters areas
/area/metnal/inside/Headquarters
	name = "Headquarters"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND_CAVE

/area/metnal/inside/quartermaster
	name = "Quartermaster Staging Area"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ

/area/metnal/inside/bridge
	name = "Bridge"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/metnal/inside/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/restroom
	name = "Main Restroom"
	icon_state = "cafeteria"
	minimap_color = MINIMAP_AREA_JUNGLE

/area/metnal/inside/executivedorms
	name = "Command Dormitories"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_COMMAND

/area/metnal/inside/primarystorage
	name = "Primary Colony Storage"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ_CAVE

// other civilian areas

/area/metnal/inside/chapel
	name = "Chapel"
	icon_state = "chapel"
	minimap_color = MINIMAP_AREA_LIVING

/area/metnal/inside/recreation
	name = "The Intersection"
	icon_state = "showroom"
	minimap_color = MINIMAP_AREA_LIVING
	ceiling = CEILING_DEEP_UNDERGROUND

/area/metnal/inside/bathhouse
	name = "The Bathhouse"
	icon_state = "bathhouse"
	minimap_color = MINIMAP_AREA_LIVING
	ceiling = CEILING_METAL

// command areas
/area/metnal/inside/northmeetingroom
	name = "War Room"
	icon_state = "conference"
	minimap_color = MINIMAP_AREA_ESCAPE

/area/metnal/inside/administration
	name = "Administration"
	icon_state = "admin"
	minimap_color = MINIMAP_AREA_COMMAND

// security areas
/area/metnal/inside/security
	name = "Security"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

// medbay areas
/area/metnal/inside/meddesk
	name = "Medbay Clerk's Desk"
	ceiling = CEILING_OBSTRUCTED
	minimap_color = MINIMAP_AREA_MEDBAY

/area/metnal/inside/medical
	name = "Infirmary"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY
	ceiling = CEILING_OBSTRUCTED
/area/metnal/inside/medical/storage
	name = "Medbay Offices and Storage"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/metnal/inside/medical/chemistry
	name = "Chemistry"
	ceiling = CEILING_OBSTRUCTED

// hydroponics areas
/area/metnal/inside/garden
	name = "Hydroponics Garden"
	icon_state = "garden"
	minimap_color = MINIMAP_AREA_LIVING

// other areas
/area/metnal/inside/landingzoneone
	name = "Landing Zone One"
	icon_state = "landingzone1"
	area_flags = NO_DROPPOD
	minimap_color = MINIMAP_AREA_LZ

/area/metnal/inside/telecomms
	name = "Telecomms"
	icon_state = "tcomsatcham"
	area_flags = NO_DROPPOD
	requires_power = FALSE
