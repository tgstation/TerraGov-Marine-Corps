//MARINE SHIP AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/mainship
	icon = 'icons/turf/area_mainship.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "mainship"
	ceiling = CEILING_METAL
	outside = 0

/area/mainship/command
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/command/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/mainship/command/cic
	name = "Combat Information Center"
	icon_state = "cic"


/area/mainship/command/airoom
	name = "AI Core"
	icon_state = "airoom"


/area/mainship/command/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"


/area/mainship/command/self_destruct
	name = "Self-Destruct Core Room"
	icon_state = "selfdestruct"
	minimap_color = MINIMAP_AREA_SEC_CAVE


/area/mainship/command/corporateliaison
	name = "Operations Officer Office"
	icon_state = "corporatespace"


/area/mainship/engineering
	minimap_color = MINIMAP_AREA_ENGI

/area/mainship/engineering/upper_engineering
	name = "Upper Engineering"
	icon_state = "upperengineering"


/area/mainship/engineering/ce_room
	name = "Chief Ship Engineer Office"
	icon_state = "ceroom"


/area/mainship/engineering/lower_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "lowermonitoring"


/area/mainship/engineering/upper_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "uppermonitoring"

/area/mainship/engineering/lower_engineering
	name = "Engineering Lower"
	icon_state = "lowerengineering"


/area/mainship/engineering/engineering_workshop
	name = "Engineering Workshop"
	icon_state = "workshop"


/area/mainship/engineering/engine_core
	name = "Engine Reactor Core Room"
	icon_state = "coreroom"


/area/mainship/engineering/starboard_atmos
	name = "Atmospherics Starboard"
	icon_state = "starboardatmos"

/area/mainship/engineering/port_atmos
	name = "Atmospherics Port"
	icon_state = "portatmos"


/area/mainship/shipboard
	minimap_color = MINIMAP_AREA_SEC

/area/mainship/shipboard/navigation
	name = "Astronavigational Deck"
	icon_state = "astronavigation"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/shipboard/starboard_missiles
	name = "Missile Tubes Starboard"
	icon_state = "starboardmissile"


/area/mainship/shipboard/port_missiles
	name = "Missile Tubes Port"
	icon_state = "portmissile"


/area/mainship/shipboard/weapon_room
	name = "Weapon Control Room"
	icon_state = "weaponroom"

/area/mainship/shipboard/starboard_point_defense
	name = "Point Defense Starboard"
	icon_state = "starboardpd"

/area/mainship/shipboard/port_point_defense
	name = "Point Defense Port"
	icon_state = "portpd"

/area/mainship/shipboard/brig
	name = "Brig"
	icon_state = "brig"

/area/mainship/shipboard/brig_cells
	name = "Brig Cells"
	icon_state = "brigcells"

/area/mainship/shipboard/chief_mp_office
	name = "Brig Command Master at Arms Office"
	icon_state = "chiefmpoffice"

/area/mainship/shipboard/ex_firing_range
	name = "Experimental Firing Range"
	icon_state = "firingrange"

/area/mainship/shipboard/firing_range
	name = "Firing Range"
	icon_state = "firingrange"


/area/mainship/shipboard/sensors
	name = "Sensor Room"
	icon_state = "sensor"

/area/mainship/hallways/hangar
	name = "Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/hallways/hangar2
	name = "Hangar 2"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/hallways/cargobay
	name = "Cargo Bay"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/command/fcroom
	name = "Field Commander's Office"
	icon_state = "hos_office"
	minimap_color = "#2d3fa2d0"

/area/mainship/hallways/hangar/flight_control
	name = "Flight Control"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/hallways/hangar/flight_observation
	name = "Flight Observation"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/living/tankerbunks
	name = "Vehicle Crew Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/living/mechpilotquarters
	name = "Mech Pilot Quarters"
	icon_state = "blueold"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/hallways/exoarmor
	name = "Vehicle Armor Storage"
	icon_state = "exoarmor"

/area/mainship/hallways/boxingring
	name = "Boxing Ring"
	icon_state = "livingspace"

/area/mainship/hallways/synthdorms
	name = "Synth Dormitories"
	icon_state = "livingspace"

/area/mainship/hallways/chapel
	name = "Chapel"
	icon_state = "chapel"

/area/mainship/hallways/workerprep
	name = "Worker Preperations"
	icon_state = "livingspace"

/area/mainship/nukeroom
	name = "Nuke Storage"
	icon_state = "Exoarmor"

/area/mainship/hallways/dorm1
	name = "Dormitories 1"
	icon_state = "livingspace"

/area/mainship/hallways/dorm2
	name = "Dormitories 2"
	icon_state = "livingspace"

/area/mainship/hallways/dorm3
	name = "Dormitories 3"
	icon_state = "livingspace"

/area/mainship/hallways/repair_bay
	name = "Vehicle Repair Bay"
	icon_state = "dropshiprepair"
	minimap_color = MINIMAP_AREA_ENGI

/area/mainship/hallways/mission_planner
	name = "Dropship Central Computer Room"
	icon_state = "missionplanner"

/area/mainship/hallways/starboard_umbilical
	name = "Umbilical Starboard"
	icon_state = "starboardumbilical"
	minimap_color = MINIMAP_AREA_CAVES


/area/mainship/hallways/port_umbilical
	name = "Umbilical Port"
	icon_state = "portumbilical"
	minimap_color = MINIMAP_AREA_CAVES


/area/mainship/hallways/aft_umbilical
	name = "Umbilical Aft"
	icon_state = "aft"
	minimap_color = MINIMAP_AREA_CAVES

/area/mainship/hallways/bow_hallway
	name = "Hallway Bow"
	icon_state = "bow"

/area/mainship/hallways/aft_hallway
	name = "Hallway Aft"
	icon_state = "aft"


/area/mainship/hallways/stern_hallway
	name = "Hallway Stern"
	icon_state = "stern"


/area/mainship/hallways/port_hallway
	name = "Hallway Port"
	icon_state = "port"


/area/mainship/hallways/starboard_hallway
	name = "Hallway Starboard"
	icon_state = "starboard"


/area/mainship/hallways/port_ert
	name = "Port ERT Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ


/area/mainship/hallways/starboard_ert
	name = "Starboard ERT Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ


/area/mainship/hull
	minimap_color = MINIMAP_AREA_CAVES

/area/mainship/hull/lower_hull
	name = "Hull Lower"
	icon_state = "lowerhull"


/area/mainship/hull/upper_hull
	name = "Hull Upper"
	icon_state = "upperhull"

/area/mainship/hull/port_hull
	name = "Hull Port"
	icon_state = "lowerhull"

/area/mainship/hull/starboard_hull
	name = "Hull Starboard"
	icon_state = "upperhull"

