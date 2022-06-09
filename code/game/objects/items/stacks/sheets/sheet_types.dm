/* Diffrent misc types of sheets
* Contains:
*		Metal
*		Plasteel
*		Wood
*		Cloth
*		Cardboard
*/

/*
* Metal
*/
GLOBAL_LIST_INIT(metal_recipes, list ( \
	new/datum/stack_recipe("metal barricade", /obj/structure/barricade/metal, 4, time = 8 SECONDS, max_per_turf = STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_METAL), \
	new/datum/stack_recipe("barbed wire", /obj/item/stack/barbed_wire, 2, 1, 20, time = 1 SECONDS, skill_req = SKILL_CONSTRUCTION_METAL), \
	new/datum/stack_recipe("razor wire", /obj/item/stack/razorwire, 3, 1, 20, time = 5 SECONDS, skill_req = SKILL_CONSTRUCTION_METAL), \
	null, \
	new/datum/stack_recipe("apc frame", /obj/item/frame/apc, 2), \
	new/datum/stack_recipe("wall girder", /obj/structure/girder, 8, time = 10 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_ADVANCED), \
	new/datum/stack_recipe("metal rod", /obj/item/stack/rods, 1, 4, 60), \
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20), \
	new/datum/stack_recipe("grenade casing", /obj/item/explosive/grenade/chem_grenade), \
	null, \
	new/datum/stack_recipe("bed", /obj/structure/bed, 2, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE), \
	new/datum/stack_recipe("chair", /obj/structure/bed/chair, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE), \
	new/datum/stack_recipe("comfy chair", /obj/structure/bed/chair/comfy/beige, 2, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE), \
	new/datum/stack_recipe("office chair",/obj/structure/bed/chair/office/dark, 2, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE), \
	new/datum/stack_recipe("light fixture frame", /obj/item/frame/light_fixture, 2), \
	new/datum/stack_recipe("small light fixture frame", /obj/item/frame/light_fixture/small, 1), \
	new/datum/stack_recipe_list("airlock assemblies", list( \
		new/datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		new/datum/stack_recipe("multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 4, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE, skill_req = SKILL_CONSTRUCTION_MASTER), \
		), 4), \
	null, \
	))

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out of metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	flags_item = NOBLUDGEON
	materials = list(/datum/material/metal = 4000)
	throwforce = 14.0
	flags_atom = CONDUCT
	merge_type = /obj/item/stack/sheet/metal
	number_of_extra_variants = 3


/obj/item/stack/sheet/metal/small_stack
	amount = 10

/obj/item/stack/sheet/metal/medium_stack
	amount = 25

/obj/item/stack/sheet/metal/large_stack
	amount = 50

/obj/item/stack/sheet/metal/cyborg

/obj/item/stack/sheet/metal/Initialize(mapload, amount)
	. = ..()
	recipes = GLOB.metal_recipes

/*
* Plasteel
*/
GLOBAL_LIST_INIT(plasteel_recipes, list ( \
	new/datum/stack_recipe("metal crate", /obj/structure/closet/crate, 5, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE), \
	new/datum/stack_recipe("plasteel barricade", /obj/structure/barricade/plasteel, 5, time = 8 SECONDS, max_per_turf = STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE, on_floor = TRUE, skill_req =  SKILL_CONSTRUCTION_PLASTEEL)
	))

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and phoron."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	flags_item = NOBLUDGEON
	materials = list(/datum/material/metal = 7500)
	throwforce = 15.0
	flags_atom = CONDUCT
	merge_type = /obj/item/stack/sheet/plasteel
	number_of_extra_variants = 3

/obj/item/stack/sheet/plasteel/Initialize(mapload, amount)
	. = ..()
	recipes = GLOB.plasteel_recipes


/obj/item/stack/sheet/plasteel/small_stack
	amount = 10

/obj/item/stack/sheet/plasteel/medium_stack
	amount = 30

/obj/item/stack/sheet/plasteel/large_stack
	amount = 50

/*
* Wood
*/
GLOBAL_LIST_INIT(wood_recipes, list ( \
	new/datum/stack_recipe("pair of wooden sandals", /obj/item/clothing/shoes/sandal, 1), \
	new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20), \
	/*
	new/datum/stack_recipe("table parts", /obj/item/frame/table/wood, 2), \
	*/
	new/datum/stack_recipe("wooden chair", /obj/structure/bed/chair/wood/normal, 1, time = 1 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE), \
	new/datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 5 SECONDS, max_per_turf = STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE, on_floor = TRUE), \

	new/datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 2 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE), \
	new/datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 1.5 SECONDS, max_per_turf = STACK_RECIPE_ONE_PER_TILE, on_floor = TRUE), \
	new/datum/stack_recipe("baseball bat", /obj/item/weapon/baseballbat, 10, time = 2 SECONDS, on_floor = TRUE) \
	))

/obj/item/stack/sheet/wood
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	merge_type = /obj/item/stack/sheet/wood
	number_of_extra_variants = 3

/obj/item/stack/sheet/wood/large_stack
	amount = 50


/obj/item/stack/sheet/wood/cyborg
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"

/obj/item/stack/sheet/wood/Initialize(mapload, amount)
	. = ..()
	recipes = GLOB.wood_recipes

