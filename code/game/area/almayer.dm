//ALMAYER AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/almayer
	icon = 'icons/turf/area_almayer.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "almayer"
	ceiling = CEILING_METAL

/area/shuttle/almayer/elevator_maintenance/upperdeck
	name = "\improper Maintenance Elevator"
	icon_state = "shuttle"
	fake_zlevel = 1

/area/shuttle/almayer/elevator_maintenance/lowerdeck
	name = "\improper Maintenance Elevator"
	icon_state = "shuttle"
	fake_zlevel = 2

/area/shuttle/almayer/elevator_hangar/lowerdeck
	name = "\improper Hangar Elevator"
	icon_state = "shuttle"
	fake_zlevel = 2 // lowerdeck

/area/shuttle/almayer/elevator_hangar/underdeck
	name = "\improper Hangar Elevator"
	icon_state = "shuttle"
	fake_zlevel = 3

/obj/machinery/computer/shuttle_control/almayer/hangar
	name = "Elevator Console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "supply"
	unacidable = 1
	exproof = 1
	density = 1
	req_access = null
	shuttle_tag = "Hangar"

/obj/machinery/computer/shuttle_control/almayer/maintenance
	name = "Elevator Console"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"
	unacidable = 1
	exproof = 1
	density = 1
	req_access = null
	shuttle_tag = "Maintenance"

/area/almayer/command/cic
	name = "\improper Combat Information Center"
	icon_state = "cic"
	fake_zlevel = 1 // upperdeck

/area/almayer/command/airoom
	name = "\improper AI Core"
	icon_state = "airoom"
	fake_zlevel = 1 // upperdeck

/area/almayer/command/telecomms
	name = "\improper Telecommunications"
	icon_state = "tcomms"
	fake_zlevel = 1 // upperdeck

/area/almayer/command/self_destruct
	name = "\improper Self-Destruct Core Room"
	icon_state = "selfdestruct"
	fake_zlevel = 1 // upperdeck

/area/almayer/command/corporateliason
	name = "\improper Corporate Liason Office"
	icon_state = "corporatespace"
	fake_zlevel = 1 // upperdeck

/area/almayer/engineering/upper_engineering
	name = "\improper Upper Engineering"
	icon_state = "upperengineering"
	fake_zlevel = 1 // upperdeck

/area/almayer/engineering/ce_room
	name = "\improper Chief Engineer Office"
	icon_state = "ceroom"
	fake_zlevel = 1 // upperdeck

/area/almayer/engineering/lower_engine_monitoring
	name = "\improper Engine Reactor Monitoring"
	icon_state = "lowermonitoring"
	fake_zlevel = 2 // lowerdeck

/area/almayer/engineering/lower_engineering
	name = "\improper Engineering Lower"
	icon_state = "lowerengineering"
	fake_zlevel = 2 // lowerdeck

/area/almayer/engineering/engineering_workshop
	name = "\improper Engineering Workshop"
	icon_state = "workshop"
	fake_zlevel = 2 // lowerdeck

/area/almayer/engineering/engine_core
	name = "\improper Engine Reactor Core Room"
	icon_state = "coreroom"
	fake_zlevel = 2 // lowerdeck

/area/almayer/engineering/starboard_atmos
	name = "\improper Atmospherics Starboard"
	icon_state = "starboardatmos"
	fake_zlevel = 1 // upperdeck

/area/almayer/engineering/port_atmos
	name = "\improper Atmospherics Port"
	icon_state = "portatmos"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/navigation
	name = "\improper Astronavigational Deck"
	icon_state = "astronavigation"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/starboard_missiles
	name = "\improper Missile Tubes Starboard"
	icon_state = "starboardmissile"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/port_missiles
	name = "\improper Missile Tubes Port"
	icon_state = "portmissile"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/weapon_room
	name = "\improper Weapon Control Room"
	icon_state = "weaponroom"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/starboard_point_defense
	name = "\improper Point Defense Starboard"
	icon_state = "starboardpd"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/port_point_defense
	name = "\improper Point Defense Port"
	icon_state = "portpd"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/brig
	name = "\improper Brig"
	icon_state = "brig"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/brig_cells
	name = "\improper Brig Cells"
	icon_state = "brigcells"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/chief_mp_office
	name = "\improper Brig Chief MP Office"
	icon_state = "chiefmpoffice"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/firing_range
	name = "\improper Firing Range"
	icon_state = "firingrange"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/sensors
	name = "\improper Sensor Room"
	icon_state = "sensor"

/area/almayer/hallways/hangar
	name = "\improper Hangar"
	icon_state = "hangar"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/vehiclehangar
	name = "\improper Vehicle Storage"
	icon_state = "exoarmor"
	fake_zlevel = 3

/area/almayer/living/tankerbunks
	name = "\improper Vehicle Crew Bunks"
	icon_state = "livingspace"
	fake_zlevel = 3

/area/almayer/squads/tankdeliveries
	name = "\improper Vehicle ASRS"
	icon_state = "req"
	fake_zlevel = 3 // lowerdeck

/area/almayer/hallways/exoarmor
	name = "\improper Vehicle Armor Storage"
	icon_state = "exoarmor"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/repair_bay
	name = "\improper Vehicle Repair Bay"
	icon_state = "dropshiprepair"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/mission_planner
	name = "\improper Dropship Central Computer Room"
	icon_state = "missionplanner"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/starboard_umbilical
	name = "\improper Umbilical Starboard"
	icon_state = "starboardumbilical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/port_umbilical
	name = "\improper Umbilical Port"
	icon_state = "portumbilical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/aft_hallway
	name = "\improper Hallway Aft"
	icon_state = "aft"
	fake_zlevel = 1 // upperdeck