/area/mainship/living
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/living/cryo_cells
	name = "Cryo Cells"
	icon_state = "cryo"


/area/mainship/living/briefing
	name = "Briefing Area"
	icon_state = "briefing"


/area/mainship/living/port_emb
	name = "Extended Mission Bunks"
	icon_state = "portemb"


/area/mainship/living/starboard_emb
	name = "Extended Mission Bunks"
	icon_state = "starboardemb"

/area/mainship/living/port_garden
	name = "Garden"
	icon_state = "portemb"


/area/mainship/living/starboard_garden
	name = "Garden"
	icon_state = "starboardemb"

/area/mainship/living/basketball
	name = "Basketball Court"
	icon_state = "basketball"

/area/mainship/living/grunt_rnr
	name = "Lounge"
	icon_state = "gruntrnr"

/area/mainship/living/grunt_rnr/two

/area/mainship/living/officer_rnr
	name = "Officer's Lounge"
	icon_state = "officerrnr"
	//minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/living/officer_study
	name = "Officer's Study"
	icon_state = "officerstudy"
	//minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/living/cafeteria
	name = "Cafeteria"
	icon_state = "food"

/area/mainship/living/cafeteria_port
	name = "Cafeteria Port"
	icon_state = "food"

/area/mainship/living/cafeteria_starboard
	name = "Cafeteria Starboard"
	icon_state = "food"


/area/mainship/living/cafeteria_officer
	name = "Officer Cafeteria"
	icon_state = "food"

/area/mainship/living/offices
	name = "Pool Area"
	icon_state = "briefing"

/area/mainship/living/captain_mess
	name = "Captain's Mess"
	icon_state = "briefing"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/living/pilotbunks
	name = "Pilot's Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/living/bridgebunks
	name = "Staff Officer Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/living/commandbunks
	name = "Captain's Bunk"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/living/numbertwobunks
	name = "Executive Officer's Bunk"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/living/chapel
	name = "Chapel"
	icon_state = "officerrnr"

/area/mainship/medical
	name = "\improper Medical Bay"
	minimap_color = MINIMAP_AREA_MEDBAY
	icon_state = "medical"

/area/mainship/medical/lower_medical
	name = "Medical Lower"
	icon_state = "medical"


/area/mainship/medical/upper_medical
	name = "Medical Upper"
	icon_state = "medical"

/area/mainship/medical/operating_room_one
	name = "Medical Operating Room 1"
	icon_state = "operating"


/area/mainship/medical/operating_room_two
	name = "Medical Operating Room 2"
	icon_state = "operating"


/area/mainship/medical/operating_room_three
	name = "Medical Operating Room 3"
	icon_state = "operating"

/area/mainship/medical/operating_room_four
	name = "Medical Operating Room 4"
	icon_state = "operating"

/area/mainship/medical/medical_science
	name = "Medical Research laboratories"
	icon_state = "science"


/area/mainship/medical/chemistry
	name = "Medical Chemical laboratory"
	icon_state = "chemistry"


/area/mainship/medical/cryo_tubes
	name = "Medical Cryogenics Tubes"
	icon_state = "medical"

/area/mainship/medical/surgery_hallway
	name = "Medical Surgical Hallway"
	icon_state = "medical"

/area/mainship/medical/morgue
	name = "Morgue"
	icon_state = "medical"

/area/mainship/medical/cmo_office
	name = "CMO's Office"
	icon_state = "medical"

/area/mainship/squads
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/squads/alpha
	name = "Squad Alpha Preparation"
	icon_state = "alpha"

/area/mainship/squads/specialist
	name = "Specialist Preparation"
	icon_state = "delta"

/area/mainship/squads/bravo
	name = "Squad Bravo Preparation"
	icon_state = "bravo"

/area/mainship/squads/charlie
	name = "Squad Charlie Preparation"
	icon_state = "charlie"

/area/mainship/squads/delta
	name = "Squad Delta Preparation"
	icon_state = "delta"

/area/mainship/squads/general
	name = "Common Squads Preparation"
	icon_state = "req"


/area/mainship/squads/general/som

/area/mainship/squads/req
	name = "Requisitions"
	icon_state = "req"
	minimap_color = MINIMAP_AREA_REQ


/area/mainship/powered //for objects not intended to lose power
	name = "Powered"
	icon_state = "selfdestruct"
	requires_power = FALSE

/area/mainship/hallways/hangar/droppod
	name = "Drop Pod Bay"
	icon_state = "storage"

/area/mainship/living/evacuation
	name = "Evacuation"
	icon_state = "departures"
	minimap_color = MINIMAP_AREA_ESCAPE
	requires_power = FALSE

/area/mainship/living/evacuation/two //some ships have entirely separate evac areas

/area/mainship/living/evacuation/pod
	requires_power = FALSE

/area/mainship/living/evacuation/pod/one

/area/mainship/living/evacuation/pod/two

/area/mainship/living/evacuation/pod/three

/area/mainship/living/evacuation/pod/four

/area/mainship/medical/lounge
	name = "Medical Lounge"
	icon_state = "medical"

//combat patrol base

/area/mainship/patrol_base
	name = "NTC Combat Patrol Base"
	icon_state = "req"
	requires_power = FALSE

/area/mainship/patrol_base/hangar
	name = "NTC hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/patrol_base/command
	name = "NTC Bridge"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/patrol_base/prep
	name = "NTC Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/patrol_base/barracks
	name = "NTC Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/patrol_base/som
	name = "SOM Combat Patrol Base"

/area/mainship/patrol_base/som/hangar
	name = "SOM Main hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/patrol_base/som/command
	name = "SOM Command"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/patrol_base/som/prep
	name = "SOM Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/patrol_base/som/barracks
	name = "SOM Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/patrol_base/som/medical
	name = "SOM Medical bay"
	icon_state = "medical"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/mainship/patrol_base/som/equipment_bay
	name = "SOM Equipment bay"
	icon_state = "req"
	minimap_color = MINIMAP_AREA_REQ

/area/mainship/patrol_base/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"

/area/mainship/multiz_debug_area
	name = "Multi-Z Debugging"
	icon_state = "req"

/area/mainship/multiz_debug_area/floorone
	name = "Multi-Z Debugging Floor One"

/area/mainship/multiz_debug_area/floortwo
	name = "Multi-Z Debugging Floor Two"

/area/mainship/multiz_debug_area/floorthree
	name = "Multi-Z Debugging Floor Three"
//MARINE SHIP AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/mainship/groundhq/ntf
	icon = 'icons/turf/area_mainship.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "mainship"
	ceiling = CEILING_METAL

/area/mainship/groundhq/ntf/command
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/ntf/command/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/mainship/groundhq/ntf/command/cic
	name = "Combat Information Center"
	icon_state = "cic"


