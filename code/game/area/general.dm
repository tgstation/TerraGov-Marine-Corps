/area/space
	name = "Space"
	requires_power = 1
	always_unpowered = 1
	base_lighting_alpha = 255

	power_light = 0
	power_equip = 0
	power_environ = 0
	ambience = list('sound/ambience/ambispace.ogg')
	temperature = TCMB
	pressure = 0
	flags_area = NO_DROPPOD
	///What type of debuff do we apply when someone enters this area?
	var/debuff_type = /datum/status_effect/spacefreeze

/area/space/light
	debuff_type = /datum/status_effect/spacefreeze/light

/area/engine
	ambience = list('sound/ambience/ambisin1.ogg','sound/ambience/ambisin2.ogg','sound/ambience/ambisin3.ogg','sound/ambience/ambisin4.ogg')

/area/turret_protected

/area/arrival
	requires_power = 0

/area/arrival/start
	name = "Arrival Area"
	icon_state = "start"

/area/admin
	name = "Admin room"
	icon_state = "start"



//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle //DO NOT TURN THE dynamic_lighting STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	requires_power = FALSE
	outside = FALSE
	flags_area = OB_CAS_IMMUNE
	minimap_color = MINIMAP_AREA_LZ

/area/shuttle/arrival
	name = "Abandoned Arrival Shuttle"

/area/shuttle/arrival/pre_game
	icon_state = "shuttle2"

/area/shuttle/arrival/station
	icon_state = "shuttle"

/area/shuttle/escape
	name = "Abandoned Emergency Shuttle"

/area/shuttle/escape/station
	name = "Abandoned Emergency Shuttle Station"
	icon_state = "shuttle2"

/area/shuttle/escape/centcom
	name = "Abandoned Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	name = "Abandoned Emergency Shuttle Transit"
	icon_state = "shuttle"

/area/shuttle/escape_pod1
	name = "Escape Pod One"

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod2
	name = "Escape Pod Two"

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod3
	name = "Escape Pod Three"

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"

/area/shuttle/escape_pod5 //Pod 4 was lost to meteors
	name = "Escape Pod Five"

/area/shuttle/escape_pod5/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod5/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod5/transit
	icon_state = "shuttle"

/area/shuttle/mining
	name = "abandoned Mining Shuttle"

/area/shuttle/mining/station
	icon_state = "shuttle2"

/area/shuttle/mining/outpost
	icon_state = "shuttle"

/area/shuttle/transport1/centcom
	icon_state = "shuttle"
	name = "Abandoned Transport Shuttle Centcom"

/area/shuttle/transport1/station
	icon_state = "shuttle"
	name = "Abandoned Transport Shuttle"


/area/shuttle/prison/
	name = "Abandoned Prison Shuttle"


/area/shuttle/prison/station
	icon_state = "shuttle"


/area/shuttle/prison/prison
	icon_state = "shuttle2"


/area/shuttle/specops/centcom
	name = "Abandoned Special Ops Shuttle"
	icon_state = "shuttlered"


/area/shuttle/specops/station
	name = "Abandoned Special Ops Shuttle"
	icon_state = "shuttlered2"


/area/shuttle/syndicate_elite/mothership
	name = "Abandoned Syndicate Elite Shuttle"
	icon_state = "shuttlered"


/area/shuttle/syndicate_elite/station
	name = "Abandoned Syndicate Elite Shuttle"
	icon_state = "shuttlered2"


/area/shuttle/administration/centcom
	name = "Abandoned Administration Shuttle Centcom"
	icon_state = "shuttlered"


/area/shuttle/administration/station
	name = "Abandoned Administration Shuttle"
	icon_state = "shuttlered2"


/area/shuttle/thunderdome
	name = "honk"


/area/shuttle/thunderdome/grnshuttle
	name = "Abandoned Thunderdome GRN Shuttle"
	icon_state = "green"


/area/shuttle/thunderdome/grnshuttle/dome
	name = "Abandoned GRN Shuttle"
	icon_state = "shuttlegrn"


/area/shuttle/thunderdome/grnshuttle/station
	name = "Abandoned GRN Station"
	icon_state = "shuttlegrn2"


/area/shuttle/thunderdome/redshuttle
	name = "Abandoned Thunderdome RED Shuttle"
	icon_state = "red"


/area/shuttle/thunderdome/redshuttle/dome
	name = "Abandoned RED Shuttle"
	icon_state = "shuttlered"


