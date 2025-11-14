

//Flame thrower.

/obj/item/ammo_magazine/flamer_tank
	name = "incinerator tank"
	desc = "A fuel tank of usually ultra thick napthal, a sticky combustable liquid chemical, for use in the FL-240 incinerator unit. Handle with care."
	icon_state = "flametank"
	icon = 'icons/obj/items/ammo/flamer.dmi'
	max_rounds = 50 //Per turf.
	current_rounds = 50
	reload_delay = 2 SECONDS
	w_class = WEIGHT_CLASS_NORMAL //making sure you can't sneak this onto your belt.
	caliber = CALIBER_FUEL_THICK //Ultra Thick Napthal Fuel, from the lore book.
	magazine_flags = NONE
	icon_state_mini = "tank_light"

	default_ammo = /datum/ammo/flamethrower

	var/dispenser_type = /obj/structure/reagent_dispensers/fueltank

/obj/item/ammo_magazine/flamer_tank/mini
	name = "mini incinerator tank"
	desc = "A fuel tank of usually ultra thick napthal, a sticky combustable liquid chemical, for use in the underail incinerator unit. Handle with care."
	icon_state = "flametank_mini"
	reload_delay = 0 SECONDS
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 25
	max_rounds = 25
	icon_state_mini = "tank_orange_mini"

/obj/item/ammo_magazine/flamer_tank/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of ammo.

	if(!istype(target, /obj/structure/reagent_dispensers) || get_dist(user, target) > 1)
		return ..()
	if(!dispenser_type)
		to_chat(user, span_warning("This isn't refillable!"))
		return ..()
	if(!istype(target, dispenser_type))
		to_chat(user, span_warning("Not the right kind of tank!"))
		return ..()
	if(current_rounds >= max_rounds)
		to_chat(user, span_warning("[src] is already full."))
		return ..()
	var/obj/structure/reagent_dispensers/dispenser = target
	if(dispenser.reagents.total_volume == 0)
		to_chat(user, span_warning("This tank is empty!"))
		return..()

	//Reworked and much simpler equation; fuel capacity minus the current amount, with a check for insufficient fuel
	var/liquid_transfer_amount = min(dispenser.reagents.total_volume, (max_rounds - current_rounds))
	dispenser.reagents.remove_any(liquid_transfer_amount)
	current_rounds += liquid_transfer_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, span_notice("You refill [src] with [lowertext(caliber)]."))
	update_icon()

/obj/item/ammo_magazine/flamer_tank/large	// Extra thicc tank
	name = "large flamerthrower tank"
	desc = "A large fuel tank of ultra thick napthal, a sticky combustable liquid chemical, for use in the FL-84 flamethrower."
	icon_state = "flametank_large"
	max_rounds = 75
	current_rounds = 75
	reload_delay = 3 SECONDS
	icon_state_mini = "tank_orange"

/obj/item/ammo_magazine/flamer_tank/large/som
	name = "large flamerthrower tank"
	desc = "A large fuel tank of ultra thick napthal, a sticky combustable liquid chemical, for use in the V-62 flamethrower."
	icon_state = "flametank_som"
	icon_state_mini = "tank_red"
	max_rounds = 75
	current_rounds = 75
	reload_delay = 3 SECONDS

/obj/item/ammo_magazine/flamer_tank/large/X
	name = "large flamethrower tank (X)"
	desc = "A large fuel tank of ultra thick napthal fuel type X, a sticky combustable liquid chemical that burns extremely hot, for use in the FL-84 flamethrower. Handle with care."
	icon_state = "flametank_large_blue"
	default_ammo = /datum/ammo/flamethrower/blue
	icon_state_mini = "tank_blue"
	dispenser_type = /obj/structure/reagent_dispensers/fueltank/xfuel

/obj/item/ammo_magazine/flamer_tank/large/X/som
	desc = "A large fuel tank of ultra thick napthal Fuel type X, a sticky combustable liquid chemical, for use in the V-62 flamethrower."
	icon_state = "flametank_som_x"
	icon_state_mini = "tank_red_blue"

/obj/item/ammo_magazine/flamer_tank/large/X/deathsquad
	name = "Gargantuan flamethrower X-tank"
	desc = "Using Bluespace technology, Nanotrasen has managed to fit in way more x-fuel than you would ever hope to need in a single lifetime into this specialized tank."
	max_rounds = 225
	current_rounds = 225
	reload_delay = 2 SECONDS

/obj/item/ammo_magazine/flamer_tank/backtank
	name = "backpack fuel tank"
	desc = "A specialized fuel tank for use with the FL-84 flamethrower and FL-240 incinerator unit."
	icon_state = "flamethrower_tank"
	equip_slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 500
	current_rounds = 500
	reload_delay = 1 SECONDS
	caliber = CALIBER_FUEL_THICK
	magazine_flags = MAGAZINE_WORN
	icon_state_mini = "tank"

	default_ammo = /datum/ammo/flamethrower

/obj/item/ammo_magazine/flamer_tank/backtank/X
	name = "backpack fuel tank (X)"
	desc = "A specialized fuel tank of ultra thick napthal type X for use with the FL-84 flamethrower and FL-240 incinerator unit."
	icon_state = "x_flamethrower_tank"
	default_ammo = /datum/ammo/flamethrower/blue
	dispenser_type = /obj/structure/reagent_dispensers/fueltank/xfuel

/obj/item/ammo_magazine/flamer_tank/water
	name = "pressurized water tank"
	desc = "A cannister of water for use with the FL-84's underslung extinguisher. Can be refilled by hand."
	icon_state = "watertank"
	max_rounds = 200
	current_rounds = 200
	reload_delay = 0 SECONDS
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_WATER //Deep lore
	magazine_flags = NONE
	icon_state_mini = "tank_water"

	default_ammo = /datum/ammo/water
	dispenser_type = /obj/structure/reagent_dispensers/watertank

//The engineer pyro bag internal fuel tank
/obj/item/ammo_magazine/flamer_tank/internal
	name = "internal fuel tank"
	desc = "A large fuel tank of ultra thick napthal, a sticky combustable liquid chemical, you shouldn't see this though."
	icon_state = ""
	max_rounds = 280
	current_rounds = 280
	reload_delay = 0 SECONDS

/obj/item/ammo_magazine/flamer_tank/vsd
	name = "large CC/21 flamerthrower tank (X)"
	desc = "A large tank for the Vyacheslav CC/21 Flamer, filled with thick napthal X fuel."
	icon_state = "flametank_vsd"
	max_rounds = 150
	current_rounds = 150
	reload_delay = 4 SECONDS
	default_ammo = /datum/ammo/flamethrower/blue
	icon_state_mini = "tank_blue"
	dispenser_type = /obj/structure/reagent_dispensers/fueltank/xfuel