/area/mainship/groundhq/ntf/command/airoom
	name = "AI Core"
	icon_state = "airoom"


/area/mainship/groundhq/ntf/command/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"


/area/mainship/groundhq/ntf/command/self_destruct
	name = "Self-Destruct Core Room"
	icon_state = "selfdestruct"
	minimap_color = MINIMAP_AREA_SEC_CAVE


/area/mainship/groundhq/ntf/command/corporateliaison
	name = "Operations Officer Office"
	icon_state = "corporatespace"


/area/mainship/groundhq/ntf/engineering
	minimap_color = MINIMAP_AREA_ENGI

/area/mainship/groundhq/ntf/engineering/upper_engineering
	name = "Upper Engineering"
	icon_state = "upperengineering"


/area/mainship/groundhq/ntf/engineering/ce_room
	name = "Chief Ship Engineer Office"
	icon_state = "ceroom"


/area/mainship/groundhq/ntf/engineering/lower_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "lowermonitoring"


/area/mainship/groundhq/ntf/engineering/upper_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "uppermonitoring"

/area/mainship/groundhq/ntf/engineering/lower_engineering
	name = "Engineering Lower"
	icon_state = "lowerengineering"


/area/mainship/groundhq/ntf/engineering/engineering_workshop
	name = "Engineering Workshop"
	icon_state = "workshop"


/area/mainship/groundhq/ntf/engineering/engine_core
	name = "Engine Reactor Core Room"
	icon_state = "coreroom"


/area/mainship/groundhq/ntf/engineering/starboard_atmos
	name = "Atmospherics Starboard"
	icon_state = "starboardatmos"

/area/mainship/groundhq/ntf/engineering/port_atmos
	name = "Atmospherics Port"
	icon_state = "portatmos"


/area/mainship/groundhq/ntf/shipboard
	minimap_color = MINIMAP_AREA_SEC

/area/mainship/groundhq/ntf/shipboard/navigation
	name = "Astronavigational Deck"
	icon_state = "astronavigation"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/ntf/shipboard/starboard_missiles
	name = "Missile Tubes Starboard"
	icon_state = "starboardmissile"


/area/mainship/groundhq/ntf/shipboard/port_missiles
	name = "Missile Tubes Port"
	icon_state = "portmissile"


/area/mainship/groundhq/ntf/shipboard/weapon_room
	name = "Weapon Control Room"
	icon_state = "weaponroom"

/area/mainship/groundhq/ntf/shipboard/starboard_point_defense
	name = "Point Defense Starboard"
	icon_state = "starboardpd"

/area/mainship/groundhq/ntf/shipboard/port_point_defense
	name = "Point Defense Port"
	icon_state = "portpd"

/area/mainship/groundhq/ntf/shipboard/brig
	name = "Brig"
	icon_state = "brig"

/area/mainship/groundhq/ntf/shipboard/brig_cells
	name = "Brig Cells"
	icon_state = "brigcells"

/area/mainship/groundhq/ntf/shipboard/chief_mp_office
	name = "Brig Command Master at Arms Office"
	icon_state = "chiefmpoffice"

/area/mainship/groundhq/ntf/shipboard/ex_firing_range
	name = "Experimental Firing Range"
	icon_state = "firingrange"

/area/mainship/groundhq/ntf/shipboard/firing_range
	name = "Firing Range"
	icon_state = "firingrange"


/area/mainship/groundhq/ntf/shipboard/sensors
	name = "Sensor Room"
	icon_state = "sensor"

/area/mainship/groundhq/ntf/hallways/hangar
	name = "Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/ntf/hallways/hangar/flight_control
	name = "Flight Control"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/ntf/living/tankerbunks
	name = "Vehicle Crew Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/hallways/ntf/dorm1
	name = "Dormitories 1"
	icon_state = "livingspace"

/area/mainship/hallways/ntf/dorm2
	name = "Dormitories 2"
	icon_state = "livingspace"

/area/mainship/hallways/ntf/dorm3
	name = "Dormitories 3"
	icon_state = "livingspace"

/area/mainship/groundhq/ntf/hallways/exoarmor
	name = "Vehicle Armor Storage"
	icon_state = "exoarmor"

/area/mainship/groundhq/ntf/hallways/boxingring
	name = "Boxing Ring"
	icon_state = "livingspace"

/area/mainship/groundhq/ntf/hallways/repair_bay
	name = "Vehicle Repair Bay"
	icon_state = "dropshiprepair"
	minimap_color = MINIMAP_AREA_ENGI

/area/mainship/groundhq/ntf/hallways/mission_planner
	name = "Dropship Central Computer Room"
	icon_state = "missionplanner"

/area/mainship/groundhq/ntf/hallways/starboard_umbilical
	name = "Umbilical Starboard"
	icon_state = "starboardumbilical"
	minimap_color = MINIMAP_AREA_CAVES


/area/mainship/groundhq/ntf/hallways/port_umbilical
	name = "Umbilical Port"
	icon_state = "portumbilical"
	minimap_color = MINIMAP_AREA_CAVES


/area/mainship/groundhq/ntf/hallways/aft_umbilical
	name = "Umbilical Aft"
	icon_state = "aft"
	minimap_color = MINIMAP_AREA_CAVES

/area/mainship/groundhq/ntf/hallways/bow_hallway
	name = "Hallway Bow"
	icon_state = "bow"

/area/mainship/groundhq/ntf/hallways/aft_hallway
	name = "Hallway Aft"
	icon_state = "aft"


/area/mainship/groundhq/ntf/hallways/stern_hallway
	name = "Hallway Stern"
	icon_state = "stern"


/area/mainship/groundhq/ntf/hallways/port_hallway
	name = "Hallway Port"
	icon_state = "port"

/area/mainship/groundhq/ntf/hallways/bathroom
	name = "Bathroom"
	icon_state = "port"

/area/mainship/groundhq/ntf/hallways/starboard_hallway
	name = "Hallway Starboard"
	icon_state = "starboard"


/area/mainship/groundhq/ntf/hallways/port_ert
	name = "Port ERT Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ


/area/mainship/groundhq/ntf/hallways/starboard_ert
	name = "Starboard ERT Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/ntf/fcroom
	name = "Field Commander's Office"
	icon_state = "hos_office"
	minimap_color = "#2d3fa2d0"

/area/mainship/groundhq/ntf/hull
	minimap_color = MINIMAP_AREA_CAVES

/area/mainship/groundhq/ntf/hull/lower_hull
	name = "Hull Lower"
	icon_state = "lowerhull"


/area/mainship/groundhq/ntf/hull/upper_hull
	name = "Hull Upper"
	icon_state = "upperhull"

/area/mainship/groundhq/ntf/hull/port_hull
	name = "Hull Port"
	icon_state = "lowerhull"

