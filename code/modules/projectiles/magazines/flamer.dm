

//Flame thrower.

/obj/item/ammo_magazine/flamer_tank
	name = "incinerator tank"
	desc = "A fuel tank of usually ultra thick napthal, a sticky combustable liquid chemical, for use in the M240A1 incinerator unit. Handle with care."
	icon_state = "flametank"
	default_ammo = /datum/ammo/flamethrower //doesn't actually need bullets. But we'll get null ammo error messages if we don't
	max_rounds = 60 //Per turf.
	current_rounds = 60
	w_class = WEIGHT_CLASS_NORMAL //making sure you can't sneak this onto your belt.
	gun_type = /obj/item/weapon/gun/flamer
	caliber = "UT-Napthal Fuel" //Ultra Thick Napthal Fuel, from the lore book.
	flags_magazine = NONE


/obj/item/ammo_magazine/flamer_tank/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of ammo.

	if(istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(user,target) <= 1)
		var/obj/structure/reagent_dispensers/fueltank/FT = target
		if(FT.reagents.total_volume == 0)
			to_chat(user, "<span class='warning'>Out of fuel!</span>")
			return..()

		//Reworked and much simpler equation; fuel capacity minus the current amount, with a check for insufficient fuel
		var/fuel_transfer_amount = min(FT.reagents.total_volume, (max_rounds - current_rounds))
		FT.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		current_rounds += fuel_transfer_amount
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		caliber = "Fuel"
		to_chat(user, "<span class='notice'>You refill [src] with [lowertext(caliber)].</span>")
		update_icon()

	else
		..()

/obj/item/ammo_magazine/flamer_tank/update_icon()
	return

/obj/item/ammo_magazine/flamer_tank/large	// Extra thicc tank
	name = "large flamerthrower tank"
	desc = "A large fuel tank of ultra thick napthal, a sticky combustable liquid chemical, for use in the TL-84 flamethrower."
	icon_state = "flametank_large"
	max_rounds = 100
	current_rounds = 100
	gun_type = /obj/item/weapon/gun/flamer/marinestandard

/obj/item/ammo_magazine/flamer_tank/large/B
	name = "large flamethrower tank (B)"
	desc = "A large fuel tank of ultra thick napthal type B, a wide-spreading sticky combustable liquid chemical, for use in the TL-84 flamethrower. Handle with care."
	icon_state = "flametank_large_green"
	default_ammo = /datum/ammo/flamethrower/green

/obj/item/ammo_magazine/flamer_tank/large/X
	name = "large flamethrower tank (X)"
	desc = "A large fuel tank of ultra thick napthal Fuel type X, a sticky combustable liquid chemical that burns extremely hot, for use in the TL-84 flamethrower. Handle with care."
	icon_state = "flametank_large_blue"
	default_ammo = /datum/ammo/flamethrower/blue
