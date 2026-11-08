/*******************************************************************************
FACTORY
*******************************************************************************/

/datum/supply_packs/factory
	group = "Factory"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/factory/cutter
	name = "Industrial cutter"
	contains = list(/obj/machinery/factory/cutter)
	cost = 10

/datum/supply_packs/factory/heater
	name = "Industrial heater"
	contains = list(/obj/machinery/factory/heater)
	cost = 10

/datum/supply_packs/factory/flatter
	name = "Industrial flatter"
	contains = list(/obj/machinery/factory/flatter)
	cost = 10

/datum/supply_packs/factory/former
	name = "Industrial former"
	contains = list(/obj/machinery/factory/former)
	cost = 10

/datum/supply_packs/factory/reconstructor
	name = "Industrial reconstructor"
	contains = list(/obj/machinery/factory/reconstructor)
	cost = 10

/datum/supply_packs/factory/driller
	name = "Industrial driller"
	contains = list(/obj/machinery/factory/driller)
	cost = 10

/datum/supply_packs/factory/galvanizer
	name = "Industrial galvanizer"
	contains = list(/obj/machinery/factory/galvanizer)
	cost = 10

/datum/supply_packs/factory/compressor
	name = "Industrial compressor"
	contains = list(/obj/machinery/factory/compressor)
	cost = 10

/datum/supply_packs/factory/unboxer
	name = "Industrial Unboxer"
	contains = list(/obj/machinery/unboxer)
	cost = 10

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
	name = "White phosophorous grenade refill"
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

/datum/supply_packs/factory/pizzarefill
	name = "Nanotrasen \"Eat healthy!\" margherita pizza kit refill"
	contains = list(/obj/item/factory_refill/pizza_refill)
	cost = 290 //allows a one point profit if all pizzas are processed and sold back to ASRS

/datum/supply_packs/factory/swat_mask_refill
	name = "SWAT mask assembly refill"
	contains = list(/obj/item/factory_refill/swat_mask_refill)
	cost = 500

/datum/supply_packs/factory/module_valk_refill
	name = "Valkyrie autodoc armor module assembly refill"
	contains = list(/obj/item/factory_refill/module_valk_refill)
	cost = 600

/datum/supply_packs/factory/module_mimir2_refill
	name = "Mimir mark 2 module set assembly refill"
	contains = list(/obj/item/factory_refill/module_mimir2_refill)
	cost = 600

/datum/supply_packs/factory/module_tyr2_refill
	name = "Tyr mark 2 armor module assembly refill"
	contains = list(/obj/item/factory_refill/module_tyr2_refill)
	cost = 600

/datum/supply_packs/factory/module_hlin_refill
	name = "Hlin explosive armor module assembly refill"
	contains = list(/obj/item/factory_refill/module_hlin_refill)
	cost = 600

/datum/supply_packs/factory/module_surt_refill
	name = "Surt fireproof module set assembly refill"
	contains = list(/obj/item/factory_refill/module_surt_refill)
	cost = 600

/datum/supply_packs/factory/plastique_refill
	name = "C4 plastic explosive assembly refill"
	contains = list(/obj/item/factory_refill/plastique_refill)
	cost = 150

/datum/supply_packs/factory/plastique_incendiary_refill
	name = "EX-62 Genghis incendiary charge assembly refill"
	contains = list(/obj/item/factory_refill/plastique_incendiary_refill)
	cost = 150

/datum/supply_packs/factory/detpack_refill
	name = "Detpack explosive assembly refill"
	contains = list(/obj/item/factory_refill/detpack_refill)
	cost = 250

/datum/supply_packs/factory/drop_pod_refill
	name = "Zeus orbital drop pod assembly refill"
	contains = list(/obj/item/factory_refill/drop_pod_refill)
	cost = 250

/datum/supply_packs/factory/deployable_floodlight_refill
	name = "Deployable floodlight assembly refill"
	contains = list(/obj/item/factory_refill/deployable_floodlight_refill)
	cost = 150

/datum/supply_packs/factory/deployable_camera_refill
	name = "Deployable camera assembly refill"
	contains = list(/obj/item/factory_refill/deployable_camera_refill)
	cost = 100

/datum/supply_packs/factory/cigarette_refill
	name = "500 cigarettes assembly refill"
	contains = list(/obj/item/factory_refill/cigarette_refill)
	cost = 500
