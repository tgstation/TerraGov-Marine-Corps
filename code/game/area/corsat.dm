//Areas for Biodomes Map

/area/corsat
	icon = 'icons/turf/area_corsat.dmi'
	ceiling = CEILING_GLASS

/area/corsat/landing/console
	name = "\improper LZ1 'Gamma'"
	icon_state = "corsat_telecomms"
	requires_power = FALSE

/area/corsat/landing/console2
	name = "\improper LZ2 'Sigma'"
	icon_state = "corsat_telecomms"

/area/corsat/emergency_access
	name = "\improper Unknown Area"
	icon_state = "corsat_hull"
	ceiling = CEILING_METAL
	requires_power = FALSE

//SIGMA SECTOR

/area/corsat/sigma
	name = "\improper Sigma Sector"
	icon_state = "corsat_hull"

/area/corsat/sigma/north
	name = "\improper Sigma Sector North Hallway"
	icon_state = "sigma_hallway_north"

/area/corsat/sigma/hangar
	name = "\improper Landing Bay Sigma"
	icon_state = "sigma_hangar"

/area/corsat/sigma/hangar/monorail
	name = "\improper Sigma Monorail Station"
	icon_state = "monorail"

/area/corsat/sigma/hangar/monorail/control
	name = "\improper Sigma Monorail Control"
	icon_state = "monorail"

/area/corsat/sigma/hangar/monorail/railcart
	name = "\improper CORSAT Monorail"
	icon_state = "railcart"
	ceiling = CEILING_METAL
	requires_power = FALSE

/area/corsat/sigma/hangar/monorail/railcart_transit
	name = "\improper CORSAT Monorail transit"
	icon_state = "railcart"
	ceiling = CEILING_METAL

/area/corsat/sigma/hangar/cargo
	name = "\improper Sigma Hangar Cargo Checkpoint"
	icon_state = "sigma_hangar"

/area/corsat/sigma/hangar/checkpoint
	name = "\improper Sigma Hangar Checkpoint"
	icon_state = "sigma_hangar"

/area/corsat/sigma/hangar/id
	name = "\improper Sigma Hangar ID Checkpoint"
	icon_state = "corsat_id"

/area/corsat/sigma/hangar/arrivals
	name = "\improper Sigma Arrivals"
	icon_state = "sigma_arrivals"

/area/corsat/sigma/hangar/office
	name = "\improper Sigma Hangar Office"
	icon_state = "sigma_hangar_office"

/area/corsat/sigma/hangar/security
	name = "\improper Sigma Hangar Security"
	icon_state = "sigma_hangar_security"

/area/corsat/sigma/airlock/east
	name = "\improper Sigma Dome East Airlock"
	icon_state = "sigma_airlock_east"

/area/corsat/sigma/airlock/east/id
	name = "\improper Sigma East ID Checkpoint"
	icon_state = "corsat_id"

/area/corsat/sigma/airlock/south
	name = "\improper Sigma Dome South Airlock"
	icon_state = "sigma_airlock_south"

/area/corsat/sigma/airlock/south/id
	name = "\improper Sigma South ID Checkpoint"
	icon_state = "corsat_id"

/area/corsat/sigma/airlock/control
	name = "\improper Sigma Dome Control Module"
	icon_state = "sigma_control"

/area/corsat/sigma/cargo
	name = "\improper Sigma Cargo"
	icon_state = "sigma_cargo"

/area/corsat/sigma/laundry
	name = "\improper Sigma Laundry"
	icon_state = "sigma_laundry"

/area/corsat/sigma/lavatory
	name = "\improper Sigma Lavatory"
	icon_state = "sigma_lavatory"

/area/corsat/sigma/cafe
	name = "\improper Sigma Cafe"
	icon_state = "sigma_cafe"

/area/corsat/sigma/dorms
	name = "\improper Sigma Residential Module"
	icon_state = "sigma_residential"

