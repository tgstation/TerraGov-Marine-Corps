/*******************************************************************************
FACTORY
*******************************************************************************/

/datum/supply_packs/factory
	group = "Factory"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/factory/cutter
	name = "Industrial cutter"
	contains = list(/obj/machinery/factory/cutter)
	cost = 50

/datum/supply_packs/factory/heater
	name = "Industrial heater"
	contains = list(/obj/machinery/factory/heater)
	cost = 50

/datum/supply_packs/factory/flatter
	name = "Industrial flatter"
	contains = list(/obj/machinery/factory/flatter)
	cost = 50

/datum/supply_packs/factory/former
	name = "Industrial former"
	contains = list(/obj/machinery/factory/former)
	cost = 50

/datum/supply_packs/factory/reconstructor
	name = "Industrial reconstructor"
	contains = list(/obj/machinery/factory/reconstructor)
	cost = 50

/datum/supply_packs/factory/driller
	name = "Industrial driller"
	contains = list(/obj/machinery/factory/driller)
	cost = 50

/datum/supply_packs/factory/galvanizer
	name = "Industrial galvanizer"
	contains = list(/obj/machinery/factory/galvanizer)
	cost = 50

/datum/supply_packs/factory/compressor
	name = "Industrial compressor"
	contains = list(/obj/machinery/factory/compressor)
	cost = 50

/datum/supply_packs/factory/unboxer
	name = "Industrial Unboxer"
	contains = list(/obj/machinery/unboxer)
	cost = 50

/datum/supply_packs/factory/conveyors
	name = "conveyor refill"
	contains = list(/obj/item/stack/conveyor/thirty, /obj/item/conveyor_switch_construct)
	cost = 300

/datum/supply_packs/factory/bignaderefill
	name = "Rounded M15 plates refill"
	contains = list(/obj/item/factory_refill/bignade_refill)
	cost = 550

/datum/supply_packs/factory/incennaderefill
	name = "Incendiary grenade refill"
	contains = list(/obj/item/factory_refill/incennade_refill)
	cost = 550

/datum/supply_packs/factory/stickynaderefill
	name = "Adhesive grenade refill"
	contains = list(/obj/item/factory_refill/stickynade_refill)
	cost = 450

/datum/supply_packs/factory/phosphosrefill
	name = "Phosphorus-resistant plates refill"
	contains = list(/obj/item/factory_refill/phosnade_refill)
	cost = 1050

/datum/supply_packs/factory/cloaknade_refill
	name = "Cloak grenade refill"
	contains = list(/obj/item/factory_refill/cloaknade_refill)
	cost = 450

/datum/supply_packs/factory/trailblazerrefill
	name = "Trailblazer grenade refill"
	contains = list(/obj/item/factory_refill/trailblazer_refill)
	cost = 750

/datum/supply_packs/factory/lasenaderefill
	name = "Laserburster grenade refill"
	contains = list(/obj/item/factory_refill/lasenade_refill)
	cost = 450

/datum/supply_packs/factory/hefanaderefill
	name = "HEFA fragmentation grenade refill"
	contains = list(/obj/item/factory_refill/hefanade_refill)
	cost = 750

/datum/supply_packs/factory/antigasrefill
	name = "Anti-Gas grenade refill"
	contains = list(/obj/item/factory_refill/antigas_refill)
	cost = 900

/datum/supply_packs/factory/razornade_refill
	name = "Razornade assembly refill"
	contains = list(/obj/item/factory_refill/razornade_refill)
	cost = 750

/datum/supply_packs/factory/sadar_refill_he
	name = "SADAR HE missile assembly refill"
	contains = list(/obj/item/factory_refill/sadar_he_refill)
	cost = 480

/datum/supply_packs/factory/sadar_refill_he_unguided
	name = "SADAR HE unguided missile assembly refill"
	contains = list(/obj/item/factory_refill/sadar_he_unguided_refill)
	cost = 480

/datum/supply_packs/factory/sadar_refill_ap
	name = "SADAR AP missile assembly refill"
	contains = list(/obj/item/factory_refill/sadar_ap_refill)
	cost = 580

/datum/supply_packs/factory/sadar_refill_wp
	name = "SADAR WP missile assembly refill"
	contains = list(/obj/item/factory_refill/sadar_wp_refill)
	cost = 380

/datum/supply_packs/factory/standard_recoilless_refill
	name = "RL-160 RR HE shell assembly refill"
	contains = list(/obj/item/factory_refill/normal_rr_missile_refill)
	cost = 280

/datum/supply_packs/factory/light_recoilless_refill
	name = "RL-160 RR LE shell assembly refill"
	contains = list(/obj/item/factory_refill/light_rr_missile_refill)
	cost = 280

