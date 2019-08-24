//MARINE SHIP AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/mainship
	icon = 'icons/turf/area_mainship.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "mainship"
	ceiling = CEILING_METAL

/area/mainship/command/cic
	name = "\improper Combat Information Center"
	icon_state = "cic"
	fake_zlevel = 1 // upperdeck

/area/mainship/command/airoom
	name = "\improper AI Core"
	icon_state = "airoom"
	fake_zlevel = 1 // upperdeck

/area/mainship/command/telecomms
	name = "\improper Telecommunications"
	icon_state = "tcomms"
	fake_zlevel = 1 // upperdeck

/area/mainship/command/self_destruct
	name = "\improper Self-Destruct Core Room"
	icon_state = "selfdestruct"
	fake_zlevel = 1 // upperdeck

/area/mainship/command/corporateliaison
	name = "\improper Corporate Liaison Office"
	icon_state = "corporatespace"
	fake_zlevel = 1 // upperdeck

/area/mainship/engineering/upper_engineering
	name = "\improper Upper Engineering"
	icon_state = "upperengineering"
	fake_zlevel = 1 // upperdeck

/area/mainship/engineering/ce_room
	name = "\improper Chief Ship Engineer Office"
	icon_state = "ceroom"
	fake_zlevel = 1 // upperdeck

/area/mainship/engineering/lower_engine_monitoring
	name = "\improper Engine Reactor Monitoring"
	icon_state = "lowermonitoring"
	fake_zlevel = 2 // lowerdeck

/area/mainship/engineering/lower_engineering
	name = "\improper Engineering Lower"
	icon_state = "lowerengineering"
	fake_zlevel = 2 // lowerdeck

/area/mainship/engineering/engineering_workshop
	name = "\improper Engineering Workshop"
	icon_state = "workshop"
	fake_zlevel = 2 // lowerdeck

/area/mainship/engineering/engine_core
	name = "\improper Engine Reactor Core Room"
	icon_state = "coreroom"
	fake_zlevel = 2 // lowerdeck

/area/mainship/engineering/starboard_atmos
	name = "\improper Atmospherics Starboard"
	icon_state = "starboardatmos"
	fake_zlevel = 1 // upperdeck

/area/mainship/engineering/port_atmos
	name = "\improper Atmospherics Port"
	icon_state = "portatmos"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/navigation
	name = "\improper Astronavigational Deck"
	icon_state = "astronavigation"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/starboard_missiles
	name = "\improper Missile Tubes Starboard"
	icon_state = "starboardmissile"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/port_missiles
	name = "\improper Missile Tubes Port"
	icon_state = "portmissile"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/weapon_room
	name = "\improper Weapon Control Room"
	icon_state = "weaponroom"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/starboard_point_defense
	name = "\improper Point Defense Starboard"
	icon_state = "starboardpd"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/port_point_defense
	name = "\improper Point Defense Port"
	icon_state = "portpd"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/brig
	name = "\improper Brig"
	icon_state = "brig"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/brig_cells
	name = "\improper Brig Cells"
	icon_state = "brigcells"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/chief_mp_office
	name = "\improper Brig Command Master at Arms Office"
	icon_state = "chiefmpoffice"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/ex_firing_range
	name = "\improper Experimental Firing Range"
	icon_state = "firingrange"
	fake_zlevel = 1 // upperdeck

/area/mainship/shipboard/firing_range
	name = "\improper Firing Range"
	icon_state = "firingrange"
	fake_zlevel = 2 // lowerdeck

/area/mainship/shipboard/sensors
	name = "\improper Sensor Room"
	icon_state = "sensor"

/area/mainship/hallways/hangar
	name = "\improper Hangar"
	icon_state = "hangar"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/tankerbunks
	name = "\improper Vehicle Crew Bunks"
	icon_state = "livingspace"
	fake_zlevel = 2

/area/mainship/hallways/exoarmor
	name = "\improper Vehicle Armor Storage"
	icon_state = "exoarmor"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/repair_bay
	name = "\improper Vehicle Repair Bay"
	icon_state = "dropshiprepair"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/mission_planner
	name = "\improper Dropship Central Computer Room"
	icon_state = "missionplanner"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/starboard_umbilical
	name = "\improper Umbilical Starboard"
	icon_state = "starboardumbilical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/port_umbilical
	name = "\improper Umbilical Port"
	icon_state = "portumbilical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/aft_hallway
	name = "\improper Hallway Aft"
	icon_state = "aft"
	fake_zlevel = 1 // upperdeck

