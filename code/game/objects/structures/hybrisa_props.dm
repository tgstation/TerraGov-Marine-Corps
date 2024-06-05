// Hybrisa props

/obj/structure/prop/hybrisa
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "pimp"

// Vehicles

/obj/structure/prop/urban/vehicles
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "SUV"
	max_integrity = 3000
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/prop/urban/vehicles/Destroy()
	explode()
	. = ..()

/obj/structure/prop/urban/vehicles/meridian/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	if(!.)
		return
	switch(obj_integrity)
		if(2500 to 3000)
			icon_state = initial(icon_state)
			return
		if(2000 to 2500)
			icon_state = "[base_icon_state]_damage_[1]"
		if(1500 to 2000)
			icon_state = "[base_icon_state]_damage_[2]"
		if(1000 to 1500)
			icon_state = "[base_icon_state]_damage_[3]"
		if(500 to 1000)
			icon_state = "[base_icon_state]_damage_[4]"
		if(0 to 500)
			icon_state = "[base_icon_state]_damage_[5]"

///spawns a bunch of debris and plays a sound when a vehicle is wrecked
/obj/structure/prop/urban/vehicles/proc/explode()
	src.visible_message(span_danger("<B>[src] blows apart!</B>"), null, null, 1)
	if(prob(10))
		explosion(loc, light_impact_range = 4, flame_range = 2)
	playsound(loc, 'sound/effects/car_crush.ogg', 25)
	var/turf/Tsec = get_turf(src)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/sheet/metal(Tsec)
	new /obj/item/stack/sheet/metal(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)

	new /obj/effect/spawner/gibspawner/robot(Tsec)
	new /obj/effect/decal/cleanable/blood/oil(src.loc)

/obj/structure/prop/urban/vehicles/largetruck
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "zenithlongtruck3"

/obj/structure/prop/urban/vehicles/car
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "MeridianCar_1"


// Very Large Vehicles

/obj/structure/prop/urban/vehicles/large_vehicles
	icon = 'icons/obj/structures/prop/urban/128x32_vehiclesexpanded.dmi'
	icon_state = "armoredtruck_nt_security_1"
	density = TRUE
	layer = ABOVE_MOB_LAYER

// Misc
/obj/structure/prop/urban/vehicles/large_vehicles/ambulance
	name = "ambulance"
	desc = "Seems to be broken down."
	icon_state = "ambulance"
	bound_height = 64
	bound_width = 96

// Armored Truck

/obj/structure/prop/urban/vehicles/large_vehicles/armored_trucks
	icon_state = "armoredtruck_wy_security_1"
	bound_height = 32
	bound_width = 96

/obj/structure/prop/urban/vehicles/large_vehicles/armored_trucks/Initialize(mapload)
	. = ..()
	if(dir == NORTH)
		overlays += image(icon, src, "[initial(icon_state)]_top_r", layer = ABOVE_ALL_MOB_LAYER)
	if(dir == SOUTH)
		overlays += image(icon, src, "[initial(icon_state)]_top_l", layer = ABOVE_ALL_MOB_LAYER)
	if(dir == WEST)
		overlays += image(icon, src, "[initial(icon_state)]_top_rb", layer = ABOVE_ALL_MOB_LAYER)
	if(dir == EAST)
		overlays += image(icon, src, "[initial(icon_state)]_top_lb", layer = ABOVE_ALL_MOB_LAYER)

/obj/structure/prop/urban/vehicles/large_vehicles/armored_trucks/nt_security/truck_1
	name = "\improper Nanotrasen security truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_nt_security_1"

/obj/structure/prop/urban/vehicles/large_vehicles/armored_trucks/nt_security/truck_2
	name = "\improper Nanotrasen security truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_nt_security_2"

// Armored Truck Goods
/obj/structure/prop/urban/vehicles/large_vehicles/armored_trucks/heavy_loader/white
	name = "heavy loader truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_white_white"

/obj/structure/prop/urban/vehicles/large_vehicles/armored_trucks/heavy_loader/white_teal
	name = "heavy loader truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_white_teal"

/obj/structure/prop/urban/vehicles/large_vehicles/armored_trucks/heavy_loader/blue_white
	name = "heavy loader truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_blue_white"

// Mega-Hauler Trucks 128x64

/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck
	name = "mega-hauler truck"
	icon_state = "longtruck_kellandmining"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/128x32_vehiclesexpanded.dmi'
	bound_height = 32
	bound_width = 128
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	max_integrity = 4000
	coverage = 90

/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck/Initialize(mapload)
	. = ..()
	if(dir == NORTH || EAST)
		overlays += image(icon, src, "[initial(icon_state)]_top_r", layer = ABOVE_ALL_MOB_LAYER)
	if(dir == SOUTH || WEST)
		overlays += image(icon, src, "[initial(icon_state)]_top_l", layer = ABOVE_ALL_MOB_LAYER)

/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck/kelland
	icon_state = "longtruck_kellandmining"

/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck/red_stripe
	icon_state = "longtruck_blue_redstripe"

/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck/blue_stripe
	icon_state = "longtruck_red_bluestripe"

/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck/brown
	icon_state = "longtruck_brown"

/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck/donk
	icon_state = "longtruck_donk"

//WY
/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck/nt_black
	name = "\improper Nanotrasen mega-hauler truck"
	icon_state = "longtruck_nt_black"

/obj/structure/prop/urban/vehicles/large_vehicles/mega_hauler_truck/nt_blue
	name = "\improper Nanotrasen mega-hauler truck"
	icon_state = "longtruck_nt_blue"

// SUV
/obj/structure/prop/urban/vehicles/suv
	name = "SUV"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "SUV"
	bound_height = 64
	bound_width = 64
	density = TRUE
	coverage = 75

/obj/structure/prop/urban/vehicles/suv/suv_1
	icon_state = "SUV1"

/obj/structure/prop/urban/vehicles/suv/suv_2
	icon_state = "SUV2"

/obj/structure/prop/urban/vehicles/suv/suv_5
	icon_state = "SUV5"

/obj/structure/prop/urban/vehicles/suv/suv_6
	icon_state = "SUV6"

/obj/structure/prop/urban/vehicles/suv/suv_7
	icon_state = "SUV7"

/obj/structure/prop/urban/vehicles/suv/suv_8
	icon_state = "SUV8"

// damaged suv

/obj/structure/prop/urban/vehicles/suv/suvdamaged
	name = "heavily damaged SUV"
	desc = "A shell of a vehicle, broken down beyond repair."
	icon_state = "SUV_damaged"

/obj/structure/prop/urban/vehicles/suv/suvdamaged/suv_damaged1
	icon_state = "SUV1_damaged"

/obj/structure/prop/urban/vehicles/suv/suvdamaged/suv_damaged2
	icon_state = "SUV2_damaged"

// Meridian Cars - Damage States
/obj/structure/prop/urban/vehicles/meridian
	name = "\improper Mono-Spectra"
	desc = "The 'Mono-Spectra', a mass-produced civilian vehicle for extraterrestrial markets, in and outside of Terra controlled space. Produced by 'Meridian' a car marque and associated operating division of the Nanotrasen Corporation."
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_red.dmi'
	icon_state = "meridian_red"
	bound_height = 32
	bound_width = 64
	density = TRUE
	layer = ABOVE_MOB_LAYER
	resistance_flags = XENO_DAMAGEABLE
	coverage = 30
	base_icon_state = "meridian_red"

/obj/structure/prop/urban/vehicles/meridian/red
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_red.dmi'
	icon_state = "meridian_red"
	base_icon_state = "meridian_red"

/obj/structure/prop/urban/vehicles/meridian/red/damageone
	icon_state = "meridian_red_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/red/damagetwo
	icon_state = "meridian_red_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/red/damagethree
	icon_state = "meridian_red_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/red/damagefour
	icon_state = "meridian_red_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/red/damagefive
	icon_state = "meridian_red_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/black
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_black.dmi'
	icon_state = "meridian_black"
	base_icon_state = "meridian_black"

/obj/structure/prop/urban/vehicles/meridian/black/damageone
	icon_state = "meridian_black_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/black/damagetwo
	icon_state = "meridian_black_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/black/damagethree
	icon_state = "meridian_black_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/black/damagefour
	icon_state = "meridian_black_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/black/damagefive
	icon_state = "meridian_black_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/blue
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_blue.dmi'
	icon_state = "meridian_blue"
	base_icon_state = "meridian_blue"

