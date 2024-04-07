
/area/campaign/tgmc_raiding
	icon_state = "cliff_blocked"
	area_flags = ALWAYS_RADIO

//Colony
/area/campaign/tgmc_raiding/colony
	icon_state = "red"

/area/campaign/tgmc_raiding/colony/outdoor
	name = "Central Colony Grounds"
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/campaign/tgmc_raiding/colony/outdoor/northeast
	name = "Northeast Colony Grounds"
	icon_state = "northeast"

/area/campaign/tgmc_raiding/colony/outdoor/east
	name = "Eastern Colony Grounds"
	icon_state = "east"

/area/campaign/tgmc_raiding/colony/outdoor/southeast
	name = "Southeast Colony Grounds"
	icon_state = "southeast"

/area/campaign/tgmc_raiding/colony/outdoor/south
	name = "Southern Colony Grounds"
	icon_state = "south"

/area/campaign/tgmc_raiding/colony/outdoor/southwest
	name = "Southwest Colony Grounds"
	icon_state = "southwest"

//Colony Buildings

/area/campaign/tgmc_raiding/colony/indoor
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/campaign/tgmc_raiding/colony/indoor/southwest_shed
	name = "Southwest Maintenance Shed"
	icon_state = "panelsA"

/area/campaign/tgmc_raiding/colony/indoor/housing
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/campaign/tgmc_raiding/colony/indoor/housing/southwest
	name = "Southwest Colony Housing"

/area/campaign/tgmc_raiding/colony/indoor/housing/southeast
	name = "Southeast Colony Housing"

/area/campaign/tgmc_raiding/colony/indoor/housing/east
	name = "East Colony Housing"

/area/campaign/tgmc_raiding/colony/indoor/freezer
	name = "Colony Meat Locker"
	icon_state = "kitchen"

/area/campaign/tgmc_raiding/colony/indoor/engineering
	name = "Colony Engineering"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI

/area/campaign/tgmc_raiding/colony/indoor/engineering/storage
	name = "Colony Engineering Storage"
	icon_state = "engine_storage"

/area/campaign/tgmc_raiding/colony/indoor/garage
	name = "Colony Garage"
	icon_state = "garage"

/area/campaign/tgmc_raiding/colony/indoor/supermarket
	name = "Colony Supermarket"
	icon_state = "disposal"

/area/campaign/tgmc_raiding/colony/indoor/hydroponics
	name = "Colony Hydroponics"
	icon_state = "hydro"

/area/campaign/tgmc_raiding/colony/indoor/laundry
	name = "Colony Laundromat"
	icon_state = "locker"

/area/campaign/tgmc_raiding/colony/indoor/bar
	name = "Colony Bar"
	icon_state = "bar"

/area/campaign/tgmc_raiding/colony/indoor/toolbox
	name = "Colony Toolbox Storage"
	icon_state = "engine_waste"

/area/campaign/tgmc_raiding/colony/indoor/storage
	name = "Colony Storage Dome"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ

/area/campaign/tgmc_raiding/colony/indoor/chapel
	name = "Colony Chapel"
	icon_state = "chapel"

/area/campaign/tgmc_raiding/colony/indoor/security
	name = "Colony Security"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/campaign/tgmc_raiding/colony/indoor/dome
	name = "Colony Northeast Dome"
	icon_state = "construction"

/area/campaign/tgmc_raiding/colony/indoor/station
	name = "Colony Subway Station"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/campaign/tgmc_raiding/colony/indoor/bathroom
	name = "Colony Restroom"
	icon_state = "toilet"

//Underground

/area/campaign/tgmc_raiding/underground
	name = "Underground"
	icon_state = "cave"
	ceiling = CEILING_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

/area/campaign/tgmc_raiding/underground/tunnel
	icon_state = "shuttlegrn"
	minimap_color = MINIMAP_AREA_LZ

/area/campaign/tgmc_raiding/underground/tunnel/east
	name = "East Subway Tunnel"

/area/campaign/tgmc_raiding/underground/tunnel/central
	name = "Central Subway Tunnel"

