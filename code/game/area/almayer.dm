//ALMAYER AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/almayer
	icon = 'icons/turf/area_almayer.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "almayer"
	ceiling = CEILING_METAL

/area/shuttle/almayer/elevator_maintenance/upperdeck
	name = " Maintenance Elevator"
	icon_state = "shuttle"
	fake_zlevel = 1

/area/shuttle/almayer/elevator_maintenance/lowerdeck
	name = " Maintenance Elevator"
	icon_state = "shuttle"
	fake_zlevel = 2

/area/shuttle/almayer/elevator_hangar/lowerdeck
	name = " Hangar Elevator"
	icon_state = "shuttle"
	fake_zlevel = 2 // lowerdeck

/area/shuttle/almayer/elevator_hangar/underdeck
	name = " Hangar Elevator"
	icon_state = "shuttle"
	fake_zlevel = 3

/area/almayer/command/cic
	name = " Combat Information Center"
	icon_state = "cic"
	fake_zlevel = 1 // upperdeck

/area/almayer/command/airoom
	name = " AI Core"
	icon_state = "airoom"
	fake_zlevel = 1 // upperdeck

/area/almayer/command/telecomms
	name = " Telecommunications"
	icon_state = "tcomms"
	fake_zlevel = 1 // upperdeck

/area/almayer/command/self_destruct
	name = " Self-Destruct Core Room"
	icon_state = "selfdestruct"
	fake_zlevel = 1 // upperdeck

/area/almayer/command/corporateliaison
	name = " Corporate Liaison Office"
	icon_state = "corporatespace"
	fake_zlevel = 1 // upperdeck

/area/almayer/engineering/upper_engineering
	name = " Upper Engineering"
	icon_state = "upperengineering"
	fake_zlevel = 1 // upperdeck

/area/almayer/engineering/ce_room
	name = " Chief Engineer Office"
	icon_state = "ceroom"
	fake_zlevel = 1 // upperdeck

/area/almayer/engineering/lower_engine_monitoring
	name = " Engine Reactor Monitoring"
	icon_state = "lowermonitoring"
	fake_zlevel = 2 // lowerdeck

/area/almayer/engineering/lower_engineering
	name = " Engineering Lower"
	icon_state = "lowerengineering"
	fake_zlevel = 2 // lowerdeck

/area/almayer/engineering/engineering_workshop
	name = " Engineering Workshop"
	icon_state = "workshop"
	fake_zlevel = 2 // lowerdeck

/area/almayer/engineering/engine_core
	name = " Engine Reactor Core Room"
	icon_state = "coreroom"
	fake_zlevel = 2 // lowerdeck

/area/almayer/engineering/starboard_atmos
	name = " Atmospherics Starboard"
	icon_state = "starboardatmos"
	fake_zlevel = 1 // upperdeck

/area/almayer/engineering/port_atmos
	name = " Atmospherics Port"
	icon_state = "portatmos"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/navigation
	name = " Astronavigational Deck"
	icon_state = "astronavigation"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/starboard_missiles
	name = " Missile Tubes Starboard"
	icon_state = "starboardmissile"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/port_missiles
	name = " Missile Tubes Port"
	icon_state = "portmissile"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/weapon_room
	name = " Weapon Control Room"
	icon_state = "weaponroom"
	fake_zlevel = 1 // upperdeck

/area/almayer/shipboard/starboard_point_defense
	name = " Point Defense Starboard"
	icon_state = "starboardpd"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/port_point_defense
	name = " Point Defense Port"
	icon_state = "portpd"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/brig
	name = " Brig"
	icon_state = "brig"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/brig_cells
	name = " Brig Cells"
	icon_state = "brigcells"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/chief_mp_office
	name = " Brig Chief MP Office"
	icon_state = "chiefmpoffice"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/firing_range
	name = " Firing Range"
	icon_state = "firingrange"
	fake_zlevel = 2 // lowerdeck

/area/almayer/shipboard/sensors
	name = " Sensor Room"
	icon_state = "sensor"

/area/almayer/hallways/hangar
	name = " Hangar"
	icon_state = "hangar"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/vehiclehangar
	name = " Vehicle Storage"
	icon_state = "exoarmor"
	fake_zlevel = 3

/area/almayer/living/tankerbunks
	name = " Vehicle Crew Bunks"
	icon_state = "livingspace"
	fake_zlevel = 3

/area/almayer/squads/tankdeliveries
	name = " Vehicle ASRS"
	icon_state = "req"
	fake_zlevel = 3 // lowerdeck

/area/almayer/hallways/exoarmor
	name = " Vehicle Armor Storage"
	icon_state = "exoarmor"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/repair_bay
	name = " Vehicle Repair Bay"
	icon_state = "dropshiprepair"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/mission_planner
	name = " Dropship Central Computer Room"
	icon_state = "missionplanner"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/starboard_umbilical
	name = " Umbilical Starboard"
	icon_state = "starboardumbilical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/port_umbilical
	name = " Umbilical Port"
	icon_state = "portumbilical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/aft_hallway
	name = " Hallway Aft"
	icon_state = "aft"
	fake_zlevel = 1 // upperdeck

