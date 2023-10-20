//MARINE SHIP AREAS--------------------------------------//
// Fore = West  | Aft = East //
// Port = South | Starboard = North //
/area/mainship
	icon = 'icons/turf/area_mainship.dmi'
	ambience = list('sound/ambience/shipambience.ogg')
	icon_state = "mainship"
	ceiling = CEILING_METAL

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
	name = "Corporate Liaison Office"
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

/area/mainship/hallways/hangar/flight_control
	name = "Flight Control"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_COMMAND


/area/mainship/living/tankerbunks
	name = "Vehicle Crew Bunks"
	icon_state = "livingspace"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/hallways/exoarmor
	name = "Vehicle Armor Storage"
	icon_state = "exoarmor"

/area/mainship/hallways/boxingring
	name = "Boxing Ring"
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
	minimap_color = MINIMAP_AREA_MEDBAY

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
	name = "TGMC Combat Patrol Base"
	icon_state = "req"
	requires_power = FALSE

/area/mainship/patrol_base/hanger
	name = "TGMC Hanger"
	icon_state = "hangar"
	minimap_color = MINIMAP_AREA_LZ

/area/mainship/patrol_base/command
	name = "TGMC Bridge"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/mainship/patrol_base/prep
	name = "TGMC Preparations"
	icon_state = "mainship"
	minimap_color = MINIMAP_AREA_PREP

/area/mainship/patrol_base/barracks
	name = "TGMC Barracks"
	icon_state = "cryo"
	minimap_color = MINIMAP_AREA_LIVING

/area/mainship/patrol_base/som
	name = "SOM Combat Patrol Base"

/area/mainship/patrol_base/som/hanger
	name = "SOM Main Hanger"
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

/area/mainship/patrol_base/telecomms
	name = "Telecommunications"
	icon_state = "tcomms"