/area/shuttle/thunderdome/redshuttle/station
	name = "Abandoned RED Station"
	icon_state = "shuttlered2"


/area/shuttle/vox/station
	name = "Abandoned Vox Skipjack"
	icon_state = "yellow"
	requires_power = 0


/area/start            // will be unused once kurper gets his login interface patch done
	name = "start area"
	icon_state = "start"
	requires_power = 0
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/testroom
	requires_power = FALSE
	// Mobs should be able to see inside the testroom
	static_lighting = FALSE
	base_lighting_alpha = 255
	name = "Test Room"
	icon_state = "test_room"


/area/syndicate_mothership
	name = "Abandoned Syndicate Base"
	icon_state = "syndie-ship"
	requires_power = 0


/area/syndicate_mothership/control
	name = "Abandoned Syndicate Control Room"
	icon_state = "syndie-control"


/area/syndicate_mothership/elite_squad
	name = "Abandoned Syndicate Elite Squad"
	icon_state = "syndie-elite"


/area/asteroid
	name = "Abandoned Asteroid"
	icon_state = "asteroid"
	requires_power = 0


/area/asteroid/cave
	name = "Abandoned Asteroid - Underground"
	icon_state = "cave"
	requires_power = 0
	minimap_color = MINIMAP_AREA_CAVES


/area/asteroid/artifactroom
	name = "Abandoned Asteroid - Artifact"
	icon_state = "cave"


/area/tdome
	name = "Abandoned Thunderdome"
	icon_state = "thunder"
	requires_power = FALSE
	base_lighting_alpha = 255



/area/tdome/tdome1
	name = "Abandoned Thunderdome (Team 1)"
	icon_state = "green"


/area/tdome/tdome2
	name = "Abandoned Thunderdome (Team 2)"
	icon_state = "yellow"


/area/tdome/tdomeadmin
	name = "Abandoned Thunderdome (Admin.)"
	icon_state = "purple"


/area/tdome/tdomeobserve
	name = "Abandoned Thunderdome (Observer.)"
	icon_state = "purple"


/area/deathmatch
	name = "End of Round Deathmatch Arena"
	icon_state = "green"
	base_lighting_alpha = 255

	requires_power = 0


/area/syndicate_station
	name = "Abandoned Syndicate Station"
	icon_state = "yellow"
	requires_power = 0

/area/syndicate_station/start
	name = "Abandoned Syndicate Forward Operating Base"
	icon_state = "yellow"

/area/syndicate_station/southwest
	name = "Abandoned south-west of SS13"
	icon_state = "southwest"

/area/syndicate_station/northwest
	name = "Abandoned north-west of SS13"
	icon_state = "northwest"

/area/syndicate_station/northeast
	name = "Abandoned north-east of SS13"
	icon_state = "northeast"

/area/syndicate_station/southeast
	name = "Abandoned south-east of SS13"
	icon_state = "southeast"

/area/syndicate_station/north
	name = "Abandoned north of SS13"
	icon_state = "north"

/area/syndicate_station/south
	name = "Abandoned south of SS13"
	icon_state = "south"

/area/syndicate_station/commssat
	name = "Abandoned south of the communication satellite"
	icon_state = "south"

/area/syndicate_station/mining
	name = "Abandoned north east of the mining asteroid"
	icon_state = "north"

/area/syndicate_station/transit
	name = "Abandoned hyperspace"
	icon_state = "shuttle"

/area/wizard_station
	name = "Abandoned Wizard's Den"
	icon_state = "yellow"
	requires_power = 0

/area/vox_station/transit
	name = "Abandoned hyperspace"
	icon_state = "shuttle"
	requires_power = 0

/area/vox_station/southwest_solars
	name = "Abandoned aft port solars"
	icon_state = "southwest"
	requires_power = 0

/area/vox_station/northwest_solars
	name = "Abandoned fore port solars"
	icon_state = "northwest"
	requires_power = 0

/area/vox_station/northeast_solars
	name = "Abandoned fore starboard solars"
	icon_state = "northeast"
	requires_power = 0

/area/vox_station/southeast_solars
	name = "Abandoned aft starboard solars"
	icon_state = "southeast"
	requires_power = 0

/area/vox_station/mining
	name = "Abandoned nearby mining asteroid"
	icon_state = "north"
	requires_power = 0


//Maintenance

