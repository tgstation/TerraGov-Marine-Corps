///Base item used in factories, only changes icon and stage for the item then creates a new item when its done
///in order to set a recipe set recipe = GLOB.myrecipe in Initialize
/obj/item/factory_part
	name = "test part"
	desc = "you shouldnt be seeing this"
	icon = 'icons/obj/factory/factoryparts.dmi'
	icon_state = "implant_evil"
	///How many cycles of processing we've gone through
	var/stage = 0
	///How many cycles we go through until we become the result
	var/completion_stage = 4
	///What type of machine the obj goes through first/next
	var/next_machine = FACTORY_MACHINE_FLATTER
	///reference to a glob list containing the recipe
	var/list/recipe
	///What result we become when we've run through all our machines
	var/result = /obj/item/violin

///once the part is processed this proc updates iconstate, result, completion etc
/obj/item/factory_part/proc/advance_stage()
	stage++
	if(stage >= completion_stage)
		new result(loc)
		qdel(src)
		return
	next_machine = recipe[stage][STEP_NEXT_MACHINE]
	icon_state = recipe[stage][STEP_ICON_STATE]

GLOBAL_LIST_INIT(phosnade_recipe, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "hotplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FORMER, STEP_ICON_STATE = "barrelplate"),
	))

/obj/item/factory_part/phosnade
	name = "Phosphorus Grenade assembly"
	desc = "A incomplete phosphorus grenade assembly"
	icon_state = "uncutplate"
	result = /obj/item/explosive/grenade/phosphorus

/obj/item/factory_part/phosnade/Initialize()
	. = ..()
	recipe = GLOB.phosnade_recipe

GLOBAL_LIST_INIT(bignade_recipe,  list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FORMER, STEP_ICON_STATE = "roundplate"),
	))

/obj/item/factory_part/bignade
	name = "M15 grenade assembly"
	desc = "An incomplete M15 grenade"
	icon_state = "uncutplate"
	result = /obj/item/explosive/grenade/frag/m15
	next_machine = FACTORY_MACHINE_CUTTER

/obj/item/factory_part/bignade/Initialize()
	. = ..()
	recipe = GLOB.bignade_recipe

// to add
//pizza
//sadar 3 ammo types
//rr two ammo types
//claymores
//mortar ammo
//sg ammo