/area/almayer/hallways/stern_hallway
	name = " Hallway Stern"
	icon_state = "stern"
	fake_zlevel = 1 // upperdeck

/area/almayer/hallways/port_hallway
	name = " Hallway Port"
	icon_state = "port"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hallways/starboard_hallway
	name = " Hallway Starboard"
	icon_state = "starboard"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hull/under_hull
	name = " Hull Under"
	icon_state = "lowerhull"
	fake_zlevel = 3

/area/almayer/hull/lower_hull
	name = " Hull Lower"
	icon_state = "lowerhull"
	fake_zlevel = 2 // lowerdeck

/area/almayer/hull/upper_hull
	name = " Hull Upper"
	icon_state = "upperhull"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/cryo_cells
	name = " Cryo Cells"
	icon_state = "cryo"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/briefing
	name = " Briefing Area"
	icon_state = "briefing"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/port_emb
	name = " Extended Mission Bunks"
	icon_state = "portemb"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/starboard_emb
	name = " Extended Mission Bunks"
	icon_state = "starboardemb"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/port_garden
	name = " Garden"
	icon_state = "portemb"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/starboard_garden
	name = " Garden"
	icon_state = "starboardemb"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/basketball
	name = " Basketball Court"
	icon_state = "basketball"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/grunt_rnr
	name = " Lounge"
	icon_state = "gruntrnr"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/officer_rnr
	name = " Officer's Lounge"
	icon_state = "officerrnr"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/officer_study
	name = " Officer's Study"
	icon_state = "officerstudy"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/cafeteria_port
	name = " Cafeteria Port"
	icon_state = "food"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/cafeteria_starboard
	name = " Cafeteria Starboard"
	icon_state = "food"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/cafeteria_officer
	name = " Officer Cafeteria"
	icon_state = "food"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/offices
	name = " Pool Area"
	icon_state = "briefing"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/captain_mess
	name = " Captain's Mess"
	icon_state = "briefing"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/pilotbunks
	name = " Pilot's Bunks"
	icon_state = "livingspace"
	fake_zlevel = 2 // lowerdeck

/area/almayer/living/bridgebunks
	name = " Staff Officer Bunks"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/commandbunks
	name = " Commander's Bunk"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/numbertwobunks
	name = " Executive Officer's Bunk"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/almayer/living/chapel
	name = " Chapel"
	icon_state = "officerrnr"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/lower_medical
	name = " Medical Lower"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/upper_medical
	name = " Medical Upper"
	icon_state = "medical"
	fake_zlevel = 1 // upperdeck

/area/almayer/medical/operating_room_one
	name = " Medical Operating Room 1"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/operating_room_two
	name = " Medical Operating Room 2"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/operating_room_three
	name = " Medical Operating Room 3"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/operating_room_four
	name = " Medical Operating Room 4"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/medical_science
	name = " Medical Research laboratories"
	icon_state = "science"
	fake_zlevel = 1 // upperdeck

/area/almayer/medical/chemistry
	name = " Medical Chemical laboratory"
	icon_state = "chemistry"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/cryo_tubes
	name = " Medical Cryogenics Tubes"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/medical/surgery_hallway
	name = " Medical Surgical Hallway"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/alpha
	name = " Squad Alpha Preparation"
	icon_state = "alpha"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/bravo
	name = " Squad Bravo Preparation"
	icon_state = "bravo"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/charlie
	name = " Squad Charlie Preparation"
	icon_state = "charlie"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/delta
	name = " Squad Delta Preparation"
	icon_state = "delta"
	fake_zlevel = 2 // lowerdeck

/area/almayer/squads/req
	name = " Requisitions"
	icon_state = "req"
	fake_zlevel = 2 // lowerdeck

/area/almayer/powered //for objects not intended to lose power
	name = " Powered"
	icon_state = "selfdestruct"
	requires_power = 0

/area/almayer/evacuation
	icon = 'icons/turf/areas.dmi'
	icon_state = "shuttle2"
	requires_power = 0

/area/vehicle_interior
	name = "Vehicle Interior Placeholder"
	icon = 'icons/turf/area_almayer.dmi'
	ceiling = CEILING_METAL
	luminosity = 1
	requires_power = 0

/area/vehicle_interior/apc_1
	name = "APC_1 Interior"
	icon = 'icons/turf/area_almayer.dmi'
	icon_state = "apc_1"

/area/vehicle_interior/apc_2
	name = "APC_2 Interior"
	icon = 'icons/turf/area_almayer.dmi'
	icon_state = "apc_2"

/area/vehicle_interior/apc_3
	name = "APC_3 Interior"
	icon = 'icons/turf/area_almayer.dmi'
	icon_state = "apc_3"

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