/area/corsat/sigma/checkpoint
	name = "\improper Sigma Security Checkpoint"
	icon_state = "sigma_security_checkpoint"

/area/corsat/sigma/southeast
	name = "\improper Sigma Sector Southeast Hallways"
	icon_state = "sigma_hallway_southeast"

/area/corsat/sigma/southeast/generator
	name = "\improper CORSAT Secondary Generators"
	icon_state = "secondary_core"
	ceiling = CEILING_METAL

/area/corsat/sigma/southeast/telecomm
	name = "\improper CORSAT Telecommunications"
	icon_state = "corsat_telecomms"
	ceiling = CEILING_METAL

/area/corsat/sigma/southeast/datalab
	name = "\improper Sigma Data Laboratory"
	icon_state = "sigma_data_lab"
	ceiling = CEILING_METAL

/area/corsat/sigma/southeast/dataoffice
	name = "\improper Sigma Data Office"
	icon_state = "sigma_data_offices"

/area/corsat/sigma/southeast/datamaint
	name = "\improper Sigma Data Maintenance"
	icon_state = "sigma_data_lab"

/area/corsat/sigma/south
	name = "\improper Sigma Sector South Hallways"
	icon_state = "sigma_hallway_south"

/area/corsat/sigma/south/complex
	name = "\improper Sigma Research Complex"
	icon_state = "sigma_complex"

/area/corsat/sigma/south/complex/teleporter
	name = "\improper Sigma Teleporter"
	icon = 'icons/turf/areas.dmi'
	icon_state = "shuttle"
	ceiling = CEILING_METAL
	requires_power = FALSE

/area/corsat/sigma/south/robotics
	name = "\improper Sigma Robotics Laboratory"
	icon_state = "robotics"

/area/corsat/sigma/south/engineering
	name = "\improper Sigma Engineering"
	icon_state = "sigma_engineering"

/area/corsat/sigma/south/security
	name = "\improper Sigma Security Hub"
	icon_state = "sigma_security"

/area/corsat/sigma/south/offices
	name = "\improper Sigma Offices"
	icon_state = "sigma_offices"

/area/corsat/sigma/biodome
	name = "\improper Biodome Sigma"
	icon_state = "sigma_biodome"
	always_unpowered = 1
	ceiling = CEILING_UNDERGROUND_METAL

// Ice Nightmare insert variation. COLD!
/area/corsat/sigma/biodome/ice

/area/corsat/sigma/biodome/testgrounds
	name = "\improper Sigma Biodome Testing Grounds"
	icon_state = "sigma_testgrounds"
	requires_power = FALSE

/area/corsat/sigma/biodome/gunrange
	name = "\improper Sigma Biodome Firing Range"
	icon_state = "sigma_gunrange"
	requires_power = FALSE

/area/corsat/sigma/biodome/scrapyard
	name = "\improper Sigma Biodome Scrapyard"
	icon_state = "sigma_scrapyard"
	requires_power = FALSE

//GAMMA SECTOR

/area/corsat/gamma
	name = "\improper Gamma Sector"
	icon_state = "corsat_hull"

/area/corsat/gamma/hangar
	name = "\improper Landing Bay Gamma"
	icon_state = "gamma_hangar"

/area/corsat/gamma/hangar/monorail
	name = "\improper Gamma Monorail Station"
	icon_state = "monorail"

/area/corsat/gamma/hangar/monorail/control
	name = "\improper Gamma Monorail Control"
	icon_state = "monorail"

/area/corsat/gamma/hangar/monorail/railcart
	name = "\improper CORSAT Railcart"
	icon_state = "railcart"
	ceiling = CEILING_METAL
	requires_power = FALSE

/area/corsat/gamma/hangar/cargo
	name = "\improper Gamma Hangar Cargo Checkpoint"
	icon_state = "gamma_hangar"

/area/corsat/gamma/hangar/checkpoint
	name = "\improper Gamma Hangar Checkpoint"
	icon_state = "gamma_hangar"