/obj/structure/prop/urban/vehicles/meridian/blue/damageone
	icon_state = "meridian_blue_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/blue/damagetwo
	icon_state = "meridian_blue_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/blue/damagethree
	icon_state = "meridian_blue_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/blue/damagefour
	icon_state = "meridian_blue_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/blue/damagefive
	icon_state = "meridian_blue_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/brown
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_brown.dmi'
	icon_state = "meridian_brown"
	base_icon_state = "meridian_brown"

/obj/structure/prop/urban/vehicles/meridian/brown/damageone
	icon_state = "meridian_brown_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/brown/damagetwo
	icon_state = "meridian_brown_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/brown/damagethree
	icon_state = "meridian_brown_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/brown/damagefour
	icon_state = "meridian_brown_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/brown/damagefive
	icon_state = "meridian_brown_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/cop
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_cop.dmi'
	icon_state = "meridian_cop"
	base_icon_state = "meridian_cop"

/obj/structure/prop/urban/vehicles/meridian/cop/damageone
	icon_state = "meridian_cop_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/cop/damagetwo
	icon_state = "meridian_cop_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/cop/damagethree
	icon_state = "meridian_cop_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/cop/damagefour
	icon_state = "meridian_cop_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/cop/damagefive
	icon_state = "meridian_cop_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/desat_blue
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_desatblue.dmi'
	icon_state = "meridian_desatblue"
	base_icon_state = "meridian_desatblue"

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damageone
	icon_state = "meridian_desatblue_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damagetwo
	icon_state = "meridian_desatblue_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damagethree
	icon_state = "meridian_desatblue_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damagefour
	icon_state = "meridian_desatblue_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damagefive
	icon_state = "meridian_desatblue_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/green
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_green.dmi'
	icon_state = "meridian_green"
	base_icon_state = "meridian_green"

/obj/structure/prop/urban/vehicles/meridian/green/damageone
	icon_state = "meridian_green_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/green/damagetwo
	icon_state = "meridian_green_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/green/damagethree
	icon_state = "meridian_green_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/green/damagefour
	icon_state = "meridian_green_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/green/damagefive
	icon_state = "meridian_green_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/light_blue
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_lightblue.dmi'
	icon_state = "meridian_lightblue"
	base_icon_state = "meridian_lightblue"

/obj/structure/prop/urban/vehicles/meridian/light_blue/damageone
	icon_state = "meridian_lightblue_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/light_blue/damagetwo
	icon_state = "meridian_lightblue_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/light_blue/damagethree
	icon_state = "meridian_lightblue_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/light_blue/damagefour
	icon_state = "meridian_lightblue_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/light_blue/damagefive
	icon_state = "meridian_lightblue_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/pink
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_pink.dmi'
	icon_state = "meridian_pink"
	base_icon_state = "meridian_pink"

/obj/structure/prop/urban/vehicles/meridian/pink/damageone
	icon_state = "meridian_pink_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/pink/damagetwo
	icon_state = "meridian_pink_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/pink/damagethree
	icon_state = "meridian_pink_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/pink/damagefour
	icon_state = "meridian_pink_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/pink/damagefive
	icon_state = "meridian_pink_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/purple
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_purple.dmi'
	icon_state = "meridian_purple"
	base_icon_state = "meridian_purple"

/obj/structure/prop/urban/vehicles/meridian/purple/damageone
	icon_state = "meridian_purple_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/purple/damagetwo
	icon_state = "meridian_purple_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/purple/damagethree
	icon_state = "meridian_purple_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/purple/damagefour
	icon_state = "meridian_purple_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/purple/damagefive
	icon_state = "meridian_purple_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/turquoise
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_turquoise.dmi'
	icon_state = "meridian_turquoise"
	base_icon_state = "meridian_turquoise"

/obj/structure/prop/urban/vehicles/meridian/turquoise/damageone
	icon_state = "meridian_turquoise_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/turquoise/damagetwo
	icon_state = "meridian_turquoise_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/turquoise/damagethree
	icon_state = "meridian_turquoise_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/turquoise/damagefour
	icon_state = "meridian_turquoise_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/turquoise/damagefive
	icon_state = "meridian_turquoise_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/orange
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_orange.dmi'
	icon_state = "meridian_orange"
	base_icon_state = "meridian_orange"

/obj/structure/prop/urban/vehicles/meridian/orange/damageone
	icon_state = "meridian_orange_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/orange/damagetwo
	icon_state = "meridian_orange_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/orange/damagethree
	icon_state = "meridian_orange_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/orange/damagefour
	icon_state = "meridian_orange_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/orange/damagefive
	icon_state = "meridian_orange_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/generic
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_wy.dmi'
	icon_state = "meridian_wy"
	base_icon_state = "meridian_wy"

/obj/structure/prop/urban/vehicles/meridian/generic/damageone
	icon_state = "meridian_wy_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/generic/damagetwo
	icon_state = "meridian_wy_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/generic/damagethree
	icon_state = "meridian_wy_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/generic/damagefour
	icon_state = "meridian_wy_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/generic/damagefive
	icon_state = "meridian_wy_damage_5"
	max_integrity = 500

/obj/structure/prop/urban/vehicles/meridian/taxi
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_taxi.dmi'
	icon_state = "meridian_taxi"
	base_icon_state = "meridian_taxi"

/obj/structure/prop/urban/vehicles/meridian/taxi/damageone
	icon_state = "meridian_taxi_damage_1"
	max_integrity = 2500

/obj/structure/prop/urban/vehicles/meridian/taxi/damagetwo
	icon_state = "meridian_taxi_damage_2"
	max_integrity = 2000

/obj/structure/prop/urban/vehicles/meridian/taxi/damagethree
	icon_state = "meridian_taxi_damage_3"
	max_integrity = 1500

/obj/structure/prop/urban/vehicles/meridian/taxi/damagefour
	icon_state = "meridian_taxi_damage_4"
	max_integrity = 1000

/obj/structure/prop/urban/vehicles/meridian/taxi/damagefive
	icon_state = "meridian_taxi_damage_5"
	max_integrity = 500

// Car Chassis

/obj/structure/prop/urban/vehicles/car/car_chassis
	desc = "A Mono-Spectra chassis in the early stages of assembly."

/obj/structure/prop/urban/vehicles/car/car_chassis
	name = "\improper Mono-Spectra Chassis"
	icon_state = "MeridianCar_shell"

// small trucks

/obj/structure/prop/urban/vehicles/truck
	name = "truck"
	icon_state = "zentruck1"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/truck/truck1
	icon_state = "zentruck2"

/obj/structure/prop/urban/vehicles/truck/truck2
	icon_state = "zentruck3"

/obj/structure/prop/urban/vehicles/truck/truck3
	icon_state = "zentruck4"

/obj/structure/prop/urban/vehicles/truck/truck4
	icon_state = "zentruck5"

/obj/structure/prop/urban/vehicles/truck/truck5
	icon_state = "truck_cargo"

/obj/structure/prop/urban/vehicles/truck/truck6
	icon_state = "truck"

/obj/structure/prop/urban/vehicles/truck/garbage
	name = "garbage truck"
	icon_state = "zengarbagetruck"
	desc = "Seems to be broken down."

/obj/structure/prop/urban/vehicles/truck/mining
	name = "mining supply truck"
	icon_state = "truck_mining"
	desc = "Seems to be broken down."
// large trucks

/obj/structure/prop/urban/vehicles/largetruck
	name = "mega-hauler truck"
	icon_state = "zenithlongtruck4"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/largetruck/largetruck1
	icon_state = "zenithlongtruck2"

/obj/structure/prop/urban/vehicles/largetruck/largetruck2
	icon_state = "zenithlongtruck3"

/obj/structure/prop/urban/vehicles/largetruck/largetruck3
	icon_state = "zenithlongtruck4"

/obj/structure/prop/urban/vehicles/largetruck/largetruck4
	icon_state = "zenithlongtruck5"

// mining truck

/obj/structure/prop/urban/vehicles/largetruck/largetruckmining
	icon_state = "zenithlongtruckkellandmining1"

/obj/structure/prop/urban/vehicles/largetruck/largetruckmining
	name = "Kelland mining mega-hauler truck"

/obj/structure/prop/urban/vehicles/largetruck/largetruckmining/mining
	icon_state = "zenithlongtruckkellandmining1"

// w-y truck

/obj/structure/prop/urban/vehicles/largetruck/largetruckwy
	icon_state = "zenithlongtruckweyland1"

/obj/structure/prop/urban/vehicles/largetruck/largetruckwy
	name = "\improper Nanotrasen mega-hauler truck"