/area/maintenance/aft
	name = "Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/fore
	name = "Fore Maintenance"
	icon_state = "fmaint"

/area/maintenance/starboard
	name = "Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/port
	name = "Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/atmos_control
	name = "Atmospherics Maintenance"
	icon_state = "fpmaint"

/area/maintenance/fpmaint
	name = "Fore Port Maintenance - 1"
	icon_state = "fpmaint"

/area/maintenance/fpmaint2
	name = "Fore Port Maintenance - 2"
	icon_state = "fpmaint"

/area/maintenance/fsmaint
	name = "Fore Starboard Maintenance - 1"
	icon_state = "fsmaint"

/area/maintenance/fsmaint2
	name = "Fore Starboard Maintenance - 2"
	icon_state = "fsmaint"

/area/maintenance/asmaint
	name = "Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/maintenance/engi_shuttle
	name = "Engineering Shuttle Access"
	icon_state = "maint_e_shuttle"

/area/maintenance/engi_engine
	name = "Engine Maintenance"
	icon_state = "maint_engine"

/area/maintenance/asmaint2
	name = "Science Maintenance"
	icon_state = "asmaint"

/area/maintenance/apmaint
	name = "Cargo Maintenance"
	icon_state = "apmaint"

/area/maintenance/maintcentral
	name = "Bridge Maintenance"
	icon_state = "maintcentral"

/area/maintenance/arrivals
	name = "Arrivals Maintenance"
	icon_state = "maint_arrivals"

/area/maintenance/bar
	name = "Bar Maintenance"
	icon_state = "maint_bar"

/area/maintenance/cargo
	name = "Cargo Maintenance"
	icon_state = "maint_cargo"

/area/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/maintenance/engineering
	name = "Engineering Maintenance"
	icon_state = "maint_engineering"

/area/maintenance/evahallway
	name = "Abandoned EVA Maintenance"
	icon_state = "maint_eva"

/area/maintenance/dormitory
	name = "Dormitory Maintenance"
	icon_state = "maint_dormitory"

/area/maintenance/incinerator
	name = "Abandoned Incinerator"
	icon_state = "disposal"

/area/maintenance/locker
	name = "Locker Room Maintenance"
	icon_state = "maint_locker"

/area/maintenance/medbay
	name = "Medbay Maintenance"
	icon_state = "maint_medbay"

/area/maintenance/research_port
	name = "Port Research Maintenance"
	icon_state = "maint_research_port"

/area/maintenance/research_starboard
	name = "Starboard Research Maintenance"
	icon_state = "maint_research_starboard"

/area/maintenance/research_shuttle
	name = "Research Shuttle Dock Maintenance"
	icon_state = "maint_research_shuttle"

/area/maintenance/security_port
	name = "Port Security Maintenance"
	icon_state = "maint_security_port"

/area/maintenance/security_starboard
	name = "Starboard Security Maintenance"
	icon_state = "maint_security_starboard"

/area/maintenance/storage
	name = "Atmospherics"
	icon_state = "green"

// SUBSTATIONS (Subtype of maint, that should let them serve as shielded area during radstorm)


/area/maintenance/substation
	name = "Substation"
	icon_state = "substation"

/area/maintenance/substation/engineering // Probably will be connected to engineering SMES room, as wires cannot be crossed properly without them sharing powernets.
	name = "Engineering Substation"

/area/maintenance/substation/medical_science // Medbay and Science. Each has it's own separated machinery, but it originates from the same room.
	name = "Medical Research Substation"

/area/maintenance/substation/civilian_east // Bar, kitchen, dorms, ...
	name = "Civilian East Substation"

/area/maintenance/substation/civilian_west // Cargo, PTS, locker room, probably arrivals, ...)
	name = "Civilian West Substation"

/area/maintenance/substation/command // AI and central cluster. This one will be between HoP office and meeting room (probably).
	name = "Command Substation"

/area/maintenance/substation/security // Security, Brig, Permabrig, etc.
	name = "Security Substation"




//Hallway

/area/hallway/primary/fore
	name = "Abandoned Fore Primary Hallway"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "Abandoned Starboard Primary Hallway"
	icon_state = "hallS"

/area/hallway/primary/aft
	name = "Abandoned Aft Primary Hallway"
	icon_state = "hallA"

/area/hallway/primary/port
	name = "Abandoned Port Primary Hallway"
	icon_state = "hallP"