/area/corsat/gamma/hangar/office
	name = "\improper Gamma Hangar Office"
	icon_state = "gamma_hangar_office"

/area/corsat/gamma/hangar/flightcontrol
	name = "\improper CORSAT Flight Control Center"
	icon_state = "flight_center"

/area/corsat/gamma/hangar/security
	name = "\improper Gamma Hangar Security"
	icon_state = "gamma_hangar_security"

/area/corsat/gamma/hangar/arrivals
	name = "\improper Gamma Arrivals"
	icon_state = "gamma_arrivals"

/area/corsat/gamma/foyer
	name = "\improper Gamma Foyer"
	icon_state = "gamma_foyer"

/area/corsat/gamma/hallwaymain
	name = "\improper Gamma Sector West Hallway"
	icon_state = "gamma_hallway_main"

/area/corsat/gamma/hallwaysouth
	name = "\improper Gamma Sector South Hallways"
	icon_state = "gamma_hallway_south"

/area/corsat/gamma/residential
	name = "\improper Gamma Residential Hallway"
	icon_state = "gamma_hallway_main"

/area/corsat/gamma/residential/west
	name = "\improper CORSAT Academy"
	icon_state = "gamma_residential_west"

/area/corsat/gamma/residential/east
	name = "\improper Gamma North Residential"
	icon_state = "gamma_residential_east"

/area/corsat/gamma/residential/maint
	name = "\improper Gamma Residential Maintenance"
	icon_state = "gamma_residential_maint"

/area/corsat/gamma/residential/researcher
	name = "\improper Researcher Quarters"
	icon_state = "researcher_quarters"

/area/corsat/gamma/residential/lounge
	name = "\improper Researcher Lounge"
	icon_state = "researcher_lounge"

/area/corsat/gamma/residential/lavatory
	name = "\improper Gamma Lavatory"
	icon_state = "gamma_lavatory"

/area/corsat/gamma/residential/showers
	name = "\improper Gamma Showers"
	icon_state = "gamma_showers"

/area/corsat/gamma/residential/laundry
	name = "\improper Gamma Laundry"
	icon_state = "gamma_laundry"

/area/corsat/gamma/cargo
	name = "\improper Gamma Cargo"
	icon_state = "gamma_cargo"

/area/corsat/gamma/cargo/lobby
	name = "\improper Gamma Cargo Lobby"
	icon_state = "gamma_cargo_lobby"

/area/corsat/gamma/cargo/disposal
	name = "\improper Gamma Disposals"
	icon_state = "gamma_disposals"

/area/corsat/gamma/medbay
	name = "\improper CORSAT Medbay"
	icon_state = "corsat_medbay"

/area/corsat/gamma/medbay/morgue
	name = "\improper CORSAT Morgue"
	icon_state = "corsat_morgue"

/area/corsat/gamma/medbay/chemistry
	name = "\improper CORSAT Chemistry"
	icon_state = "corsat_chemistry"

/area/corsat/gamma/medbay/surgery
	name = "\improper CORSAT Surgery"
	icon_state = "corsat_surgery"

/area/corsat/gamma/medbay/lobby
	name = "\improper CORSAT Medbay Lobby"
	icon_state = "medbay_lobby"

/area/corsat/gamma/hydroponics
	name = "\improper CORSAT Hydroponics"
	icon_state = "corsat_hydroponics"

/area/corsat/gamma/canteen
	name = "\improper CORSAT Canteen"
	icon_state = "corsat_canteen"

/area/corsat/gamma/kitchen
	name = "\improper CORSAT Kitchen"
	icon_state = "corsat_kitchen"

/area/corsat/gamma/freezer
	name = "\improper CORSAT Food Storage"
	icon_state = "food_storage"

/area/corsat/gamma/administration
	name = "\improper CORSAT Administration Center"
	icon_state = "corsat_administration"

/area/corsat/gamma/security
	name = "\improper CORSAT Security Hub"
	icon_state = "gamma_security"