/obj/structure/prop/urban/vehicles/largetruck/largetruckwy/wy1
	icon_state = "zenithlongtruckweyland1"

/obj/structure/prop/urban/vehicles/largetruck/largetruckwy/wy2
	icon_state = "zenithlongtruckweyland2"

// Colony Crawlers

/obj/structure/prop/urban/vehicles/colonycrawlers
	icon_state = "crawler_wy2"
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/colonycrawlers/mining
	icon_state = "miningcrawler1"
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

/obj/structure/prop/urban/vehicles/colonycrawlers/mining2
	icon_state = "crawler_fuel"
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

/obj/structure/prop/urban/vehicles/colonycrawlers/mining3
	icon_state = "crawler_covered_bed"
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

/obj/structure/prop/urban/vehicles/colonycrawlers/science
	icon_state = "crawler_wy2"
	desc = "It is a tread bound crawler used in harsh conditions. This one is designed for personnel transportation. Supplied by Orbital Blue International; 'Your friends, in the Aerospace business.' A subsidiary of Nanotrasen."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

// science crawlers

/obj/structure/prop/urban/vehicles/colonycrawlers/science
	name = "\improper Nanotrasen colony crawler"

/obj/structure/prop/urban/vehicles/colonycrawlers/science/science1
	icon_state = "crawler_wy1"
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

/obj/structure/prop/urban/vehicles/colonycrawlers/science/science2
	icon_state = "crawler_wy2"
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

// Mining Crawlers

/obj/structure/prop/urban/vehicles/colonycrawlers/mining
	name = "kelland mining colony crawler"

/obj/structure/prop/urban/vehicles/colonycrawlers/mining/mining1
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon_state = "miningcrawler2"

/obj/structure/prop/urban/vehicles/colonycrawlers/mining/mining2
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon_state = "miningcrawler3"

/obj/structure/prop/urban/vehicles/colonycrawlers/mining/mining3
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon_state = "miningcrawler4"

/obj/structure/prop/urban/vehicles/colonycrawlers/mining/mining4
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon_state = "miningcrawlerblank"

// Special SUV's

/obj/structure/prop/urban/vehicles/suv/misc
	name = "\improper Nanotrasen rapid response vehicle"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "WYSUV1"
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/suv/misc/wy1
	icon_state = "WYSUV1"

/obj/structure/prop/urban/vehicles/suv/misc/wy2
	icon_state = "WYSUV2"

/obj/structure/prop/urban/vehicles/suv/misc/wy3
	icon_state = "WYSUV3"

/obj/structure/prop/urban/vehicles/suv/misc/ambulance
	name = "emergency response medical van"
	desc = "Seems to be broken down."
	icon_state = "ambulance"

/obj/structure/prop/urban/vehicles/suv/misc/whitevan
	name = "maintenance SUV"
	desc = "Seems to be broken down."
	icon_state = "whitevan"

/obj/structure/prop/urban/vehicles/suv/misc/maintenance
	name = "maintenance SUV"
	desc = "Seems to be broken down."
	icon_state = "maintenaceSUV"

/obj/structure/prop/urban/vehicles/suv/misc/marshalls
	name = "colonial marshalls rapid response SUV"
	desc = "Seems to be broken down."
	icon_state = "marshalls"

/obj/structure/prop/urban/vehicles/suv/misc/marshalls2
	name = "colonial marshalls rapid response SUV"
	desc = "Seems to be broken down."
	icon_state = "marshalls2"

/obj/structure/prop/urban/vehicles/suv/misc/expensive
	name = "Expensive looking SUV"
	desc = "Seems to be broken down."
	icon_state = "SUV9"

/obj/structure/prop/urban/vehicles/suv/misc/expensive2
	name = "Expensive Nanotrasen SUV"
	desc = "Seems to be broken down."
	icon_state = "blackSUV"

/obj/structure/prop/urban/vehicles/suv/misc/expensive3
	name = "The Pimp-Mobile"
	desc = "Seems to be broken down."
	icon_state = "pimpmobile"

// Vans

/obj/structure/prop/urban/vehicles/van
	name = "van"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "greyvan"
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/van/vandamaged
	name = "van"
	desc = "A shell of a vehicle, broken down beyond repair."
	icon_state = "greyvan_damaged"
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/van/vanpizza
	name = "pizza delivery van"
	desc = "Seems to be broken down."
	icon_state = "pizzavan"
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/van/vanmining
	name = "Kelland Mining van"
	desc = "Seems to be broken down."
	icon_state = "kellandminingvan"
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/van/hyperdynevan
	name = "Hyperdyne van"
	desc = "Seems to be broken down."
	icon_state = "hyperdynevan"
	bound_height = 64
	bound_width = 64
	density = TRUE

/obj/structure/prop/urban/vehicles/crashedcarsleft
	name = "car pileup"
	desc = "Burned out wrecked vehicles block your path."
	icon = 'icons/obj/structures/prop/urban/crashedcars.dmi'
	icon_state = "crashedcarsleft"
	bound_height = 64
	bound_width = 64
	density = TRUE
	layer = 5

/obj/structure/prop/urban/vehicles/crashedcarsright
	name = "car pileup"
	desc = "Burned out wrecked vehicles block your path."
	icon = 'icons/obj/structures/prop/urban/crashedcars.dmi'
	icon_state = "crashedcarsright"
	bound_height = 64
	bound_width = 64
	density = TRUE
	layer = 5

// Cave props

/obj/structure/prop/urban/boulders
	icon = 'icons/obj/structures/boulder_largedark.dmi'
	icon_state = "boulder_largedark1"

/obj/structure/prop/urban/boulders/large_boulderdark
	name = "boulder"
	desc = "A large rock. It's not cooking anything."
	icon = 'icons/obj/structures/boulder_largedark.dmi'
	icon_state = "boulder_largedark1"
	density = TRUE
	bound_height = 64
	bound_width = 64

/obj/structure/prop/urban/boulders/large_boulderdark/boulder_dark1
	icon_state = "boulder_largedark1"

/obj/structure/prop/urban/boulders/large_boulderdark/boulder_dark2
	icon_state = "boulder_largedark2"

/obj/structure/prop/urban/boulders/large_boulderdark/boulder_dark3
	icon_state = "boulder_largedark3"

/obj/structure/prop/urban/boulders/wide_boulderdark
	name = "boulder"
	desc = "A large rock. It's not cooking anything."
	icon = 'icons/obj/structures/boulder_widedark.dmi'
	icon_state = "boulderwidedark"
	density = TRUE
	bound_height = 32
	bound_width = 64

/obj/structure/prop/urban/boulders/wide_boulderdark/wide_boulder1
	icon_state = "boulderwidedark"

/obj/structure/prop/urban/boulders/wide_boulderdark/wide_boulder2
	icon_state = "boulderwidedark2"

/obj/structure/prop/urban/boulders/smallboulderdark
	name = "boulder"
	icon_state = "bouldersmalldark1"
	desc = "A large rock. It's not cooking anything."
	icon = 'icons/obj/structures/boulder_small.dmi'
	density = TRUE

/obj/structure/prop/urban/boulders/smallboulderdark/boulder_dark1
	icon_state = "bouldersmalldark1"

/obj/structure/prop/urban/boulders/smallboulderdark/boulder_dark2
	icon_state = "bouldersmalldark2"

/obj/structure/prop/urban/boulders/smallboulderdark/boulder_dark3
	icon_state = "bouldersmalldark3"

/obj/structure/prop/urban/cavedecor
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	name = "stalagmite"
	icon_state = "stalagmite"
	desc = "A cave stalagmite."
	layer = TURF_LAYER
	plane = FLOOR_PLANE

/obj/structure/prop/urban/cavedecor/stalagmite0
	icon_state = "stalagmite"

/obj/structure/prop/urban/cavedecor/stalagmite1
	icon_state = "stalagmite1"

/obj/structure/prop/urban/cavedecor/stalagmite2
	icon_state = "stalagmite2"

/obj/structure/prop/urban/cavedecor/stalagmite3
	icon_state = "stalagmite3"

/obj/structure/prop/urban/cavedecor/stalagmite4
	icon_state = "stalagmite4"

/obj/structure/prop/urban/cavedecor/stalagmite5
	icon_state = "stalagmite5"


// Supermart

/obj/structure/prop/urban/supermart
	name = "long rack"
	icon_state = "longrack1"
	desc = "A long shelf filled with various foodstuffs"
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	density = TRUE

/obj/structure/prop/urban/supermart/rack/longrackempty
	name = "shelf"
	desc = "A long empty shelf."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "longrackempty"