/area/hallway/primary/central_one
	name = "Abandoned Central Primary Hallway"
	icon_state = "hallC1"
	ambience = list('sound/ambience/signal.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg')

/area/hallway/primary/central_two
	name = "Abandoned Central Primary Hallway"
	icon_state = "hallC2"

/area/hallway/primary/central_three
	name = "Abandoned Central Primary Hallway"
	icon_state = "hallC3"

/area/hallway/secondary/exit
	name = "Abandoned Escape Shuttle Hallway"
	icon_state = "escape"

/area/hallway/secondary/construction
	name = "Abandoned Construction Area"
	icon_state = "construction"

/area/hallway/secondary/entry
	name = "Abandoned Arrival Shuttle Hallway"
	icon_state = "entry"

//Command

/area/bridge
	name = "Abandoned Bridge"
	icon_state = "bridge"

/area/bridge/meeting_room
	name = "Abandoned Heads of Staff Meeting Room"
	icon_state = "bridge"


/area/crew_quarters/captain
	name = "Abandoned Captain's Office"
	icon_state = "captain"

/area/crew_quarters/heads/hop
	name = "Abandoned Head of Personnel's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hor
	name = "Abandoned Research Director's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/chief
	name = "Abandoned Chief Engineer's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/hos
	name = "Abandoned Head of Security's Office"
	icon_state = "head_quarters"

/area/crew_quarters/heads/cmo
	name = "Abandoned Chief Medical Officer's Office"
	icon_state = "head_quarters"

/area/crew_quarters/courtroom
	name = "Abandoned Courtroom"
	icon_state = "courtroom"

/area/mint
	name = "Abandoned Mint"
	icon_state = "green"

/area/comms
	name = "Abandoned Communications Relay"
	icon_state = "tcomsatcham"

/area/server
	name = "Abandoned Messaging Server Room"
	icon_state = "server"

//Crew

/area/crew_quarters
	name = "Abandoned Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/toilet
	name = "Abandoned Dormitory Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep
	name = "Abandoned Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep/engi
	name = "Abandoned Engineering Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep/engi_wash
	name = "Abandoned Engineering Washroom"
	icon_state = "toilet"

/area/crew_quarters/sleep/sec
	name = "Abandoned Security Dormitories"
	icon_state = "Sleep"

/area/crew_quarters/sleep/bedrooms
	name = "Abandoned Dormitory Bedroom"
	icon_state = "Sleep"

/area/crew_quarters/sleep/cryo
	name = "Abandoned Cryogenic Storage"
	icon_state = "Sleep"

/area/crew_quarters/sleep_male
	name = "Abandoned Male Dorm"
	icon_state = "Sleep"
/*
/area/crew_quarters/sleep_male/toilet_male
	name = "Abandoned Male Toilets"
	icon_state = "toilet"

/area/crew_quarters/sleep_female
	name = "Abandoned Female Dorm"
	icon_state = "Sleep"

/area/crew_quarters/sleep_female/toilet_female
	name = "Abandoned Female Toilets"
	icon_state = "toilet"
*/
/area/crew_quarters/locker
	name = "Abandoned Locker Room"
	icon_state = "locker"

/area/crew_quarters/locker/locker_toilet
	name = "Abandoned Locker Toilets"
	icon_state = "toilet"

/area/crew_quarters/fitness
	name = "Abandoned Fitness Room"
	icon_state = "fitness"

/area/crew_quarters/cafeteria
	name = "Abandoned Cafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "Abandoned Kitchen"
	icon_state = "kitchen"

/area/crew_quarters/bar
	name = "Abandoned Bar"
	icon_state = "bar"

/area/crew_quarters/theatre
	name = "Abandoned Theatre"
	icon_state = "Theatre"

/area/library
	name = "Abandoned Library"
	icon_state = "library"

/area/chapel/main
	name = "Abandoned Chapel"
	icon_state = "chapel"
	ambience = list('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg')

/area/chapel/office
	name = "Abandoned Chapel Office"
	icon_state = "chapeloffice"

/area/lawoffice
	name = "Abandoned Internal Affairs"
	icon_state = "law"







/area/holodeck
	name = "Abandoned Holodeck"
	icon_state = "Holodeck"
	static_lighting = FALSE
	base_lighting_alpha = 255
	always_unpowered = TRUE

/area/holodeck/alphadeck
	name = "Abandoned Holodeck Alpha"