/area/campaign/tgmc_raiding/underground/tunnel/south
	name = "South Subway Tunnel"

/area/campaign/tgmc_raiding/underground/tunnel/west
	name = "West Subway Tunnel"

/area/campaign/tgmc_raiding/underground/tunnel/station
	name = "Northwest Subway Station"
	icon_state = "hangar"

/area/campaign/tgmc_raiding/underground/security
	name = "Marine Security"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/campaign/tgmc_raiding/underground/security/central_outpost
	name = "Central Security Outpost"

/area/campaign/tgmc_raiding/underground/security/south_outpost
	name = "South Security Outpost"

/area/campaign/tgmc_raiding/underground/engineering
	name = "Engineering"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/campaign/tgmc_raiding/underground/engineering/filtration
	name = "Water Filtration"
	icon_state = "blue2"

/area/campaign/tgmc_raiding/underground/command
	name = "Central Command Office"
	icon_state = "observatory"
	minimap_color = MINIMAP_AREA_COMMAND_CAVE

/area/campaign/tgmc_raiding/underground/command/east
	name = "Eastern Command Office"
	icon_state = "ai_upload"

/area/campaign/tgmc_raiding/underground/command/captain
	name = "Captain's Office"
	icon_state = "captain"

/area/campaign/tgmc_raiding/underground/medbay
	name = "Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY_CAVE

/area/campaign/tgmc_raiding/underground/living
	minimap_color = MINIMAP_AREA_LIVING_CAVE

/area/campaign/tgmc_raiding/underground/living/barracks
	name = "Barracks"
	icon_state = "crew_quarters"

/area/campaign/tgmc_raiding/underground/living/cafeteria
	name = "Cafeteria"
	icon_state = "cafeteria"

/area/campaign/tgmc_raiding/underground/living/bathroom
	name = "Central Bathroom"
	icon_state = "toilet"

/area/campaign/tgmc_raiding/underground/living/bathroom/south
	name = "South Bathroom"

/area/campaign/tgmc_raiding/underground/living/laundry
	name = "Marine Laundromat"
	icon_state = "fitness"

/area/campaign/tgmc_raiding/underground/living/boxing
	name = "Boxing Ring"
	icon_state = "fitness"

/area/campaign/tgmc_raiding/underground/living/chapel
	name = "Marine Chapel"
	icon_state = "chapeloffice"

/area/campaign/tgmc_raiding/underground/living/library
	name = "Marine Library"
	icon_state = "library"

/area/campaign/tgmc_raiding/underground/living/offices
	name = "Northwest Offices"
	icon_state = "showroom"

/area/campaign/tgmc_raiding/underground/general
	icon_state = "purple"
	minimap_color = MINIMAP_AREA_COLONY

/area/campaign/tgmc_raiding/underground/general/firing_range
	name = "Firing Range"

/area/campaign/tgmc_raiding/underground/general/prep
	name = "Marine Prep"

/area/campaign/tgmc_raiding/underground/general/hallway
	name = "Central Base Hallway"
	icon_state = "hallC1"

/area/campaign/tgmc_raiding/underground/general/hallway/west
	name = "West Base Hallway"

/area/campaign/tgmc_raiding/underground/general/hallway/east
	name = "East Base Hallway"

/area/campaign/tgmc_raiding/underground/cargo
	name = "Cargo Dock"
	icon_state = "eva"
	minimap_color = MINIMAP_AREA_REQ_CAVE

/area/campaign/tgmc_raiding/underground/cargo/storage
	name = "Cargo Storage"
	icon_state = "auxstorage"

/area/campaign/tgmc_raiding/underground/maintenance
	icon_state = "maintcentral"

/area/campaign/tgmc_raiding/underground/maintenance/north
	name = "North Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/kitchen
	name = "Kitchen Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/laundry
	name = "Laundry Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/security
	name = "Security Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/filtration
	name = "Filtration Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/cargo
	name = "Cargo Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/prep
	name = "Prep Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/sewer
	name = "Sewage Tunnel"
	icon_state = "blue2"