/obj/structure/prop/urban/supermart/rack/longrack1
	name = "shelf"
	desc = "A long shelf filled with various foodstuffs"
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "longrack1"

/obj/structure/prop/urban/supermart/rack/longrack2
	name = "shelf"
	desc = "A long shelf filled with various foodstuffs"
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "longrack2"

/obj/structure/prop/urban/supermart/rack/longrack3
	name = "shelf"
	desc = "A long shelf filled with various foodstuffs"
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "longrack3"

/obj/structure/prop/urban/supermart/rack/longrack4
	name = "shelf"
	desc = "A long shelf filled with various foodstuffs"
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "longrack4"

/obj/structure/prop/urban/supermart/rack/longrack5
	name = "shelf"
	desc = "A long shelf filled with various foodstuffs"
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "longrack5"

/obj/structure/prop/urban/supermart/rack/longrack6
	name = "shelf"
	desc = "A long shelf filled with various foodstuffs"
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "longrack6"

/obj/structure/prop/urban/supermart/rack/longrack7
	name = "shelf"
	desc = "A long shelf filled with various foodstuffs"
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "longrack7"

/obj/structure/prop/urban/supermart/supermartbelt
	name = "conveyor belt"
	desc = "A conveyor belt."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "checkoutbelt"

/obj/structure/prop/urban/supermart/freezer
	name = "commercial freezer"
	desc = "A commercial grade freezer."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "freezerupper"
	density = TRUE
/obj/structure/prop/urban/supermart/freezer/supermartfreezer1
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "freezerupper"

/obj/structure/prop/urban/supermart/freezer/supermartfreezer2
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "freezerlower"

/obj/structure/prop/urban/supermart/freezer/supermartfreezer3
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "freezermid"

/obj/structure/prop/urban/supermart/freezer/supermartfreezer4
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "freezerupper1"

/obj/structure/prop/urban/supermart/freezer/supermartfreezer5
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "freezerlower1"

/obj/structure/prop/urban/supermart/freezer/supermartfreezer6
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "freezermid1"

/obj/structure/prop/urban/supermart/supermartfruitbasketempty
	name = "basket"
	desc = "A basket."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "supermarketbasketempty"

/obj/structure/prop/urban/supermart/supermartfruitbasketoranges
	name = "basket"
	desc = "A basket full of oranges."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "supermarketbasket1"

/obj/structure/prop/urban/supermart/supermartfruitbasketpears
	name = "basket"
	desc = "A basket full of pears."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "supermarketbasket2"

/obj/structure/prop/urban/supermart/supermartfruitbasketcarrots
	name = "basket"
	desc = "A basket full of carrots."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "supermarketbasket3"

/obj/structure/prop/urban/supermart/supermartfruitbasketmelons
	name = "basket"
	desc = "A basket full of melons."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "supermarketbasket4"

/obj/structure/prop/urban/supermart/supermartfruitbasketapples
	name = "basket"
	desc = "A basket full of apples."
	icon = 'icons/obj/structures/prop/urban/supermart.dmi'
	icon_state = "supermarketbasket5"

// Furniture
/obj/structure/prop/urban/furniture
	icon = 'icons/obj/structures/prop/urban/urbantables.dmi'
	icon_state = "blackmetaltable"

/obj/structure/prop/urban/furniture/tables
	icon = 'icons/obj/structures/prop/urban/urbantables.dmi'
	icon_state = "table_pool"

/obj/structure/prop/urban/furniture/tables/tableblack
	name = "large metal table"
	desc = "A large black metal table, looks very expensive."
	icon_state = "blackmetaltable"
	density = TRUE
	climbable = TRUE
	bound_height = 32
	bound_width = 64

/obj/structure/prop/urban/furniture/tables/tableblack/blacktablecomputer
	icon = 'icons/obj/structures/prop/urban/urbantables.dmi'
	icon_state = "blackmetaltable_computer"

/obj/structure/prop/urban/furniture/tables/tablewood
	name = "large wood table"
	desc = "A large wooden table, looks very expensive."
	icon_state = "brownlargetable"
	density = TRUE
	climbable = TRUE
	bound_height = 32
	bound_width = 64

/obj/structure/prop/urban/furniture/tables/tablewood/woodtablecomputer
	icon = 'icons/obj/structures/prop/urban/urbantables.dmi'
	icon_state = "brownlargetable_computer"

/obj/structure/prop/urban/furniture/tables/tablepool
	name = "pool table"
	desc = "A large table used for Pool."
	icon = 'icons/obj/structures/prop/urban/urbantables.dmi'
	icon_state = "table_pool"
	density = TRUE
	bound_height = 32
	bound_width = 64
	climbable = TRUE

/obj/structure/prop/urban/furniture/tables/tablegambling
	name = "gambling table"
	desc = "A large table used for gambling."
	icon = 'icons/obj/structures/prop/urban/urbantables.dmi'
	icon_state = "table_cards"
	density = TRUE
	bound_height = 32
	bound_width = 64
	climbable = TRUE

// Chairs
/obj/structure/bed/urban/chairs
	name = "expensive chair"
	desc = "An expensive looking chair"

/obj/structure/bed/urban/chairs/black
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "comfychair_zenithblack"

/obj/structure/bed/urban/chairs/red
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "comfychair_zenithred"

/obj/structure/bed/urban/chairs/blue
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "comfychair_zenithblue"

/obj/structure/bed/urban/chairs/brown
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "comfychair_zenithbrown"

// Beds

/obj/structure/bed/hybrisa
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "hybrisa"

/obj/structure/bed/urban/prisonbed
	name = "bunk bed"
	desc = "A sorry looking bunk-bed."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "prisonbed"

/obj/structure/bed/urban/bunkbed1
	name = "bunk bed"
	desc = "A comfy looking bunk-bed."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "zbunkbed"

/obj/structure/bed/urban/bunkbed2
	name = "bunk bed"
	desc = "A comfy looking bunk-bed."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "zbunkbed2"

/obj/structure/bed/urban/bunkbed3
	name = "bunk bed"
	desc = "A comfy looking bunk-bed."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "zbunkbed3"

/obj/structure/bed/urban/bunkbed4
	name = "bunk bed"
	desc = "A comfy looking bunk-bed."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "zbunkbed4"

/obj/structure/bed/urban/hospitalbeds
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "hospital"

/obj/structure/bed/urban/hospitalbeds/hospitalbed1
	name = "hospital bed"
	desc = "A mattress seated on a rectangular metallic frame with wheels. This is used to support a lying person in a comfortable manner."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "bigrollerempty2_up"

/obj/structure/bed/urban/hospitalbeds/hospitalbed2
	name = "hospital bed"
	desc = "A mattress seated on a rectangular metallic frame with wheels. This is used to support a lying person in a comfortable manner."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "bigrollerempty_up"

/obj/structure/bed/urban/hospitalbeds/hospitalbed3
	name = "hospital bed"
	desc = "A mattress seated on a rectangular metallic frame with wheels. This is used to support a lying person in a comfortable manner."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "bigrollerempty3_up"

// Xenobiology

/obj/structure/prop/urban/xenobiology
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocellemptyon"
	layer = ABOVE_MOB_LAYER


/obj/structure/prop/urban/xenobiology/small/empty
	name = "specimen containment cell"
	desc = "It's empty."
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocellemptyon"
	density = TRUE

/obj/structure/prop/urban/xenobiology/small/offempty
	name = "specimen containment cell"
	desc = "It's turned off and empty."
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocellemptyoff"
	density = TRUE

/obj/structure/prop/urban/xenobiology/small/larva
	name = "specimen containment cell"
	desc = "There is something worm-like inside..."
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocelllarva"
	density = TRUE

/obj/structure/prop/urban/xenobiology/small/egg
	name = "specimen containment cell"
	desc = "There is, what looks like some sort of egg inside..."
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocellegg"
	density = TRUE

/obj/structure/prop/urban/xenobiology/small/hugger
	name = "specimen containment cell"
	desc = "There's something spider-like inside..."
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocellhugger"
	density = TRUE

/obj/structure/prop/urban/xenobiology/small/cracked1
	name = "specimen containment cell"
	desc = "Looks like something broke it...from the inside."
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocellcrackedempty"
	density = TRUE

/obj/structure/prop/urban/xenobiology/small/cracked2
	name = "specimen containment cell"
	desc = "Looks like something broke it...from the inside."
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocellcrackedempty2"
	density = TRUE