/*
* Cloth
*/
/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "This roll of cloth is made from only the finest chemicals and bunny rabbits."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"


/*
* Cardboard
*/
GLOBAL_LIST_INIT(cardboard_recipes, list ( \
	new/datum/stack_recipe("box", /obj/item/storage/box), \
	new/datum/stack_recipe("donut box", /obj/item/storage/donut_box/empty), \
	new/datum/stack_recipe("egg box", /obj/item/storage/fancy/egg_box), \
	new/datum/stack_recipe("light tubes", /obj/item/storage/box/lights/tubes), \
	new/datum/stack_recipe("light bulbs", /obj/item/storage/box/lights/bulbs), \
	new/datum/stack_recipe("mouse traps", /obj/item/storage/box/mousetraps), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg), \
	new/datum/stack_recipe("pizza box", /obj/item/pizzabox), \
	null, \
	new/datum/stack_recipe_list("folders",list( \
		new/datum/stack_recipe("blue folder", /obj/item/folder/blue), \
		new/datum/stack_recipe("grey folder", /obj/item/folder), \
		new/datum/stack_recipe("red folder", /obj/item/folder/red), \
		new/datum/stack_recipe("white folder", /obj/item/folder/white), \
		new/datum/stack_recipe("yellow folder", /obj/item/folder/yellow), \
		)), \
	null, \
	new/datum/stack_recipe_list("pistol boxes",list( \
		new/datum/stack_recipe("P-14 mag box", /obj/item/storage/box/visual/magazine/compact/standard_pistol), \
		new/datum/stack_recipe("P-23 mag box", /obj/item/storage/box/visual/magazine/compact/standard_heavypistol), \
		new/datum/stack_recipe("R-44 mag box", /obj/item/storage/box/visual/magazine/compact/standard_revolver), \
		new/datum/stack_recipe("P-17 mag box", /obj/item/storage/box/visual/magazine/compact/standard_pocketpistol), \
		new/datum/stack_recipe("88M4 mag box", /obj/item/storage/box/visual/magazine/compact/vp70), \
		new/datum/stack_recipe("Derringer packet box", /obj/item/storage/box/visual/magazine/compact/derringer), \
		new/datum/stack_recipe("PP-7 plasma cell box", /obj/item/storage/box/visual/magazine/compact/plasma_pistol), \
		)), \
	new/datum/stack_recipe_list("smg boxes",list( \
		new/datum/stack_recipe("SMG-90 mag box", /obj/item/storage/box/visual/magazine/compact/standard_smg), \
		new/datum/stack_recipe("MP-19 mag box", /obj/item/storage/box/visual/magazine/compact/standard_machinepistol), \
		new/datum/stack_recipe("PPSh drum mag box", /obj/item/storage/box/visual/magazine/compact/ppsh), \
		new/datum/stack_recipe("Pepperball canister box", /obj/item/storage/box/visual/magazine/compact/pepperball), \
		)), \
	new/datum/stack_recipe_list("rifle boxes",list( \
		new/datum/stack_recipe("AR-12 mag box", /obj/item/storage/box/visual/magazine/compact/standard_assaultrifle), \
		new/datum/stack_recipe("AR-18 mag box", /obj/item/storage/box/visual/magazine/compact/standard_carbine), \
		new/datum/stack_recipe("AR-21 mag box", /obj/item/storage/box/visual/magazine/compact/standard_skirmishrifle), \
		new/datum/stack_recipe("AR-11 mag box", /obj/item/storage/box/visual/magazine/compact/tx11), \
		new/datum/stack_recipe("Martini Henry packet box", /obj/item/storage/box/visual/magazine/compact/martini), \
		new/datum/stack_recipe("TE cell box", /obj/item/storage/box/visual/magazine/compact/lasrifle/marine), \
		new/datum/stack_recipe("SH-15 mag box", /obj/item/storage/box/visual/magazine/compact/tx15), \
		)), \
	new/datum/stack_recipe_list("marksmen rifle boxes",list( \
		new/datum/stack_recipe("DMR-37 mag box", /obj/item/storage/box/visual/magazine/compact/standard_dmr), \
		new/datum/stack_recipe("BR-64 mag box", /obj/item/storage/box/visual/magazine/compact/standard_br), \
		new/datum/stack_recipe("SR-127 mag box", /obj/item/storage/box/visual/magazine/compact/chamberedrifle), \
		new/datum/stack_recipe("Mosin packet box", /obj/item/storage/box/visual/magazine/compact/mosin), \
		)), \
	new/datum/stack_recipe_list("machinegun boxes",list( \
		new/datum/stack_recipe("MG-42 drum mag box", /obj/item/storage/box/visual/magazine/compact/standard_lmg), \
		new/datum/stack_recipe("MG-60 mag box", /obj/item/storage/box/visual/magazine/compact/standard_gpmg), \
		new/datum/stack_recipe("MG-27 mag box", /obj/item/storage/box/visual/magazine/compact/standard_mmg), \
		new/datum/stack_recipe("HMG-08 drum box", /obj/item/storage/box/visual/magazine/compact/heavymachinegun), \
		)) \
	))

/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"


/obj/item/stack/sheet/cardboard/Initialize(mapload, amount)
	. = ..()
	recipes = GLOB.cardboard_recipes
