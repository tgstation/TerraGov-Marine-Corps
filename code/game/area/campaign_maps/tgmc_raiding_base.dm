
/area/campaign/tgmc_raiding
	icon_state = "cliff_blocked"
	area_flags = ALWAYS_RADIO

//Colony
/area/campaign/tgmc_raiding/colony
	icon_state = "red"

/area/campaign/tgmc_raiding/colony/outdoor
	name = "\improper Central Colony Grounds"
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/campaign/tgmc_raiding/colony/outdoor/northeast
	name = "\improper Northeast Colony Grounds"
	icon_state = "northeast"

/area/campaign/tgmc_raiding/colony/outdoor/east
	name = "\improper Eastern Colony Grounds"
	icon_state = "east"

/area/campaign/tgmc_raiding/colony/outdoor/southeast
	name = "\improper Southeast Colony Grounds"
	icon_state = "southeast"

/area/campaign/tgmc_raiding/colony/outdoor/south
	name = "\improper Southern Colony Grounds"
	icon_state = "south"

/area/campaign/tgmc_raiding/colony/outdoor/southwest
	name = "\improper Southwest Colony Grounds"
	icon_state = "southwest"

//Colony Buildings

/area/campaign/tgmc_raiding/colony/indoor
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/campaign/tgmc_raiding/colony/indoor/southwest_shed
	name = "\improper Southwest Maintenance Shed"
	icon_state = "panelsA"

/area/campaign/tgmc_raiding/colony/indoor/housing
	icon_state = "crew_quarters"
	minimap_color = MINIMAP_AREA_LIVING

/area/campaign/tgmc_raiding/colony/indoor/housing/southwest
	name = "\improper Southwest Colony Housing"

/area/campaign/tgmc_raiding/colony/indoor/housing/southeast
	name = "\improper Southeast Colony Housing"

/area/campaign/tgmc_raiding/colony/indoor/housing/east
	name = "\improper East Colony Housing"

/area/campaign/tgmc_raiding/colony/indoor/freezer
	name = "\improper Colony Meat Locker"
	icon_state = "kitchen"

/area/campaign/tgmc_raiding/colony/indoor/engineering
	name = "\improper Colony Engineering"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI

/area/campaign/tgmc_raiding/colony/indoor/engineering/storage
	name = "\improper Colony Engineering Storage"
	icon_state = "engine_storage"

/area/campaign/tgmc_raiding/colony/indoor/garage
	name = "\improper Colony Garage"
	icon_state = "garage"

/area/campaign/tgmc_raiding/colony/indoor/supermarket
	name = "\improper Colony Supermarket"
	icon_state = "disposal"

/area/campaign/tgmc_raiding/colony/indoor/hydroponics
	name = "\improper Colony Hydroponics"
	icon_state = "hydro"

/area/campaign/tgmc_raiding/colony/indoor/laundry
	name = "\improper Colony Laundromat"
	icon_state = "locker"

/area/campaign/tgmc_raiding/colony/indoor/bar
	name = "\improper Colony Bar"
	icon_state = "bar"

/area/campaign/tgmc_raiding/colony/indoor/toolbox
	name = "\improper Colony Toolbox Storage"
	icon_state = "engine_waste"

/area/campaign/tgmc_raiding/colony/indoor/storage
	name = "\improper Colony Storage Dome"
	icon_state = "storage"
	minimap_color = MINIMAP_AREA_REQ

/area/campaign/tgmc_raiding/colony/indoor/chapel
	name = "\improper Colony Chapel"
	icon_state = "chapel"

/area/campaign/tgmc_raiding/colony/indoor/security
	name = "\improper Colony Security"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/campaign/tgmc_raiding/colony/indoor/dome
	name = "\improper Colony Northeast Dome"
	icon_state = "construction"

/area/campaign/tgmc_raiding/colony/indoor/station
	name = "\improper Colony Subway Station"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/campaign/tgmc_raiding/colony/indoor/bathroom
	name = "\improper Colony Restroom"
	icon_state = "toilet"

//Underground

/area/campaign/tgmc_raiding/underground
	name = "\improper Underground"
	icon_state = "cave"
	ceiling = CEILING_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

/area/campaign/tgmc_raiding/underground/tunnel
	icon_state = "shuttlegrn"
	minimap_color = MINIMAP_AREA_LZ

/area/campaign/tgmc_raiding/underground/tunnel/east
	name = "\improper East Subway Tunnel"

