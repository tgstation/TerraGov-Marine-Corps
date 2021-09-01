

//Flame thrower.

/obj/item/ammo_magazine/flamer_tank
	name = "incinerator tank"
	desc = "A fuel tank of usually ultra thick napthal, a sticky combustable liquid chemical, for use in the M240A1 incinerator unit. Handle with care."
	icon_state = "flametank"
	default_ammo = /datum/ammo/flamethrower //doesn't actually need bullets. But we'll get null ammo error messages if we don't
	max_rounds = 50 //Per turf.
	current_rounds = 50
	reload_delay = 2 SECONDS
	w_class = WEIGHT_CLASS_NORMAL //making sure you can't sneak this onto your belt.
	gun_type = /obj/item/weapon/gun/flamer/big_flamer
	caliber = CALIBER_FUEL_THICK //Ultra Thick Napthal Fuel, from the lore book.
	flags_magazine = NONE
	icon_state_mini = "tank"

/obj/item/ammo_magazine/flamer_tank/mini
	name = "mini incinerator tank"
	desc = "A fuel tank of usually ultra thick napthal, a sticky combustable liquid chemical, for use in the underail incinerator unit. Handle with care."
	icon_state = "flametank_mini"
	reload_delay = 0 SECONDS
	current_rounds = 25
	max_rounds = 25
	gun_type = /obj/item/weapon/gun/flamer/mini_flamer



/obj/item/ammo_magazine/flamer_tank/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of ammo.

	if(istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(user,target) <= 1)
		var/obj/structure/reagent_dispensers/fueltank/FT = target
		if(FT.reagents.total_volume == 0)
			to_chat(user, span_warning("Out of fuel!"))
			return..()

		//Reworked and much simpler equation; fuel capacity minus the current amount, with a check for insufficient fuel
		var/fuel_transfer_amount = min(FT.reagents.total_volume, (max_rounds - current_rounds))
		FT.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		current_rounds += fuel_transfer_amount
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		caliber = CALIBER_FUEL
		to_chat(user, span_notice("You refill [src] with [lowertext(caliber)]."))
		update_icon()

	else
		..()

/obj/item/ammo_magazine/flamer_tank/update_icon()
	return

/obj/item/ammo_magazine/flamer_tank/large	// Extra thicc tank
	name = "large flamerthrower tank"
	desc = "A large fuel tank of ultra thick napthal, a sticky combustable liquid chemical, for use in the TL-84 flamethrower."
	icon_state = "flametank_large"
	max_rounds = 75
	current_rounds = 75
	reload_delay = 3 SECONDS
	gun_type = /obj/item/weapon/gun/flamer/big_flamer
	icon_state_mini = "tank_orange"

/obj/item/ammo_magazine/flamer_tank/backtank
	name = "back fuel tank"
	desc = "A specialized fuel tank for use with the TL-84 flamethrower and M240A1 incinerator unit."
	icon_state = "flamethrower_tank"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 500
	current_rounds = 500
	reload_delay = 1 SECONDS
	gun_type = /obj/item/weapon/gun/flamer
	var/obj/item/weapon/gun/flamer/attached_flamer


/obj/item/ammo_magazine/flamer_tank/backtank/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/FLT = I

	if(!istype(user, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/humanuser = user

	if (!humanuser.is_item_in_slots(src) && !FLT.master_gun)
		to_chat(user, span_warning("You must equip or hold this fuel tank to be able to link it to a flamer"))
		return

	if(FLT.current_mag == src)
		FLT.detach_fueltank(user)
		return

	if (attached_flamer)
		to_chat(user, span_warning("This fuel tank is already attached to something"))
		return

	FLT.attach_fueltank(user,src)

/obj/item/ammo_magazine/flamer_tank/attackby_alternate(obj/item/I, mob/user, params)
	. = ..()
	if(!isgun(I))
		return
	var/obj/item/weapon/gun/gun = I
	if(!istype(gun.active_attachable, /obj/item/weapon/gun/flamer))
		return
	attackby(gun.active_attachable, user, params)


/obj/item/ammo_magazine/flamer_tank/backtank/removed_from_inventory(mob/user) //Dropping the tank should unlink it from the flamer
	. = ..()
	var/mob/living/carbon/human/humanuser = user
	if (!istype(humanuser))
		return
	if(!attached_flamer)
		return
	attached_flamer.detach_fueltank(user,FALSE)

/obj/item/ammo_magazine/flamer_tank/backtank/X
	name = "back fuel tank (X)"
	desc = "A specialized fuel tank of ultra thick napthal type X for use with the TL-84 flamethrower and M240A1 incinerator unit."
	default_ammo = /datum/ammo/flamethrower/blue

/obj/item/ammo_magazine/flamer_tank/large/X
	name = "large flamethrower tank (X)"
	desc = "A large fuel tank of ultra thick napthal Fuel type X, a sticky combustable liquid chemical that burns extremely hot, for use in the TL-84 flamethrower. Handle with care."
	icon_state = "flametank_large_blue"
	default_ammo = /datum/ammo/flamethrower/blue
	icon_state_mini = "tank_blue"
