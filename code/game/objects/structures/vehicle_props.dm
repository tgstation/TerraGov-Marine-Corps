/obj/structure/prop/urban/vehicles
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "SUV"
	max_integrity = 100
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	///used to determine the probability that a car will detonate upon being destroyed
	var/explosion_probability = 1

/obj/structure/prop/urban/vehicles/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	explode(blame_mob)
	return ..()

///spawns a bunch of debris and plays a sound when a vehicle is wrecked
/obj/structure/prop/urban/vehicles/proc/explode(mob/blame_mob)
	src.visible_message(span_danger("<B>[src] blows apart!</B>"), null, null, 1)
	if(prob(explosion_probability))
		explosion(loc, light_impact_range = 3, flame_range = 2, explosion_cause=blame_mob)
	playsound(loc, 'sound/effects/car_crush.ogg', 25)
	var/turf/Tsec = get_turf(src)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/sheet/metal(Tsec)
	new /obj/item/stack/sheet/metal(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)

	new /obj/effect/spawner/gibspawner/robot(Tsec)
	new /obj/effect/decal/cleanable/blood/oil(src.loc)

// Meridian Cars - Damage States
/obj/structure/prop/urban/vehicles/meridian
	name = "\improper Mono-Spectra"
	desc = "The 'Mono-Spectra', a mass-produced civilian vehicle for extraterrestrial markets, in and outside of Terra controlled space. Produced by 'Meridian' a car marque and associated operating division of the Nanotrasen Corporation."
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_red.dmi'
	icon_state = "meridian_red"
	bound_height = 32
	bound_width = 64
	layer = ABOVE_MOB_LAYER
	resistance_flags = XENO_DAMAGEABLE
	coverage = 40
	base_icon_state = "meridian_red"
	max_integrity = 60
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	soft_armor = list(MELEE = 10, BULLET = 75, LASER = 45, ENERGY = 45, BOMB = 20, BIO = 10, FIRE = 10, ACID = 10)

/obj/structure/prop/urban/vehicles/meridian/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/prop/urban/vehicles/meridian/update_icon_state()
	switch(obj_integrity)
		if(50 to 60)
			icon_state = initial(icon_state)
		if(40 to 50)
			icon_state = "[base_icon_state]_damage_[1]"
		if(30 to 40)
			icon_state = "[base_icon_state]_damage_[2]"
		if(20 to 30)
			icon_state = "[base_icon_state]_damage_[3]"
		if(10 to 20)
			icon_state = "[base_icon_state]_damage_[4]"
		if(0 to 10)
			icon_state = "[base_icon_state]_damage_[5]"

/obj/structure/prop/urban/vehicles/meridian/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	if(!.)
		return
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/prop/urban/vehicles/meridian/red
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_red.dmi'
	icon_state = "meridian_red"
	base_icon_state = "meridian_red"

/obj/structure/prop/urban/vehicles/meridian/red/damageone
	icon_state = "meridian_red_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/red/damagetwo
	icon_state = "meridian_red_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/red/damagethree
	icon_state = "meridian_red_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/red/damagefour
	icon_state = "meridian_red_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/red/damagefive
	icon_state = "meridian_red_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/black
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_black.dmi'
	icon_state = "meridian_black"
	base_icon_state = "meridian_black"

/obj/structure/prop/urban/vehicles/meridian/black/damageone
	icon_state = "meridian_black_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/black/damagetwo
	icon_state = "meridian_black_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/black/damagethree
	icon_state = "meridian_black_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/black/damagefour
	icon_state = "meridian_black_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/black/damagefive
	icon_state = "meridian_black_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/blue
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_blue.dmi'
	icon_state = "meridian_blue"
	base_icon_state = "meridian_blue"

/obj/structure/prop/urban/vehicles/meridian/blue/damageone
	icon_state = "meridian_blue_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/blue/damagetwo
	icon_state = "meridian_blue_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/blue/damagethree
	icon_state = "meridian_blue_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/blue/damagefour
	icon_state = "meridian_blue_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/blue/damagefive
	icon_state = "meridian_blue_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/brown
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_brown.dmi'
	icon_state = "meridian_brown"
	base_icon_state = "meridian_brown"

/obj/structure/prop/urban/vehicles/meridian/brown/damageone
	icon_state = "meridian_brown_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/brown/damagetwo
	icon_state = "meridian_brown_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/brown/damagethree
	icon_state = "meridian_brown_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/brown/damagefour
	icon_state = "meridian_brown_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/brown/damagefive
	icon_state = "meridian_brown_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/cop
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_cop.dmi'
	icon_state = "meridian_cop"
	base_icon_state = "meridian_cop"

/obj/structure/prop/urban/vehicles/meridian/cop/damageone
	icon_state = "meridian_cop_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/cop/damagetwo
	icon_state = "meridian_cop_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/cop/damagethree
	icon_state = "meridian_cop_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/cop/damagefour
	icon_state = "meridian_cop_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/cop/damagefive
	icon_state = "meridian_cop_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/desat_blue
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_desatblue.dmi'
	icon_state = "meridian_desatblue"
	base_icon_state = "meridian_desatblue"

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damageone
	icon_state = "meridian_desatblue_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damagetwo
	icon_state = "meridian_desatblue_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damagethree
	icon_state = "meridian_desatblue_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damagefour
	icon_state = "meridian_desatblue_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/desat_blue/damagefive
	icon_state = "meridian_desatblue_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/green
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_green.dmi'
	icon_state = "meridian_green"
	base_icon_state = "meridian_green"

