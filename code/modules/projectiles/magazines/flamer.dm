

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
	///The type of fuel we refuel with
	var/fuel_type = DEFAULT_FUEL_TYPE

/obj/item/ammo_magazine/flamer_tank/get_fueltype()
	return fuel_type

/obj/item/ammo_magazine/flamer_tank/can_refuel(atom/refueler, fuel_type, mob/user)
	if(fuel_type != get_fueltype())
		user?.balloon_alert(user, "wrong fuel")
		return FALSE
	if(current_rounds == max_rounds)
		user?.balloon_alert(user, "full")
		return FALSE
	return TRUE

/obj/item/ammo_magazine/flamer_tank/do_refuel(atom/refueler, fuel_type, mob/user)
	var/fuel_transfer_amount = min(refueler.reagents.total_volume, (max_rounds - current_rounds))
	refueler.reagents.remove_reagent(fuel_type, fuel_transfer_amount)
	current_rounds += fuel_transfer_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	caliber = CALIBER_FUEL
	user?.balloon_alert(user, "refilled")
	update_appearance(UPDATE_ICON)

/obj/item/ammo_magazine/flamer_tank/mini
	name = "mini incinerator tank"
	desc = "A fuel tank of usually ultra thick napthal, a sticky combustable liquid chemical, for use in the underail incinerator unit. Handle with care."
	icon_state = "flametank_mini"
	reload_delay = 0 SECONDS
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 25
	max_rounds = 25
	icon_state_mini = "tank_orange_mini"

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
	fuel_type = /datum/reagent/fuel/xfuel
	icon_state_mini = "tank_blue"

/obj/item/ammo_magazine/flamer_tank/large/X/som
	desc = "A large fuel tank of ultra thick napthal Fuel type X, a sticky combustable liquid chemical, for use in the V-62 flamethrower."
	icon_state = "flametank_som_x"
	icon_state_mini = "tank_red_blue"

/obj/item/ammo_magazine/flamer_tank/large/X/deathsquad
	name = "Gargantuan flamethrower X-tank"
	desc = "Using Bluespace technology, Ninetails has managed to fit in way more x-fuel than you would ever hope to need in a single lifetime into this specialized tank."
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
	fuel_type = /datum/reagent/fuel/xfuel

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
	fuel_type = /datum/reagent/water

//The engineer pyro bag internal fuel tank
/obj/item/ammo_magazine/flamer_tank/internal
	name = "internal fuel tank"
	desc = "A large fuel tank of ultra thick napthal, a sticky combustable liquid chemical, you shouldn't see this though."
	icon_state = ""
	max_rounds = 280
	current_rounds = 280
	reload_delay = 0 SECONDS

/obj/item/ammo_magazine/flamer_tank/vsd
	name = "large CC/21 flamerthrower tank"
	desc = "A large tank for the Kaizoku CC/21 Flamer, filled with thick napthal fuel."
	icon_state = "flametank_vsd_orange"
	max_rounds = 150
	current_rounds = 150
	reload_delay = 4 SECONDS
	default_ammo = /datum/ammo/flamethrower
	icon_state_mini = "tank_orange"
	fuel_type = DEFAULT_FUEL_TYPE


/obj/item/ammo_magazine/flamer_tank/vsd/blue
	name = "large CC/21 flamerthrower tank (X)"
	desc = "A large tank for the Kaizoku CC/21 Flamer, filled with thick napthal X fuel."
	icon_state = "flametank_vsd"
	max_rounds = 150
	current_rounds = 150
	reload_delay = 4 SECONDS
	default_ammo = /datum/ammo/flamethrower/blue
	fuel_type = /datum/reagent/fuel/xfuel
	icon_state_mini = "tank_blue"
