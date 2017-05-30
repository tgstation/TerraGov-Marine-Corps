



//------- New Welder Backpacks -------//

/obj/item/weapon/storage/backpack/marine/engineerpack
	name = "\improper USCM technician welderpack"
	desc = "A specialized backpack worn by USCM technicians. It carries a fueltank for quick welder refueling and use,"
	icon_state = "engineerpack"
	item_state = "engineerpack"
	var/max_fuel = 260
	max_combined_w_class = 15

/obj/item/weapon/storage/backpack/marine/engineerpack/New()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)
	..()
	return

/obj/item/weapon/storage/backpack/marine/engineerpack/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/T = W
		if(T.welding)
			user << "\red That was close! However you realized you had the welder on and prevented disaster"
			return
		src.reagents.trans_to(W, T.max_fuel)
		user << "\blue Welder refilled!"
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	..()

/obj/item/weapon/storage/backpack/marine/engineerpack/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) // this replaces and improves the get_dist(src,O) <= 1 checks used previously
		return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume < max_fuel)
		O.reagents.trans_to(src, max_fuel)
		user << "\blue You crack the cap off the top of the pack and fill it back up again from the tank."
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume == max_fuel)
		user << "\blue The pack is already full!"
		return
	..()

/obj/item/weapon/storage/backpack/marine/engineerpack/examine()
	set src in usr
	usr << text("\icon[] [] units of fuel left!", src, src.reagents.total_volume)
	..()
	return