/area/holodeck/source_plating
	name = "Abandoned Holodeck - Off"
	icon_state = "Holodeck"

/area/holodeck/source_emptycourt
	name = "Abandoned Holodeck - Empty Court"

/area/holodeck/source_boxingcourt
	name = "Abandoned Holodeck - Boxing Court"

/area/holodeck/source_basketball
	name = "Abandoned Holodeck - Basketball Court"

/area/holodeck/source_thunderdomecourt
	name = "Abandoned Holodeck - Thunderdome Court"

/area/holodeck/source_beach
	name = "Abandoned Holodeck - Beach"
	icon_state = "Holodeck" // Lazy.

/area/holodeck/source_burntest
	name = "Abandoned Holodeck - Atmospheric Burn Test"

/area/holodeck/source_wildlife
	name = "Abandoned Holodeck - Wildlife Simulation"

/area/holodeck/source_meetinghall
	name = "Abandoned Holodeck - Meeting Hall"

/area/holodeck/source_theatre
	name = "Abandoned Holodeck - Theatre"

/area/holodeck/source_picnicarea
	name = "Abandoned Holodeck - Picnic Area"

/area/holodeck/source_snowfield
	name = "Abandoned Holodeck - Snow Field"

/area/holodeck/source_desert
	name = "Abandoned Holodeck - Desert"

/area/holodeck/source_space
	name = "Abandoned Holodeck - Space"


/area/maintenance/auxsolarport
	name = "Fore Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/starboardsolar
	name = "Aft Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/portsolar
	name = "Aft Port Solar Maintenance"
	icon_state = "SolarcontrolP"

/area/maintenance/auxsolarstarboard
	name = "Fore Starboard Solar Maintenance"
	icon_state = "SolarcontrolS"

/area/maintenance/foresolar
	name = "Fore Solar Maintenance"
	icon_state = "SolarcontrolA"

/area/assembly/chargebay
	name = "Abandoned Mech Bay"
	icon_state = "mechbay"

/area/assembly/showroom
	name = "Abandoned Robotics Showroom"
	icon_state = "showroom"

/area/assembly/robotics
	name = "Abandoned Robotics Lab"
	icon_state = "ass_line"

/area/assembly/assembly_line //Derelict Assembly Line
	name = "Abandoned Assembly Line"
	icon_state = "ass_line"
	power_equip = 0
	power_light = 0
	power_environ = 0

//Teleporter

/area/teleporter
	name = "Abandoned Teleporter"
	icon_state = "teleporter"


/area/gateway
	name = "Abandoned Gateway"
	icon_state = "teleporter"


/area/AIsattele
	name = "Abandoned AI Satellite Teleporter Room"
	icon_state = "teleporter"

	ambience = list('sound/ambience/ambimalf.ogg')

//MedBay
/area/medical
	minimap_color = MINIMAP_AREA_MEDBAY

/area/medical/medbay
	name = "Abandoned Medbay"
	icon_state = "medbay"


//Medbay is a large area, these additional areas help level out APC load.
/area/medical/medbay2
	name = "Abandoned Medbay"
	icon_state = "medbay2"


/area/medical/medbay3
	name = "Abandoned Medbay"
	icon_state = "medbay3"


/area/medical/biostorage
	name = "Abandoned Secondary Storage"
	icon_state = "medbay2"


/area/medical/reception
	name = "Abandoned Medbay Reception"
	icon_state = "medbay"


/area/medical/psych
	name = "Abandoned Psych Room"
	icon_state = "medbay3"


/area/crew_quarters/medbreak
	name = "Abandoned Break Room"
	icon_state = "medbay3"


/area/medical/patients_rooms
	name = "Abandoned Patient's Rooms"
	icon_state = "patients"

/area/medical/ward
	name = "Abandoned Recovery Ward"
	icon_state = "patients"

/area/medical/patient_a
	name = "Abandoned Isolation A"
	icon_state = "patients"

/area/medical/patient_b
	name = "Abandoned Isolation B"
	icon_state = "patients"

/area/medical/patient_c
	name = "Abandoned Isolation C"
	icon_state = "patients"

/area/medical/patient_wing
	name = "Abandoned Patient Wing"
	icon_state = "patients"

/area/medical/cmostore
	name = "Abandoned Secure Storage"
	icon_state = "CMO"

/area/medical/robotics
	name = "Abandoned Robotics"
	icon_state = "medresearch"

