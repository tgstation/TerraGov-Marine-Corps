///Base item used in factories, only changes icon and stage for the item then creates a new item when its done
/obj/item/factory_part
	name = "test part"
	desc = "you shouldnt be seeing this"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "implant_evil"
	///How many cycles of processing we've gone through
	var/stage = 0
	///How many cycles we go through until we become the result
	var/completion_stage = 4
	///What type of machine the obj goes through first/next
	var/next_machine = FACTORY_MACHINE_FLATTER
	///Static reference to a glob list
	var/list/recipe = list()
	///What result we become when we've run through all our machines
	var/result = /obj/item/violin

/obj/item/factory_part/proc/advance_stage()
	stage++
	if(stage >= completion_stage)
		new result(loc)
		qdel(src)
		return
	next_machine = recipe[stage]["next_machine"]
	icon_state = recipe[stage]["icon_state"]

GLOBAL_LIST_INIT(phosnade_recipe, list(
			list("next_machine" = FACTORY_MACHINE_CUTTER, "icon_state" = "decompiler"),
			list("next_machine" = FACTORY_MACHINE_HEATER, "icon_state" = "battererburnt"),
			list("next_machine" = FACTORY_MACHINE_FORMER, "icon_state" = "batterer"),
			))

/obj/item/factory_part/phosnade
	name = "Phosphorus Grenade assembly"
	desc = "A incomplete phosphorus grenade assembly"
	result = /obj/item/explosive/grenade/phosphorus

/obj/item/factory_part/phosnade/Initialize()
	. = ..()
	recipe = GLOB.phosnade_recipe

GLOBAL_LIST_INIT(m15_recipe,  list(
		list("next_machine" = FACTORY_MACHINE_FORMER, "icon_state" = "r_arm"),
		list("next_machine" = FACTORY_MACHINE_CUTTER, "icon_state" = "r_leg"),
		))

/obj/item/factory_part/m15_nade
	name = "M15 grenade assembly"
	desc = "An incomplete M15 grenade"
	icon = 'icons/unused/r_predator.dmi'//aaaaaaa
	icon_state = "r_foot"
	result = /obj/item/explosive/grenade/frag/m15
	next_machine = FACTORY_MACHINE_CUTTER

/obj/item/factory_part/m15_nade/Initialize()
	. = ..()
	recipe = GLOB.phosnade_recipe
