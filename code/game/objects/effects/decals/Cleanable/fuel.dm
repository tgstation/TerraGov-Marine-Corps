/obj/effect/decal/cleanable/liquid_fuel
	name = "fuel puddle"
	//Liquid fuel is used for things that used to rely on volatile fuels or phoron being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	layer = ABOVE_TURF_LAYER
	anchored = TRUE
	dir = NORTHEAST //Spawns with a diagonal direction, for spread optimization.
	var/amount = 1 //Basically moles.
	var/spread_fail_chance = 75 //percent
	///Used for the fire_lvl of the resulting fire
	var/fire_lvl
	///Used for the burn_lvl of the resulting fire
	var/burn_lvl
	var/f_color = "red"


/obj/effect/decal/cleanable/liquid_fuel/Initialize(mapload, amt = 1, logs = TRUE, newDir)
	. = ..()
	amount = amt
	burn_lvl = rand(0, 25)
	fire_lvl = rand(5,30)
	if(newDir)
		setDir(newDir)
	return INITIALIZE_HINT_LATELOAD


/obj/effect/decal/cleanable/liquid_fuel/LateInitialize()
	. = ..()
	for(var/obj/effect/decal/cleanable/liquid_fuel/other in loc)
		if(other == src || other.type != type)
			continue
		amount += other.amount
		qdel(other)
	fuel_spread()


/obj/effect/decal/cleanable/liquid_fuel/proc/fuel_spread()
	//Allows liquid fuels to sometimes flow into other tiles.
	if(amount < 5) //At least one unit per transfer
		return
	var/slice_per_transfer = round((1 / 5), 0.01)
	var/successful_spread = 0
	var/turf/S = get_turf(src)
	for(var/D in CARDINAL_DIRS)
		if(prob(spread_fail_chance))
			continue
		var/turf/T = get_step(S, D)
		if(!S.CanPass(src, T) || !T.CanPass(src, S))
			continue
		var/other_found = FALSE
		var/obj/effect/decal/cleanable/liquid_fuel/valid_target
		for(var/obj/effect/decal/cleanable/liquid_fuel/other in T)
			if(other.type != type)
				continue
			if(other.amount > amount * slice_per_transfer) //Only large transfers to avoid infinite loops.
				other_found = TRUE
				break
			other_found = TRUE
			valid_target = other
			break
		if(other_found)
			if(valid_target)
				valid_target.amount += amount * slice_per_transfer
				valid_target.fuel_spread()
			else
				continue //Failed spread.
		else //If there's no fuel in the target tile, make some.
			new type(T, amount * slice_per_transfer, FALSE, D)
		successful_spread++
	amount *= max(0, 1 - (successful_spread * slice_per_transfer))

/obj/effect/decal/cleanable/liquid_fuel/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/tool/lighter))
		ignite_fuel()
		user.visible_message("<span class='notice'>[user] ignites \the [src]</span>", "<span class='notice'>You ignite some fuel on [src]</span>")
		log_attack("[key_name(user)] ignites [src] in fuel in [AREACOORD(user)]")

/obj/effect/decal/cleanable/liquid_fuel/flamer_fire_act()
	. = ..()
	ignite_fuel()

/obj/effect/decal/cleanable/liquid_fuel/proc/ignite_fuel()
	new /obj/flamer_fire(loc, fire_lvl, burn_lvl, f_color)
	var/turf/S = get_turf(src)
	for(var/D in CARDINAL_DIRS)
		var/turf/T = get_step(S, D)
		for(var/obj/effect/decal/cleanable/liquid_fuel/other in T)
			INVOKE_NEXT_TICK(other, .proc/ignite_fuel)	//Spread effect
	qdel(src)

/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel
	icon_state = "mustard"
	spread_fail_chance = 0 //percent
