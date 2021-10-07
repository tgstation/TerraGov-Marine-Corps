/* Glass stack types
* Contains:
*		Glass sheets
*		Reinforced glass sheets
*		Phoron Glass Sheets
*		Reinforced Phoron Glass Sheets (AKA Holy fuck strong windows)
*/

/*
* Glass sheets
*/
/obj/item/stack/sheet/glass
	name = "glass"
	desc = "Glass is a non-crystalline solid, made out of silicate, the primary constituent of sand. It is valued for its transparency, albeit it is not too resistant to damage."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	materials = list(/datum/material/glass = 3750)
	merge_type = /obj/item/stack/sheet/glass
	var/created_window = /obj/structure/window
	var/reinforced_type = /obj/item/stack/sheet/glass/reinforced
	var/is_reinforced = FALSE

/obj/item/stack/sheet/glass/Initialize(mapload, new_amount)
	. = ..()
	recipes = list(new/datum/stack_recipe("directional window", created_window, 1, time = 4 SECONDS, max_per_turf = STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE, on_floor = TRUE, skill_req =  SKILL_CONSTRUCTION_PLASTEEL),\
				new/datum/stack_recipe("fulltile window", text2path("[created_window]/full"), 4, time = 4 SECONDS, max_per_turf = STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE, on_floor = TRUE, skill_req =  SKILL_CONSTRUCTION_PLASTEEL),\
				new/datum/stack_recipe("windoor", /obj/structure/windoor_assembly, 5, time = 4 SECONDS, max_per_turf = STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE, on_floor = TRUE, skill_req =  SKILL_CONSTRUCTION_PLASTEEL))

/obj/item/stack/sheet/glass/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(is_reinforced)
		return

	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/V  = I
		if(V.get_amount() < 1 || get_amount() < 1)
			to_chat(user, span_warning("You need one rod and one sheet of glass to make reinforced glass."))
			return

		var/obj/item/stack/sheet/glass/RG = new reinforced_type(user.loc)
		RG.add_to_stacks(user)
		use(1)
		V.use(1)
		if(!src && !RG)
			user.put_in_hands(RG)

/obj/item/stack/sheet/glass/large_stack
	amount = 50


/*
* Reinforced glass sheets
*/
/obj/item/stack/sheet/glass/reinforced
	name = "reinforced glass"
	desc = "Reinforced glass is made out of squares of regular silicate glass layered on a metallic rod matrice. This glass is more resistant to direct impacts, even if it may crack."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"

	materials = list(/datum/material/metal = 20, /datum/material/glass = 3750)

	created_window = /obj/structure/window/reinforced
	is_reinforced = TRUE


/*
* Phoron Glass sheets
*/
/obj/item/stack/sheet/glass/phoronglass
	name = "phoron glass"
	desc = "Phoron glass is a silicate-phoron alloy turned into a non-crystalline solid. It is transparent just like glass, even if visibly tainted pink, and very resistant to damage and heat."
	singular_name = "phoron glass sheet"
	icon_state = "sheet-phoronglass"
	materials = list(/datum/material/glass = 7500)
	created_window = /obj/structure/window/phoronbasic
	reinforced_type = /obj/item/stack/sheet/glass/phoronrglass

/*
* Reinforced phoron glass sheets
*/
/obj/item/stack/sheet/glass/phoronrglass
	name = "reinforced phoron glass"
	desc = "Reinforced phoron glass is made out of squares of silicate-phoron alloy glass layered on a metallic rod matrice. It is insanely resistant to both physical shock and heat."
	singular_name = "reinforced phoron glass sheet"
	icon_state = "sheet-phoronrglass"
	materials = list(/datum/material/glass = 7500, /datum/material/metal = 1875)
	created_window = /obj/structure/window/phoronreinforced
	is_reinforced = TRUE
