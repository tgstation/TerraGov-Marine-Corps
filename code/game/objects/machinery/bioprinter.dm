//These machines are mostly just here for debugging/spawning. Skeletons of the feature to come.

/obj/machinery/bioprinter
	name = "bio/synthetic printer"
	desc = "It's a machine that can either grow replacement or manufacture synthetic organs."
	icon = 'icons/obj/surgery.dmi'

	anchored = TRUE
	density = TRUE
	coverage = 30

	icon_state = "bioprinter"

	var/working = 0
	var/stored_matter = 0
	var/stored_metal = 0

	//"Name" = list(location, matter, metal, time, isorganic)
	var/list/products = list(
		"biotic left arm (100 - Matter)" = list(/obj/item/robot_parts/biotic/l_arm,  LIMB_MATTER_AMOUNT, 0, LIMB_PRINTING_TIME),
		"biotic right arm (100 - Matter)" = list(/obj/item/robot_parts/biotic/r_arm,  LIMB_MATTER_AMOUNT, 0, LIMB_PRINTING_TIME),
		"biotic left leg (100 - Matter)" = list(/obj/item/robot_parts/biotic/l_leg,  LIMB_MATTER_AMOUNT, 0, LIMB_PRINTING_TIME),
		"biotic right leg (100 - Matter)" = list(/obj/item/robot_parts/biotic/r_leg,  LIMB_MATTER_AMOUNT, 0, LIMB_PRINTING_TIME),
		"synthetic left arm (125 - Metal)" = list(/obj/item/robot_parts/l_arm,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
		"synthetic right arm (125 - Metal)" = list(/obj/item/robot_parts/r_arm,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
		"synthetic left leg (125 - Metal)" = list(/obj/item/robot_parts/l_leg,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
		"synthetic right leg (125 - Metal)" = list(/obj/item/robot_parts/r_leg,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME)
		)

/obj/machinery/bioprinter/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(working)
		to_chat(user, "Something is already being printed...")
		return
	var/choice = tgui_input_list(user, "What would you like to print?", null, products)
	if(!choice)
		return
	if(stored_matter >= products[choice][2] && stored_metal >= products[choice][3]) //Matter and metal
		if(working)
			to_chat(user, "Something is already being printed...")
			return
		stored_matter -= products[choice][2] //Matter
		stored_metal -= products[choice][3] //Metal
		to_chat(user, span_notice("\The [src] is now printing the selected organ. Please hold."))
		working = 1
		update_icon()
		spawn(products[choice][4]) //Time
			var/new_organ = products[choice][1]
			new new_organ(get_turf(src))
			working = 0
			visible_message("The bio/synthetic printer spits out a new organ.")
			update_icon()

	else
		to_chat(user, "There is not enough materials in the printer.")

/obj/machinery/bioprinter/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(I, /obj/item/reagent_containers/glass/beaker))
		var/obj/item/reagent_containers/glass/beaker/B = I
		if(B.reagents.has_reagent(/datum/reagent/medicine/biomass, 30))
			to_chat(user, span_notice("\The [src] processes \the [I]."))
			stored_matter += 200
			B.reagents.remove_reagent(/datum/reagent/medicine/biomass, 30)

	else if(istype(I, /obj/item/limb))
		to_chat(user, span_notice("\The [src] processes \the [I]."))
		stored_matter += 50
		user.drop_held_item()
		qdel(I)

	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		to_chat(user, span_notice("\The [src] processes \the [I]."))
		stored_metal += M.amount * 100
		user.drop_held_item()
		qdel(I)

/obj/machinery/bioprinter/examine(mob/user)
	. = ..()
	. += "It has [stored_matter] matter and [stored_metal] metal left."

/obj/machinery/bioprinter/update_icon_state()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "bioprinter_off"
		return
	if(working)
		icon_state = "bioprinter_busy"
	else
		icon_state = "bioprinter"

/obj/machinery/bioprinter/stocked
	stored_metal = 1000
	stored_matter = 1000