/area/mainship/groundhq/ntf/hull/starboard_hull
	name = "Hull Starboard"
	icon_state = "upperhull"

/area/mainship/groundhq/ntf/living
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/hallways/hangar2
	name = "Hangar 2"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/hallways/cargobay
	name = "Cargo Bay"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/ntf/living/cryo_cells
	name = "Cryo Cells"
	icon_state = "cryo"


/area/mainship/groundhq/ntf/living/briefing
	name = "Briefing Area"
	icon_state = "briefing"


/area/mainship/groundhq/ntf/living/port_emb
	name = "Extended Mission Bunks"
	icon_state = "portemb"


/area/mainship/groundhq/ntf/living/starboard_emb
	name = "Extended Mission Bunks"
	icon_state = "starboardemb"

/area/mainship/groundhq/ntf/living/port_garden
	name = "Garden"
	icon_state = "portemb"


/area/mainship/groundhq/ntf/living/starboard_garden
	name = "Garden"
	icon_state = "starboardemb"

/area/mainship/groundhq/ntf/living/basketball
	name = "Basketball Court"
	icon_state = "basketball"

/area/mainship/groundhq/ntf/living/grunt_rnr
	name = "Lounge"
	icon_state = "gruntrnr"

/area/mainship/groundhq/ntf/living/grunt_rnr/two

/area/mainship/groundhq/ntf/living/officer_rnr
	name = "Officer's Lounge"
	icon_state = "officerrnr"
	//minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/ntf/living/officer_study
	name = "Officer's Study"
	icon_state = "officerstudy"
	//minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/ntf/living/cafeteria
	name = "Cafeteria"
	icon_state = "food"

/area/mainship/groundhq/ntf/living/cafeteria_port
	name = "Cafeteria Port"
	icon_state = "food"

/area/mainship/groundhq/ntf/living/cafeteria_starboard
	name = "Cafeteria Starboard"
	icon_state = "food"


/area/mainship/groundhq/ntf/living/cafeteria_officer
	name = "Officer Cafeteria"
	icon_state = "food"

/area/mainship/groundhq/ntf/living/offices
	name = "Pool Area"
	icon_state = "briefing"

/area/mainship/groundhq/ntf/living/captain_mess
	name = "Captain's Mess"
	icon_state = "briefing"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/ntf/living/pilotbunks
	name = "Pilot's Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/ntf/living/bridgebunks
	name = "Staff Officer Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/ntf/living/commandbunks
	name = "Captain's Bunk"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/ntf/living/numbertwobunks
	name = "Executive Officer's Bunk"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/ntf/living/chapel
	name = "Chapel"
	icon_state = "officerrnr"

/area/mainship/groundhq/ntf/medical
	minimap_color = MINIMAP_AREA_MEDBAY

/area/mainship/groundhq/ntf/medical/lower_medical
	name = "Medical Lower"
	icon_state = "medical"


/area/mainship/groundhq/ntf/medical/upper_medical
	name = "Medical Upper"
	icon_state = "medical"

/area/mainship/groundhq/ntf/medical/operating_room_one
	name = "Medical Operating Room 1"
	icon_state = "operating"


/area/mainship/groundhq/ntf/medical/operating_room_two
	name = "Medical Operating Room 2"
	icon_state = "operating"


/area/mainship/groundhq/ntf/medical/operating_room_three
	name = "Medical Operating Room 3"
	icon_state = "operating"

/area/mainship/groundhq/ntf/medical/operating_room_four
	name = "Medical Operating Room 4"
	icon_state = "operating"

/area/mainship/groundhq/ntf/medical/medical_science
	name = "Medical Research laboratories"
	icon_state = "science"


/area/mainship/groundhq/ntf/medical/chemistry
	name = "Medical Chemical laboratory"
	icon_state = "chemistry"


/area/mainship/groundhq/ntf/medical/cryo_tubes
	name = "Medical Cryogenics Tubes"
	icon_state = "medical"

/area/mainship/groundhq/ntf/medical/surgery_hallway
	name = "Medical Surgical Hallway"
	icon_state = "medical"

/area/mainship/groundhq/ntf/medical/morgue
	name = "Morgue"
	icon_state = "medical"

/area/mainship/groundhq/ntf/medical/cmo_office
	name = "CMO's Office"
	icon_state = "medical"

/area/mainship/groundhq/ntf/squads
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/ntf/squads/alpha
	name = "Squad Alpha Preparation"
	icon_state = "alpha"

/area/mainship/groundhq/ntf/squads/bravo
	name = "Squad Bravo Preparation"
	icon_state = "bravo"

/area/mainship/groundhq/ntf/squads/charlie
	name = "Squad Charlie Preparation"
	icon_state = "charlie"

/area/mainship/groundhq/ntf/squads/delta
	name = "Squad Delta Preparation"
	icon_state = "delta"

/area/mainship/groundhq/ntf/squads/general
	name = "Common Squads Preparation"
	icon_state = "req"


/area/mainship/groundhq/ntf/squads/general/som

/area/mainship/groundhq/ntf/squads/req
	name = "Requisitions"
	icon_state = "req"
	minimap_color = MINIMAP_AREA_REQ


/area/mainship/groundhq/ntf/powered //for objects not intended to lose power
	name = "Powered"
	icon_state = "selfdestruct"
	requires_power = FALSE

/area/mainship/groundhq/ntf/hallways/hangar/droppod
	name = "Drop Pod Bay"
	icon_state = "storage"

/area/mainship/groundhq/ntf/living/evacuation
	name = "Evacuation"
	icon_state = "departures"
	minimap_color = MINIMAP_AREA_ESCAPE
	requires_power = FALSE

/area/mainship/groundhq/ntf/living/evacuation/two //some ships have entirely separate evac areas

/area/mainship/groundhq/ntf/living/evacuation/pod
	requires_power = FALSE

/area/mainship/groundhq/ntf/living/evacuation/pod/one

/area/mainship/groundhq/ntf/living/evacuation/pod/two

/area/mainship/groundhq/ntf/living/evacuation/pod/three

/area/mainship/groundhq/ntf/living/evacuation/pod/four

/area/mainship/groundhq/ntf/medical/lounge
	name = "Medical Lounge"
	icon_state = "medical"

//combat patrol base

/area/mainship/groundhq/ntf/patrol_base
	name = "NTC Combat Patrol Base"
	icon_state = "req"
	requires_power = FALSE

/area/mainship/groundhq/ntf/patrol_base/hangar
	name = "NTC hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/ntf/patrol_base/command
	name = "NTC Bridge"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/ntf/patrol_base/prep
	name = "NTC Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/ntf/patrol_base/barracks
	name = "NTC Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/groundhq/ntf/patrol_base/som
	name = "SOM Combat Patrol Base"