/area/mainship/hallways/stern_hallway
	name = "\improper Hallway Stern"
	icon_state = "stern"
	fake_zlevel = 1 // upperdeck

/area/mainship/hallways/port_hallway
	name = "\improper Hallway Port"
	icon_state = "port"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hallways/starboard_hallway
	name = "\improper Hallway Starboard"
	icon_state = "starboard"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hull/lower_hull
	name = "\improper Hull Lower"
	icon_state = "lowerhull"
	fake_zlevel = 2 // lowerdeck

/area/mainship/hull/upper_hull
	name = "\improper Hull Upper"
	icon_state = "upperhull"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/cryo_cells
	name = "\improper Cryo Cells"
	icon_state = "cryo"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/briefing
	name = "\improper Briefing Area"
	icon_state = "briefing"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/port_emb
	name = "\improper Extended Mission Bunks"
	icon_state = "portemb"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/starboard_emb
	name = "\improper Extended Mission Bunks"
	icon_state = "starboardemb"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/port_garden
	name = "\improper Garden"
	icon_state = "portemb"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/starboard_garden
	name = "\improper Garden"
	icon_state = "starboardemb"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/basketball
	name = "\improper Basketball Court"
	icon_state = "basketball"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/grunt_rnr
	name = "\improper Lounge"
	icon_state = "gruntrnr"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/officer_rnr
	name = "\improper Officer's Lounge"
	icon_state = "officerrnr"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/officer_study
	name = "\improper Officer's Study"
	icon_state = "officerstudy"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/cafeteria_port
	name = "\improper Cafeteria Port"
	icon_state = "food"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/cafeteria_starboard
	name = "\improper Cafeteria Starboard"
	icon_state = "food"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/cafeteria_officer
	name = "\improper Officer Cafeteria"
	icon_state = "food"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/offices
	name = "\improper Pool Area"
	icon_state = "briefing"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/captain_mess
	name = "\improper Captain's Mess"
	icon_state = "briefing"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/pilotbunks
	name = "\improper Pilot's Bunks"
	icon_state = "livingspace"
	fake_zlevel = 2 // lowerdeck

/area/mainship/living/bridgebunks
	name = "\improper Staff Officer Bunks"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/commandbunks
	name = "\improper Captain's Bunk"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/numbertwobunks
	name = "\improper Executive Officer's Bunk"
	icon_state = "livingspace"
	fake_zlevel = 1 // upperdeck

/area/mainship/living/chapel
	name = "\improper Chapel"
	icon_state = "officerrnr"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/lower_medical
	name = "\improper Medical Lower"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/upper_medical
	name = "\improper Medical Upper"
	icon_state = "medical"
	fake_zlevel = 1 // upperdeck

/area/mainship/medical/operating_room_one
	name = "\improper Medical Operating Room 1"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/operating_room_two
	name = "\improper Medical Operating Room 2"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/operating_room_three
	name = "\improper Medical Operating Room 3"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/operating_room_four
	name = "\improper Medical Operating Room 4"
	icon_state = "operating"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/medical_science
	name = "\improper Medical Research laboratories"
	icon_state = "science"
	fake_zlevel = 1 // upperdeck

/area/mainship/medical/chemistry
	name = "\improper Medical Chemical laboratory"
	icon_state = "chemistry"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/cryo_tubes
	name = "\improper Medical Cryogenics Tubes"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/medical/surgery_hallway
	name = "\improper Medical Surgical Hallway"
	icon_state = "medical"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/alpha
	name = "\improper Squad Alpha Preparation"
	icon_state = "alpha"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/bravo
	name = "\improper Squad Bravo Preparation"
	icon_state = "bravo"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/charlie
	name = "\improper Squad Charlie Preparation"
	icon_state = "charlie"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/delta
	name = "\improper Squad Delta Preparation"
	icon_state = "delta"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/general
	name = "\improper Common Squads Preparation"
	icon_state = "req"
	fake_zlevel = 2 // lowerdeck

/area/mainship/squads/req
	name = "\improper Requisitions"
	icon_state = "req"
	fake_zlevel = 2 // lowerdeck

/area/mainship/powered //for objects not intended to lose power
	name = "\improper Powered"
	icon_state = "selfdestruct"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