/area/medical/virology
	name = "Abandoned Virology"
	icon_state = "virology"

/area/medical/virologyaccess
	name = "Abandoned Virology Access"
	icon_state = "virology"

/area/medical/morgue
	name = "Abandoned Morgue"
	icon_state = "morgue"
	ambience = list('sound/ambience/ambimo1.ogg','sound/ambience/ambimo2.ogg')

/area/medical/chemistry
	name = "Abandoned Chemistry"
	icon_state = "chem"

/area/medical/surgery
	name = "Abandoned Operating Theatre 1"
	icon_state = "surgery"

/area/medical/surgery2
	name = "Abandoned Operating Theatre 2"
	icon_state = "surgery"

/area/medical/surgeryobs
	name = "Abandoned Operation Observation Room"
	icon_state = "surgery"

/area/medical/surgeryprep
	name = "Abandoned Pre-Op Prep Room"
	icon_state = "surgery"

/area/medical/cryo
	name = "Abandoned Cryogenics"
	icon_state = "cryo"

/area/medical/exam_room
	name = "Abandoned Exam Room"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Abandoned Genetics Lab"
	icon_state = "genetics"

/area/medical/genetics_cloning
	name = "Abandoned Cloning Lab"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Abandoned Emergency Treatment Centre"
	icon_state = "exam_room"

//Security
/area/security
	minimap_color = MINIMAP_AREA_SEC

/area/security/main
	name = "Abandoned Security Office"
	icon_state = "security"

/area/security/lobby
	name = "Abandoned Security lobby"
	icon_state = "security"

/area/security/brig
	name = "Abandoned Brig"
	icon_state = "brig"

/area/security/prison
	name = "Abandoned Prison Wing"
	icon_state = "sec_prison"


/area/security/warden
	name = "Abandoned Warden"
	icon_state = "Warden"

/area/security/armoury
	name = "Abandoned Armory"
	icon_state = "Warden"

/area/security/detectives_office
	name = "Abandoned Detective's Office"
	icon_state = "detective"

/area/security/range
	name = "Abandoned Firing Range"
	icon_state = "firingrange"

/area/security/tactical
	name = "Abandoned Tactical Equipment"
	icon_state = "Tactical"

/area/security/nuke_storage
	name = "Abandoned Vault"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "Abandoned Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint2
	name = "Abandoned Security Checkpoint"
	icon_state = "security"

/area/security/checkpoint/supply
	name = "Security Post - Cargo Bay"
	icon_state = "checkpoint1"

/area/security/checkpoint/engineering
	name = "Security Post - Engineering"
	icon_state = "checkpoint1"

/area/security/checkpoint/medical
	name = "Security Post - Medbay"
	icon_state = "checkpoint1"

/area/security/checkpoint/science
	name = "Security Post - Science"
	icon_state = "checkpoint1"

/area/security/vacantoffice
	name = "Abandoned Vacant Office"
	icon_state = "security"

/area/security/vacantoffice2
	name = "Abandoned Vacant Office"
	icon_state = "security"

/area/quartermaster
	name = "Abandoned Quartermasters"
	icon_state = "quart"

///////////WORK IN PROGRESS//////////

/area/quartermaster/sorting
	name = "Abandoned Delivery Office"
	icon_state = "quartstorage"

////////////WORK IN PROGRESS//////////

/area/quartermaster/office
	name = "Abandoned Cargo Office"
	icon_state = "quartoffice"

/area/quartermaster/storage
	name = "Abandoned Cargo Bay"
	icon_state = "quartstorage"

/area/quartermaster/qm
	name = "Abandoned Quartermaster's Office"
	icon_state = "quart"

/area/quartermaster/miningdock
	name = "Abandoned Mining Dock"
	icon_state = "mining"

/area/quartermaster/miningstorage
	name = "Abandoned Mining Storage"
	icon_state = "green"

/area/quartermaster/mechbay
	name = "Abandoned Mech Bay"
	icon_state = "yellow"

/area/janitor/
	name = "Abandoned Custodial Closet"
	icon_state = "janitor"

/area/hydroponics
	name = "Abandoned Hydroponics"
	icon_state = "hydro"

/area/hydroponics/garden
	name = "Abandoned Garden"
	icon_state = "garden"

//rnd (Research and Development
/area/rnd
	minimap_color = MINIMAP_AREA_RESEARCH