/area/corsat/gamma/security/cells
	name = "\improper CORSAT Security Cells"
	icon_state = "security_cell"

/area/corsat/gamma/security/armory
	name = "\improper CORSAT Armory"
	icon_state = "corsat_armory"

/area/corsat/gamma/rnr
	name = "\improper CORSAT R&R"
	icon_state = "corsat_rnr"

/area/corsat/gamma/rnr/bar
	name = "\improper CORSAT Bar"
	icon_state = "corsat_bar"

/area/corsat/gamma/rnr/arcade
	name = "\improper CORSAT Arcade"
	icon_state = "corsat_arcade"

/area/corsat/gamma/rnr/library
	name = "\improper CORSAT Library"
	icon_state = "corsat_library"

/area/corsat/gamma/engineering
	name = "\improper Gamma Engineering"
	icon_state = "gamma_engineering"

/area/corsat/gamma/engineering/lobby
	name = "\improper Gamma Engineering Lobby"
	icon_state = "gamma_engineering"

/area/corsat/gamma/engineering/atmos
	name = "\improper CORSAT Atmospherics"
	icon_state = "gamma_atmos"

/area/corsat/gamma/engineering/core
	name = "\improper CORSAT Generator Core"
	icon_state = "corsat_core"

/area/corsat/gamma/sigmaremote
	name = "\improper Sigma Remote Complex"
	icon_state = "sigma_complex_remote"

/area/corsat/gamma/sigmaremote/teleporter
	name = "\improper Sigma Remote Teleporter"
	icon = 'icons/turf/areas.dmi'
	icon_state = "shuttle"
	ceiling = CEILING_METAL
	requires_power = FALSE

/area/corsat/gamma/airlock/north
	name = "\improper Gamma Dome North Airlock"
	icon_state = "gamma_airlock_north"
	ceiling = CEILING_GLASS

/area/corsat/gamma/airlock/north/id
	name = "\improper Gamma North ID Checkpoint"
	icon_state = "corsat_id"

/area/corsat/gamma/airlock/south
	name = "\improper Gamma Dome South Airlock"
	icon_state = "gamma_airlock_south"

/area/corsat/gamma/airlock/south/id
	name = "\improper Gamma South ID Checkpoint"
	icon_state = "corsat_id"

/area/corsat/gamma/airlock/control
	name = "\improper Gamma Dome Control Module"
	icon_state = "gamma_control"
	ceiling = CEILING_GLASS

/area/corsat/gamma/biodome
	name = "\improper Biodome Gamma"
	icon_state = "gamma_biodome"
	temperature = ICE_COLONY_TEMPERATURE
	ceiling = CEILING_UNDERGROUND_METAL
	requires_power = FALSE

/area/corsat/gamma/biodome/complex
	name = "\improper Gamma Research Complex"
	icon_state = "gamma_complex"
	temperature = T20C
	requires_power = TRUE

/area/corsat/gamma/biodome/virology
	name = "\improper Gamma Virology Wing"
	icon_state = "gamma_virology"
	temperature = T20C
	requires_power = TRUE

/area/corsat/gamma/biodome/toxins
	name = "\improper Gamma Toxins Wing"
	icon_state = "gamma_toxin"
	temperature = T20C
	requires_power = TRUE

//THETA SECTOR

/area/corsat/theta
	name = "\improper Theta Sector"
	icon_state = "corsat_hull"
	ceiling = CEILING_GLASS

/area/corsat/theta/biodome
	name = "\improper Biodome Theta"
	icon_state = "theta_biodome"
	ceiling = CEILING_UNDERGROUND_METAL
	requires_power = FALSE

/area/corsat/theta/biodome/complex
	name = "\improper Theta Research Complex"
	icon_state = "theta_complex"
	requires_power = TRUE

/area/corsat/theta/biodome/hydroeast
	name = "\improper Theta East Hydroponics Wing"
	icon_state = "theta_hydro_east"
	requires_power = TRUE

