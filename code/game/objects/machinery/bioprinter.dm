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
		"synthetic left arm (125 - Metal)" =  list(/obj/item/robot_parts/l_arm,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
		"synthetic right arm (125 - Metal)" = list(/obj/item/robot_parts/r_arm,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
		"synthetic left leg (125 - Metal)" =  list(/obj/item/robot_parts/l_leg,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
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
	if(istype(I, /obj/item/reagent_containers/food/snacks/meat))
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
	if(machine_stat & NOPOWER)
		icon_state = "bioprinter_off"
		return
	if(working)
		icon_state = "bioprinter_busy"
	else
		icon_state = "bioprinter"

/obj/machinery/bioprinter/stocked
	stored_metal = 1000
