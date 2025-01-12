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
	new/datum/stack_recipe("metal barricade", /obj/structure/barricade/metal, 4, time = 8 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_CHECK_DIRECTION | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_METAL), \
	new/datum/stack_recipe("barbed wire", /obj/item/stack/barbed_wire, 1, 1, 20, time = 1 SECONDS, crafting_flags = NONE, skill_req = SKILL_CONSTRUCTION_METAL), \
	new/datum/stack_recipe("razor wire", /obj/item/stack/razorwire, 4, 2, 20, time = 5 SECONDS, crafting_flags = NONE, skill_req = SKILL_CONSTRUCTION_METAL), \
	null, \
	new/datum/stack_recipe("apc frame", /obj/item/frame/apc, 2, crafting_flags = NONE), \
	new/datum/stack_recipe("wall girder", /obj/structure/girder, 8, time = 10 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_ADVANCED), \
	new/datum/stack_recipe("window frame", /obj/structure/window_frame, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_METAL), \
	new/datum/stack_recipe("metal rod", /obj/item/stack/rods, 1, 4, 60, crafting_flags = NONE), \
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20, crafting_flags = NONE), \
	null, \
	new/datum/stack_recipe("bed", /obj/structure/bed, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	new/datum/stack_recipe("chair", /obj/structure/bed/chair, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	new/datum/stack_recipe("comfy chair", /obj/structure/bed/chair/comfy/beige, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	new/datum/stack_recipe("office chair",/obj/structure/bed/chair/office/dark, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	new/datum/stack_recipe("light fixture frame", /obj/item/frame/light_fixture, req_amount = 2, crafting_flags = NONE), \
	new/datum/stack_recipe("small light fixture frame", /obj/item/frame/light_fixture/small, crafting_flags = NONE), \
	new/datum/stack_recipe("table parts", /obj/item/frame/table, crafting_flags = NONE), \
	new/datum/stack_recipe("reinforced table parts", /obj/item/frame/table/reinforced, req_amount = 2, crafting_flags = NONE), \
	new/datum/stack_recipe("rack parts", /obj/item/frame/rack, crafting_flags = NONE), \
	new/datum/stack_recipe_list("airlock assemblies", list( \
		new/datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		new/datum/stack_recipe("multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_EXPERT), \
		), 4), \
	null, \
	))


GLOBAL_LIST_INIT(metal_radial_images, list(
	"recipes" = image('icons/obj/structures/barricades/misc.dmi', icon_state = "plus"),
	"barricade" = image('icons/obj/structures/barricades/metal.dmi', icon_state = "metal_0"),
	"razorwire" = image('icons/obj/structures/barricades/barbedwire.dmi', icon_state = "barbedwire_assembly"),
	"barbedwire" = image('icons/obj/stack_objects.dmi', icon_state = "barbed_wire")
	))

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out of metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	worn_icon_state = "sheet-metal"
	item_flags = NOBLUDGEON
	throwforce = 14
	atom_flags = CONDUCT
	merge_type = /obj/item/stack/sheet/metal
	number_of_extra_variants = 3


/obj/item/stack/sheet/metal/small_stack
	amount = 10

/obj/item/stack/sheet/metal/medium_stack
	amount = 25

/obj/item/stack/sheet/metal/large_stack
	amount = 50

/obj/item/stack/sheet/metal/cyborg

/obj/item/stack/sheet/metal/get_main_recipes()
	. = ..()
	. += GLOB.metal_recipes

/obj/item/stack/sheet/metal/select_radial(mob/user)
	if(user.get_active_held_item() != src)
		return
	if(!can_interact(user))
		return TRUE

	add_fingerprint(usr, "topic")

	var/choice = show_radial_menu(user, src, GLOB.metal_radial_images, require_near = TRUE)

	switch (choice)
		if("recipes")
			return TRUE
		if("barricade")
			create_object(user, new/datum/stack_recipe("metal barricade", /obj/structure/barricade/metal, 4, time = 8 SECONDS, crafting_flags = CRAFT_CHECK_DIRECTION | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_METAL), 1)
		if("barbedwire")
			create_object(user, new/datum/stack_recipe("barbed wire", /obj/item/stack/barbed_wire, 1, 1, 20, time = 1 SECONDS, crafting_flags = NONE, skill_req = SKILL_CONSTRUCTION_METAL), 1)
		if("razorwire")
			create_object(user, new/datum/stack_recipe("razor wire", /obj/item/stack/razorwire, 4, 2, 20, time = 5 SECONDS, crafting_flags = NONE, skill_req = SKILL_CONSTRUCTION_METAL), 1)

	return FALSE

/*
* Plasteel
*/

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and phoron."
	icon_state = "sheet-plasteel"
	worn_icon_state = "sheet-plasteel"
	item_flags = NOBLUDGEON
	throwforce = 15
	atom_flags = CONDUCT
	merge_type = /obj/item/stack/sheet/plasteel
	number_of_extra_variants = 3

/obj/item/stack/sheet/plasteel/attack_self(mob/user)
	. = ..()
	create_object(user, new/datum/stack_recipe("plasteel barricade", /obj/structure/barricade/plasteel, 5, time = 8 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_CHECK_DIRECTION | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_PLASTEEL), 1)

GLOBAL_LIST_INIT(plasteel_recipes, list( \
	new/datum/stack_recipe("plasteel barricade", /obj/structure/barricade/plasteel, 5, time = 8 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_CHECK_DIRECTION | CRAFT_ON_SOLID_GROUND, skill_req = SKILL_CONSTRUCTION_PLASTEEL), \
))

/obj/item/stack/sheet/plasteel/get_main_recipes()
	. = ..()
	. += GLOB.plasteel_recipes

/obj/item/stack/sheet/plasteel/small_stack
	amount = 10

/obj/item/stack/sheet/plasteel/medium_stack
	amount = 30

/obj/item/stack/sheet/plasteel/large_stack
	amount = 50

/*
* Wood
*/
GLOBAL_LIST_INIT(wood_radial_images, list(
	"recipes" = image('icons/obj/structures/barricades/misc.dmi', icon_state = "plus"),
	"barricade" = image('icons/obj/structures/barricades/misc.dmi', icon_state = "wooden"),
	"chair" = image('icons/obj/objects.dmi', icon_state = "wooden_chair"),
	"tile" = image('icons/obj/stack_objects.dmi', icon_state = "tile-wood"),
	"crate" = image('icons/obj/structures/crates.dmi', icon_state = "secure_crate")
	))


/obj/item/stack/sheet/wood
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	worn_icon_state = "sheet-wood"
	merge_type = /obj/item/stack/sheet/wood
	number_of_extra_variants = 3

GLOBAL_LIST_INIT(wood_recipes, list ( \
	new/datum/stack_recipe("pair of wooden sandals", /obj/item/clothing/shoes/sandal, 1), \
	new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20), \
	/*
	new/datum/stack_recipe("table parts", /obj/item/frame/table/wood, 2), \
	*/
	new/datum/stack_recipe("wooden chair", /obj/structure/bed/chair/wood/normal, 1, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	new/datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_CHECK_DIRECTION | CRAFT_ON_SOLID_GROUND), \

	new/datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	new/datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 1.5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	new/datum/stack_recipe("baseball bat", /obj/item/weapon/baseballbat, 10, time = 2 SECONDS, crafting_flags = NONE), \
	new/datum/stack_recipe("wooden crate", /obj/structure/largecrate/packed, 5, time = 2 SECONDS, crafting_flags = NONE) \
	))

/obj/item/stack/sheet/wood/get_main_recipes()
	. = ..()
	. += GLOB.wood_recipes

/obj/item/stack/sheet/wood/select_radial(mob/user)
	if(user.get_active_held_item() != src)
		return
	if(!can_interact(user))
		return TRUE

	add_fingerprint(usr, "topic")

	var/choice = show_radial_menu(user, src, GLOB.wood_radial_images, require_near = TRUE)

	switch (choice)
		if("recipes")
			return TRUE
		if("barricade")
			create_object(user, new/datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_CHECK_DIRECTION | CRAFT_ON_SOLID_GROUND), 1)
		if("chair")
			create_object(user, new/datum/stack_recipe("wooden chair", /obj/structure/bed/chair/wood/normal, 1, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), 1)
		if("tile")
			create_object(user, new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20, crafting_flags = NONE), 1)
		if("crate")
			create_object(user, new/datum/stack_recipe("wooden crate", /obj/structure/largecrate/packed, 5, time = 2 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND), 1)

	return FALSE

/obj/item/stack/sheet/wood/five
	amount = 5

/obj/item/stack/sheet/wood/large_stack
	amount = 50

/obj/item/stack/sheet/wood/cyborg
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"

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
/obj/item/stack/sheet/cardboard
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"

GLOBAL_LIST_INIT(cardboard_recipes, list ( \
	new/datum/stack_recipe("box", /obj/item/storage/box, crafting_flags = NONE), \
	new/datum/stack_recipe("donut box", /obj/item/storage/donut_box/empty, crafting_flags = NONE), \
	new/datum/stack_recipe("egg box", /obj/item/storage/fancy/egg_box, crafting_flags = NONE), \
	new/datum/stack_recipe("light tubes", /obj/item/storage/box/lights/tubes, crafting_flags = NONE), \
	new/datum/stack_recipe("light bulbs", /obj/item/storage/box/lights/bulbs, crafting_flags = NONE), \
	new/datum/stack_recipe("mouse traps", /obj/item/storage/box/mousetraps, crafting_flags = NONE), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3, crafting_flags = NONE), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg, crafting_flags = NONE), \
	new/datum/stack_recipe("pizza box", /obj/item/pizzabox, crafting_flags = NONE), \
	null, \
	new/datum/stack_recipe_list("folders",list( \
		new/datum/stack_recipe("blue folder", /obj/item/folder/blue, crafting_flags = NONE), \
		new/datum/stack_recipe("grey folder", /obj/item/folder, crafting_flags = NONE), \
		new/datum/stack_recipe("red folder", /obj/item/folder/red, crafting_flags = NONE), \
		new/datum/stack_recipe("white folder", /obj/item/folder/white, crafting_flags = NONE), \
		new/datum/stack_recipe("yellow folder", /obj/item/folder/yellow, crafting_flags = NONE), \
		)), \
	null, \
	new/datum/stack_recipe_list("pistol boxes",list( \
		new/datum/stack_recipe("P-14 mag box", /obj/item/storage/box/visual/magazine/compact/standard_pistol, crafting_flags = NONE), \
		new/datum/stack_recipe("P-23 mag box", /obj/item/storage/box/visual/magazine/compact/standard_heavypistol, crafting_flags = NONE), \
		new/datum/stack_recipe("R-44 mag box", /obj/item/storage/box/visual/magazine/compact/standard_revolver, crafting_flags = NONE), \
		new/datum/stack_recipe("P-17 mag box", /obj/item/storage/box/visual/magazine/compact/standard_pocketpistol, crafting_flags = NONE), \
		new/datum/stack_recipe("88M4 mag box", /obj/item/storage/box/visual/magazine/compact/vp70, crafting_flags = NONE), \
		new/datum/stack_recipe("Derringer packet box", /obj/item/storage/box/visual/magazine/compact/derringer, crafting_flags = NONE), \
		new/datum/stack_recipe("PP-7 plasma cell box", /obj/item/storage/box/visual/magazine/compact/plasma_pistol, crafting_flags = NONE), \
		)), \
	new/datum/stack_recipe_list("smg boxes",list( \
		new/datum/stack_recipe("SMG-90 mag box", /obj/item/storage/box/visual/magazine/compact/standard_smg, crafting_flags = NONE), \
		new/datum/stack_recipe("MP-19 mag box", /obj/item/storage/box/visual/magazine/compact/standard_machinepistol, crafting_flags = NONE), \
		new/datum/stack_recipe("Pepperball canister box", /obj/item/storage/box/visual/magazine/compact/pepperball, crafting_flags = NONE), \
		)), \
	new/datum/stack_recipe_list("rifle boxes",list( \
		new/datum/stack_recipe("AR-12 mag box", /obj/item/storage/box/visual/magazine/compact/standard_assaultrifle, crafting_flags = NONE), \
		new/datum/stack_recipe("AR-18 mag box", /obj/item/storage/box/visual/magazine/compact/standard_carbine, crafting_flags = NONE), \
		new/datum/stack_recipe("AR-21 mag box", /obj/item/storage/box/visual/magazine/compact/standard_skirmishrifle, crafting_flags = NONE), \
		new/datum/stack_recipe("AR-11 mag box", /obj/item/storage/box/visual/magazine/compact/ar11, crafting_flags = NONE), \
		new/datum/stack_recipe("Martini Henry packet box", /obj/item/storage/box/visual/magazine/compact/martini, crafting_flags = NONE), \
		new/datum/stack_recipe("TE cell box", /obj/item/storage/box/visual/magazine/compact/lasrifle/marine, crafting_flags = NONE), \
		new/datum/stack_recipe("SH-15 mag box", /obj/item/storage/box/visual/magazine/compact/sh15, crafting_flags = NONE), \
		)), \
	new/datum/stack_recipe_list("marksmen rifle boxes",list( \
		new/datum/stack_recipe("DMR-37 mag box", /obj/item/storage/box/visual/magazine/compact/standard_dmr, crafting_flags = NONE), \
		new/datum/stack_recipe("BR-64 mag box", /obj/item/storage/box/visual/magazine/compact/standard_br, crafting_flags = NONE), \
		new/datum/stack_recipe("SR-127 mag box", /obj/item/storage/box/visual/magazine/compact/chamberedrifle, crafting_flags = NONE), \
		new/datum/stack_recipe("Mosin packet box", /obj/item/storage/box/visual/magazine/compact/mosin, crafting_flags = NONE), \
		)), \
	new/datum/stack_recipe_list("machinegun boxes",list( \
		new/datum/stack_recipe("MG-42 drum mag box", /obj/item/storage/box/visual/magazine/compact/standard_lmg, crafting_flags = NONE), \
		new/datum/stack_recipe("MG-60 mag box", /obj/item/storage/box/visual/magazine/compact/standard_gpmg, crafting_flags = NONE), \
		new/datum/stack_recipe("MG-27 mag box", /obj/item/storage/box/visual/magazine/compact/standard_mmg, crafting_flags = NONE), \
		new/datum/stack_recipe("HMG-08 drum box", /obj/item/storage/box/visual/magazine/compact/heavymachinegun, crafting_flags = NONE), \
		)) \
	))

/obj/item/stack/sheet/cardboard/get_main_recipes()
	. = ..()
	. += GLOB.cardboard_recipes
