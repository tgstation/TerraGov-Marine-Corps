//These machines are mostly just here for debugging/spawning. Skeletons of the feature to come.

/obj/machinery/bioprinter
	name = "bio/prosthetic printer"
	desc = "It's a machine that can either grow replacement organs or manufacture prosthetics."
	icon = 'icons/obj/surgery.dmi'

	anchored = 1
	density = 1

	icon_state = "bioprinter"

	var/working = 0
	var/stored_matter = 100
	var/stored_metal = 100
	var/loaded_dna //Blood sample for DNA hashing.
	var/list/products = list(
		"heart (50 - Matter)" =   list(/obj/item/organ/heart,  50, 0),
		"lungs (40 - Matter)" =   list(/obj/item/organ/lungs,  40, 0),
		"kidneys (40 - Matter)" = list(/obj/item/organ/kidneys,40, 0),
		"eyes (30 - Matter)" =    list(/obj/item/organ/eyes,   30, 0),
		"liver (50 - Matter)" =   list(/obj/item/organ/liver,  50, 0),
		"prosthetic heart (50 - Metal)" =   list(/obj/item/organ/heart/prosthetic,  0, 50),
		"prosthetic lungs (40 - Metal)" =   list(/obj/item/organ/lungs/prosthetic,  0, 40),
		"prosthetic kidneys (30 - Metal)" = list(/obj/item/organ/kidneys/prosthetic,0, 30),
		"prosthetic eyes (30 - Metal)" =    list(/obj/item/organ/eyes/prosthetic,   0, 30),
		"prosthetic liver (50 - Metal)" =   list(/obj/item/organ/liver/prosthetic,  0, 50),
		"prosthetic left arm (100 - Metal)" =  list(/obj/item/robot_parts/l_arm,  0, 100),
		"prosthetic right arm (100 - Metal)" = list(/obj/item/robot_parts/r_arm,  0, 100),
		"prosthetic left leg (125 - Metal)" =  list(/obj/item/robot_parts/l_leg,  0, 125),
		"prosthetic right leg (125 - Metal)" = list(/obj/item/robot_parts/r_leg,  0, 125)
		)

/obj/machinery/bioprinter/attack_hand(mob/user)

	var/choice = input("What would you like to print?") as null|anything in products
	if(!choice)
		return

	if(stored_matter >= products[choice][2] && stored_metal >= products[choice][3])
		if(working)
			user << "Something is already being printed..."
			return
		stored_matter -= products[choice][2]
		stored_metal -= products[choice][3]
		user << "\blue \The [src] is now printing the selected organ. Please hold."
		working = 1
		spawn(250)
			var/new_organ = products[choice][1]
			new new_organ(get_turf(src))
			working = 0
			visible_message("The bio/prosthetic printer spits out a new organ.")

	else
		user << "There is not enough materials in the printer."

/obj/machinery/bioprinter/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		user << "\blue \The [src] processes \the [W]."
		stored_matter += 50
		user.drop_item()
		del(W)
		return
	else if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		user << "\blue \The [src] processes \the [W]."
		stored_metal += M.amount * 100
		user.drop_item()
		del(W)
		return
	else
		return..()

/obj/machinery/bioprinter/examine()
	..()
	usr << "It has [stored_matter] matter and [stored_metal] metal left."