/obj/structure/prop/urban/xenobiology/small/crackedegg
	name = "specimen containment cell"
	desc = "Looks like something broke it, there's a giant empty egg inside."
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics.dmi'
	icon_state = "xenocellcrackedegg"
	density = TRUE

/obj/structure/prop/urban/xenobiology/big
	name = "specimen containment cell"
	desc = "A giant tube with a hulking monstrosity inside, is this thing alive?"
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics2.dmi'
	icon_state = "bigqueencryo1"

/obj/structure/prop/urban/xenobiology/big/bigleft
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics2.dmi'
	icon_state = "bigqueencryo1"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/xenobiology/big/bigright
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics2.dmi'
	icon_state = "bigqueencryo2"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/xenobiology/big/bigbottomleft
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics2.dmi'
	icon_state = "bigqueencryo3"
	density = TRUE
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/xenobiology/big/bigbottomright
	icon = 'icons/obj/structures/prop/urban/urbanxenocryogenics2.dmi'
	icon_state = "bigqueencryo4"
	density = TRUE
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/xenobiology/misc
	name = "strange egg"
	desc = "A strange ancient looking egg, it seems to be inert."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "inertegg"
	layer = 2

// Engineer

/obj/structure/prop/hybrisa/engineer
	icon = 'icons/obj/structures/prop/urban/engineerjockey.dmi'
	icon_state = "spacejockey"

/obj/structure/prop/hybrisa/engineer/spacejockey
	name = "Giant Pilot"
	desc = "A Giant Alien life form. Looks like it's been dead a long time. Fossilized. Looks like it's growing out of the chair. Bones are bent outward, like it exploded from inside."
	icon = 'icons/obj/structures/prop/urban/engineerjockey.dmi'
	icon_state = "spacejockey"
	layer = ABOVE_MOB_LAYER
	resistance_flags = RESIST_ALL

/obj/structure/prop/urban/engineer
	icon_state = "spacejockey"

/obj/structure/prop/urban/engineer/giantconsole
	name = "Giant Alien Console"
	desc = "A Giant Alien console of some kind, unlike anything you've ever seen before. Who knows the purpose of this strange technology..."
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "engineerconsole"
	bound_height = 32
	bound_width = 32
	density = TRUE
/obj/structure/prop/urban/engineer/engineerpillar
	icon = 'icons/obj/structures/prop/urban/urbanengineerpillarangled.dmi'
	icon_state = "engineerpillar_SW1fade"
	bound_height = 64
	bound_width = 128
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/engineer/engineerpillar/northwesttop
	name = "strange pillar"
	icon = 'icons/obj/structures/prop/urban/urbanengineerpillarangled.dmi'
	icon_state = "engineerpillar_NW1"
/obj/structure/prop/urban/engineer/engineerpillar/northwestbottom
	name = "strange pillar"
	icon = 'icons/obj/structures/prop/urban/urbanengineerpillarangled.dmi'
	icon_state = "engineerpillar_NW2"
/obj/structure/prop/urban/engineer/engineerpillar/southwesttop
	name = "strange pillar"
	icon = 'icons/obj/structures/prop/urban/urbanengineerpillarangled.dmi'
	icon_state = "engineerpillar_SW1"
/obj/structure/prop/urban/engineer/engineerpillar/southwestbottom
	name = "strange pillar"
	icon = 'icons/obj/structures/prop/urban/urbanengineerpillarangled.dmi'
	icon_state = "engineerpillar_SW2"
/obj/structure/prop/urban/engineer/engineerpillar/smallsouthwest1
	name = "strange pillar"
	icon = 'icons/obj/structures/prop/urban/urbanengineerpillarangled.dmi'
	icon_state = "engineerpillar_SW1fade"
/obj/structure/prop/urban/engineer/engineerpillar/smallsouthwest2
	name = "strange pillar"
	icon = 'icons/obj/structures/prop/urban/urbanengineerpillarangled.dmi'
	icon_state = "engineerpillar_SW2fade"

// Airport

/obj/structure/prop/urban/airport
	name = "nose cone"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dropshipfrontwhite1"

/obj/structure/prop/urban/airport/dropshipnosecone
	name = "nose cone"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dropshipfrontwhite1"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/airport/dropshipwingleft
	name = "wing"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dropshipwingtop1"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/airport/dropshipwingright
	name = "wing"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dropshipwingtop2"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/airport/dropshipvent1left
	name = "vent"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dropshipvent1"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/airport/dropshipvent2right
	name = "vent"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dropshipvent2"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/airport/dropshipventleft
	name = "vent"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dropshipvent3"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/airport/dropshipventright
	name = "vent"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dropshipvent4"
	layer = ABOVE_MOB_LAYER

// Dropship damage

/obj/structure/prop/urban/airport/dropshipenginedamage
	name = "dropship damage"
	desc = "the engine appears to have severe damage."
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "dropship_engine_damage"
	bound_height = 64
	bound_width = 96

/obj/structure/prop/urban/airport/dropshipenginedamagenofire
	name = "dropship damage"
	desc = "the engine appears to have severe damage."
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "dropship_engine_damage_nofire"
	bound_height = 64
	bound_width = 96

/obj/structure/prop/urban/airport/refuelinghose
	name = "refueling hose"
	desc = "A long refueling hose that connects to various types of dropships."
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "fuelline1"
	bound_height = 64
	bound_width = 96
	layer = BELOW_TABLE_LAYER


/obj/structure/prop/urban/airport/refuelinghose2
	name = "refueling hose"
	desc = "A long refueling hose that connects to various types of dropships."
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "fuelline2"
	bound_height = 64
	bound_width = 96
	layer = BELOW_TABLE_LAYER

// Pilot body

/obj/structure/prop/urban/airport/deadpilot1
	name = "decapitated Nanotrasen Pilot"
	desc = "What remains of a Nanotrasen Pilot. Their entire head is missing. Where'd it roll off to?..."
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "pilotbody_decap1"
	bound_height = 64
	bound_width = 96

/obj/structure/prop/urban/airport/deadpilot2
	name = "decapitated Nanotrasen Pilot"
	desc = "What remains of a Nanotrasen Pilot. Their entire head is missing. Where'd it roll off to?..."
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "pilotbody_decap2"
	bound_height = 64
	bound_width = 96

// Misc

/obj/structure/prop/urban/misc
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrier"

// Floor props

/obj/structure/prop/urban/misc/floorprops
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "solidgrate1"

/obj/structure/prop/urban/misc/floorprops/grate
	name = "solid metal grate"
	desc = "A metal grate."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "solidgrate1"

/obj/structure/prop/urban/misc/floorprops/grate2
	name = "solid metal grate"
	desc = "A metal grate."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "solidgrate5"

/obj/structure/prop/urban/misc/floorprops/grate3
	name = "solid metal grate"
	desc = "A metal grate."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "zhalfgrate1"

/obj/structure/prop/urban/misc/floorprops/floorglass
	name = "reinforced glass floor"
	desc = "A heavily reinforced glass floor panel, this looks almost indestructible."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "solidgrate2"

/obj/structure/prop/urban/misc/floorprops/floorglass2
	name = "reinforced glass floor"
	desc = "A heavily reinforced glass floor panel, this looks almost indestructible."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "solidgrate3"
	layer = 2.1

/obj/structure/prop/urban/misc/floorprops/floorglass3
	name = "reinforced glass floor"
	desc = "A heavily reinforced glass floor panel, this looks almost indestructible."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "solidgrate4"

// Graffiti

/obj/structure/prop/urban/misc/graffiti
	name = "graffiti"
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zgraffiti4"
	bound_height = 64
	bound_width = 96

/obj/structure/prop/urban/misc/graffiti/graffiti1
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zgraffiti1"

/obj/structure/prop/urban/misc/graffiti/graffiti2
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zgraffiti2"

/obj/structure/prop/urban/misc/graffiti/graffiti3
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zgraffiti3"

/obj/structure/prop/urban/misc/graffiti/graffiti4
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zgraffiti4"

/obj/structure/prop/urban/misc/graffiti/graffiti5
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zgraffiti5"

/obj/structure/prop/urban/misc/graffiti/graffiti6
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zgraffiti6"

/obj/structure/prop/urban/misc/graffiti/graffiti7
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zgraffiti7"

// Wall Blood

/obj/structure/prop/urban/misc/blood
	name = "blood"
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "wallblood_floorblood"

/obj/structure/prop/urban/misc/blood/blood1
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "wallblood_floorblood"

/obj/structure/prop/urban/misc/blood/blood2
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "wall_blood_1"