/area/mainship/groundhq/ntf/patrol_base/ntf/hangar
	name = "SOM Main hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/ntf/patrol_base/ntf/command
	name = "SOM Command"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/ntf/patrol_base/ntf/prep
	name = "SOM Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/ntf/patrol_base/ntf/barracks
	name = "SOM Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/groundhq/ntf/patrol_base/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"

//MARINE SHIP AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/mainship/groundhq/som
	icon = 'icons/turf/area_mainship.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "mainship"
	ceiling = CEILING_METAL

/area/mainship/groundhq/som/command
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/som/command/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/mainship/groundhq/som/command/cic
	name = "Combat Information Center"
	icon_state = "cic"


/area/mainship/groundhq/som/command/airoom
	name = "AI Core"
	icon_state = "airoom"


/area/mainship/groundhq/som/command/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"


/area/mainship/groundhq/som/command/self_destruct
	name = "Self-Destruct Core Room"
	icon_state = "selfdestruct"
	minimap_color = MINIMAP_AREA_SEC_CAVE


/area/mainship/groundhq/som/command/corporateliaison
	name = "Operations Officer Office"
	icon_state = "corporatespace"


/area/mainship/groundhq/som/engineering
	minimap_color = MINIMAP_AREA_ENGI

/area/mainship/groundhq/som/engineering/upper_engineering
	name = "Upper Engineering"
	icon_state = "upperengineering"


/area/mainship/groundhq/som/engineering/ce_room
	name = "Chief Ship Engineer Office"
	icon_state = "ceroom"


/area/mainship/groundhq/som/engineering/lower_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "lowermonitoring"


/area/mainship/groundhq/som/engineering/upper_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "uppermonitoring"

/area/mainship/groundhq/som/engineering/lower_engineering
	name = "Engineering Lower"
	icon_state = "lowerengineering"


/area/mainship/groundhq/som/engineering/engineering_workshop
	name = "Engineering Workshop"
	icon_state = "workshop"


/area/mainship/groundhq/som/engineering/engine_core
	name = "Engine Reactor Core Room"
	icon_state = "coreroom"


/area/mainship/groundhq/som/engineering/starboard_atmos
	name = "Atmospherics Starboard"
	icon_state = "starboardatmos"

/area/mainship/groundhq/som/engineering/port_atmos
	name = "Atmospherics Port"
	icon_state = "portatmos"


/area/mainship/groundhq/som/shipboard
	minimap_color = MINIMAP_AREA_SEC

/area/mainship/groundhq/som/shipboard/navigation
	name = "Astronavigational Deck"
	icon_state = "astronavigation"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/som/shipboard/starboard_missiles
	name = "Missile Tubes Starboard"
	icon_state = "starboardmissile"


/area/mainship/groundhq/som/shipboard/port_missiles
	name = "Missile Tubes Port"
	icon_state = "portmissile"


/area/mainship/groundhq/som/shipboard/weapon_room
	name = "Weapon Control Room"
	icon_state = "weaponroom"

/area/mainship/groundhq/som/shipboard/starboard_point_defense
	name = "Point Defense Starboard"
	icon_state = "starboardpd"

/area/mainship/groundhq/som/shipboard/port_point_defense
	name = "Point Defense Port"
	icon_state = "portpd"

/area/mainship/groundhq/som/shipboard/brig
	name = "Brig"
	icon_state = "brig"

/area/mainship/groundhq/som/shipboard/brig_cells
	name = "Brig Cells"
	icon_state = "brigcells"

/area/mainship/groundhq/som/shipboard/chief_mp_office
	name = "Brig Command Master at Arms Office"
	icon_state = "chiefmpoffice"

/area/mainship/groundhq/som/shipboard/ex_firing_range
	name = "Experimental Firing Range"
	icon_state = "firingrange"

/area/mainship/groundhq/som/shipboard/firing_range
	name = "Firing Range"
	icon_state = "firingrange"


/area/mainship/groundhq/som/shipboard/sensors
	name = "Sensor Room"
	icon_state = "sensor"

/area/mainship/groundhq/som/hallways/hangar
	name = "Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/som/hallways/hangar/flight_control
	name = "Flight Control"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/som/living/tankerbunks
	name = "Vehicle Crew Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/som/hallways/exoarmor
	name = "Vehicle Armor Storage"
	icon_state = "exoarmor"

/area/mainship/groundhq/som/hallways/boxingring
	name = "Boxing Ring"
	icon_state = "livingspace"

/area/mainship/groundhq/som/hallways/repair_bay
	name = "Vehicle Repair Bay"
	icon_state = "dropshiprepair"
	minimap_color = MINIMAP_AREA_ENGI

/area/mainship/groundhq/som/hallways/mission_planner
	name = "Dropship Central Computer Room"
	icon_state = "missionplanner"

/area/mainship/groundhq/som/hallways/starboard_umbilical
	name = "Umbilical Starboard"
	icon_state = "starboardumbilical"
	minimap_color = MINIMAP_AREA_CAVES


/area/mainship/groundhq/som/hallways/port_umbilical
	name = "Umbilical Port"
	icon_state = "portumbilical"
	minimap_color = MINIMAP_AREA_CAVES


/area/mainship/groundhq/som/hallways/aft_umbilical
	name = "Umbilical Aft"
	icon_state = "aft"
	minimap_color = MINIMAP_AREA_CAVES

/area/mainship/groundhq/som/hallways/bow_hallway
	name = "Hallway Bow"
	icon_state = "bow"

/area/mainship/groundhq/som/hallways/aft_hallway
	name = "Hallway Aft"
	icon_state = "aft"


/area/mainship/groundhq/som/hallways/stern_hallway
	name = "Hallway Stern"
	icon_state = "stern"


/area/mainship/groundhq/som/hallways/port_hallway
	name = "Hallway Port"
	icon_state = "port"


/area/mainship/groundhq/som/hallways/starboard_hallway
	name = "Hallway Starboard"
	icon_state = "starboard"


/area/mainship/groundhq/som/hallways/port_ert
	name = "Port ERT Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ


/area/mainship/groundhq/som/hallways/starboard_ert
	name = "Starboard ERT Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ


/area/mainship/groundhq/som/hull
	minimap_color = MINIMAP_AREA_CAVES

/area/mainship/groundhq/som/hull/lower_hull
	name = "Hull Lower"
	icon_state = "lowerhull"


/area/mainship/groundhq/som/hull/upper_hull
	name = "Hull Upper"
	icon_state = "upperhull"

/area/mainship/groundhq/som/hull/port_hull
	name = "Hull Port"
	icon_state = "lowerhull"

/area/mainship/groundhq/som/hull/starboard_hull
	name = "Hull Starboard"
	icon_state = "upperhull"

/area/mainship/groundhq/som/living
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/groundhq/som/living/cryo_cells
	name = "Cryo Cells"
	icon_state = "cryo"


