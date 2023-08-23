// Magmoor Digsite IV - Hathkar

//Base Area

/area/magmoor
	name = "Lava"
	icon_state = "lava"
	outside = FALSE


/area/magmoor/landing
	name = "Landing Zone One"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_LZ

/area/magmoor/landing/two
	name = "Landing Zone Two"
	minimap_color = MINIMAP_AREA_LZ


// Volcano
/area/magmoor/volcano
	name = "Magmoor Central Fissure"
	ceiling = CEILING_DEEP_UNDERGROUND
	flags_area = NO_DROPPOD
	always_unpowered = TRUE

//Caves

/area/magmoor/cave
	ceiling = CEILING_DEEP_UNDERGROUND
	ambience = list('sound/ambience/ambicave.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava2.ogg', 'sound/ambience/ambilava3.ogg')
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/magmoor/cave/central
	name = "Central Caves"
	icon_state = "lava_cave_c"

/area/magmoor/cave/north
	name = "North Caves"
	icon_state = "lava_cave_n"

/area/magmoor/cave/northeast
	name = "North East Caves"
	icon_state = "lava_cave_ne"

/area/magmoor/cave/northwest
	name = "North West Caves"
	icon_state = "lava_cave_nw"

/area/magmoor/cave/south
	name = "South Caves"
	icon_state = "lava_cave_s"

/area/magmoor/cave/southeast
	name = "South East Caves"
	icon_state = "lava_cave_se"

/area/magmoor/cave/southwest
	name = "South West Caves"
	icon_state = "lava_cave_sw"

/area/magmoor/cave/east
	name = "East Caves"
	icon_state = "lava_cave_e"

/area/magmoor/cave/west
	name = "West Caves"
	icon_state = "lava_cave_w"

/area/magmoor/cave/mining/fossil
	name = "Southwest Fossil Deposits"
	icon_state = "lava_mining_fossil"

/area/magmoor/cave/rock
	name = "Enclosed Area"
	icon_state = "transparent"

//Compound Outside
/area/magmoor/compound
	ceiling = CEILING_NONE
	name = "Central Magmoor Compound"
	icon_state = "central"
	outside = TRUE
	ambience = list('sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava2.ogg', 'sound/ambience/ambilava3.ogg')
	always_unpowered = TRUE

/area/magmoor/compound/north
	name = "North Magmoor Compound"
	icon_state = "north"

/area/magmoor/compound/northeast
	name = "Northeast Magmoor Compound"
	icon_state = "northeast"

/area/magmoor/compound/northwest
	name = "Northwest Magmoor Compound"
	icon_state = "northwest"

/area/magmoor/compound/south
	name = "South Magmoor Compound"
	icon_state = "south"

/area/magmoor/compound/southeast
	name = "Southeast Magmoor Compound"
	icon_state = "southeast"

/area/magmoor/compound/southwest
	name = "Southwest Magmoor Compound"
	icon_state = "southwest"

/area/magmoor/compound/east
	name = "East Magmoor Compound"
	icon_state = "east"

/area/magmoor/compound/west
	name = "West Magmoor Compound"
	icon_state = "west"

//Medical

/area/magmoor/medical
	name = "Medical Clinic"
	icon_state = "lava_med"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_MEDBAY

/area/magmoor/medical/chemistry
	name = "Medical Clinic Chemistry"
	icon_state = "lava_chem"

/area/magmoor/medical/cmo
	name = "Chief Medical Office"
	icon_state = "lava_cmo"

/area/magmoor/medical/breakroom
	name = "Medical Break Room"
	icon_state = "cafeteria"

/area/magmoor/medical/lobby
	name = "Medical Lobby"
	icon_state = "lava_med"

/area/magmoor/medical/surgery
	name = "Operating Theatre"
	icon_state = "surgery"

/area/magmoor/medical/morgue
	name = "Medical Morgue"
	icon_state = "morgue"

/area/magmoor/medical/storage
	name = "Medical Storage"
	icon_state = "lava_med"

/area/magmoor/medical/treatment
	name = "Medical Treatment Center"
	icon_state = "medbay2"

/area/magmoor/medical/patient
	name = "Medical Patient Room"
	icon_state = "medbay3"


//Engineer

/area/magmoor/engi
	name = "Engineering"
	icon_state = "lava_engie"
	ceiling = CEILING_METAL
	ambience = list('sound/ambience/ambisin1.ogg', 'sound/ambience/ambisin2.ogg', 'sound/ambience/ambisin3.ogg', 'sound/ambience/ambisin4.ogg')
	minimap_color = MINIMAP_AREA_ENGI

/area/magmoor/engi/atmos
	name = "Atmospheric Processing"
	icon_state = "lava_atmos"

/area/magmoor/engi/thermal
	name = "Thermal Reactors"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	icon_state = "lava_power"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/magmoor/engi/power
	name = "Power Management Centre"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	icon_state = "lava_power"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

/area/magmoor/engi/storage
	name = "Engineering Lobby & Storage"
	icon_state = "lava_engi_storage"

//Security

/area/magmoor/security
	name = "Holding Cells"
	icon_state = "lava_sec_prison"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_SEC

/area/magmoor/security/storage
	name = "Security Armory"
	icon_state = "lava_sec_secure"

/area/magmoor/security/infocenter
	name = "Security Information Center"
	icon_state = "lava_sec"

/area/magmoor/security/nuke
	name = "Emergency Nuclear Fission Facility"
	icon_state = "lava_sec_nuke"