/area/corsat/theta/biodome/hydrowest
	name = "\improper Theta West Hydroponics Wing"
	icon_state = "theta_hydro_west"
	requires_power = TRUE

/area/corsat/theta/airlock/west
	name = "\improper Theta Dome West Airlock"
	icon_state = "theta_airlock_west"

/area/corsat/theta/airlock/west/id
	name = "\improper Theta West ID Checkpoint"
	icon_state = "corsat_id"

/area/corsat/theta/airlock/east
	name = "\improper Theta Dome East Airlock"
	icon_state = "theta_airlock_east"

/area/corsat/theta/airlock/east/id
	name = "\improper Theta East ID Checkpoint"
	icon_state = "corsat_id"

/area/corsat/theta/airlock/control
	name = "\improper Theta Dome Control Module"
	icon_state = "theta_control"

//OMEGA SECTOR

/area/corsat/omega
	name = "\improper Sector Omega"
	icon_state = "corsat_hull"
	ceiling = CEILING_METAL

/area/corsat/omega/biodome
	name = "\improper Biodome Omega"
	icon_state = "omega_biodome"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/corsat/omega/biodome/one
	name = "\improper Biodome Omega Alpha"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/corsat/omega/biodome/two
	name = "\improper Biodome Omega Beta"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/corsat/omega/biodome/three
	name = "\improper Biodome Omega Charlie"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/corsat/omega/biodome/four
	name = "\improper Biodome Omega Delta"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/corsat/omega/hangar
	name = "\improper Landing Bay Omega"
	icon_state = "omega_hangar"

/area/corsat/omega/hangar/office
	name = "\improper Omega Hangar Office"
	icon_state = "omega_hangar_office"

/area/corsat/omega/hangar/security
	name = "\improper Omega Hangar Security"
	icon_state = "omega_hangar_security"

/area/corsat/omega/hallways
	name = "\improper Omega Sector Hallways"
	icon_state = "omega_hallway"

/area/corsat/omega/complex
	name = "\improper Omega Research Complex"
	icon_state = "omega_complex"

/area/corsat/omega/containment
	name = "\improper Omega Research Containment"
	icon_state = "omega_containment"

/area/corsat/omega/security
	name = "\improper Omega Security Hub"
	icon_state = "omega_security"

/area/corsat/omega/checkpoint
	name = "\improper Omega Access Checkpoint"
	icon_state = "omega_checkpoint"

/area/corsat/omega/offices
	name = "\improper Omega Offices"
	icon_state = "omega_offices"

/area/corsat/omega/cargo
	name = "\improper Omega Cargo"
	icon_state = "omega_cargo"

/area/corsat/omega/maint
	name = "\improper Omega Maintenance"
	icon_state = "omega_maintenance"

/area/corsat/omega/airlocknorth
	name = "\improper Omega Dome North Airlock"
	icon_state = "omega_airlock"

/area/corsat/omega/airlocknorth/id
	name = "\improper Omega North ID Checkpoint"
	icon_state = "corsat_id"

/area/corsat/omega/control
	name = "\improper Omega Dome Control Module"
	icon_state = "omega_control"

/area/corsat/hangar_storage/research
	name = "\improper Hangar Storage"
	icon_state = "omega_hangar"

/area/corsat/hangar_storage/research/ship
	name = "\improper Corporate Ship"
	icon_state = "railcart"
	requires_power = FALSE

/area/corsat/dropzone/landingzoneone
	name = "\improper Hangar Storage"
	icon_state = "flight_center"
	requires_power = FALSE

/area/corsat/dropzone/landingzonetwo
	name = "\improper Hangar Storage"
	icon_state = "flight_center"

/area/corsat/dropzone/landingzonethree
	name = "\improper Hangar Storage"
	icon_state = "flight_center"

//INACCESSIBLE

/area/corsat/inaccessible
	name = "\improper Unknown Location"
	icon_state = "corsat_hull"
	ceiling = CEILING_METAL
	requires_power = FALSE