/area/mainship/groundhq/som/living/briefing
	name = "Briefing Area"
	icon_state = "briefing"


/area/mainship/groundhq/som/living/port_emb
	name = "Extended Mission Bunks"
	icon_state = "portemb"


/area/mainship/groundhq/som/living/starboard_emb
	name = "Extended Mission Bunks"
	icon_state = "starboardemb"

/area/mainship/groundhq/som/living/port_garden
	name = "Garden"
	icon_state = "portemb"


/area/mainship/groundhq/som/living/starboard_garden
	name = "Garden"
	icon_state = "starboardemb"

/area/mainship/groundhq/som/living/basketball
	name = "Basketball Court"
	icon_state = "basketball"

/area/mainship/groundhq/som/living/grunt_rnr
	name = "Lounge"
	icon_state = "gruntrnr"

/area/mainship/groundhq/som/living/grunt_rnr/two

/area/mainship/groundhq/som/living/officer_rnr
	name = "Officer's Lounge"
	icon_state = "officerrnr"
	//minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/som/living/officer_study
	name = "Officer's Study"
	icon_state = "officerstudy"
	//minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/som/living/cafeteria
	name = "Cafeteria"
	icon_state = "food"

/area/mainship/groundhq/som/living/cafeteria_port
	name = "Cafeteria Port"
	icon_state = "food"

/area/mainship/groundhq/som/living/cafeteria_starboard
	name = "Cafeteria Starboard"
	icon_state = "food"


/area/mainship/groundhq/som/living/cafeteria_officer
	name = "Officer Cafeteria"
	icon_state = "food"

/area/mainship/groundhq/som/living/offices
	name = "Pool Area"
	icon_state = "briefing"

/area/mainship/groundhq/som/living/captain_mess
	name = "Captain's Mess"
	icon_state = "briefing"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/som/living/pilotbunks
	name = "Pilot's Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/som/living/bridgebunks
	name = "Staff Officer Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/som/living/commandbunks
	name = "Captain's Bunk"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/som/living/numbertwobunks
	name = "Executive Officer's Bunk"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/som/living/chapel
	name = "Chapel"
	icon_state = "officerrnr"

/area/mainship/groundhq/som/medical
	minimap_color = MINIMAP_AREA_MEDBAY

/area/mainship/groundhq/som/medical/lower_medical
	name = "Medical Lower"
	icon_state = "medical"


/area/mainship/groundhq/som/medical/upper_medical
	name = "Medical Upper"
	icon_state = "medical"

/area/mainship/groundhq/som/medical/operating_room_one
	name = "Medical Operating Room 1"
	icon_state = "operating"


/area/mainship/groundhq/som/medical/operating_room_two
	name = "Medical Operating Room 2"
	icon_state = "operating"


/area/mainship/groundhq/som/medical/operating_room_three
	name = "Medical Operating Room 3"
	icon_state = "operating"

/area/mainship/groundhq/som/medical/operating_room_four
	name = "Medical Operating Room 4"
	icon_state = "operating"

/area/mainship/groundhq/som/medical/medical_science
	name = "Medical Research laboratories"
	icon_state = "science"


/area/mainship/groundhq/som/medical/chemistry
	name = "Medical Chemical laboratory"
	icon_state = "chemistry"


/area/mainship/groundhq/som/medical/cryo_tubes
	name = "Medical Cryogenics Tubes"
	icon_state = "medical"

/area/mainship/groundhq/som/medical/surgery_hallway
	name = "Medical Surgical Hallway"
	icon_state = "medical"

/area/mainship/groundhq/som/medical/morgue
	name = "Morgue"
	icon_state = "medical"

/area/mainship/groundhq/som/medical/cmo_office
	name = "CMO's Office"
	icon_state = "medical"

/area/mainship/groundhq/som/squads
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/som/squads/alpha
	name = "Squad Alpha Preparation"
	icon_state = "alpha"

/area/mainship/groundhq/som/hallways/bathroom
	name = "Bathroom"
	icon_state = "port"

/area/mainship/groundhq/som/squads/bravo
	name = "Squad Bravo Preparation"
	icon_state = "bravo"

/area/mainship/groundhq/som/squads/charlie
	name = "Squad Charlie Preparation"
	icon_state = "charlie"

/area/mainship/groundhq/som/squads/delta
	name = "Squad Delta Preparation"
	icon_state = "delta"

/area/mainship/groundhq/som/squads/general
	name = "Common Squads Preparation"
	icon_state = "req"


/area/mainship/groundhq/som/squads/general/som

/area/mainship/groundhq/som/squads/req
	name = "Requisitions"
	icon_state = "req"
	minimap_color = MINIMAP_AREA_REQ


/area/mainship/groundhq/som/powered //for objects not intended to lose power
	name = "Powered"
	icon_state = "selfdestruct"
	requires_power = FALSE

/area/mainship/groundhq/som/hallways/hangar/droppod
	name = "Drop Pod Bay"
	icon_state = "storage"

/area/mainship/groundhq/som/living/evacuation
	name = "Evacuation"
	icon_state = "departures"
	minimap_color = MINIMAP_AREA_ESCAPE
	requires_power = FALSE

/area/mainship/groundhq/som/living/evacuation/two //some ships have entirely separate evac areas

/area/mainship/groundhq/som/living/evacuation/pod
	requires_power = FALSE

/area/mainship/groundhq/som/living/evacuation/pod/one

/area/mainship/groundhq/som/living/evacuation/pod/two

/area/mainship/groundhq/som/living/evacuation/pod/three

/area/mainship/groundhq/som/living/evacuation/pod/four

/area/mainship/groundhq/som/medical/lounge
	name = "Medical Lounge"
	icon_state = "medical"

//combat patrol base

/area/mainship/groundhq/som/patrol_base
	name = "NTC Combat Patrol Base"
	icon_state = "req"
	requires_power = FALSE

/area/mainship/groundhq/som/patrol_base/hangar
	name = "NTC hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/som/patrol_base/command
	name = "NTC Bridge"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/som/patrol_base/prep
	name = "NTC Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/som/patrol_base/barracks
	name = "NTC Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/groundhq/som/patrol_base/som
	name = "SOM Combat Patrol Base"

/area/mainship/groundhq/som/patrol_base/som/hangar
	name = "SOM Main hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/som/patrol_base/som/command
	name = "SOM Command"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/som/patrol_base/som/prep
	name = "SOM Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/som/patrol_base/som/barracks
	name = "SOM Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/groundhq/som/patrol_base/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"

//MARINE SHIP AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/mainship/groundhq/clf
	icon = 'icons/turf/area_mainship.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "mainship"
	ceiling = CEILING_METAL

