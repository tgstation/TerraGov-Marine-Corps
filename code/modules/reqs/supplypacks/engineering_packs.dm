/*******************************************************************************
ENGINEERING
*******************************************************************************/
/datum/supply_packs/engineering
	group = "Engineering"
	containertype = /obj/structure/closet/crate/supply

/datum/supply_packs/engineering/powerloader
	name = "RPL-Y Cargo Loader"
	contains = list(/obj/vehicle/ridden/powerloader)
	cost = 200
	containertype = null

/datum/supply_packs/engineering/sandbags
	name = "50 empty sandbags"
	contains = list(/obj/item/stack/sandbags_empty/full)
	cost = 100

/datum/supply_packs/engineering/metal50
	name = "50 metal sheets"
	contains = list(/obj/item/stack/sheet/metal/large_stack)
	cost = 200

/datum/supply_packs/engineering/plas50
	name = "50 plasteel sheets"
	contains = list(/obj/item/stack/sheet/plasteel/large_stack)
	cost = 400

/datum/supply_packs/engineering/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/sheet/glass/glass/large_stack)
	cost = 100

/datum/supply_packs/engineering/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/sheet/wood/large_stack)
	cost = 100

/datum/supply_packs/engineering/plasmacutter
	name = "Plasma cutter"
	contains = list(/obj/item/tool/pickaxe/plasmacutter/)
	cost = 300

/datum/supply_packs/engineering/quikdeploycade
	name = "Quikdeploy barricade"
	contains = list(/obj/item/quikdeploy/cade)
	cost = 30

/datum/supply_packs/engineering/pacman
	name = "P.A.C.M.A.N. Portable Generator"
	contains = list(/obj/machinery/power/port_gen/pacman)
	cost = 150
	containertype = null

/datum/supply_packs/engineering/phoron
	name = "30 phoron sheets"
	contains = list(/obj/item/stack/sheet/mineral/phoron/medium_stack)
	cost = 200

/datum/supply_packs/engineering/electrical
	name = "Electrical maintenance supplies"
	contains = list(
		/obj/item/storage/toolbox/electrical,
		/obj/item/clothing/gloves/insulated,
		/obj/item/cell,
		/obj/item/cell/high,
	)
	cost = 50

/datum/supply_packs/engineering/mechanical
	name = "Mechanical maintenance crate"
	contains = list(
		/obj/item/storage/belt/utility/full,
		/obj/item/storage/belt/utility/full,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/hazardvest/lime,
		/obj/item/clothing/suit/storage/hazardvest/blue,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/hardhat,
	)
	cost = 100

/datum/supply_packs/engineering/fueltank
	name = "Fuel tank"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 100
	containertype = null

/datum/supply_packs/engineering/watertank
	name = "Water Tank"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 50
	containertype = null

/datum/supply_packs/engineering/inflatable
	name = "Inflatable barriers"
	notes = "Contains 3 doors and 4 walls"
	contains = list(/obj/item/storage/briefcase/inflatable)
	cost = 50

/datum/supply_packs/engineering/lightbulbs
	name = "Replacement lights"
	notes = "Contains 14 tubes, 7 bulbs"
	contains = list(/obj/item/storage/box/lights/mixed)
	cost = 50

/datum/supply_packs/engineering/foam_grenade
	name = "Foam grenade"
	contains = list(/obj/item/explosive/grenade/chem_grenade/metalfoam)
	cost = 30

/datum/supply_packs/engineering/floodlight
	name = "Deployable floodlight"
	contains = list(/obj/item/deployable_floodlight)
	cost = 30

/datum/supply_packs/engineering/advanced_generator
	name = "Wireless power generator"
	contains = list(/obj/machinery/power/port_gen/pacman/mobile_power)
	cost = 200

/datum/supply_packs/engineering/teleporter
	name = "Teleporter pads"
	contains = list(/obj/effect/teleporter_linker)
	cost = 500

/datum/supply_packs/engineering/tesla_turret
	name = "Tesla turret"
	contains = list(/obj/item/tesla_turret)
	cost = 400