/area/campaign/tgmc_raiding/underground/tunnel/central
	name = "\improper Central Subway Tunnel"

/area/campaign/tgmc_raiding/underground/tunnel/south
	name = "\improper South Subway Tunnel"

/area/campaign/tgmc_raiding/underground/tunnel/west
	name = "\improper West Subway Tunnel"

/area/campaign/tgmc_raiding/underground/tunnel/station
	name = "\improper Northwest Subway Station"
	icon_state = "hangar"

/area/campaign/tgmc_raiding/underground/security
	name = "\improper Marine Security"
	icon_state = "brig"
	minimap_color = MINIMAP_AREA_SEC

/area/campaign/tgmc_raiding/underground/security/central_outpost
	name = "\improper Central Security Outpost"

/area/campaign/tgmc_raiding/underground/security/south_outpost
	name = "\improper South Security Outpost"

/area/campaign/tgmc_raiding/underground/engineering
	name = "\improper Engineering"
	icon_state = "yellow"
	minimap_color = MINIMAP_AREA_ENGI

/area/campaign/tgmc_raiding/underground/engineering/filtration
	name = "\improper Water Filtration"
	icon_state = "blue2"

/area/campaign/tgmc_raiding/underground/command
	name = "\improper Central Command Office"
	icon_state = "observatory"
	minimap_color = MINIMAP_AREA_COMMAND

/area/campaign/tgmc_raiding/underground/command/east
	name = "\improper Eastern Command Office"
	icon_state = "ai_upload"

/area/campaign/tgmc_raiding/underground/command/captain
	name = "\improper Captain's Office"
	icon_state = "captain"

/area/campaign/tgmc_raiding/underground/medbay
	name = "\improper Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/campaign/tgmc_raiding/underground/living
	minimap_color = MINIMAP_AREA_LIVING

/area/campaign/tgmc_raiding/underground/living/barracks
	name = "\improper Barracks"
	icon_state = "crew_quarters"

/area/campaign/tgmc_raiding/underground/living/cafeteria
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/campaign/tgmc_raiding/underground/living/bathroom
	name = "\improper Central Bathroom"
	icon_state = "toilet"

/area/campaign/tgmc_raiding/underground/living/bathroom/south
	name = "\improper South Bathroom"

/area/campaign/tgmc_raiding/underground/living/laundry
	name = "\improper Marine Laundromat"
	icon_state = "fitness"

/area/campaign/tgmc_raiding/underground/living/boxing
	name = "\improper Boxing Ring"
	icon_state = "fitness"

/area/campaign/tgmc_raiding/underground/living/chapel
	name = "\improper Marine Chapel"
	icon_state = "chapeloffice"

/area/campaign/tgmc_raiding/underground/living/library
	name = "\improper Marine Library"
	icon_state = "library"

/area/campaign/tgmc_raiding/underground/living/offices
	name = "\improper Northwest Offices"
	icon_state = "showroom"

/area/campaign/tgmc_raiding/underground/general
	icon_state = "purple"
	minimap_color = MINIMAP_AREA_COLONY

/area/campaign/tgmc_raiding/underground/general/firing_range
	name = "\improper Firing Range"

/area/campaign/tgmc_raiding/underground/general/prep
	name = "\improper Marine Prep"

/area/campaign/tgmc_raiding/underground/general/hallway
	name = "\improper Central Base Hallway"
	icon_state = "hallC1"

/area/campaign/tgmc_raiding/underground/general/hallway/west
	name = "\improper West Base Hallway"

/area/campaign/tgmc_raiding/underground/general/hallway/east
	name = "\improper East Base Hallway"

/area/campaign/tgmc_raiding/underground/cargo
	name = "\improper Cargo Dock"
	icon_state = "eva"
	minimap_color = MINIMAP_AREA_REQ

/area/campaign/tgmc_raiding/underground/cargo/storage
	name = "\improper Cargo Storage"
	icon_state = "auxstorage"

/area/campaign/tgmc_raiding/underground/maintenance
	icon_state = "maintcentral"

/area/campaign/tgmc_raiding/underground/maintenance/north
	name = "\improper North Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/kitchen
	name = "\improper Kitchen Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/laundry
	name = "\improper Laundry Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/security
	name = "\improper Security Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/filtration
	name = "\improper Filtration Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/cargo
	name = "\improper Cargo Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/prep
	name = "\improper Prep Maintenance"

/area/campaign/tgmc_raiding/underground/maintenance/sewer
	name = "\improper Sewage Tunnel"
	icon_state = "blue2"