/area/mainship/groundhq/clf/command
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/clf/command/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/mainship/groundhq/clf/command/cic
	name = "Combat Information Center"
	icon_state = "cic"


/area/mainship/groundhq/clf/command/airoom
	name = "AI Core"
	icon_state = "airoom"


/area/mainship/groundhq/clf/command/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"


/area/mainship/groundhq/clf/command/self_destruct
	name = "Self-Destruct Core Room"
	icon_state = "selfdestruct"
	minimap_color = MINIMAP_AREA_SEC_CAVE


/area/mainship/groundhq/clf/command/corporateliaison
	name = "Operations Officer Office"
	icon_state = "corporatespace"


/area/mainship/groundhq/clf/engineering
	minimap_color = MINIMAP_AREA_ENGI

/area/mainship/groundhq/clf/engineering/upper_engineering
	name = "Upper Engineering"
	icon_state = "upperengineering"


/area/mainship/groundhq/clf/engineering/ce_room
	name = "Chief Ship Engineer Office"
	icon_state = "ceroom"


/area/mainship/groundhq/clf/engineering/lower_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "lowermonitoring"


/area/mainship/groundhq/clf/engineering/upper_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "uppermonitoring"

/area/mainship/groundhq/clf/engineering/lower_engineering
	name = "Engineering Lower"
	icon_state = "lowerengineering"


/area/mainship/groundhq/clf/engineering/engineering_workshop
	name = "Engineering Workshop"
	icon_state = "workshop"


/area/mainship/groundhq/clf/engineering/engine_core
	name = "Engine Reactor Core Room"
	icon_state = "coreroom"


/area/mainship/groundhq/clf/engineering/starboard_atmos
	name = "Atmospherics Starboard"
	icon_state = "starboardatmos"

/area/mainship/groundhq/clf/engineering/port_atmos
	name = "Atmospherics Port"
	icon_state = "portatmos"


/area/mainship/groundhq/clf/shipboard
	minimap_color = MINIMAP_AREA_SEC

/area/mainship/groundhq/clf/shipboard/navigation
	name = "Astronavigational Deck"
	icon_state = "astronavigation"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/clf/shipboard/starboard_missiles
	name = "Missile Tubes Starboard"
	icon_state = "starboardmissile"


/area/mainship/groundhq/clf/shipboard/port_missiles
	name = "Missile Tubes Port"
	icon_state = "portmissile"


/area/mainship/groundhq/clf/shipboard/weapon_room
	name = "Weapon Control Room"
	icon_state = "weaponroom"

/area/mainship/groundhq/clf/shipboard/starboard_point_defense
	name = "Point Defense Starboard"
	icon_state = "starboardpd"

/area/mainship/groundhq/clf/shipboard/port_point_defense
	name = "Point Defense Port"
	icon_state = "portpd"

/area/mainship/groundhq/clf/shipboard/brig
	name = "Brig"
	icon_state = "brig"

/area/mainship/groundhq/clf/shipboard/brig_cells
	name = "Brig Cells"
	icon_state = "brigcells"

/area/mainship/groundhq/clf/shipboard/chief_mp_office
	name = "Brig Command Master at Arms Office"
	icon_state = "chiefmpoffice"

/area/mainship/groundhq/clf/shipboard/ex_firing_range
	name = "Experimental Firing Range"
	icon_state = "firingrange"

/area/mainship/groundhq/clf/shipboard/firing_range
	name = "Firing Range"
	icon_state = "firingrange"


/area/mainship/groundhq/clf/shipboard/sensors
	name = "Sensor Room"
	icon_state = "sensor"

/area/mainship/groundhq/clf/hallways/hangar
	name = "Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/clf/hallways/hangar/flight_control
	name = "Flight Control"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/clf/living/tankerbunks
	name = "Vehicle Crew Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/hallways/clf/dorm1
	name = "Dormitories 1"
	icon_state = "livingspace"

/area/mainship/hallways/clf/dorm2
	name = "Dormitories 2"
	icon_state = "livingspace"

/area/mainship/hallways/clf/dorm3
	name = "Dormitories 3"
	icon_state = "livingspace"


/area/mainship/groundhq/clf/hallways/exoarmor
	name = "Vehicle Armor Storage"
	icon_state = "exoarmor"

/area/mainship/groundhq/clf/hallways/boxingring
	name = "Boxing Ring"
	icon_state = "livingspace"

/area/mainship/groundhq/clf/hallways/repair_bay
	name = "Vehicle Repair Bay"
	icon_state = "dropshiprepair"
	minimap_color = MINIMAP_AREA_ENGI

/area/mainship/groundhq/clf/hallways/mission_planner
	name = "Dropship Central Computer Room"
	icon_state = "missionplanner"

/area/mainship/groundhq/clf/hallways/starboard_umbilical
	name = "Umbilical Starboard"
	icon_state = "starboardumbilical"
	minimap_color = MINIMAP_AREA_CAVES


/area/mainship/groundhq/clf/hallways/port_umbilical
	name = "Umbilical Port"
	icon_state = "portumbilical"
	minimap_color = MINIMAP_AREA_CAVES


/area/mainship/groundhq/clf/hallways/aft_umbilical
	name = "Umbilical Aft"
	icon_state = "aft"
	minimap_color = MINIMAP_AREA_CAVES

/area/mainship/groundhq/clf/hallways/bow_hallway
	name = "Hallway Bow"
	icon_state = "bow"

/area/mainship/groundhq/clf/hallways/aft_hallway
	name = "Hallway Aft"
	icon_state = "aft"


/area/mainship/groundhq/clf/hallways/stern_hallway
	name = "Hallway Stern"
	icon_state = "stern"


/area/mainship/groundhq/clf/hallways/port_hallway
	name = "Hallway Port"
	icon_state = "port"


/area/mainship/groundhq/clf/hallways/starboard_hallway
	name = "Hallway Starboard"
	icon_state = "starboard"


/area/mainship/groundhq/clf/hallways/port_ert
	name = "Port ERT Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ


/area/mainship/groundhq/clf/hallways/starboard_ert
	name = "Starboard ERT Hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ


/area/mainship/groundhq/clf/hull
	minimap_color = MINIMAP_AREA_CAVES

/area/mainship/groundhq/clf/hull/lower_hull
	name = "Hull Lower"
	icon_state = "lowerhull"


/area/mainship/groundhq/clf/hull/upper_hull
	name = "Hull Upper"
	icon_state = "upperhull"

/area/mainship/groundhq/clf/hull/port_hull
	name = "Hull Port"
	icon_state = "lowerhull"

/area/mainship/groundhq/clf/hull/starboard_hull
	name = "Hull Starboard"
	icon_state = "upperhull"

/area/mainship/groundhq/clf/living
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/groundhq/clf/living/cryo_cells
	name = "Cryo Cells"
	icon_state = "cryo"