/area/magmoor/security/arrivals/south
	name = "Southern Arrivals Security Checkpoint"
	icon_state = "lava_sec"

/area/magmoor/security/arrivals/east
	name = "Eastern Arrivals Security Checkpoint"
	icon_state = "lava_sec"

/area/magmoor/security/lobby
	name = "Security Lobby"
	icon_state = "lava_sec"

//Civilian

/area/magmoor/civilian
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_LIVING

/area/magmoor/civilian/cook
	name = "Kitchen"
	icon_state = "lava_cook"

/area/magmoor/civilian/bar
	name = "The Drunk Carp"

/area/magmoor/civilian/dorms
	name = "Dormitories"
	icon_state = "lava_dorms"

/area/magmoor/civilian/jani
	name = "Janitorial Office"
	icon_state = "lava_jani"

/area/magmoor/civilian/clean
	name = "Washrooms"
	icon_state = "lava_bathrooms"

/area/magmoor/civilian/clean/toilet
	name = "Bathrooms"
	icon_state = "red"

/area/magmoor/civilian/clean/shower
	name = "Showers"
	icon_state = "blue"

/area/magmoor/civilian/chapel
	name = "Chapel"
	icon_state = "lava_chapel"
	ceiling = CEILING_GLASS
	ambience = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')

/area/magmoor/civilian/mosque
	name = "Mosque"
	icon_state = "lava_chapel"
	ceiling = CEILING_GLASS
	ambience = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')

/area/magmoor/civilian/pool
	name = "Bath House"
	icon_state = "lava_civ"
	ceiling = CEILING_GLASS

/area/magmoor/civilian/basket
	name = "Basketball Arena"
	icon_state = "lava_civ"
	ceiling = CEILING_GLASS

/area/magmoor/civilian/gambling
	name = "Games Lounge"
	icon_state = "lava_civ"

/area/magmoor/civilian/cryostasis
	name = "Cryostasis"
	icon_state = "lava_civ"

/area/magmoor/civilian/rnr
	name = "Rest and Recreation"

/area/magmoor/civilian/arrival
	name = "Southern Arrivals Hallway"
	icon_state = "lava_civ"
	ceiling = CEILING_GLASS
	minimap_color = MINIMAP_AREA_COLONY

/area/magmoor/civilian/arrival/east
	name = "Eastern Arrivals Hallway"


// Research
/area/magmoor/research
	name = "Research & Archaeology"
	icon_state = "lava_research"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	ambience = list('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg')
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/magmoor/research/containment
	name = "Research Materials & Containment"
	icon_state = "storage"

/area/magmoor/research/researchdirector
	name = "Research Director's Office"
	icon_state = "blue"

/area/magmoor/research/decontamination
	name = "Research Decontamination"
	icon_state = "decontamination"

/area/magmoor/research/serverroom
	name = "Research Server Room"
	icon_state = "party"

/area/magmoor/research/rnd
	name = "Research & Development"
	icon_state = "research"

/area/magmoor/research/rnd/lobby
	name = "Research & Development Lobby"
	icon_state = "purple"

/area/magmoor/research/lab
	name = "Research Material Study"
	icon_state = "lava_research"

//Cargo
/area/magmoor/cargo
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_REQ

/area/magmoor/cargo/processing
	name = "Cargo Processing East"
	icon_state = "lava_civ_cargo"

/area/magmoor/cargo/processing/south
	name = "Cargo Processing South"

/area/magmoor/cargo/storage
	name = "Cargo Storage East"
	icon_state = "storage"

/area/magmoor/cargo/storage/south
	name = "Cargo Storage South"

/area/magmoor/cargo/storage/secure
	name = "Cargo Secure Storage East"
	icon_state = "auxstorage"

/area/magmoor/cargo/storage/secure/south
	name = "Cargo Secure Storage South"

/area/magmoor/cargo/freezer
	name = "Cargo Freezer East"
	icon_state = "kitchen"

//Hydroponics
/area/magmoor/hydroponics
	name = "Hydropnics Lobby & Livestock"
	icon_state = "lava_civ_garden"
	ceiling = CEILING_GLASS
	outside = TRUE
	minimap_color = MINIMAP_AREA_LIVING

/area/magmoor/hydroponics/north
	name = "Hydropnics North"

/area/magmoor/hydroponics/south
	name = "Hydropnics South"

//Command
/area/magmoor/command
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_COMMAND

/area/magmoor/command/lobby
	name = "North Command Lobby"
	icon_state = "blue2"

/area/magmoor/command/lobby/east
	name = "East Command Lobby"

/area/magmoor/command/office
	name = "Command Office"
	icon_state = "law"

/area/magmoor/command/office/main
	name = "Overseer's Office"
	icon_state = "lava_comm"

/area/magmoor/command/conference
	name = "Command Conference Room"
	icon_state = "head_quarters"

/area/magmoor/command/commandroom
	name = "Command Control Room"
	icon_state = "bridge"
	ambience = list('sound/ambience/signal.ogg')

//Mining
/area/magmoor/mining/
	name = "Mining Equipment & Break Room"
	icon_state = "lava_mining"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_REQ_CAVE

/area/magmoor/mining/garage
	name = "Mining Garage & Storage"
	icon_state = "storage"

/area/magmoor/mining/refinery
	name = "Ore Refinery"
	icon_state = "lava_mining_proc"

/area/magmoor/mining/storage
	name = "Mineral Storage"
	icon_state = "storage"