/datum/supply_packs/factory/heat_recoilless_refill
	name = "RL-160 RR HEAT shell assembly refill"
	contains = list(/obj/item/factory_refill/heat_rr_missile_refill)
	cost = 280

/datum/supply_packs/factory/smoke_recoilless_refill
	name = "RL-160 RR smoke shell assembly refill"
	contains = list(/obj/item/factory_refill/smoke_rr_missile_refill)
	cost = 280

/datum/supply_packs/factory/cloak_recoilless_refill
	name = "RL-160 RR cloak shell assembly refill"
	contains = list(/obj/item/factory_refill/cloak_rr_missile_refill)
	cost = 280

/datum/supply_packs/factory/tfoot_recoilless_refill
	name = "RL-160 RR tanglefoot shell assembly refill"
	contains = list(/obj/item/factory_refill/tfoot_rr_missile_refill)
	cost = 280

/datum/supply_packs/factory/pizzarefill
	name = "Ninetails \"Eat healthy!\" margerita pizza kit refill"
	contains = list(/obj/item/factory_refill/pizza_refill)
	cost = 250 //allows a one point profit if all pizzas are processed and sold back to ASRS

/datum/supply_packs/factory/smartgun_minigun_box_refill
	name = "SG-85 ammo bin parts refill"
	contains = list(/obj/item/factory_refill/smartgunner_minigun_box_refill)
	cost = 350

/datum/supply_packs/factory/smartgun_magazine_refill
	name = "SG-29 ammo drum parts refill"
	contains = list(/obj/item/factory_refill/smartgunner_machinegun_magazine_refill)
	cost = 350

/datum/supply_packs/factory/smartgun_targetrifle_refill
	name = "SG-62 ammo magazine parts refill"
	contains = list(/obj/item/factory_refill/smartgunner_targetrifle_magazine_refill)
	cost = 400

/datum/supply_packs/factory/smartgun_targetrifle_ammobin_refill
	name = "SG-62 ammo bin parts refill"
	contains = list(/obj/item/factory_refill/smartgunner_targetrifle_ammobin_refill)
	cost = 400

/datum/supply_packs/factory/autosniper_magazine_refill
	name = "SR-81 IFF Auto Sniper magazine assembly refill"
	contains = list(/obj/item/factory_refill/auto_sniper_magazine_refill)
	cost = 380

/datum/supply_packs/factory/scout_rifle_magazine_refill
	name = "BR-8 scout rifle magazine assembly refill"
	contains = list(/obj/item/factory_refill/scout_rifle_magazine_refill)
	cost = 300

/datum/supply_packs/factory/scout_rifle_incen_magazine_refill
	name = "BR-8 scout rifle incendiary magazine assembly refill"
	contains = list(/obj/item/factory_refill/scout_rifle_incen_magazine_refill)
	cost = 600

/datum/supply_packs/factory/scout_rifle_impact_magazine_refill
	name = "BR-8 scout rifle impact magazine assembly refill"
	contains = list(/obj/item/factory_refill/scout_rifle_impact_magazine_refill)
	cost = 600

/datum/supply_packs/factory/claymorerefill
	name = "Claymore parts refill"
	contains = list(/obj/item/factory_refill/claymore_refill)
	cost = 280

/datum/supply_packs/factory/mateba_speedloader_refill
	name = "Mateba autorevolver speedloader assembly refill"
	contains = list(/obj/item/factory_refill/mateba_speedloader_refill)
	cost = 280

/datum/supply_packs/factory/railgun_magazine_refill
	name = "Railgun magazine assembly refill"
	contains = list(/obj/item/factory_refill/railgun_magazine_refill)
	cost = 180

/datum/supply_packs/factory/railgun_hvap_magazine_refill
	name = "Railgun HVAP magazine assembly refill"
	contains = list(/obj/item/factory_refill/railgun_hvap_magazine_refill)
	cost = 200

/datum/supply_packs/factory/railgun_smart_magazine_refill
	name = "Railgun magazine assembly refill"
	contains = list(/obj/item/factory_refill/railgun_smart_magazine_refill)
	cost = 200

/datum/supply_packs/factory/minigun_powerpack_refill
	name = "Minigun powerpack assembly refill"
	contains = list(/obj/item/factory_refill/minigun_powerpack_refill)
	cost = 230

/datum/supply_packs/factory/flak_sniper_refill
	name = "SR-127 flak magazine assembly refill"
	contains = list(/obj/item/factory_refill/sniper_flak_magazine_refill)
	cost = 600

/datum/supply_packs/factory/amr_magazine_refill
	name = "T-26 AMR standard magazine assembly refill"
	contains = list(/obj/item/factory_refill/amr_magazine_refill)
	cost = 380

/datum/supply_packs/factory/amr_magazine_incend_refill
	name = "T-26 AMR incendiary magazine assembly refill"
	contains = list(/obj/item/factory_refill/amr_magazine_incend_refill)
	cost = 380