/area/rnd/research
	name = "Abandoned Research and Development"
	icon_state = "research"

/area/rnd/docking
	name = "Abandoned Research Dock"
	icon_state = "research_dock"

/area/rnd/lab
	name = "Abandoned Research Lab"
	icon_state = "toxlab"

/area/rnd/rdoffice
	name = "Abandoned Research Director's Office"
	icon_state = "head_quarters"

/area/rnd/supermatter
	name = "Abandoned Supermatter Lab"
	icon_state = "toxlab"

/area/rnd/xenobiology
	name = "Abandoned Xenobiology Lab"
	icon_state = "xeno_lab"

/area/rnd/xenobiology/xenoflora_storage
	name = "Abandoned Xenoflora Storage"
	icon_state = "xeno_f_store"

/area/rnd/xenobiology/xenoflora
	name = "Abandoned Xenoflora Lab"
	icon_state = "xeno_f_lab"

/area/rnd/storage
	name = "Abandoned Toxins Storage"
	icon_state = "toxstorage"

/area/rnd/test_area
	name = "Abandoned Toxins Test Area"
	icon_state = "toxtest"

/area/rnd/mixing
	name = "Abandoned Toxins Mixing Room"
	icon_state = "toxmix"

/area/rnd/misc_lab
	name = "Abandoned Miscellaneous Research"
	icon_state = "toxmisc"

/area/toxins/server
	name = "Abandoned Server Room"
	icon_state = "server"

//Storage

/area/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "storage"

/area/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/storage/autolathe
	name = "Autolathe Storage"
	icon_state = "storage"

/area/storage/art
	name = "Art Supply Storage"
	icon_state = "storage"

/area/storage/auxillary
	name = "Auxillary Storage"
	icon_state = "auxstorage"

/area/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/storage/emergency
	name = "Starboard Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency2
	name = "Port Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/emergency3
	name = "Central Emergency Storage"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Technical Storage"
	icon_state = "auxstorage"

/area/storage/testroom
	requires_power = 0
	name = "Abandoned Test Room"
	icon_state = "storage"
	flags_area = NO_DROPPOD


//DJSTATION

/area/djstation
	name = "Abandoned Listening Post"
	icon_state = "LP"

/area/djstation/solars
	name = "Abandoned Listening Post Solars"
	icon_state = "LPS"


//Construction

/area/construction
	name = "Abandoned Construction Area"
	icon_state = "yellow"

/area/construction/supplyshuttle
	name = "Abandoned Supply Shuttle"
	icon_state = "yellow"

/area/construction/quarters
	name = "Abandoned Engineer's Quarters"
	icon_state = "yellow"

/area/construction/qmaint
	name = "Maintenance"
	icon_state = "yellow"

/area/construction/hallway
	name = "Abandoned Hallway"
	icon_state = "yellow"

/area/construction/solars
	name = "Abandoned Solar Panels"
	icon_state = "yellow"

/area/construction/solarscontrol
	name = "Abandoned Solar Panel Control"
	icon_state = "yellow"

/area/construction/Storage
	name = "Construction Site Storage"
	icon_state = "yellow"

//AI

/area/ai_monitored/storage/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/ai_monitored/storage/secure
	name = "Secure Storage"
	icon_state = "storage"

/area/ai_monitored/storage/emergency
	name = "Emergency Storage"
	icon_state = "storage"

/area/turret_protected/ai_upload
	name = "Abandoned AI Upload Chamber"
	icon_state = "ai_upload"
	ambience = list('sound/ambience/ambimalf.ogg')

/area/turret_protected/ai_upload_foyer
	name = "AI Upload Access"
	icon_state = "ai_foyer"
	ambience = list('sound/ambience/ambimalf.ogg')

/area/turret_protected/ai_server_room
	name = "AI Server Room"
	icon_state = "ai_server"

/area/turret_protected/ai
	name = "Abandoned AI Chamber"
	icon_state = "ai_chamber"
	ambience = list('sound/ambience/ambimalf.ogg')

/area/turret_protected/ai_cyborg_station
	name = "Abandoned Cyborg Station"
	icon_state = "ai_cyborg"

/area/turret_protected/aisat
	name = "Abandoned AI Satellite"
	icon_state = "ai"

/area/sensor_tower_1
	name = "Sensor tower 1"
	icon_state = "sensor"

/area/sensor_tower_2
	name = "Sensor tower 2"
	icon_state = "sensor"
