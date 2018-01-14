/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/machines/hydroponics.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1

obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob)

	// Fruits and vegetables.
	if(istype(O, /obj/item/reagent_container/food/snacks/grown) || istype(O, /obj/item/grown))

		if(user.temp_drop_inv_item(O))

			var/datum/seed/new_seed_type
			if(istype(O, /obj/item/grown))
				var/obj/item/grown/F = O
				new_seed_type = seed_types[F.plantname]
			else
				var/obj/item/reagent_container/food/snacks/grown/F = O
				new_seed_type = seed_types[F.plantname]

			if(new_seed_type)
				user << "<span class='notice'>You extract some seeds from [O].</span>"
				var/produce = rand(1,4)
				for(var/i = 0;i<=produce;i++)
					var/obj/item/seeds/seeds = new(get_turf(src))
					seeds.seed_type = new_seed_type.name
					seeds.update_seed()
			else
				user << "[O] doesn't seem to have any usable seeds inside it."

			cdel(O)

	//Grass.
	else if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		if (S.use(1))
			user << "<span class='notice'>You extract some seeds from the grass tile.</span>"
			new /obj/item/seeds/grassseed(loc)