/datum/supply_packs/factory/amr_magazine_flak_refill
	name = "T-26 AMR flak magazine assembly refill"
	contains = list(/obj/item/factory_refill/amr_magazine_flak_refill)
	cost = 380

/datum/supply_packs/factory/howitzer_shell_he_refill
	name = "Howitzer HE shell assembly refill"
	contains = list(/obj/item/factory_refill/howitzer_shell_he_refill)
	cost = 780

/datum/supply_packs/factory/howitzer_shell_incen_refill
	name = "Howitzer Incendiary shell assembly refill"
	contains = list(/obj/item/factory_refill/howitzer_shell_incen_refill)
	cost = 780

/datum/supply_packs/factory/howitzer_shell_wp_refill
	name = "Howitzer WP shell assembly refill"
	contains = list(/obj/item/factory_refill/howitzer_shell_wp_refill)
	cost = 980

/datum/supply_packs/factory/howitzer_shell_tfoot_refill
	name = "Howitzer Tanglefoot shell assembly refill"
	contains = list(/obj/item/factory_refill/howitzer_shell_tfoot_refill)
	cost = 980

/datum/supply_packs/factory/swat_mask_refill
	name = "SWAT mask assembly refill"
	contains = list(/obj/item/factory_refill/swat_mask_refill)
	cost = 480

/datum/supply_packs/factory/module_valk_refill
	name = "Valkyrie Automedical Armor System assembly refill"
	contains = list(/obj/item/factory_refill/module_valk_refill)
	cost = 580

/datum/supply_packs/factory/module_mimir2_refill
	name = "Mark 2 Mimir Environmental Resistance System assembly refill"
	contains = list(/obj/item/factory_refill/module_mimir2_refill)
	cost = 580

/datum/supply_packs/factory/module_tyr2_refill
	name = "Mark 2 Tyr Armor Reinforcement assembly refill"
	contains = list(/obj/item/factory_refill/module_tyr2_refill)
	cost = 580

/datum/supply_packs/factory/module_hlin_refill
	name = "Hlin Explosive Compensation Module assembly refill"
	contains = list(/obj/item/factory_refill/module_hlin_refill)
	cost = 580

/datum/supply_packs/factory/module_surt_refill
	name = "Surt Pyrotechnical Insulation System assembly refill"
	contains = list(/obj/item/factory_refill/module_surt_refill)
	cost = 580

/datum/supply_packs/factory/plastique_refill
	name = "C4 assembly refill"
	contains = list(/obj/item/factory_refill/plastique_refill)
	cost = 150

/datum/supply_packs/factory/plastique_incendiary_refill
	name = "EX-62 Genghis incendiary assembly refill"
	contains = list(/obj/item/factory_refill/plastique_incendiary_refill)
	cost = 500

/datum/supply_packs/factory/detpack_refill
	name = "Detpack assembly refill"
	contains = list(/obj/item/factory_refill/detpack_refill)
	cost = 250

/datum/supply_packs/factory/mortar_shell_he_refill
	name = "Mortar High Explosive shell assembly refill"
	contains = list(/obj/item/factory_refill/mortar_shell_he_refill)
	cost = 100

/datum/supply_packs/factory/mortar_shell_incen_refill
	name = "Mortar Incendiary shell assembly refill"
	contains = list(/obj/item/factory_refill/mortar_shell_incen_refill)
	cost = 100

/datum/supply_packs/factory/mortar_shell_tfoot_refill
	name = "Mortar Tanglefoot Gas shell assembly refill"
	contains = list(/obj/item/factory_refill/mortar_shell_tfoot_refill)
	cost = 180

/datum/supply_packs/factory/mortar_shell_flare_refill
	name = "Mortar Flare shell assembly refill"
	contains = list(/obj/item/factory_refill/mortar_shell_flare_refill)
	cost = 80

/datum/supply_packs/factory/mortar_shell_smoke_refill
	name = "Mortar Smoke shell assembly refill"
	contains = list(/obj/item/factory_refill/mortar_shell_smoke_refill)
	cost = 80

/datum/supply_packs/factory/mlrs_rocket_refill
	name = "MLRS High Explosive rocket assembly refill"
	contains = list(/obj/item/factory_refill/mlrs_rocket_refill)
	cost = 220

/datum/supply_packs/factory/mlrs_rocket_refill_cloak
	name = "MLRS 'S-2' Cloak rocket assembly refill"
	contains = list(/obj/item/factory_refill/mlrs_rocket_refill_cloak)
	cost = 240

/datum/supply_packs/factory/mlrs_rocket_refill_gas
	name = "MLRS 'X-50' gas rocket assembly refill"
	contains = list(/obj/item/factory_refill/mlrs_rocket_refill_gas)
	cost = 240

