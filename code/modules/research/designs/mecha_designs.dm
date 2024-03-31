///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////

/datum/design/board/ripley_main
	name = "APLU \"Ripley\" Central Control module"
	desc = ""
	id = "ripley_main"
	build_path = /obj/item/circuitboard/mecha/ripley/main
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/ripley_peri
	name = "APLU \"Ripley\" Peripherals Control module"
	desc = ""
	id = "ripley_peri"
	build_path = /obj/item/circuitboard/mecha/ripley/peripherals
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/odysseus_main
	name = "\"Odysseus\" Central Control module"
	desc = ""
	id = "odysseus_main"
	build_path = /obj/item/circuitboard/mecha/odysseus/main
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/odysseus_peri
	name = "\"Odysseus\" Peripherals Control module"
	desc = ""
	id = "odysseus_peri"
	build_path = /obj/item/circuitboard/mecha/odysseus/peripherals
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/gygax_main
	name = "\"Gygax\" Central Control module"
	desc = ""
	id = "gygax_main"
	build_path = /obj/item/circuitboard/mecha/gygax/main
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/gygax_peri
	name = "\"Gygax\" Peripherals Control module"
	desc = ""
	id = "gygax_peri"
	build_path = /obj/item/circuitboard/mecha/gygax/peripherals
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/gygax_targ
	name = "\"Gygax\" Weapons & Targeting Control module"
	desc = ""
	id = "gygax_targ"
	build_path = /obj/item/circuitboard/mecha/gygax/targeting
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/durand_main
	name = "\"Durand\" Central Control module"
	desc = ""
	id = "durand_main"
	build_path = /obj/item/circuitboard/mecha/durand/main
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/durand_peri
	name = "\"Durand\" Peripherals Control module"
	desc = ""
	id = "durand_peri"
	build_path = /obj/item/circuitboard/mecha/durand/peripherals
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/durand_targ
	name = "\"Durand\" Weapons & Targeting Control module"
	desc = ""
	id = "durand_targ"
	build_path = /obj/item/circuitboard/mecha/durand/targeting
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/honker_main
	name = "\"H.O.N.K\" Central Control module"
	desc = ""
	id = "honker_main"
	build_path = /obj/item/circuitboard/mecha/honker/main
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/honker_peri
	name = "\"H.O.N.K\" Peripherals Control module"
	desc = ""
	id = "honker_peri"
	build_path = /obj/item/circuitboard/mecha/honker/peripherals
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/honker_targ
	name = "\"H.O.N.K\" Weapons & Targeting Control module"
	desc = ""
	id = "honker_targ"
	build_path = /obj/item/circuitboard/mecha/honker/targeting
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/phazon_main
	name = "\"Phazon\" Central Control module"
	desc = ""
	id = "phazon_main"
	materials = list(/datum/material/glass = 1000, /datum/material/bluespace = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/main
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/phazon_peri
	name = "\"Phazon\" Peripherals Control module"
	desc = ""
	id = "phazon_peri"
	materials = list(/datum/material/glass = 1000, /datum/material/bluespace = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/peripherals
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/phazon_targ
	name = "\"Phazon\" Weapons & Targeting Control module"
	desc = ""
	id = "phazon_targ"
	materials = list(/datum/material/glass = 1000, /datum/material/bluespace = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/targeting
	category = list("Exosuit Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

////////////////////////////////////////
/////////// Mecha Equpment /////////////
////////////////////////////////////////

/datum/design/mech_scattershot
	name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	desc = ""
	id = "mech_scattershot"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_scattershot_ammo
	name = "LBX AC 10 Scattershot Ammunition"
	desc = ""
	id = "mech_scattershot_ammo"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_ammo/scattershot
	materials = list(/datum/material/iron=6000)
	construction_time = 20
	category = list("Exosuit Ammunition", "Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mech_carbine
	name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	desc = ""
	id = "mech_carbine"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_carbine_ammo
	name = "FNX-99 Carbine Ammunition"
	desc = ""
	id = "mech_carbine_ammo"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_ammo/incendiary
	materials = list(/datum/material/iron=6000)
	construction_time = 20
	category = list("Exosuit Ammunition", "Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mech_ion
	name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	desc = ""
	id = "mech_ion"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	materials = list(/datum/material/iron=20000,/datum/material/silver=6000,/datum/material/uranium=2000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_tesla
	name = "Exosuit Weapon (MKI Tesla Cannon)"
	desc = ""
	id = "mech_tesla"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	materials = list(/datum/material/iron=20000,/datum/material/silver=8000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_laser
	name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	desc = ""
	id = "mech_laser"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_laser_heavy
	name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	desc = ""
	id = "mech_laser_heavy"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_disabler
	name = "Exosuit Weapon (CH-DS \"Peacemaker\" Disabler)"
	desc = ""
	id = "mech_disabler"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_grenade_launcher
	name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	desc = ""
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	materials = list(/datum/material/iron=22000,/datum/material/gold=6000,/datum/material/silver=8000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_grenade_launcher_ammo
	name = "SGL-6 Grenade Launcher Ammunition"
	desc = ""
	id = "mech_grenade_launcher_ammo"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_ammo/flashbang
	materials = list(/datum/material/iron=4000,/datum/material/gold=500,/datum/material/iron=500)
	construction_time = 20
	category = list("Exosuit Ammunition", "Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mech_missile_rack
	name = "Exosuit Weapon (BRM-6 Missile Rack)"
	desc = ""
	id = "mech_missile_rack"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/breaching
	materials = list(/datum/material/iron=22000,/datum/material/gold=6000,/datum/material/silver=8000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_missile_rack_ammo
	name = "SRM-8 Missile Rack Ammunition"
	desc = ""
	id = "mech_missile_rack_ammo"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_ammo/missiles_br
	materials = list(/datum/material/iron=8000,/datum/material/gold=500,/datum/material/iron=500)
	construction_time = 20
	category = list("Exosuit Ammunition", "Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/clusterbang_launcher
	name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	desc = ""
	id = "clusterbang_launcher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/clusterbang
	materials = list(/datum/material/iron=20000,/datum/material/gold=10000,/datum/material/uranium=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/clusterbang_launcher_ammo
	name = "SOB-3 Clusterbang Launcher Ammunition"
	desc = ""
	id = "clusterbang_launcher_ammo"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_ammo/clusterbang
	materials = list(/datum/material/iron=6000,/datum/material/gold=1500,/datum/material/uranium=1500)
	construction_time = 20
	category = list("Exosuit Ammunition", "Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mech_wormhole_gen
	name = "Exosuit Module (Localized Wormhole Generator)"
	desc = ""
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_teleporter
	name = "Exosuit Module (Teleporter Module)"
	desc = ""
	id = "mech_teleporter"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	materials = list(/datum/material/iron=10000,/datum/material/diamond=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_rcd
	name = "Exosuit Module (RCD Module)"
	desc = ""
	id = "mech_rcd"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/rcd
	materials = list(/datum/material/iron=30000,/datum/material/gold=20000,/datum/material/plasma=25000,/datum/material/silver=20000)
	construction_time = 1200
	category = list("Exosuit Equipment")

/datum/design/mech_thrusters
	name = "Exosuit Module (RCS Thruster Package)"
	desc = ""
	id = "mech_thrusters"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/thrusters/gas
	materials = list(/datum/material/iron=25000,/datum/material/titanium=5000,/datum/material/silver=3000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_gravcatapult
	name = "Exosuit Module (Gravitational Catapult Module)"
	desc = ""
	id = "mech_gravcatapult"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_repair_droid
	name = "Exosuit Module (Repair Droid Module)"
	desc = ""
	id = "mech_repair_droid"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	materials = list(/datum/material/iron=10000,/datum/material/glass = 5000,/datum/material/gold=1000,/datum/material/silver=2000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_energy_relay
	name = "Exosuit Module (Tesla Energy Relay)"
	desc = ""
	id = "mech_energy_relay"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	materials = list(/datum/material/iron=10000,/datum/material/glass =  2000,/datum/material/gold=2000,/datum/material/silver=3000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_ccw_armor
	name = "Exosuit Module (Reactive Armor Booster Module)"
	desc = ""
	id = "mech_ccw_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	materials = list(/datum/material/iron=20000,/datum/material/silver=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_proj_armor
	name = "Exosuit Module (Reflective Armor Booster Module)"
	desc = ""
	id = "mech_proj_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	materials = list(/datum/material/iron=20000,/datum/material/gold=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_diamond_drill
	name = "Exosuit Module (Diamond Mining Drill)"
	desc = ""
	id = "mech_diamond_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	materials = list(/datum/material/iron=10000,/datum/material/diamond=6500)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_generator_nuclear
	name = "Exosuit Module (ExoNuclear Reactor)"
	desc = ""
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	materials = list(/datum/material/iron=10000,/datum/material/glass =  1000,/datum/material/silver=500)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_plasma_cutter
	name = "Exosuit Module Design (217-D Heavy Plasma Cutter)"
	desc = ""
	id = "mech_plasma_cutter"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 1000, /datum/material/plasma = 2000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_lmg
	name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	desc = ""
	id = "mech_lmg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_lmg_ammo
	name = "Ultra AC 2 Ammunition"
	desc = ""
	id = "mech_lmg_ammo"
	build_type = PROTOLATHE | MECHFAB
	build_path = /obj/item/mecha_ammo/lmg
	materials = list(/datum/material/iron=4000)
	construction_time = 20
	category = list("Exosuit Ammunition", "Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mech_sleeper
	name = "Exosuit Medical Equipment (Mounted Sleeper)"
	desc = ""
	id = "mech_sleeper"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/sleeper
	materials = list(/datum/material/iron=5000, /datum/material/glass =  10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_syringe_gun
	name = "Exosuit Medical Equipment (Syringe Gun)"
	desc = ""
	id = "mech_syringe_gun"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	materials = list(/datum/material/iron=3000, /datum/material/glass = 2000)
	construction_time = 200
	category = list("Exosuit Equipment")

/datum/design/mech_medical_beamgun
	name = "Exosuit Medical Equipment (Medical Beamgun)"
	desc = ""
	id = "mech_medi_beam"
	build_type = MECHFAB
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 8000, /datum/material/plasma = 3000, /datum/material/gold = 8000, /datum/material/diamond = 2000)
	construction_time = 250
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	category = list("Exosuit Equipment")