/obj/structure/prop/urban/misc/blood/blood3
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "wall_blood_2"

// Fire

/obj/structure/prop/urban/misc/fire/fire1
	name = "fire"
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zfire_smoke"
	layer = 5
	light_on = TRUE
	light_power = 2
	light_range = 3

/obj/structure/prop/urban/misc/fire/fire2
	name = "fire"
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zfire_smoke2"
	layer = 5
	light_on = TRUE
	light_power = 2
	light_range = 3

/obj/structure/prop/urban/misc/fire/firebarrel
	name = "barrel"
	icon = 'icons/obj/structures/prop/urban/64x96-urbanrandomprops.dmi'
	icon_state = "zbarrelfireon"
	layer = 5
	light_on = TRUE
	light_power = 2
	light_range = 3

// Misc

/obj/structure/prop/urban/misc/commandosuitemptyprop
	name = "\improper Nanotrasen 'Ape-Suit' Showcase"
	desc = "A display model of the Nanotrasen 'Apesuit', shame it's only a model..."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "dogcatchersuitempty1"

/obj/structure/prop/urban/misc/cabinet
	name = "cabinet"
	desc = "a small cabinet with drawers."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "sidecabinet"

/obj/structure/prop/urban/misc/trash/green
	name = "trash bin"
	desc = "A Nanotrasen trash bin used for disposing your unwanted items, or you can just throw your shit on the ground like every other asshole."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "trashgreen"
	density = TRUE

/obj/structure/prop/urban/misc/trash/blue
	name = "trash bin"
	desc = "A Nanotrasen trash bin used for disposing your unwanted items, or you can just throw your shit on the ground like every other asshole."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "trashblue"
	density = TRUE

/obj/structure/prop/urban/misc/redmeter
	name = "meter"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "redmeter"

/obj/structure/prop/urban/misc/firebarreloff
	name = "barrel"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "zfirebarreloff"

/obj/structure/prop/urban/misc/trashbagfullprop
	name = "trash bag"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "ztrashbag"

/obj/structure/prop/urban/misc/slotmachine
	name = "slot machine"
	desc = "A slot machine."
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "slotmachine"
	bound_width = 32
	bound_height = 32
	anchored = TRUE
	density = TRUE
	layer = 3.2

/obj/structure/prop/urban/misc/atm
	name = "\improper NanoTrasen Automatic Teller Machine"
	desc = "For all your monetary needs!"
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "atm"
	bound_width = 32
	bound_height = 32
	anchored = TRUE
	density = TRUE
	layer = 3.2

/obj/structure/prop/urban/misc/slotmachine_broken
	name = "slot machine"
	desc = "A broken slot machine."
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "slotmachine_broken"
	bound_width = 32
	bound_height = 32
	anchored = TRUE
	density = TRUE
	layer = 3.2

/obj/structure/prop/urban/misc/coffeestuff/coffeemachine1
	name = "coffee machine"
	desc = "A coffee machine."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "coffee"

/obj/structure/prop/urban/misc/coffeestuff/coffeemachine2
	name = "coffee machine"
	desc = "A coffee machine."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "coffee_cup"

/obj/structure/prop/urban/misc/machinery/computers
	name = "computer"
	icon_state = "mapping_comp"

/obj/structure/prop/urban/misc/machinery/computers/computerwhite/computer1
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "mapping_comp"

/obj/structure/prop/urban/misc/machinery/computers/computerwhite/computer2
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "mps"

/obj/structure/prop/urban/misc/machinery/computers/computerwhite/computer3
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "sensor_comp1"

/obj/structure/prop/urban/misc/machinery/computers/computerwhite/computer4
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "sensor_comp2"

/obj/structure/prop/urban/misc/machinery/computers/computerwhite/computer5
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "sensor_comp3"


/obj/structure/prop/urban/misc/machinery/computers/computerblack/computer1
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "blackmapping_comp"

/obj/structure/prop/urban/misc/machinery/computers/computerblack/computer2
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "blackmps"

/obj/structure/prop/urban/misc/machinery/computers/computerblack/computer3
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "blacksensor_comp1"

/obj/structure/prop/urban/misc/machinery/computers/computerblack/computer4
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "blacksensor_comp2"

/obj/structure/prop/urban/misc/machinery/computers/computerblack/computer5
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "blacksensor_comp3"


/obj/structure/prop/urban/misc/machinery/screens
	name = "monitor"

/obj/structure/prop/urban/misc/machinery/screens/frame
	icon_state = "frame"

/obj/structure/prop/urban/misc/machinery/screens/security
	icon_state = "security"

/obj/structure/prop/urban/misc/machinery/screens/evac
	icon_state = "evac"

/obj/structure/prop/urban/misc/machinery/screens/redalert
	icon_state = "redalert"

/obj/structure/prop/urban/misc/machinery/screens/redalertblank
	icon_state = "redalertblank"

/obj/structure/prop/urban/misc/machinery/screens/entertainment
	icon_state = "entertainment"

/obj/structure/prop/urban/misc/machinery/screens/telescreen
	icon_state = "telescreen"

/obj/structure/prop/urban/misc/machinery/screens/telescreenbroke
	icon_state = "telescreenb"

/obj/structure/prop/urban/misc/machinery/screens/telescreenbrokespark
	icon_state = "telescreenbspark"

// Multi-Monitor

//Green
/obj/structure/prop/urban/misc/machinery/screens/multimonitorsmall_off
	icon_state = "multimonitorsmall_off"

/obj/structure/prop/urban/misc/machinery/screens/multimonitorsmall_on
	icon_state = "multimonitorsmall_on"

/obj/structure/prop/urban/misc/machinery/screens/multimonitormedium_off
	icon_state = "multimonitormedium_off"

/obj/structure/prop/urban/misc/machinery/screens/multimonitormedium_on
	icon_state = "multimonitormedium_on"

/obj/structure/prop/urban/misc/machinery/screens/multimonitorbig_off
	icon_state = "multimonitorbig_off"

/obj/structure/prop/urban/misc/machinery/screens/multimonitorbig_on
	icon_state = "multimonitorbig_on"

// Blue

/obj/structure/prop/urban/misc/machinery/screens/bluemultimonitorsmall_off
	icon_state = "bluemultimonitorsmall_off"

/obj/structure/prop/urban/misc/machinery/screens/bluemultimonitorsmall_on
	icon_state = "bluemultimonitorsmall_on"

/obj/structure/prop/urban/misc/machinery/screens/bluemultimonitormedium_off
	icon_state = "bluemultimonitormedium_off"

/obj/structure/prop/urban/misc/machinery/screens/bluemultimonitormedium_on
	icon_state = "bluemultimonitormedium_on"

/obj/structure/prop/urban/misc/machinery/screens/bluemultimonitorbig_off
	icon_state = "bluemultimonitorbig_off"

/obj/structure/prop/urban/misc/machinery/screens/bluemultimonitorbig_on
	icon_state = "bluemultimonitorbig_on"

// Egg
/obj/structure/prop/urban/misc/machinery/screens/wallegg_off
	icon_state = "wallegg_off"

/obj/structure/prop/urban/misc/machinery/screens/wallegg_on
	icon_state = "wallegg_on"

/obj/structure/prop/urban/misc/fake/pipes
	name = "disposal pipe"

/obj/structure/prop/urban/misc/fake/pipes/pipe1
	layer = 2
	icon_state = "pipe-s"

/obj/structure/prop/urban/misc/fake/pipes/pipe2
	layer = 2
	icon_state = "pipe-c"

/obj/structure/prop/urban/misc/fake/pipes/pipe3
	layer = 2
	icon_state = "pipe-j1"

/obj/structure/prop/urban/misc/fake/pipes/pipe4
	layer = 2
	icon_state = "pipe-y"

/obj/structure/prop/urban/misc/fake/pipes/pipe5
	layer = 2
	icon_state = "pipe-b"

/obj/structure/prop/urban/misc/fake/wire
	name = "power cable"

/obj/structure/prop/urban/misc/fake/wire/red
	layer = 2
	icon_state = "intactred"

/obj/structure/prop/urban/misc/fake/wire/yellow
	layer = 2
	icon_state = "intactyellow"

/obj/structure/prop/urban/misc/fake/wire/blue
	layer = 2
	icon_state = "intactblue"


/obj/structure/prop/urban/misc/fake/heavydutywire
	name = "heavy duty wire"

/obj/structure/prop/urban/misc/fake/heavydutywire/heavy1
	layer = 2
	icon_state = "0-1"

/obj/structure/prop/urban/misc/fake/heavydutywire/heavy2
	layer = 2
	icon_state = "1-2"