/obj/structure/prop/urban/vehicles/meridian/green/damageone
	icon_state = "meridian_green_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/green/damagetwo
	icon_state = "meridian_green_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/green/damagethree
	icon_state = "meridian_green_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/green/damagefour
	icon_state = "meridian_green_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/green/damagefive
	icon_state = "meridian_green_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/light_blue
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_lightblue.dmi'
	icon_state = "meridian_lightblue"
	base_icon_state = "meridian_lightblue"

/obj/structure/prop/urban/vehicles/meridian/light_blue/damageone
	icon_state = "meridian_lightblue_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/light_blue/damagetwo
	icon_state = "meridian_lightblue_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/light_blue/damagethree
	icon_state = "meridian_lightblue_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/light_blue/damagefour
	icon_state = "meridian_lightblue_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/light_blue/damagefive
	icon_state = "meridian_lightblue_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/pink
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_pink.dmi'
	icon_state = "meridian_pink"
	base_icon_state = "meridian_pink"

/obj/structure/prop/urban/vehicles/meridian/pink/damageone
	icon_state = "meridian_pink_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/pink/damagetwo
	icon_state = "meridian_pink_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/pink/damagethree
	icon_state = "meridian_pink_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/pink/damagefour
	icon_state = "meridian_pink_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/pink/damagefive
	icon_state = "meridian_pink_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/purple
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_purple.dmi'
	icon_state = "meridian_purple"
	base_icon_state = "meridian_purple"

/obj/structure/prop/urban/vehicles/meridian/purple/damageone
	icon_state = "meridian_purple_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/purple/damagetwo
	icon_state = "meridian_purple_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/purple/damagethree
	icon_state = "meridian_purple_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/purple/damagefour
	icon_state = "meridian_purple_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/purple/damagefive
	icon_state = "meridian_purple_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/turquoise
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_turquoise.dmi'
	icon_state = "meridian_turquoise"
	base_icon_state = "meridian_turquoise"

/obj/structure/prop/urban/vehicles/meridian/turquoise/damageone
	icon_state = "meridian_turquoise_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/turquoise/damagetwo
	icon_state = "meridian_turquoise_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/turquoise/damagethree
	icon_state = "meridian_turquoise_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/turquoise/damagefour
	icon_state = "meridian_turquoise_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/turquoise/damagefive
	icon_state = "meridian_turquoise_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/orange
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_orange.dmi'
	icon_state = "meridian_orange"
	base_icon_state = "meridian_orange"

/obj/structure/prop/urban/vehicles/meridian/orange/damageone
	icon_state = "meridian_orange_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/orange/damagetwo
	icon_state = "meridian_orange_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/orange/damagethree
	icon_state = "meridian_orange_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/orange/damagefour
	icon_state = "meridian_orange_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/orange/damagefive
	icon_state = "meridian_orange_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/generic
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_wy.dmi'
	icon_state = "meridian_wy"
	base_icon_state = "meridian_wy"

/obj/structure/prop/urban/vehicles/meridian/generic/damageone
	icon_state = "meridian_wy_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/generic/damagetwo
	icon_state = "meridian_wy_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/generic/damagethree
	icon_state = "meridian_wy_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/generic/damagefour
	icon_state = "meridian_wy_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/generic/damagefive
	icon_state = "meridian_wy_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/taxi
	icon = 'icons/obj/structures/prop/urban_vehicles/meridian_taxi.dmi'
	icon_state = "meridian_taxi"
	base_icon_state = "meridian_taxi"

/obj/structure/prop/urban/vehicles/meridian/taxi/damageone
	icon_state = "meridian_taxi_damage_1"
	max_integrity = 50

/obj/structure/prop/urban/vehicles/meridian/taxi/damagetwo
	icon_state = "meridian_taxi_damage_2"
	max_integrity = 40

/obj/structure/prop/urban/vehicles/meridian/taxi/damagethree
	icon_state = "meridian_taxi_damage_3"
	max_integrity = 30

/obj/structure/prop/urban/vehicles/meridian/taxi/damagefour
	icon_state = "meridian_taxi_damage_4"
	max_integrity = 20

/obj/structure/prop/urban/vehicles/meridian/taxi/damagefive
	icon_state = "meridian_taxi_damage_5"
	max_integrity = 10

/obj/structure/prop/urban/vehicles/meridian/marshalls
	name = "colonial marshalls rapid response SUV"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "marshalls2"

/obj/structure/prop/urban/vehicles/meridian/marshalls/update_icon_state()
	icon_state = initial(icon_state)

// Car Chassis
/obj/structure/prop/urban/vehicles/meridian/chassis
	name = "\improper Mono-Spectra Chassis"
	desc = "A Mono-Spectra chassis in the early stages of assembly."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "MeridianCar_shell"

/obj/structure/prop/urban/vehicles/meridian/chassis/update_icon_state()
	icon_state = initial(icon_state)