/area/mainship/groundhq/clf/living/briefing
	name = "Briefing Area"
	icon_state = "briefing"


/area/mainship/groundhq/clf/living/port_emb
	name = "Extended Mission Bunks"
	icon_state = "portemb"


/area/mainship/groundhq/clf/living/starboard_emb
	name = "Extended Mission Bunks"
	icon_state = "starboardemb"

/area/mainship/groundhq/clf/living/port_garden
	name = "Garden"
	icon_state = "portemb"


/area/mainship/groundhq/clf/living/starboard_garden
	name = "Garden"
	icon_state = "starboardemb"

/area/mainship/groundhq/clf/living/basketball
	name = "Basketball Court"
	icon_state = "basketball"

/area/mainship/groundhq/clf/living/grunt_rnr
	name = "Lounge"
	icon_state = "gruntrnr"

/area/mainship/groundhq/clf/living/grunt_rnr/two

/area/mainship/groundhq/clf/living/officer_rnr
	name = "Officer's Lounge"
	icon_state = "officerrnr"
	//minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/clf/living/officer_study
	name = "Officer's Study"
	icon_state = "officerstudy"
	//minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/clf/living/cafeteria
	name = "Cafeteria"
	icon_state = "food"

/area/mainship/groundhq/clf/living/cafeteria_port
	name = "Cafeteria Port"
	icon_state = "food"

/area/mainship/groundhq/clf/living/cafeteria_starboard
	name = "Cafeteria Starboard"
	icon_state = "food"


/area/mainship/groundhq/clf/living/cafeteria_officer
	name = "Officer Cafeteria"
	icon_state = "food"

/area/mainship/groundhq/clf/living/offices
	name = "Pool Area"
	icon_state = "briefing"

/area/mainship/groundhq/clf/living/captain_mess
	name = "Captain's Mess"
	icon_state = "briefing"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/clf/living/pilotbunks
	name = "Pilot's Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/clf/living/bridgebunks
	name = "Staff Officer Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/clf/living/commandbunks
	name = "Captain's Bunk"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/clf/living/numbertwobunks
	name = "Executive Officer's Bunk"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/groundhq/clf/living/chapel
	name = "Chapel"
	icon_state = "officerrnr"

/area/mainship/groundhq/clf/medical
	minimap_color = MINIMAP_AREA_MEDBAY

/area/mainship/groundhq/clf/medical/lower_medical
	name = "Medical Lower"
	icon_state = "medical"


/area/mainship/groundhq/clf/medical/upper_medical
	name = "Medical Upper"
	icon_state = "medical"

/area/mainship/groundhq/clf/medical/operating_room_one
	name = "Medical Operating Room 1"
	icon_state = "operating"


/area/mainship/groundhq/clf/medical/operating_room_two
	name = "Medical Operating Room 2"
	icon_state = "operating"


/area/mainship/groundhq/clf/medical/operating_room_three
	name = "Medical Operating Room 3"
	icon_state = "operating"

/area/mainship/groundhq/clf/medical/operating_room_four
	name = "Medical Operating Room 4"
	icon_state = "operating"

/area/mainship/groundhq/clf/medical/medical_science
	name = "Medical Research laboratories"
	icon_state = "science"


/area/mainship/groundhq/clf/medical/chemistry
	name = "Medical Chemical laboratory"
	icon_state = "chemistry"


/area/mainship/groundhq/clf/medical/cryo_tubes
	name = "Medical Cryogenics Tubes"
	icon_state = "medical"

/area/mainship/groundhq/clf/medical/surgery_hallway
	name = "Medical Surgical Hallway"
	icon_state = "medical"

/area/mainship/groundhq/clf/medical/morgue
	name = "Morgue"
	icon_state = "medical"

/area/mainship/groundhq/clf/medical/cmo_office
	name = "CMO's Office"
	icon_state = "medical"

/area/mainship/groundhq/clf/squads
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/clf/squads/alpha
	name = "Squad Alpha Preparation"
	icon_state = "alpha"

/area/mainship/groundhq/clf/squads/bravo
	name = "Squad Bravo Preparation"
	icon_state = "bravo"

/area/mainship/groundhq/clf/squads/charlie
	name = "Squad Charlie Preparation"
	icon_state = "charlie"

/area/mainship/groundhq/clf/squads/delta
	name = "Squad Delta Preparation"
	icon_state = "delta"

/area/mainship/groundhq/clf/squads/general
	name = "Common Squads Preparation"
	icon_state = "req"


/area/mainship/groundhq/clf/squads/general/som

/area/mainship/groundhq/clf/squads/req
	name = "Requisitions"
	icon_state = "req"
	minimap_color = MINIMAP_AREA_REQ


/area/mainship/groundhq/clf/powered //for objects not intended to lose power
	name = "Powered"
	icon_state = "selfdestruct"
	requires_power = FALSE

/area/mainship/groundhq/clf/hallways/hangar/droppod
	name = "Drop Pod Bay"
	icon_state = "storage"

/area/mainship/groundhq/clf/living/evacuation
	name = "Evacuation"
	icon_state = "departures"
	minimap_color = MINIMAP_AREA_ESCAPE
	requires_power = FALSE

/area/mainship/groundhq/clf/living/evacuation/two //some ships have entirely separate evac areas

/area/mainship/groundhq/clf/living/evacuation/pod
	requires_power = FALSE

/area/mainship/groundhq/clf/living/evacuation/pod/one

/area/mainship/groundhq/clf/living/evacuation/pod/two

/area/mainship/groundhq/clf/living/evacuation/pod/three

/area/mainship/groundhq/clf/living/evacuation/pod/four

/area/mainship/groundhq/clf/medical/lounge
	name = "Medical Lounge"
	icon_state = "medical"

//combat patrol base

/area/mainship/groundhq/clf/patrol_base
	name = "NTC Combat Patrol Base"
	icon_state = "req"
	requires_power = FALSE

/area/mainship/groundhq/clf/patrol_base/hangar
	name = "NTC hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/clf/patrol_base/command
	name = "NTC Bridge"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/clf/patrol_base/prep
	name = "NTC Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/clf/patrol_base/barracks
	name = "NTC Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/groundhq/clf/patrol_base/som
	name = "SOM Combat Patrol Base"

/area/mainship/groundhq/clf/patrol_base/som/hangar
	name = "SOM Main hangar"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/groundhq/clf/patrol_base/som/command
	name = "SOM Command"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/groundhq/clf/patrol_base/som/prep
	name = "SOM Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/groundhq/clf/patrol_base/som/barracks
	name = "SOM Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/groundhq/clf/patrol_base/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"

/area/mainship/groundhq/clf/hallways/bathroom
	name = "Bathroom"
	icon_state = "port"
