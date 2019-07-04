

//Flame thrower.

/obj/item/ammo_magazine/flamer_tank
	name = "incinerator tank"
	desc = "A fuel tank of usually Ultra Thick Napthal Fuel,a sticky combustable liquid chemical, for use in the M240 incinerator unit. Handle with care."
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
		refill_from(target, user)
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
	default_ammo = /datum/ammo/flamethrower/green

/obj/item/ammo_magazine/flamer_tank/large/X
	name = "large incinerator tank (X)"
	desc = "A large fuel tank of Ultra Thick Napthal Fuel type X,a sticky combustable liquid chemical that burns extremely hot, for use in the M240-T incinerator unit. Handle with care."
	icon_state = "flametank_large_blue"
	default_ammo = /datum/ammo/flamethrower/blue

/obj/item/ammo_magazine/flamer_tank/internal
	name = "internal flamer tank"
	max_rounds = 20
	current_rounds = 20

GLOBAL_LIST_INIT(fuel_sources, typecacheof(list(
	/obj/structure/reagent_dispensers/fueltank,
	/obj/item/tool/weldpack,
	/obj/item/reagent_container
)))

GLOBAL_LIST_INIT(flamer_refill_objects, typecacheof(list(
	/obj/structure/reagent_dispensers/fueltank,
	/obj/item/tool/weldpack,
	/obj/item/reagent_container,
	/obj/item/ammo_magazine/flamer_tank,
	/obj/item/storage/backpack/marine/engineerpack
)))

// this mess is until napalm becomes a proper reagent
// but at least all this refill code is in one place now
/obj/item/ammo_magazine/flamer_tank/proc/refill_from(obj/O, mob/user)
	if(istype(O, /obj/item/ammo_magazine/flamer_tank))
		var/obj/item/ammo_magazine/flamer_tank/FT = O
		if(!FT.current_rounds)
			to_chat(user, "<span class='warning'>That [FT] is empty!</span>")
			return FALSE
		if(current_rounds && FT.caliber != caliber)
			to_chat(user, "<span class='warning'>You can't mix fuel types like that.</span>")
			return FALSE
		caliber = FT.caliber
		var/amount_to_transfer = min(max_rounds - current_rounds, FT.current_rounds)
		FT.current_rounds -= amount_to_transfer
		current_rounds += amount_to_transfer
		playsound(get_turf(O), 'sound/effects/refill.ogg', 25, 1, 3)
		to_chat(user, "<span class='notice'>You refill [src] with [lowertext(caliber)].</span>")
		update_icon()
		return TRUE

	if(!O.reagents?.total_volume)
		return FALSE

	var/new_fuel_type

	if(istype(O, /obj/item/storage/backpack/marine/engineerpack))
		var/obj/item/storage/backpack/marine/engineerpack/EP = O
		new_fuel_type = EP.fuel_type

	else if(is_type_in_typecache(O, GLOB.fuel_sources))
		new_fuel_type = "Fuel"

	else
		CRASH("Tried to refill a flamertank from something that isnt a fuel source")

	if(current_rounds && new_fuel_type != caliber)
		to_chat(user, "<span class='warning'>You can't mix fuel types like this.</span>")
		return FALSE

	var/fuel_amount_in_source = O.reagents.get_reagent_amount("fuel")

	if(!fuel_amount_in_source)
		to_chat(user, "<span class='warning'>[O] has no fuel in it!</span>")
		return FALSE

	var/fuel_to_transfer = min(max_rounds - current_rounds, fuel_amount_in_source)

	O.reagents.remove_reagent("fuel", fuel_to_transfer)

	current_rounds += fuel_to_transfer
	caliber = new_fuel_type
	to_chat(user, "<span class='notice'>You refill [src] with [lowertext(caliber)] from the [O].</span>")
	playsound(get_turf(O), 'sound/effects/refill.ogg', 25, 1, 3)
	update_icon()
	return TRUE

/obj/item/ammo_magazine/flamer_tank/internal/refill_from(obj/O, mob/user)
	. = ..()
	if(.)
		caliber = "Fuel" // just hardset to fuel for internal tanks until napalm reagent

