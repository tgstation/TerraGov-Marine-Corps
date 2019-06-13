//These machines are mostly just here for debugging/spawning. Skeletons of the feature to come.

/obj/machinery/bioprinter
	name = "bio/synthetic printer"
	desc = "It's a machine that can either grow replacement or manufacture synthetic organs."
	icon = 'icons/obj/surgery.dmi'

	anchored = TRUE
	density = TRUE

	icon_state = "bioprinter"

	var/working = 0
	var/stored_matter = 0
	var/stored_metal = 0

	//"Name" = list(location, matter, metal, time, isorganic)
	var/list/products = list(
		"heart (50 - Matter)" =   list(/obj/item/organ/heart,  50, 0, 350),
		"lungs (40 - Matter)" =   list(/obj/item/organ/lungs,  40, 0, 350),
		"kidneys (40 - Matter)" = list(/obj/item/organ/kidneys,40, 0, 250),
		"eyes (30 - Matter)" =    list(/obj/item/organ/eyes,   30, 0, 250),
		"liver (50 - Matter)" =   list(/obj/item/organ/liver,  50, 0, 250),
		"synthetic heart (50 - Metal)" =   list(/obj/item/organ/heart/prosthetic,  0, 50, 450),
		"synthetic lungs (40 - Metal)" =   list(/obj/item/organ/lungs/prosthetic,  0, 40, 450),
		"synthetic kidneys (30 - Metal)" = list(/obj/item/organ/kidneys/prosthetic,0, 30, 450),
		"synthetic eyes (30 - Metal)" =    list(/obj/item/organ/eyes/prosthetic,   0, 30, 450),
		"synthetic liver (50 - Metal)" =   list(/obj/item/organ/liver/prosthetic,  0, 50, 450),
		"synthetic left arm (125 - Metal)" =  list(/obj/item/robot_parts/l_arm,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
		"synthetic right arm (125 - Metal)" = list(/obj/item/robot_parts/r_arm,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
		"synthetic left leg (125 - Metal)" =  list(/obj/item/robot_parts/l_leg,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME),
		"synthetic right leg (125 - Metal)" = list(/obj/item/robot_parts/r_leg,  0, LIMB_METAL_AMOUNT, LIMB_PRINTING_TIME)
		)

/obj/machinery/bioprinter/attack_hand(mob/user)
	if(working)
		to_chat(user, "Something is already being printed...")
		return
	var/choice = input("What would you like to print?") as null|anything in products
	if(!choice)
		return
	if(stored_matter >= products[choice][2] && stored_metal >= products[choice][3]) //Matter and metal
		if(working)
			to_chat(user, "Something is already being printed...")
			return
		stored_matter -= products[choice][2] //Matter
		stored_metal -= products[choice][3] //Metal
		to_chat(user, "<span class='notice'>\The [src] is now printing the selected organ. Please hold.</span>")
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
	if(istype(I, /obj/item/reagent_container/food/snacks/meat))
		to_chat(user, "<span class='notice'>\The [src] processes \the [I].</span>")
		stored_matter += 50
		user.drop_held_item()
		qdel(I)

	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		to_chat(user, "<span class='notice'>\The [src] processes \the [I].</span>")
		stored_metal += M.amount * 100
		user.drop_held_item()
		qdel(I)

/obj/machinery/bioprinter/examine(mob/user)
	..()
	to_chat(user, "It has [stored_matter] matter and [stored_metal] metal left.")

/obj/machinery/bioprinter/power_change()
	.=..()
	update_icon()

/obj/machinery/bioprinter/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "bioprinter_off"
	else
		if(working)
			icon_state = "bioprinter_busy"
		else
			icon_state = "bioprinter"