/obj/structure/prop/urban/misc/fake/heavydutywire/heavy3
	layer = 2
	icon_state = "1-4"

/obj/structure/prop/urban/misc/fake/heavydutywire/heavy4
	layer = 2
	icon_state = "1-2-4"

/obj/structure/prop/urban/misc/fake/heavydutywire/heavy5
	layer = 2
	icon_state = "1-2-4-8"

/obj/structure/prop/urban/misc/fake/lattice
	name = "structural lattice"

/obj/structure/prop/urban/misc/fake/lattice/full
	icon_state = "latticefull"
	layer = 2

// Barriers

/obj/structure/prop/urban/misc/road
	name = "road barrier"
	desc = "A plastic barrier for blocking entry."

/obj/structure/prop/urban/misc/road/roadbarrierred
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrier"

/obj/structure/prop/urban/misc/road/roadbarrierredlong
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrier4"

/obj/structure/prop/urban/misc/road/roadbarrierblue
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrier2"

/obj/structure/prop/urban/misc/road/roadbarrierbluelong
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrier5"

/obj/structure/prop/urban/misc/road/roadbarrierwyblack
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrier3"

/obj/structure/prop/urban/misc/road/roadbarrierwyblacklong
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrier6"

/obj/structure/prop/urban/misc/road/roadbarrierwyblackjoined
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrierjoined3"

/obj/structure/prop/urban/misc/road/roadbarrierjoined
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrierjoined"

/obj/structure/prop/urban/misc/road/wood
	name = "road barrier"
	desc = "A wooden barrier for blocking entry."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrierwood"

/obj/structure/prop/urban/misc/road/wood/roadbarrierwoodorange
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrierwood"

/obj/structure/prop/urban/misc/road/wood/roadbarrierwoodblue
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "roadbarrierpolice"

// Cargo Containers extended

/obj/structure/prop/urban/containersextended
	name = "cargo container"
	desc = "a cargo container."
	icon = 'icons/obj/structures/prop/urban/containersextended.dmi'
	icon_state = "blackwyleft"
	bound_width = 32
	bound_height = 32
	density = TRUE
	max_integrity = 200
	opacity = TRUE
	anchored = TRUE
	layer = 5

/obj/structure/prop/urban/containersextended/blueleft
	name = "cargo container"
	icon_state = "blueleft"

/obj/structure/prop/urban/containersextended/blueright
	name = "cargo container"
	icon_state = "blueright"

/obj/structure/prop/urban/containersextended/greenleft
	name = "cargo container"
	icon_state = "greenleft"

/obj/structure/prop/urban/containersextended/greenright
	name = "cargo container"
	icon_state = "greenright"

/obj/structure/prop/urban/containersextended/tanleft
	name = "cargo container"
	icon_state = "tanleft"

/obj/structure/prop/urban/containersextended/tanright
	name = "cargo container"
	icon_state = "tanright"

/obj/structure/prop/urban/containersextended/redleft
	name = "cargo container"
	icon_state = "redleft"

/obj/structure/prop/urban/containersextended/redright
	name = "cargo container"
	icon_state = "redright"

/obj/structure/prop/urban/containersextended/greywyleft
	name = "\improper Nanotrasen cargo container"
	icon_state = "greywyleft"

/obj/structure/prop/urban/containersextended/greywyright
	name = "\improper Nanotrasen cargo container"
	icon_state = "greywyright"

/obj/structure/prop/urban/containersextended/lightgreywyleft
	name = "\improper Nanotrasen cargo container"
	icon_state = "lightgreywyleft"

/obj/structure/prop/urban/containersextended/lightgreywyright
	name = "\improper Nanotrasen cargo container"
	icon_state = "lightgreywyright"

/obj/structure/prop/urban/containersextended/blackwyleft
	name = "\improper Nanotrasen cargo container"
	icon_state = "blackwyleft"

/obj/structure/prop/urban/containersextended/blackwyright
	name = "\improper Nanotrasen cargo container"
	icon_state = "blackwyright"

/obj/structure/prop/urban/containersextended/whitewyleft
	name = "\improper Nanotrasen cargo container"
	icon_state = "whitewyleft"

/obj/structure/prop/urban/containersextended/whitewyright
	name = "\improper Nanotrasen cargo container"
	icon_state = "whitewyright"

/obj/structure/prop/urban/containersextended/tanwywingsleft
	name = "cargo container"
	icon_state = "tanwywingsleft"

/obj/structure/prop/urban/containersextended/tanwywingsright
	name = "cargo container"
	icon_state = "tanwywingsright"

/obj/structure/prop/urban/containersextended/greenwywingsleft
	name = "cargo container"
	icon_state = "greenwywingsleft"

/obj/structure/prop/urban/containersextended/greenwywingsright
	name = "cargo container"
	icon_state = "greenwywingsright"

/obj/structure/prop/urban/containersextended/bluewywingsleft
	name = "cargo container"
	icon_state = "bluewywingsleft"

/obj/structure/prop/urban/containersextended/bluewywingsright
	name = "cargo container"
	icon_state = "bluewywingsright"

/obj/structure/prop/urban/containersextended/redwywingsleft
	name = "cargo container"
	icon_state = "redwywingsleft"

/obj/structure/prop/urban/containersextended/redwywingsright
	name = "cargo container"
	icon_state = "redwywingsright"

/obj/structure/prop/urban/containersextended/medicalleft
	name = "medical cargo containers"
	icon_state = "medicalleft"

/obj/structure/prop/urban/containersextended/medicalright
	name = "medical cargo containers"
	icon_state = "medicalright"

/obj/structure/prop/urban/containersextended/emptymedicalleft
	name = "medical cargo container"
	icon_state = "emptymedicalleft"

/obj/structure/prop/urban/containersextended/emptymedicalright
	name = "medical cargo container"
	icon_state = "emptymedicalright"

/obj/structure/prop/urban/containersextended/graffiti
	name = "defaced cargo container"
	icon_state = "grafcontain_l"

/obj/structure/prop/urban/containersextended/graffiti/two
	name = "defaced cargo container"
	icon_state = "grafcontain_rm"

/obj/structure/prop/urban/containersextended/graffiti/three
	name = "defaced cargo container"
	icon_state = "grafcontain_r"

/obj/structure/prop/urban/containersextended/graffiti/four
	name = "defaced cargo container"
	icon_state = "grafcontain2_l"

/obj/structure/prop/urban/containersextended/graffiti/five
	name = "defaced cargo container"
	icon_state = "grafcontain2_rm"

/obj/structure/prop/urban/containersextended/graffiti/six
	name = "defaced cargo container"
	icon_state = "grafcontain2_r"

/obj/structure/prop/urban/containersextended/graffiti/seven
	name = "defaced cargo container"
	icon_state = "grafcontain3_l"

/obj/structure/prop/urban/containersextended/graffiti/eight
	name = "defaced cargo container"
	icon_state = "grafcontain3_rm"

/obj/structure/prop/urban/containersextended/graffiti/nine
	name = "defaced cargo container"
	icon_state = "grafcontain3_r"

/// Fake Platforms

/obj/structure/prop/urban/fakeplatforms
	name = "platform"

/obj/structure/prop/urban/fakeplatforms/platform1
	icon_state = "engineer_platform"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'

/obj/structure/prop/urban/fakeplatforms/platform2
	icon_state = "engineer_platform_platformcorners"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'

/obj/structure/prop/urban/fakeplatforms/platform3
	icon_state = "platform"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'

/obj/structure/prop/urban/fakeplatforms/platform4
	icon_state = "zenithplatform3"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'

// Grille

/obj/structure/prop/urban/misc/highvoltagegrille
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "highvoltagegrille"

// Greeblies
/obj/structure/prop/urban/misc/buildinggreeblies
	name = "machinery"
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "buildingventbig1"
	bound_width = 64
	bound_height = 32
	density = TRUE
	max_integrity = 200
	anchored = TRUE
	layer = 5

/obj/structure/prop/urban/misc/buildinggreeblies/greeble1
	icon_state = "buildingventbig2"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble2
	icon_state = "buildingventbig3"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble3
	icon_state = "buildingventbig4"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble4
	icon_state = "buildingventbig5"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble5
	icon_state = "buildingventbig6"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble6
	icon_state = "buildingventbig7"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble7
	icon_state = "buildingventbig8"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble8
	icon_state = "buildingventbig9"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble9
	icon_state = "buildingventbig10"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble10
	density = FALSE
	icon_state = "buildingventbig11"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble11
	density = FALSE
	icon_state = "buildingventbig12"

