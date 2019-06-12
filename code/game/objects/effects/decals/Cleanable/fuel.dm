/obj/effect/decal/cleanable/liquid_fuel
	//Liquid fuel is used for things that used to rely on volatile fuels or phoron being contained to a couple tiles.
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	layer = ABOVE_TURF_LAYER
	anchored = TRUE
	dir = NORTHEAST //Spawns with a diagonal direction, for spread optimization.
	var/amount = 1 //Basically moles.
	var/spread_fail_chance = 75 //percent


/obj/effect/decal/cleanable/liquid_fuel/Initialize(mapload, amt = 1, logs = TRUE, newDir)
	..()
	if(logs)
		log_game("[amt] units of liquid fuel have spilled in [AREACOORD(loc.loc)].")
		message_admins("[amt] units of liquid fuel have spilled in [ADMIN_VERBOSEJMP(loc.loc)].")
	amount = amt
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
	var/spread_dirs = ISDIAGONALDIR(dir) ? CARDINAL_DIRS : list(turn(dir,90), turn(dir,-90), dir)
	if(amount < (length(spread_dirs) + 1)) //At least one unit per transfer
		return
	var/slice_per_transfer = round(1 / (length(spread_dirs) + 1), 0.01)
	var/successful_spread = 0
	var/turf/S = get_turf(src)
	for(var/D in spread_dirs)
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


/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel
	icon_state = "mustard"
	spread_fail_chance = 0 //percent