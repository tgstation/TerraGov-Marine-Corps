//MARINE SHIP AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/mainship
	icon = 'icons/turf/area_mainship.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "mainship"
	ceiling = CEILING_METAL

/area/mainship/command/cic
	name = "Combat Information Center"
	icon_state = "cic"
	fake_zlevel = 1 // upperdeck

/area/mainship/command/airoom
	name = "AI Core"
	icon_state = "airoom"
	fake_zlevel = 1 // upperdeck

/area/mainship/command/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"
	fake_zlevel = 1 // upperdeck

/area/mainship/command/self_destruct
	name = "Self-Destruct Core Room"
	icon_state = "selfdestruct"
	fake_zlevel = 1 // upperdeck

/area/mainship/command/corporateliaison
	name = "Corporate Liaison Office"
	icon_state = "corporatespace"
	fake_zlevel = 1 // upperdeck

/area/mainship/engineering/upper_engineering
	name = "Upper Engineering"
	icon_state = "upperengineering"
	fake_zlevel = 1 // upperdeck

/area/mainship/engineering/ce_room
	name = "Chief Ship Engineer Office"
	icon_state = "ceroom"
	fake_zlevel = 1 // upperdeck

/area/mainship/engineering/lower_engine_monitoring
	name = "Engine Reactor Monitoring"
	icon_state = "lowermonitoring"
	fake_zlevel = 2 // lowerdeck

/area/mainship/engineering/lower_engineering
	name = "Engineering Lower"
	icon_state = "lowerengineering"
	fake_zlevel = 2 // lowerdeck

/area/mainship/engineering/engineering_workshop
	name = "Engineering Workshop"
	icon_state = "workshop"
	fake_zlevel = 2 // lowerdeck

/area/mainship/engineering/engine_core
	name = "Engine Reactor Core Room"
	icon_state = "coreroom"
	fake_zlevel = 2 // lowerdeck

/area/mainship/engineering/starboard_atmos
	name = "Atmospherics Starboard"
	icon_state = "starboardatmos"
	fake_zlevel = 1 // upperdeck

/area/mainship/engineering/port_atmos
	name = "Atmospherics Port"
	icon_state = "portatmos"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/navigation
	name = "Astronavigational Deck"
	icon_state = "astronavigation"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/starboard_missiles
	name = "Missile Tubes Starboard"
	icon_state = "starboardmissile"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/port_missiles
	name = "Missile Tubes Port"
	icon_state = "portmissile"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/weapon_room
	name = "Weapon Control Room"
	icon_state = "weaponroom"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/starboard_point_defense
	name = "Point Defense Starboard"
	icon_state = "starboardpd"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/port_point_defense
	name = "Point Defense Port"
	icon_state = "portpd"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/brig
	name = "Brig"
	icon_state = "brig"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/brig_cells
	name = "Brig Cells"
	icon_state = "brigcells"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/chief_mp_office
	name = "Brig Command Master at Arms Office"
	icon_state = "chiefmpoffice"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/ex_firing_range
	name = "Experimental Firing Range"
	icon_state = "firingrange"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/firing_range
	name = "Firing Range"
	icon_state = "firingrange"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/sensors
	name = "Sensor Room"
	icon_state = "sensor"

/area/mainship/hallways/hangar
	name = "Hangar"
	icon_state = "hangar"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/tankerbunks
	name = "Vehicle Crew Bunks"
	icon_state = "livingspace"
	fake_zlevel = 2

/area/mainship/hallways/exoarmor
	name = "Vehicle Armor Storage"
	icon_state = "exoarmor"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/repair_bay
	name = "Vehicle Repair Bay"
	icon_state = "dropshiprepair"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/mission_planner
	name = "Dropship Central Computer Room"
	icon_state = "missionplanner"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/starboard_umbilical
	name = "Umbilical Starboard"
	icon_state = "starboardumbilical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/port_umbilical
	name = "Umbilical Port"
	icon_state = "portumbilical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/aft_hallway
	name = "Hallway Aft"
	icon_state = "aft"
	fake_zlevel = 1 // upperdeck

