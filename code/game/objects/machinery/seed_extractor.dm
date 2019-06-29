/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/machines/hydroponics.dmi'
	icon_state = "sextractor"
	density = TRUE
	anchored = TRUE


/obj/machinery/seed_extractor/attackby(obj/item/I, mob/user, params)
	. = ..()
	// Fruits and vegetables.
	if(istype(I, /obj/item/reagent_container/food/snacks/grown) || istype(I, /obj/item/grown))
		if(!user.temporarilyRemoveItemFromInventory(I))
			return

		var/datum/seed/new_seed_type
		if(istype(I, /obj/item/grown))
			var/obj/item/grown/F = I
			new_seed_type = GLOB.seed_types[F.plantname]
		else
			var/obj/item/reagent_container/food/snacks/grown/F = I
			new_seed_type = GLOB.seed_types[F.plantname]

		if(new_seed_type)
			to_chat(user, "<span class='notice'>You extract some seeds from [I].</span>")
			var/produce = rand(1, 4)
			for(var/i = 1 to produce)
				var/obj/item/seeds/seeds = new(get_turf(src))
				seeds.seed_type = new_seed_type.name
				seeds.update_seed()
		else
			to_chat(user, "[I] doesn't seem to have any usable seeds inside it.")

		qdel(I)

	//Grass.
	else if(istype(I, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = I
		if(!S.use(1))
			return
		to_chat(user, "<span class='notice'>You extract some seeds from the grass tile.</span>")
		new /obj/item/seeds/grassseed(loc)