/datum/supply_packs/factory/mlrs_rocket_refill_incendiary
	name = "MLRS Incendiary rocket assembly refill"
	contains = list(/obj/item/factory_refill/mlrs_rocket_refill_incendiary)
	cost = 240

/datum/supply_packs/factory/agls_he_refill
	name = "AGLS HE magazine assembly refill"
	contains = list(/obj/item/factory_refill/agls_he_refill)
	cost = 300

/datum/supply_packs/factory/agls_frag_refill
	name = "AGLS FRAG magazine assembly refill"
	contains = list(/obj/item/factory_refill/agls_frag_refill)
	cost = 300

/datum/supply_packs/factory/agls_incendiary_refill
	name = "AGLS Incendiary magazine assembly refill"
	contains = list(/obj/item/factory_refill/agls_incendiary_refill)
	cost = 300

/datum/supply_packs/factory/agls_flare_refill
	name = "AGLS Flare magazine assembly refill"
	contains = list(/obj/item/factory_refill/agls_flare_refill)
	cost = 200

/datum/supply_packs/factory/agls_cloak_refill
	name = "AGLS Cloak magazine assembly refill"
	contains = list(/obj/item/factory_refill/agls_cloak_refill)
	cost = 200

/datum/supply_packs/factory/atgun_aphe_refill
	name = "AT-36 AP-HE shell assembly refill"
	contains = list(/obj/item/factory_refill/atgun_aphe_refill)
	cost = 200

/datum/supply_packs/factory/atgun_apcr_refill
	name = "AT-36 APCR shell assembly refill"
	contains = list(/obj/item/factory_refill/atgun_apcr_refill)
	cost = 200

/datum/supply_packs/factory/atgun_he_refill
	name = "AT-36 HE shell assembly refill"
	contains = list(/obj/item/factory_refill/atgun_he_refill)
	cost = 200

/datum/supply_packs/factory/atgun_beehive_refill
	name = "AT-36 Beehive shell assembly refill"
	contains = list(/obj/item/factory_refill/atgun_beehive_refill)
	cost = 200

/datum/supply_packs/factory/atgun_incend_refill
	name = "AT-36 Napalm shell assembly refill"
	contains = list(/obj/item/factory_refill/atgun_incend_refill)
	cost = 200

/datum/supply_packs/factory/heavy_isg_he_refill
	name = "FK-88 Flak HE shell assembly refill"
	contains = list(/obj/item/factory_refill/heavy_isg_he_refill)
	cost = 200

/datum/supply_packs/factory/heavy_isg_sabot_refill
	name = "FK-88 Flak APFDS shell assembly refill"
	contains = list(/obj/item/factory_refill/heavy_isg_sabot_refill)
	cost = 225

/datum/supply_packs/factory/ac_hv_refill
	name = "ATR-22 High Velocity magazine assembly refill"
	contains = list(/obj/item/factory_refill/ac_hv_refill)
	cost = 300

/datum/supply_packs/factory/ac_flak_refill
	name = "ATR-22 Flak magazine assembly refill"
	contains = list(/obj/item/factory_refill/ac_flak_refill)
	cost = 300

/datum/supply_packs/factory/thermobaric_wp_refill
	name = "RL-57 Thermobaric WP rocket array assembly refill"
	contains = list(/obj/item/factory_refill/thermobaric_wp_refill)
	cost = 480

/datum/supply_packs/factory/drop_pod_refill
	name = "Zeus orbital drop pod assembly refill"
	contains = list(/obj/item/factory_refill/drop_pod_refill)
	cost = 230

/// TO-DO-LATER
/datum/supply_packs/factory/ar12
	name = "AR12 assembly refill"
	notes = "Contains enough for three weapons"
	contains = list(/obj/item/factory_refill/basic_assaultrifle)
	cost = 180

/datum/supply_packs/factory/sr127
	name = "SR127 assembly refill"
	notes = "Contains enough for two weapons"
	contains = list(/obj/item/factory_refill/basic_sniperrifle)
	cost = 250

/datum/supply_packs/factory/st480
	name = "ST480 assembly refill"
	notes = "Contains enough for two automated guns"
	contains = list(/obj/item/factory_refill/light_sentry)
	cost = 600

/datum/supply_packs/factory/deployable_floodlight_refill
	name = "Deployable floodlight assembly refill"
	contains = list(/obj/item/factory_refill/deployable_floodlight_refill)
	cost = 150

/datum/supply_packs/factory/deployable_camera_refill
	name = "Deplyable security camera refill"
	contains = list(/obj/item/factory_refill/deployable_camera_refill)
	cost = 100

/datum/supply_packs/factory/cigarette_refill
	name = "500 Cigarettes refill"
	contains = list(/obj/item/factory_refill/cigarette_refill)
	cost = 500