/area/almayer/hallways/stern_hallway
	name = "\improper Hallway Stern"
	icon_state = "stern"
	fake_zlevel = 1 // upperdeck

/area/almayer/hallways/port_hallway
	name = "\improper Hallway Port"
	icon_state = "port"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/starboard_hallway
	name = "\improper Hallway Starboard"
	icon_state = "starboard"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hull/under_hull
	name = "\improper Hull Under"
	icon_state = "lowerhull"
	fake_zlevel = 3

/area/almayer/hull/lower_hull
	name = "\improper Hull Lower"
	icon_state = "lowerhull"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hull/upper_hull
	name = "\improper Hull Upper"
	icon_state = "upperhull"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/cryo_cells
	name = "\improper Cryo Cells"
	icon_state = "cryo"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/briefing
	name = "\improper Briefing Area"
	icon_state = "briefing"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/port_emb
	name = "\improper Extended Mission Bunks"
	icon_state = "portemb"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/starboard_emb
	name = "\improper Extended Mission Bunks"
	icon_state = "starboardemb"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/port_garden
	name = "\improper Garden"
	icon_state = "portemb"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/starboard_garden
	name = "\improper Garden"
	icon_state = "starboardemb"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/basketball
	name = "\improper Basketball Court"
	icon_state = "basketball"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/grunt_rnr
	name = "\improper Lounge"
	icon_state = "gruntrnr"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/officer_rnr
	name = "\improper Officer's Lounge"
	icon_state = "officerrnr"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/officer_study
	name = "\improper Officer's Study"
	icon_state = "officerstudy"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/cafeteria_port
	name = "\improper Cafeteria Port"
	icon_state = "food"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/cafeteria_starboard
	name = "\improper Cafeteria Starboard"
	icon_state = "food"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/cafeteria_officer
	name = "\improper Officer Cafeteria"
	icon_state = "food"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/offices
	name = "\improper Office Area"
	icon_state = "briefing"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/captain_mess
	name = "\improper Captain's Mess"
	icon_state = "briefing"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/pilotbunks
	name = "\improper Pilot's Bunks"
	icon_state = "livingspace"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/bridgebunks
	name = "\improper Staff Officer Bunks"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/commandbunks
	name = "\improper Commander's Bunk"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/numbertwobunks
	name = "\improper Executive Officer's Bunk"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/chapel
	name = "\improper Chapel"
	icon_state = "officerrnr"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/lower_medical
	name = "\improper Medical Lower"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/upper_medical
	name = "\improper Medical Upper"
	icon_state = "medical"
	fake_zlevel = 1 // upperdeck

/area/almayer/medical/operating_room_one
	name = "\improper Medical Operating Room 1"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/operating_room_two
	name = "\improper Medical Operating Room 2"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/operating_room_three
	name = "\improper Medical Operating Room 3"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/operating_room_four
	name = "\improper Medical Operating Room 4"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/medical_science
	name = "\improper Medical Research laboratories"
	icon_state = "science"
	fake_zlevel = 1 // upperdeck

/area/almayer/medical/chemistry
	name = "\improper Medical Chemical laboratory"
	icon_state = "chemistry"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/cryo_tubes
	name = "\improper Medical Cryogenics Tubes"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/surgery_hallway
	name = "\improper Medical Surgical Hallway"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/alpha
	name = "\improper Squad Alpha Preparation"
	icon_state = "alpha"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/bravo
	name = "\improper Squad Bravo Preparation"
	icon_state = "bravo"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/charlie
	name = "\improper Squad Charlie Preparation"
	icon_state = "charlie"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/delta
	name = "\improper Squad Delta Preparation"
	icon_state = "delta"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/req
	name = "\improper Requisitions"
	icon_state = "req"
	fake_zlevel = 2 // lowerdeck

/area/almayer/powered //for objects not intended to lose power
	name = "\improper Powered"
	icon_state = "selfdestruct"
	requires_power = 0

/area/almayer/evacuation
	icon = 'icons/turf/areas.dmi'
	icon_state = "shuttle2"
	requires_power = 0

//Placeholder.
/area/almayer/evacuation/pod1
/area/almayer/evacuation/pod2
/area/almayer/evacuation/pod3
/area/almayer/evacuation/pod4
/area/almayer/evacuation/pod5
/area/almayer/evacuation/pod6
/area/almayer/evacuation/pod7
/area/almayer/evacuation/pod8
/area/almayer/evacuation/pod9
/area/almayer/evacuation/pod10
/area/almayer/evacuation/pod11

/area/almayer/evacuation/stranded

//Placeholder.
/area/almayer/evacuation/stranded/pod1
/area/almayer/evacuation/stranded/pod2
/area/almayer/evacuation/stranded/pod3
/area/almayer/evacuation/stranded/pod4
/area/almayer/evacuation/stranded/pod5
/area/almayer/evacuation/stranded/pod6
/area/almayer/evacuation/stranded/pod7
/area/almayer/evacuation/stranded/pod8
/area/almayer/evacuation/stranded/pod9
/area/almayer/evacuation/stranded/pod10
/area/almayer/evacuation/stranded/pod11