/area/mainship/hallways/stern_hallway
	name = "Hallway Stern"
	icon_state = "stern"
	fake_zlevel = 1 // upperdeck

/area/mainship/hallways/port_hallway
	name = "Hallway Port"
	icon_state = "port"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/starboard_hallway
	name = "Hallway Starboard"
	icon_state = "starboard"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hull/lower_hull
	name = "Hull Lower"
	icon_state = "lowerhull"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hull/upper_hull
	name = "Hull Upper"
	icon_state = "upperhull"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/cryo_cells
	name = "Cryo Cells"
	icon_state = "cryo"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/briefing
	name = "Briefing Area"
	icon_state = "briefing"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/port_emb
	name = "Extended Mission Bunks"
	icon_state = "portemb"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/starboard_emb
	name = "Extended Mission Bunks"
	icon_state = "starboardemb"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/port_garden
	name = "Garden"
	icon_state = "portemb"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/starboard_garden
	name = "Garden"
	icon_state = "starboardemb"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/basketball
	name = "Basketball Court"
	icon_state = "basketball"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/grunt_rnr
	name = "Lounge"
	icon_state = "gruntrnr"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/officer_rnr
	name = "Officer's Lounge"
	icon_state = "officerrnr"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/officer_study
	name = "Officer's Study"
	icon_state = "officerstudy"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/cafeteria_port
	name = "Cafeteria Port"
	icon_state = "food"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/cafeteria_starboard
	name = "Cafeteria Starboard"
	icon_state = "food"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/cafeteria_officer
	name = "Officer Cafeteria"
	icon_state = "food"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/offices
	name = "Pool Area"
	icon_state = "briefing"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/captain_mess
	name = "Captain's Mess"
	icon_state = "briefing"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/pilotbunks
	name = "Pilot's Bunks"
	icon_state = "livingspace"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/bridgebunks
	name = "Staff Officer Bunks"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/commandbunks
	name = "Captain's Bunk"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/numbertwobunks
	name = "Executive Officer's Bunk"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/chapel
	name = "Chapel"
	icon_state = "officerrnr"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/lower_medical
	name = "Medical Lower"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/upper_medical
	name = "Medical Upper"
	icon_state = "medical"
	fake_zlevel = 1 // upperdeck

/area/mainship/medical/operating_room_one
	name = "Medical Operating Room 1"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/operating_room_two
	name = "Medical Operating Room 2"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/operating_room_three
	name = "Medical Operating Room 3"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/operating_room_four
	name = "Medical Operating Room 4"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/medical_science
	name = "Medical Research laboratories"
	icon_state = "science"
	fake_zlevel = 1 // upperdeck

/area/mainship/medical/chemistry
	name = "Medical Chemical laboratory"
	icon_state = "chemistry"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/cryo_tubes
	name = "Medical Cryogenics Tubes"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/surgery_hallway
	name = "Medical Surgical Hallway"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/alpha
	name = "Squad Alpha Preparation"
	icon_state = "alpha"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/bravo
	name = "Squad Bravo Preparation"
	icon_state = "bravo"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/charlie
	name = "Squad Charlie Preparation"
	icon_state = "charlie"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/delta
	name = "Squad Delta Preparation"
	icon_state = "delta"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/general
	name = "Common Squads Preparation"
	icon_state = "req"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/req
	name = "Requisitions"
	icon_state = "req"
	fake_zlevel = 2 // lowerdeck

/area/mainship/powered //for objects not intended to lose power
	name = "Powered"
	icon_state = "selfdestruct"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/mainship/hallways/hangar/droppod
	name = "Drop Pod Bay"
	icon_state = "storage"
	fake_zlevel = 2 // lowerdeck
