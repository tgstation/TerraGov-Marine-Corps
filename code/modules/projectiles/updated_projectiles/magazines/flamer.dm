

//Flame thrower.

/obj/item/ammo_magazine/flamer_tank
	name = "incinerator tank"
	desc = "A fuel tank of usually Ultra Thick Napthal Fuel,a sticky combustable liquid chemical, for use in the M240 incinerator unit. Handle with care."
	icon_state = "flametank"
	default_ammo = /datum/ammo/flamethrower //doesn't actually need bullets. But we'll get null ammo error messages if we don't
	max_rounds = 60 //Per turf.
	current_rounds = 60
	w_class = 3.0 //making sure you can't sneak this onto your belt.
	gun_type = /obj/item/weapon/gun/flamer
	caliber = "UT-Napthal Fuel" //Ultra Thick Napthal Fuel, from the lore book.
	flags_magazine = NOFLAGS


/obj/item/ammo_magazine/flamer_tank/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of ammo.
	if(istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(user,target) <= 1)
		var/obj/structure/reagent_dispensers/fueltank/FT = target
		if(current_rounds)
			user << "<span class='warning'>You can't mix fuel mixtures!</span>"
			return
		var/fuel_available = FT.reagents.get_reagent_amount("fuel") < max_rounds ? FT.reagents.get_reagent_amount("fuel") : max_rounds
		if(!fuel_available)
			user << "<span class='warning'>[FT] is empty!</span>"
			return

		FT.reagents.remove_reagent("fuel", fuel_available)
		current_rounds = fuel_available
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		caliber = "Fuel"
		user << "<span class='notice'>You refill [src] with [lowertext(caliber)].</span>"
		update_icon()

	else
		..()

/obj/item/ammo_magazine/flamer_tank/update_icon()
	return

/obj/item/ammo_magazine/flamer_tank/large	// Extra thicc tank
	name = "large incinerator tank"
	desc = "A large fuel tank of Ultra Thick Napthal Fuel,a sticky combustable liquid chemical, for use in the M240-T incinerator unit. Handle with care."
	icon_state = "flametank_large"
	max_rounds = 100
	current_rounds = 100
	gun_type = /obj/item/weapon/gun/flamer/M240T

/obj/item/ammo_magazine/flamer_tank/large/B
	name = "large incinerator tank (B)"
	desc = "A large fuel tank of Ultra Thick Napthal Fuel type B,a wide-spreading sticky combustable liquid chemical, for use in the M240-T incinerator unit. Handle with care."
	icon_state = "flametank_large_green"
	caliber = "Napalm B"

/obj/item/ammo_magazine/flamer_tank/large/X
	name = "large incinerator tank (X)"
	desc = "A large fuel tank of Ultra Thick Napthal Fuel type X,a sticky combustable liquid chemical that burns extremely hot, for use in the M240-T incinerator unit. Handle with care."
	icon_state = "flametank_large_blue"
	caliber = "Napalm X"