/obj/structure/prop/urban/misc/buildinggreeblies/greeble12
	density = FALSE
	icon_state = "buildingventbig13"

/obj/structure/prop/urban/misc/buildinggreebliessmall
	name = "wall vent"
	name = "wall vent"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "smallwallvent1"
	density = FALSE

/obj/structure/prop/urban/misc/buildinggreebliessmall2
	name = "wall vent"
	icon_state = "smallwallvent2"

/obj/structure/prop/urban/misc/buildinggreebliessmall2
	name = "wall vent"
	icon_state = "smallwallvent2"

/obj/structure/prop/urban/misc/buildinggreebliessmall3
	name = "wall vent"
	icon_state = "smallwallvent3"


/obj/structure/prop/urban/misc/buildinggreebliessmall/computer
	name = "machinery"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "zcomputermachine"
	density = TRUE

/obj/structure/prop/urban/misc/metergreen
	name = "meter"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "biggreenmeter1"


// MISC

/obj/structure/prop/urban/misc/stoneplanterseats
	name = "concrete seated planter"
	desc = "A decorative concrete planter with seating attached, the seats are fitted with synthetic leather, they've faded in time.."
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "planterseats"
	bound_width = 32
	bound_height = 64
	density = TRUE
	max_integrity = 200
	anchored = TRUE

/obj/structure/prop/urban/misc/stoneplanterseats/empty
	name = "concrete planter"
	desc = "A decorative concrete planter."
	icon_state = "planterempty"

/obj/structure/prop/urban/misc/concretestatue
	name = "concrete statue"
	desc = "A decorative statue with the Nanotrasen 'Wings' adorned on it, A corporate brutalist piece of art."
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "concretesculpture"
	bound_width = 64
	bound_height = 64
	density = TRUE
	anchored = TRUE

/obj/structure/prop/urban/misc/detonator
	name = "detonator"
	desc = "A detonator for explosives, armed and ready."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "detonator"
	density = FALSE
	anchored = TRUE
	var/id = 1
	var/range = 15

/obj/structure/prop/urban/misc/firehydrant
	name = "fire hydrant"
	desc = "A fire hydrant public water outlet, designed for quick access to water."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "firehydrant"
	density = TRUE
	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 150

/obj/structure/prop/urban/misc/phonebox
	name = "phonebox"
	desc = "A phone-box, it doesn't seem to be working, the line must be down."
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "phonebox_closed"
	layer = ABOVE_MOB_LAYER
	bound_width = 32
	bound_height = 32
	density = TRUE
	anchored = TRUE

/obj/structure/prop/urban/misc/phonebox/broken
	desc = "A phone-box, it doesn't seem to be working, the line must be down. The glass has been broken."
	icon_state = "phonebox_closed_broken"

/obj/structure/prop/urban/misc/phonebox/lightup
	desc = "A phone-box, it doesn't seem to be working, the line must be down."
	icon_state = "phonebox_closed_light"

/obj/structure/prop/urban/misc/bench
	name = "bench"
	desc = "A metal frame, with seats that are fitted with synthetic leather, they've faded in time."
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "seatedbench"
	bound_width = 32
	bound_height = 64
	layer = 4
	density = FALSE
	max_integrity = 200
	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE

// Signs

/obj/structure/prop/urban/signs
	name = "neon sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "jacksopen_on"
	bound_height = 64
	bound_width = 64
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/signs/casniosign
	name = "casino sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "nightgoldcasinoopen_on"

/obj/structure/prop/urban/signs/jackssign
	name = "jack's surplus sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "jacksopen_on"

/obj/structure/prop/urban/signs/opensign
	name = "open sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "open_on"
/obj/structure/prop/urban/signs/opensign2
	name = "open sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "open_on2"

/obj/structure/prop/urban/signs/pizzasign
	name = "pizza sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "pizzaneon_on"

/obj/structure/prop/urban/signs/weymartsign
	name = "weymart sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "weymartsign2"

/obj/structure/prop/urban/signs/mechanicsign
	name = "mechanic sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "mechanicopen_on2"

/obj/structure/prop/urban/signs/cuppajoessign
	name = "cuppa joe's sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "cuppajoes"

/obj/structure/prop/urban/signs/barsign
	name = "bar sign"
	icon = 'icons/obj/structures/prop/urban/urban64x64_signs.dmi'
	icon_state = "barsign_on"

// Small Sign
/obj/structure/prop/urban/signs/high_voltage
	name = "warning sign"
	desc = "DANGER - HIGH VOLTAGE - DEATH!."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "shockyBig"

/obj/structure/prop/urban/signs/high_voltage/small
	name = "warning sign"
	desc = "DANGER - HIGH VOLTAGE - DEATH!."
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	icon_state = "shockyTiny"

// billboards, Signs and Posters

/// Alien Isolation - posters used as reference (direct downscale of the image for some) If anyone wants to name the billboards individually ///
/obj/structure/prop/urban/billboardsandsigns/bigbillboards
	name = "billboard"
	desc = "A advertisement billboard."
	icon = 'icons/obj/structures/prop/urban/32x64_urbanbillboards.dmi'
	icon_state = "billboard_bigger"
	bound_width = 64
	bound_height = 32
	density = FALSE
	max_integrity = 200
	anchored = TRUE

/obj/structure/prop/urban/billboardsandsigns/billboardsmedium/billboard1
	name = "billboard"
	desc = "A advertisement billboard."
	icon = 'icons/obj/structures/prop/urban/32x64_urbanbillboards.dmi'
	icon_state = "billboard1"

/obj/structure/prop/urban/billboardsandsigns/billboardsmedium/billboard2
	name = "billboard"
	desc = "A advertisement billboard."
	icon = 'icons/obj/structures/prop/urban/32x64_urbanbillboards.dmi'
	icon_state = "billboard2"

/obj/structure/prop/urban/billboardsandsigns/billboardsmedium/billboard3
	name = "billboard"
	desc = "A advertisement billboard."
	icon = 'icons/obj/structures/prop/urban/32x64_urbanbillboards.dmi'
	icon_state = "billboard3"

/obj/structure/prop/urban/billboardsandsigns/billboardsmedium/billboard4
	name = "billboard"
	desc = "A advertisement billboard."
	icon = 'icons/obj/structures/prop/urban/32x64_urbanbillboards.dmi'
	icon_state = "billboard4"

// Big Road Signs
/obj/structure/prop/urban/billboardsandsigns/bigroadsigns
	name = "road sign"
	desc = "A road sign."
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "roadsign_1"
	bound_width = 64
	bound_height = 32
	density = FALSE
	max_integrity = 200
	anchored = TRUE
	layer = 8

/obj/structure/prop/urban/billboardsandsigns/bigroadsigns/road_sign_1
	icon_state = "roadsign_1"

/obj/structure/prop/urban/billboardsandsigns/bigroadsigns/road_sign_2
	icon_state = "roadsign_2"

// Car Factory

/obj/structure/prop/urban/factory
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "factory_roboticarm"

/obj/structure/prop/urban/factory/robotic_arm
	name = "Robotic arm"
	desc = "A robotic arm used in the construction of 'Meridian' Automobiles."
	icon_state = "factory_roboticarm"
	bound_width = 64
	bound_height = 32
	anchored = TRUE

/obj/structure/prop/urban/factory/robotic_arm/flipped
	icon_state = "factory_roboticarm2"

/obj/structure/prop/urban/factory/conveyor_belt
	name = "large conveyor belt"
	desc = "A large conveyor belt used in industrial factories."
	icon_state = "factory_conveyer"
	density = FALSE


// Hybrisa Lattice

/obj/structure/prop/urban/lattice_prop
	desc = "A support lattice."
	name = "lattice"
	icon = 'icons/obj/structures/prop/urban/urban_lattice.dmi'
	icon_state = "lattice1"
	density = FALSE
	layer = RIPPLE_LAYER
	max_integrity = 6000

/obj/structure/prop/urban/lattice_prop/lattice_1
	icon_state = "lattice1"

/obj/structure/prop/urban/lattice_prop/lattice_2
	icon_state = "lattice2"

/obj/structure/prop/urban/lattice_prop/lattice_3
	icon_state = "lattice3"

/obj/structure/prop/urban/lattice_prop/lattice_4
	icon_state = "lattice4"

/obj/structure/prop/urban/lattice_prop/lattice_5
	icon_state = "lattice5"

/obj/structure/prop/urban/lattice_prop/lattice_6
	icon_state = "lattice6"
